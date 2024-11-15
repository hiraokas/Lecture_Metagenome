#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241114
#  History:  20241114
#  - ref: https://bitbucket.org/berkeleylab/metabat/src/master/
#============================================================================================================

# 解析環境構築
conda activate assembler
conda install metabat2=2.17    -c bioconda  # デフォルトでは古いバージョンのmetabat2がインストールされるため、明示的にバージョンを指定する
conda install gtdbtk=2.4       -c bioconda  # 同様にGTDB-tkも明示的にバージョンを指定する
conda install samtools bowtie2 -c bioconda

# ディレクトリ作成
mkdir bin/

# Bowtie2を用いてリードをコンティグにマッピングする 
bowtie2-build assembly/DRR267104_spades/contigs.fasta assembly/DRR267104_spades/contigs.fasta --threads 4
bowtie2 --time -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267104.sra_1_val_1.fq.gz -2 QC/DRR267104.sra_2_val_2.fq.gz --threads 4 -q -S bin/map_DRR267104contig_DRR267104read.sam
bowtie2 --time -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267106.sra_1_val_1.fq.gz -2 QC/DRR267106.sra_2_val_2.fq.gz --threads 4 -q -S bin/map_DRR267104contig_DRR267106read.sam
bowtie2 --time -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267108.sra_1_val_1.fq.gz -2 QC/DRR267108.sra_2_val_2.fq.gz --threads 4 -q -S bin/map_DRR267104contig_DRR267108read.sam
bowtie2 --time -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267110.sra_1_val_1.fq.gz -2 QC/DRR267110.sra_2_val_2.fq.gz --threads 4 -q -S bin/map_DRR267104contig_DRR267110read.sam

# SAMファイルをBAMファイルへ変換する
samtools view -Sb bin/map_DRR267104contig_DRR267104read.sam -o bin/map_DRR267104contig_DRR267104read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267106read.sam -o bin/map_DRR267104contig_DRR267106read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267108read.sam -o bin/map_DRR267104contig_DRR267108read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267110read.sam -o bin/map_DRR267104contig_DRR267110read.bam -@ 4

# BAMファイルをソートする
samtools sort -@ 4 -o bin/map_DRR267104contig_DRR267104read.sorted.bam bin/map_DRR267104contig_DRR267104read.bam
samtools sort -@ 4 -o bin/map_DRR267104contig_DRR267106read.sorted.bam bin/map_DRR267104contig_DRR267106read.bam
samtools sort -@ 4 -o bin/map_DRR267104contig_DRR267108read.sorted.bam bin/map_DRR267104contig_DRR267108read.bam
samtools sort -@ 4 -o bin/map_DRR267104contig_DRR267110read.sorted.bam bin/map_DRR267104contig_DRR267110read.bam

# 各コンティグのデプスを計算する
jgi_summarize_bam_contig_depths --outputDepth bin/depth.txt bin/map_*.sorted.bam

# MetaBAT2の実行
metabat2 -i assembly/DRR267104_spades/contigs.fasta -a bin/depth.txt -o bin/DRR267104.bin -t 4

# CheckM2の環境構築
# 筆者の経験上、CheckM2のインストールはトラブルが起きやすい。ここでは公式ページから取得したファイルを利用して、専用のconda環境を構築する
wget https://github.com/chklovski/CheckM2/archive/refs/tags/1.0.2.tar.gz  #should download latest version
tar -xvf 1.0.2.tar.gz
conda deactivate 
conda env create -n checkm2 -f CheckM2-1.0.2/checkm2.yml 
conda activate checkm2

# checkM2のデータベースをダウンロードする
checkm2 database --download --path db/

# CheckM2を実行する、最終的な結果はcheckm2/quality_report.tsv
checkm2 predict --threads 4 --input bin/*.fa --output-directory checkm2

# GTDBtkの環境構築
# GTDBtkはpythonバージョンが高すぎるとエラーが出るため、環境をmetagenomeに戻してインストールをする
# GTDB-tkを動かす際に要求されるので、tqdmも一緒にインストールする
conda deactivate 
conda activate metagenome
conda install gtdbtk=2.4 tqdm -c bioconda

# GDTB-tkのデータベースを準備する。全部で110GBほどのサイズがある。
# download-db.sh でもできるが、ここではマニュアルで準備してみる。ダウンロードは数時間かかる
wget https://data.gtdb.ecogenomic.org/releases/release220/220.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r220_data.tar.gz -P db/
tar -xvzf db/gtdbtk_r220_data.tar.gz -C db/
gtdbtk check_install

# GDTB-tk用の解析フォルダを作成
mkdir gtdbtk gtdbtk/tmp/ -p

# GTDB-tkの実行
# メモリ使用量を減らすために--scratch_dirを追加した
export GTDBTK_DATA_PATH=`pwd`/db/release220
gtdbtk classify_wf --genome_dir bin/ --out_dir gtdbtk/ --cpus 4 --extension .fa --mash_db gtdbtk/ --tmpdir gtdbtk/tmp/ --scratch_dir gtdbtk/scratch/ 

