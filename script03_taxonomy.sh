#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241114
#  - ref: https://bioinformatics-centre.github.io/kaiju/
#============================================================================================================

# 解析環境構築
conda activate metagenome
conda install kaiju -c bioconda

# ディレクトリ作成
mkdir taxonomy

# データベースのダウンロード（時間がかかる）
# ここでは、公式配布されているプレビルド版のうち、比較的軽量なrefseq_refを利用（解凍後ファイルサイズは49GB）
# https://bioinformatics-centre.github.io/kaiju/downloads.html
mkdir db
wget https://kaiju-idx.s3.eu-central-1.amazonaws.com/2023/kaiju_db_refseq_ref_2023-07-05.tgz -P db/
tar -xvf db/2023/kaiju_db_refseq_ref_2023-07-05.tgz -C db/

# kaijuの実行(時間がかかる)
kaiju -z 4 -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267104_QC_1.fastq.gz -j QC/DRR267104_QC_2.fastq.gz -o taxonomy/DRR267104.kaiju.out
kaiju -z 4 -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267106_QC_1.fastq.gz -j QC/DRR267106_QC_2.fastq.gz -o taxonomy/DRR267106.kaiju.out
kaiju -z 4 -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267108_QC_1.fastq.gz -j QC/DRR267108_QC_2.fastq.gz -o taxonomy/DRR267108.kaiju.out
kaiju -z 4 -t db/nodes.dmp -f db/kaiju_db_refseq_ref.fmi -i QC/DRR267110_QC_1.fastq.gz -j QC/DRR267110_QC_2.fastq.gz -o taxonomy/DRR267110.kaiju.out

# kaiju出力から欲しい情報を抽出する
# 今回は門（phylum）レベルでの群集構造データを得る
kaiju2table -v -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267104.phylum.tsv taxonomy/DRR267104.kaiju.out
kaiju2table -v -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267106.phylum.tsv taxonomy/DRR267106.kaiju.out
kaiju2table -v -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267108.phylum.tsv taxonomy/DRR267108.kaiju.out
kaiju2table -v -t db/nodes.dmp -n db/names.dmp -r phylum -o taxonomy/DRR267110.phylum.tsv taxonomy/DRR267110.kaiju.out
