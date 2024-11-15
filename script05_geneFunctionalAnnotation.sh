#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241114
#  - ref: https://bioinformatics-centre.github.io/kaiju/
#============================================================================================================

#解析環境構築
conda activate metagenome
conda install prodigal hmmer -c bioconda

#ディレクトリ作成
mkdir gene annotation

#データベースのダウンロード
wget https://ftp.ncbi.nlm.nih.gov/pub/COG/COG2024/data/cog-24.cog.csv -P db/

#paired-endリードのマージ
flash2 --allow-outies QC/DRR267104_removePhiX_1.fastq.gz QC/DRR267104_removePhiX_2.fastq.gz -t 4 --output-directory QC/ --output-prefix DRR267104_merge

#fastqファイルをfastaファイルへ変換する
#sedでは、「４行毎に１行目の１文字目の@を>に変換して出力」かつ「４行毎に２行目をそのまま出力」させることで、fastqをfastaのフォーマットに変換している
sed -n '1~4s/^@/>/p;2~4p' data/DRR267102.sra.fastq               > data/DRR267102.fasta      # PacBio
sed -n '1~4s/^@/>/p;2~4p' QC/DRR267104_merge.extendedFrags.fastq > QC/DRR267104_merge.fasta  # Illumina

#CDS予測
#prodigalは並列処理が実装されておらず、シングルスレッドでの動作になるため、処理に時間がかかる
prodigal -i data/DRR267102.fasta     -o gene/DRR267102.coords.gbk -a gene/DRR267102.prot.faa -d gene/DRR267102.nucl.fna -p meta -q
prodigal -i QC/DRR267104_merge.fasta -o gene/DRR267104.coords.gbk -a gene/DRR267104.prot.faa -d gene/DRR267104.nucl.fna -p meta -q

# seqkit split QC/DRR267104_merge.extendedFrags.fastq -p 20
# for f in QC/DRR267104_merge.extendedFrags.fastq.split/*.fastq; do
# nohup prodigal -i ${f} -o gene/DRR267104.coords.gbk -a gene/DRR267104.prot.faa -d gene/DRR267104.nucl.fna -p meta -q &
# done


#遺伝子データベースのダウンロード

wget https://www.genome.jp/ftp/db/kofam/profiles.tar.gz -P db/
wget https://www.genome.jp/ftp/db/kofam/ko_list.gz      -P db/
tar -xvf db/profiles.tar.gz -C db/
cat db/profiles/*.hmm > db/KofamKOALA.hmm

#遺伝子アノテーション
hmmscan -o annotation/DRR267104_kofam.tsv --cpu 4 db/KofamKOALA.hmm gene/DRR267104.prot.faa

