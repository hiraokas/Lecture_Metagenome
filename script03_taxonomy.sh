#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20250310
#  - ref: https://bioinformatics-centre.github.io/kaiju/
#============================================================================================================

# 解析環境構築
conda activate env_metagenome
conda install kaiju --channel bioconda

# 作業ディレクトリの作成
mkdir taxonomy db

# データベースの準備（時間がかかる）
# ここでは、公式配布されているプレビルド版のうち、比較的軽量なrefseq_refを利用（解凍後ファイルサイズは49GB）
# https://bioinformatics-centre.github.io/kaiju/downloads.html
wget https://kaiju-idx.s3.eu-central-1.amazonaws.com/2023/kaiju_db_refseq_ref_2023-07-05.tgz -P db/
tar -xvf db/kaiju_db_refseq_ref_2023-07-05.tgz -C db/

# kaijuの実行(数時間程度かかる)
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267104_QC_1.fastq -j QC/DRR267104_QC_2.fastq -o taxonomy/DRR267104.kaiju.out -z 4  # Illumina
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267106_QC_1.fastq -j QC/DRR267106_QC_2.fastq -o taxonomy/DRR267106.kaiju.out -z 4
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267108_QC_1.fastq -j QC/DRR267108_QC_2.fastq -o taxonomy/DRR267108.kaiju.out -z 4
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267110_QC_1.fastq -j QC/DRR267110_QC_2.fastq -o taxonomy/DRR267110.kaiju.out -z 4
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i data/DRR267102.sra.fastq -o taxonomy/DRR267102.kaiju.out -z 4  # PacBio
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i data/DRR267105.sra.fastq -o taxonomy/DRR267105.kaiju.out -z 4
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i data/DRR267107.sra.fastq -o taxonomy/DRR267107.kaiju.out -z 4
kaiju -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i data/DRR267109.sra.fastq -o taxonomy/DRR267109.kaiju.out -z 4

# kaiju出力から欲しい情報を抽出する
# 今回は門（phylum）レベルでの群集構造データを得る
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267104.phylum.tsv taxonomy/DRR267104.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267106.phylum.tsv taxonomy/DRR267106.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267108.phylum.tsv taxonomy/DRR267108.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267110.phylum.tsv taxonomy/DRR267110.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267102.phylum.tsv taxonomy/DRR267102.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267105.phylum.tsv taxonomy/DRR267105.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267107.phylum.tsv taxonomy/DRR267107.kaiju.out
kaiju2table -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267109.phylum.tsv taxonomy/DRR267109.kaiju.out
