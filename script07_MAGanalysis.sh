#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241114
#  History:  20241117
#  - ref: https://bitbucket.org/berkeleylab/metabat/src/master/
#============================================================================================================

# 解析環境構築
conda activate env_assembly
conda install metabat2=2.17    -c bioconda  # デフォルトでは古いバージョンのmetabat2がインストールされるため、明示的にバージョンを指定する
conda install samtools bowtie2 -c bioconda

# ディレクトリ作成
mkdir bin/

# Bowtie2を用いてショートリードをコンティグにマッピングする (DRR267104;Illuminaコンティグ)
bowtie2-build assembly/DRR267104_spades/contigs.fasta assembly/DRR267104_spades/contigs.fasta --threads 4
bowtie2 -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267104_QC_1.fastq -2 QC/DRR267104_QC_2.fastq -q -S bin/map_DRR267104contig_DRR267104read.sam --threads 4 
bowtie2 -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267106_QC_1.fastq -2 QC/DRR267106_QC_2.fastq -q -S bin/map_DRR267104contig_DRR267106read.sam --threads 4
bowtie2 -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267108_QC_1.fastq -2 QC/DRR267108_QC_2.fastq -q -S bin/map_DRR267104contig_DRR267108read.sam --threads 4
bowtie2 -x assembly/DRR267104_spades/contigs.fasta -1 QC/DRR267110_QC_1.fastq -2 QC/DRR267110_QC_2.fastq -q -S bin/map_DRR267104contig_DRR267110read.sam --threads 4

# Bowtie2を用いてショートリードをコンティグにマッピングする (DRR267102;PacBioコンティグ)
bowtie2-build assembly/DRR267102_hifiasm_meta.p_ctg.fasta assembly/DRR267102_hifiasm_meta.p_ctg.fasta --threads 4
bowtie2 -x assembly/DRR267102_hifiasm_meta.p_ctg.fasta -1 QC/DRR267104_QC_1.fastq -2 QC/DRR267104_QC_2.fastq -q -S bin/map_DRR267102contig_DRR267104read.sam --threads 4 
bowtie2 -x assembly/DRR267102_hifiasm_meta.p_ctg.fasta -1 QC/DRR267106_QC_1.fastq -2 QC/DRR267106_QC_2.fastq -q -S bin/map_DRR267102contig_DRR267106read.sam --threads 4
bowtie2 -x assembly/DRR267102_hifiasm_meta.p_ctg.fasta -1 QC/DRR267108_QC_1.fastq -2 QC/DRR267108_QC_2.fastq -q -S bin/map_DRR267102contig_DRR267108read.sam --threads 4
bowtie2 -x assembly/DRR267102_hifiasm_meta.p_ctg.fasta -1 QC/DRR267110_QC_1.fastq -2 QC/DRR267110_QC_2.fastq -q -S bin/map_DRR267102contig_DRR267110read.sam --threads 4

# SAMファイルをBAMファイルへ変換する
samtools view -Sb bin/map_DRR267104contig_DRR267104read.sam -o bin/map_DRR267104contig_DRR267104read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267106read.sam -o bin/map_DRR267104contig_DRR267106read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267108read.sam -o bin/map_DRR267104contig_DRR267108read.bam -@ 4
samtools view -Sb bin/map_DRR267104contig_DRR267110read.sam -o bin/map_DRR267104contig_DRR267110read.bam -@ 4
samtools view -Sb bin/map_DRR267102contig_DRR267104read.sam -o bin/map_DRR267102contig_DRR267104read.bam -@ 4
samtools view -Sb bin/map_DRR267102contig_DRR267106read.sam -o bin/map_DRR267102contig_DRR267106read.bam -@ 4
samtools view -Sb bin/map_DRR267102contig_DRR267108read.sam -o bin/map_DRR267102contig_DRR267108read.bam -@ 4
samtools view -Sb bin/map_DRR267102contig_DRR267110read.sam -o bin/map_DRR267102contig_DRR267110read.bam -@ 4

# BAMファイルをソートする
samtools sort -o bin/map_DRR267104contig_DRR267104read.sorted.bam bin/map_DRR267104contig_DRR267104read.bam -@ 4
samtools sort -o bin/map_DRR267104contig_DRR267106read.sorted.bam bin/map_DRR267104contig_DRR267106read.bam -@ 4
samtools sort -o bin/map_DRR267104contig_DRR267108read.sorted.bam bin/map_DRR267104contig_DRR267108read.bam -@ 4
samtools sort -o bin/map_DRR267104contig_DRR267110read.sorted.bam bin/map_DRR267104contig_DRR267110read.bam -@ 4
samtools sort -o bin/map_DRR267102contig_DRR267104read.sorted.bam bin/map_DRR267102contig_DRR267104read.bam -@ 4
samtools sort -o bin/map_DRR267102contig_DRR267106read.sorted.bam bin/map_DRR267102contig_DRR267106read.bam -@ 4
samtools sort -o bin/map_DRR267102contig_DRR267108read.sorted.bam bin/map_DRR267102contig_DRR267108read.bam -@ 4
samtools sort -o bin/map_DRR267102contig_DRR267110read.sorted.bam bin/map_DRR267102contig_DRR267110read.bam -@ 4

# 各コンティグのデプスを計算する
jgi_summarize_bam_contig_depths --outputDepth bin/depth_DRR267104.txt bin/map_DRR267104*.sorted.bam
jgi_summarize_bam_contig_depths --outputDepth bin/depth_DRR267102.txt bin/map_DRR267102*.sorted.bam

# MetaBAT2の実行
metabat2 -i assembly/DRR267104_spades/contigs.fasta     -a bin/depth_DRR267104.txt -o bin/DRR267104/DRR267104.bin -t 4
metabat2 -i assembly/DRR267102_hifiasm_meta.p_ctg.fasta -a bin/depth_DRR267102.txt -o bin/DRR267102/DRR267102.bin -t 4

# CheckM2の環境構築
# 筆者の経験上、CheckM2のインストールはトラブルが起きやすい。ここでは公式ページから取得したファイルを利用して、専用のconda環境を構築する
wget https://github.com/chklovski/CheckM2/archive/refs/tags/1.0.2.tar.gz
tar -xvf 1.0.2.tar.gz
conda deactivate 
conda env create -n env_checkm2 -f CheckM2-1.0.2/checkm2.yml 
conda activate env_checkm2
conda install checkm2 -c bioconda

# CheckM2のデータベースをダウンロードする
checkm2 database --download --path db/

# CheckM2を実行する、最終的な結果はcheckm2/quality_report.tsv
checkm2 predict --input bin/DRR267104/DRR267104.bin.*.fa --output-directory checkm2/DRR267104/ --threads 4 
checkm2 predict --input bin/DRR267102/DRR267102.bin.*.fa --output-directory checkm2/DRR267102/ --threads 4 

# GTDBtkの環境構築
# GTDB-tk用のconda環境を構築した
# GTDB-tkを動かす際に要求されるので、tqdmも一緒にインストールする
conda deactivate
conda create -n env_gtdbtk gtdbtk=2.4 tqdm -c bioconda -c conda-forge
conda activate env_gtdbtk

# GDTB-tk用の解析フォルダを作成
mkdir gtdbtk gtdbtk/tmp/ -p

# GDTB-tkのデータベースを準備する。全部で110GBほどのサイズがある。
# download-db.sh でもできるが、ここではマニュアルで準備してみる。ダウンロードは数時間かかる
wget https://data.gtdb.ecogenomic.org/releases/release220/220.0/auxillary_files/gtdbtk_package/full_package/gtdbtk_r220_data.tar.gz -P db/
tar -xvzf db/gtdbtk_r220_data.tar.gz -C db/

# 環境変数の設定
export GTDBTK_DATA_PATH=`pwd`/db/release220

# GTDB-tkの実行
# メモリ使用量を減らすために--scratch_dirを追加した
gtdbtk classify_wf --genome_dir bin/DRR267104/ --extension .fa --out_dir gtdbtk/DRR267104/ --mash_db gtdbtk/DRR267104/ --tmpdir gtdbtk/tmp/ --scratch_dir gtdbtk/DRR267104/scratch/ --cpus 4
gtdbtk classify_wf --genome_dir bin/DRR267102/ --extension .fa --out_dir gtdbtk/DRR267102/ --mash_db gtdbtk/DRR267102/ --tmpdir gtdbtk/tmp/ --scratch_dir gtdbtk/DRR267102/scratch/ --cpus 4

