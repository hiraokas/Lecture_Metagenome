#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241129
#  - ref: https://bioinformatics-centre.github.io/kaiju/
#============================================================================================================

# 解析環境構築
conda activate env_metagenome
conda install prodigal eggnog-mapper --channel bioconda

# ディレクトリ作成
mkdir gene annotation

# fastqファイルをfastaファイルへ変換する
seqkit fq2fa QC/DRR267104_merge.extendedFrags.fastq --out-file QC/DRR267104_merge.fasta --threads 4 # Illumina
seqkit fq2fa QC/DRR267106_merge.extendedFrags.fastq --out-file QC/DRR267106_merge.fasta --threads 4 # Illumina
seqkit fq2fa QC/DRR267108_merge.extendedFrags.fastq --out-file QC/DRR267108_merge.fasta --threads 4 # Illumina
seqkit fq2fa QC/DRR267110_merge.extendedFrags.fastq --out-file QC/DRR267110_merge.fasta --threads 4 # Illumina
seqkit fq2fa data/DRR267102.sra.fastq               --out-file data/DRR267102.fasta     --threads 4 # PacBio
seqkit fq2fa data/DRR267105.sra.fastq               --out-file data/DRR267105.fasta     --threads 4 # PacBio
seqkit fq2fa data/DRR267107.sra.fastq               --out-file data/DRR267107.fasta     --threads 4 # PacBio
seqkit fq2fa data/DRR267109.sra.fastq               --out-file data/DRR267109.fasta     --threads 4 # PacBio

# CDS予測
# prodigalは並列処理が実装されておらず、シングルスレッドでの動作になるため、処理に時間がかかる
prodigal -i QC/DRR267104_merge.fasta -o gene/DRR267104.coords.gbk -a gene/DRR267104.prot.faa -d gene/DRR267104.nucl.fna -p meta -q
prodigal -i QC/DRR267106_merge.fasta -o gene/DRR267106.coords.gbk -a gene/DRR267106.prot.faa -d gene/DRR267106.nucl.fna -p meta -q
prodigal -i QC/DRR267108_merge.fasta -o gene/DRR267108.coords.gbk -a gene/DRR267108.prot.faa -d gene/DRR267108.nucl.fna -p meta -q
prodigal -i QC/DRR267110_merge.fasta -o gene/DRR267110.coords.gbk -a gene/DRR267110.prot.faa -d gene/DRR267110.nucl.fna -p meta -q
prodigal -i data/DRR267102.fasta     -o gene/DRR267102.coords.gbk -a gene/DRR267102.prot.faa -d gene/DRR267102.nucl.fna -p meta -q
prodigal -i data/DRR267105.fasta     -o gene/DRR267105.coords.gbk -a gene/DRR267105.prot.faa -d gene/DRR267105.nucl.fna -p meta -q
prodigal -i data/DRR267107.fasta     -o gene/DRR267107.coords.gbk -a gene/DRR267107.prot.faa -d gene/DRR267107.nucl.fna -p meta -q
prodigal -i data/DRR267109.fasta     -o gene/DRR267109.coords.gbk -a gene/DRR267109.prot.faa -d gene/DRR267109.nucl.fna -p meta -q

# データベースの準備
download_eggnog_data.py --data_dir db/ -y

# eggNOG_mapperの実行(非常に時間がかかる)
emapper.py -i gene/DRR267104.prot.faa --output_dir annotation/ --output DRR267104_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267106.prot.faa --output_dir annotation/ --output DRR267106_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267108.prot.faa --output_dir annotation/ --output DRR267108_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267110.prot.faa --output_dir annotation/ --output DRR267110_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267102.prot.faa --output_dir annotation/ --output DRR267102_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267105.prot.faa --output_dir annotation/ --output DRR267105_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267107.prot.faa --output_dir annotation/ --output DRR267107_eggnog --data_dir db/ --cpu 4
emapper.py -i gene/DRR267109.prot.faa --output_dir annotation/ --output DRR267109_eggnog --data_dir db/ --cpu 4

#カテゴリ集計
cat annotation/DRR267104_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267104\t"$2"\t"$1}' > annotation/DRR267104_eggnog.category.tsv
cat annotation/DRR267106_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267106\t"$2"\t"$1}' > annotation/DRR267106_eggnog.category.tsv
cat annotation/DRR267108_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267108\t"$2"\t"$1}' > annotation/DRR267108_eggnog.category.tsv
cat annotation/DRR267110_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267110\t"$2"\t"$1}' > annotation/DRR267110_eggnog.category.tsv
cat annotation/DRR267102_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267102\t"$2"\t"$1}' > annotation/DRR267102_eggnog.category.tsv
cat annotation/DRR267105_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267105\t"$2"\t"$1}' > annotation/DRR267105_eggnog.category.tsv
cat annotation/DRR267107_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267107\t"$2"\t"$1}' > annotation/DRR267107_eggnog.category.tsv
cat annotation/DRR267109_eggnog.emapper.annotations | grep -v "^#" | cut -f7 | fold -w 1 | sort | uniq -c | awk '{print "DRR267109\t"$2"\t"$1}' > annotation/DRR267109_eggnog.category.tsv
