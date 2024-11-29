#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241129
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

# minicondaのインストール
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# 解析環境構築
conda create --name env_metagenome seqkit sra-tools trim-galore bowtie2 ncbi-acc-download prinseq-plus-plus fastqc flash2 --channel bioconda
conda activate env_metagenome

# ディレクトリ作成
mkdir data QC

# シーケンスデータのダウンロード（すこし時間がかかる）
prefetch DRR267104 --output-directory data/  # Illumina
prefetch DRR267106 --output-directory data/  # Illumina
prefetch DRR267108 --output-directory data/  # Illumina
prefetch DRR267110 --output-directory data/  # Illumina
prefetch DRR267102 --output-directory data/  # PacBio
prefetch DRR267105 --output-directory data/  # PacBio
prefetch DRR267107 --output-directory data/  # PacBio
prefetch DRR267109 --output-directory data/  # PacBio
ncbi-acc-download -F fasta NC_001422.1  #PhiX

# sra形式をfastq形式に変換する
fasterq-dump data/*/*.sra --outdir data/ --split-files --progress --threads 4

# アダプター除去
trim_galore --paired data/DRR267104.sra_1.fastq data/DRR267104.sra_2.fastq --output_dir QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267106.sra_1.fastq data/DRR267106.sra_2.fastq --output_dir QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267108.sra_1.fastq data/DRR267108.sra_2.fastq --output_dir QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267110.sra_1.fastq data/DRR267110.sra_2.fastq --output_dir QC/ --quality 20 --cores 4 --gzip

# PhiX除去
# 最初に、PhiX配列ファイルに対してbowtie2のインデックスファイルを作成する
# 次に、メタゲノム配列をPhiXにマッピングし、マップされなかった配列を回収する
bowtie2-build data/NC_001422.1.fa data/NC_001422.1.fa 
bowtie2 -x data/NC_001422.1.fa -1 QC/DRR267104.sra_1_val_1.fq.gz -2 QC/DRR267104.sra_2_val_2.fq.gz -q --un-conc-gz QC/DRR267104_removePhiX_%.fastq.gz --threads 4 -S /dev/null --time
bowtie2 -x data/NC_001422.1.fa -1 QC/DRR267106.sra_1_val_1.fq.gz -2 QC/DRR267106.sra_2_val_2.fq.gz -q --un-conc-gz QC/DRR267106_removePhiX_%.fastq.gz --threads 4 -S /dev/null --time
bowtie2 -x data/NC_001422.1.fa -1 QC/DRR267108.sra_1_val_1.fq.gz -2 QC/DRR267108.sra_2_val_2.fq.gz -q --un-conc-gz QC/DRR267108_removePhiX_%.fastq.gz --threads 4 -S /dev/null --time
bowtie2 -x data/NC_001422.1.fa -1 QC/DRR267110.sra_1_val_1.fq.gz -2 QC/DRR267110.sra_2_val_2.fq.gz -q --un-conc-gz QC/DRR267110_removePhiX_%.fastq.gz --threads 4 -S /dev/null --time

# 低複雑度領域除去
# 同時に配列長100bp以下の短断片も除去
prinseq++ -fastq QC/DRR267104_removePhiX_1.fastq.gz -fastq2 QC/DRR267104_removePhiX_2.fastq.gz -min_len 100 -out_good QC/DRR267104_removeLowComp_1.fastq -out_good2 QC/DRR267104_removeLowComp_2.fastq -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null -threads 4
prinseq++ -fastq QC/DRR267106_removePhiX_1.fastq.gz -fastq2 QC/DRR267106_removePhiX_2.fastq.gz -min_len 100 -out_good QC/DRR267106_removeLowComp_1.fastq -out_good2 QC/DRR267106_removeLowComp_2.fastq -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null -threads 4
prinseq++ -fastq QC/DRR267108_removePhiX_1.fastq.gz -fastq2 QC/DRR267108_removePhiX_2.fastq.gz -min_len 100 -out_good QC/DRR267108_removeLowComp_1.fastq -out_good2 QC/DRR267108_removeLowComp_2.fastq -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null -threads 4
prinseq++ -fastq QC/DRR267110_removePhiX_1.fastq.gz -fastq2 QC/DRR267110_removePhiX_2.fastq.gz -min_len 100 -out_good QC/DRR267110_removeLowComp_1.fastq -out_good2 QC/DRR267110_removeLowComp_2.fastq -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null -threads 4

# ファイル名を変更（QCペアエンド）
mv QC/DRR267104_removeLowComp_1.fastq QC/DRR267104_QC_1.fastq
mv QC/DRR267104_removeLowComp_2.fastq QC/DRR267104_QC_2.fastq
mv QC/DRR267106_removeLowComp_1.fastq QC/DRR267106_QC_1.fastq
mv QC/DRR267106_removeLowComp_2.fastq QC/DRR267106_QC_2.fastq
mv QC/DRR267108_removeLowComp_1.fastq QC/DRR267108_QC_1.fastq
mv QC/DRR267108_removeLowComp_2.fastq QC/DRR267108_QC_2.fastq
mv QC/DRR267110_removeLowComp_1.fastq QC/DRR267110_QC_1.fastq
mv QC/DRR267110_removeLowComp_2.fastq QC/DRR267110_QC_2.fastq

# ペアエンドリードのマージ（QCマージ）
flash2 QC/DRR267104_QC_1.fastq QC/DRR267104_QC_2.fastq --output-directory QC/ --output-prefix DRR267104_merge --threads 4
flash2 QC/DRR267106_QC_1.fastq QC/DRR267106_QC_2.fastq --output-directory QC/ --output-prefix DRR267106_merge --threads 4
flash2 QC/DRR267108_QC_1.fastq QC/DRR267108_QC_2.fastq --output-directory QC/ --output-prefix DRR267108_merge --threads 4
flash2 QC/DRR267110_QC_1.fastq QC/DRR267110_QC_2.fastq --output-directory QC/ --output-prefix DRR267110_merge --threads 4

# リード数等の基礎統計の確認
seqkit stat data/*.sra_*.fastq         # 生リード
seqkit stat QC/*_QC_*.fastq            # QCペアエンド
seqkit stat QC/*_.extendedFrags.fastq  # QCマージ

# DRR267104についてのみ表示
seqkit stat data/DRR267104.sra_*.fastq              # 生リード
seqkit stat QC/DRR267104_QC_*.fastq                 # QCペアエンド
seqkit stat QC/DRR267104_merge.extendedFrags.fastq  # QCマージ

# FastQCによるレポート出力（QC前後）
fastqc data/*.sra_*.fastq             --outdir data/ # 生リード
fastqc QC/*_QC_*.fastq                --outdir QC/   # QCペアエンド
fastqc QC/*_merge.extendedFrags.fastq --outdir QC/   # QCマージ

