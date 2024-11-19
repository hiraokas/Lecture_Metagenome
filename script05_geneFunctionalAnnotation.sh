#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241114
#  - ref: https://bioinformatics-centre.github.io/kaiju/
#============================================================================================================

# 解析環境構築
conda activate env_metagenome
conda install prodigal eggnog-mapper -c bioconda

# ディレクトリ作成
mkdir gene annotation

# データベースのダウンロード
wget https://ftp.ncbi.nlm.nih.gov/pub/COG/COG2024/data/cog-24.cog.csv -P db/

# fastqファイルをfastaファイルへ変換する
# sedでは、「４行毎に１行目の１文字目の@を>に変換して出力」かつ「４行毎に２行目をそのまま出力」させることで、fastqをfastaのフォーマットに変換している
sed -n '1~4s/^@/>/p;2~4p' QC/DRR267104_merge.extendedFrags.fastq > QC/DRR267104_merge.fasta  # Illumina
sed -n '1~4s/^@/>/p;2~4p' QC/DRR267106_merge.extendedFrags.fastq > QC/DRR267106_merge.fasta  # Illumina
sed -n '1~4s/^@/>/p;2~4p' QC/DRR267108_merge.extendedFrags.fastq > QC/DRR267108_merge.fasta  # Illumina
sed -n '1~4s/^@/>/p;2~4p' QC/DRR267110_merge.extendedFrags.fastq > QC/DRR267110_merge.fasta  # Illumina
sed -n '1~4s/^@/>/p;2~4p' data/DRR267102.sra.fastq               > data/DRR267102.fasta      # PacBio
sed -n '1~4s/^@/>/p;2~4p' data/DRR267105.sra.fastq               > data/DRR267105.fasta      # PacBio
sed -n '1~4s/^@/>/p;2~4p' data/DRR267107.sra.fastq               > data/DRR267107.fasta      # PacBio
sed -n '1~4s/^@/>/p;2~4p' data/DRR267109.sra.fastq               > data/DRR267109.fasta      # PacBio

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


# 遺伝子データベースのダウンロードと準備(KEGG)
conda install prodigal hmmer -c bioconda
wget https://www.genome.jp/ftp/db/kofam/profiles.tar.gz -P db/
wget https://www.genome.jp/ftp/db/kofam/ko_list.gz      -P db/
tar -xvf db/profiles.tar.gz -C db/
cat db/profiles/*.hmm > db/KofamKOALA.hmm
hmmpress db/KofamKOALA.hmm

#遺伝子アノテーション
hmmscan --domtblout annotation/DRR267104_kofam.domtblout --cpu 4 db/KofamKOALA.hmm gene/DRR267104.prot.faa > /dev/null



# 遺伝子データベースのダウンロードと準備(eggNOG)
wget http://eggnog5.embl.de/download/eggnog_5.0/e5.proteomes.faa -P db/



# 解析環境構築（eggNOG_mapper）
conda install -c bioconda -c conda-forge eggnog-mapper

# データベースの準備
download_eggnog_data.py --data_dir db/ -y

# eggNOG_mapperの実行(非常に時間がかかる、スレッド数は増やす検討をしてもよいだろう)
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