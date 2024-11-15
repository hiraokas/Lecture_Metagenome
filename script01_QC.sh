#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241109
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

# minicondaインストール
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

# 解析環境構築
conda create -n metagenome
conda activate metagenome
conda install seqkit sra-tools trim-galore bowtie2 ncbi-acc-download prinseq-plus-plus fastqc flash2 -c bioconda

# ディレクトリ作成
mkdir data QC

# シーケンスデータのダウンロード、すこし時間がかかる
prefetch DRR267102 --max-size 10G  --output-directory ./data/  # PacBio
prefetch DRR267104 --max-size 10G  --output-directory ./data/  # Illumina
prefetch DRR267105 --max-size 10G  --output-directory ./data/  # PacBio
prefetch DRR267106 --max-size 10G  --output-directory ./data/  # Illumina
prefetch DRR267107 --max-size 10G  --output-directory ./data/  # PacBio 
prefetch DRR267108 --max-size 10G  --output-directory ./data/  # Illumina
prefetch DRR267109 --max-size 10G  --output-directory ./data/  # PacBio
prefetch DRR267110 --max-size 10G  --output-directory ./data/  # Illumina
ncbi-acc-download -F fasta NC_001422.1  #PhiX

# sraファイルをfastqに変換する
fasterq-dump data/*/*.sra  --threads 4 --progress --split-files --outdir data/

# アダプター除去
trim_galore --paired data/DRR267104.sra_1.fastq data/DRR267104.sra_2.fastq -o QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267106.sra_1.fastq data/DRR267106.sra_2.fastq -o QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267108.sra_1.fastq data/DRR267108.sra_2.fastq -o QC/ --quality 20 --cores 4 --gzip
trim_galore --paired data/DRR267110.sra_1.fastq data/DRR267110.sra_2.fastq -o QC/ --quality 20 --cores 4 --gzip

# PhiX除去
# メタゲノム配列をPhiXにマッピングし、マップされなかった配列を回収
bowtie2-build data/NC_001422.1.fa data/NC_001422.1.fa # 最初に、PhiX配列ファイルに対してbowtie2のインデックスファイルを作成
bowtie2 --time -x data/NC_001422.1.fa -1 QC/DRR267104.sra_1_val_1.fq.gz -2 QC/DRR267104.sra_2_val_2.fq.gz --un-conc-gz QC/DRR267104_removePhiX_%.fastq.gz --threads 4  --quiet  -S QC/DRR267104_PhiX.sam -q
bowtie2 --time -x data/NC_001422.1.fa -1 QC/DRR267106.sra_1_val_1.fq.gz -2 QC/DRR267106.sra_2_val_2.fq.gz --un-conc-gz QC/DRR267106_removePhiX_%.fastq.gz --threads 4  --quiet  -S QC/DRR267106_PhiX.sam -q
bowtie2 --time -x data/NC_001422.1.fa -1 QC/DRR267108.sra_1_val_1.fq.gz -2 QC/DRR267108.sra_2_val_2.fq.gz --un-conc-gz QC/DRR267108_removePhiX_%.fastq.gz --threads 4  --quiet  -S QC/DRR267108_PhiX.sam -q
bowtie2 --time -x data/NC_001422.1.fa -1 QC/DRR267110.sra_1_val_1.fq.gz -2 QC/DRR267110.sra_2_val_2.fq.gz --un-conc-gz QC/DRR267110_removePhiX_%.fastq.gz --threads 4  --quiet  -S QC/DRR267110_PhiX.sam -q

# 低複雑度領域除去
# 同時に配列長100bp以下の短断片も除去
prinseq++ -min_len 100 -fastq QC/DRR267104_removePhiX_1.fastq.gz -fastq2 QC/DRR267104_removePhiX_2.fastq.gz -threads 4 -out_gz -out_good QC/DRR267104_removeLowComp_1.fastq.gz -out_good2 QC/DRR267104_removeLowComp_2.fastq.gz -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null
prinseq++ -min_len 100 -fastq QC/DRR267106_removePhiX_1.fastq.gz -fastq2 QC/DRR267106_removePhiX_2.fastq.gz -threads 4 -out_gz -out_good QC/DRR267106_removeLowComp_1.fastq.gz -out_good2 QC/DRR267106_removeLowComp_2.fastq.gz -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null
prinseq++ -min_len 100 -fastq QC/DRR267108_removePhiX_1.fastq.gz -fastq2 QC/DRR267108_removePhiX_2.fastq.gz -threads 4 -out_gz -out_good QC/DRR267108_removeLowComp_1.fastq.gz -out_good2 QC/DRR267108_removeLowComp_2.fastq.gz -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null
prinseq++ -min_len 100 -fastq QC/DRR267110_removePhiX_1.fastq.gz -fastq2 QC/DRR267110_removePhiX_2.fastq.gz -threads 4 -out_gz -out_good QC/DRR267110_removeLowComp_1.fastq.gz -out_good2 QC/DRR267110_removeLowComp_2.fastq.gz -out_bad /dev/null -out_bad2 /dev/null -out_single /dev/null -out_single2 /dev/null

# リード数等の基礎統計の確認
seqkit stat data/*fastq
seqkit stat QC/*.{fastq,fastq.gz} -a

# ファイルを移動
cp QC/DRR267104_removeLowComp_1.fastq.gz QC/DRR267104_QC_1.fastq.gz
cp QC/DRR267104_removeLowComp_2.fastq.gz QC/DRR267104_QC_2.fastq.gz
cp QC/DRR267106_removeLowComp_1.fastq.gz QC/DRR267106_QC_1.fastq.gz
cp QC/DRR267106_removeLowComp_2.fastq.gz QC/DRR267106_QC_2.fastq.gz
cp QC/DRR267108_removeLowComp_1.fastq.gz QC/DRR267108_QC_1.fastq.gz
cp QC/DRR267108_removeLowComp_2.fastq.gz QC/DRR267108_QC_2.fastq.gz
cp QC/DRR267110_removeLowComp_1.fastq.gz QC/DRR267110_QC_1.fastq.gz
cp QC/DRR267110_removeLowComp_2.fastq.gz QC/DRR267110_QC_2.fastq.gz

# FastQCによるレポート出力（QC前後）
fastqc data/*.fastq    -o data/
fastqc   QC/*.fastq.gz -o QC/

