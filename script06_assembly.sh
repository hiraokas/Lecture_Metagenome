#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241116
#  - ref: https://ablab.github.io/spades/
#============================================================================================================

# 解析環境構築
# SPAdes最新バージョン(4.0)では、要求されるpythonのバージョンが高い（>3.8）など、他のツールとは条件が異なるため、conda環境を別に作成した
conda create -n env_assembly spades==4 hifiasm_meta bandage -c bioconda -c conda-forge  
conda activate env_assembly

# ディレクトリ作成
mkdir assembly

# metaSPAdesの実行（ショートリード）【ローカル環境で実行する場合】
spades.py -1 QC/DRR267104_QC_1.fastq -2 QC/DRR267104_QC_2.fastq --meta -o assembly/DRR267104_spades/ --threads 4

# hifiasm-metaの実行（ロングリードHiFi）【ローカル環境で実行する場合】
mkdir assembly/DRR267102_hifiasm_meta/  #事前に出力ディレクトリを作成する必要がある
hifiasm_meta -o assembly/DRR267102_hifiasm_meta/DRR267102 data/DRR267102.sra.fastq  -t 4

# metaSPAdesの実行（ショートリード）【qsubでジョブを投入する場合】
qsub_beta -o script06_assembly_DRR267104qsub.sh.out -e script06_assembly_DRR267104qsub.sh.err -V script06_assembly_DRR267104qsub.sh 
qsub_beta -o script06_assembly_DRR267106qsub.sh.out -e script06_assembly_DRR267106qsub.sh.err -V script06_assembly_DRR267106qsub.sh 
qsub_beta -o script06_assembly_DRR267108qsub.sh.out -e script06_assembly_DRR267108qsub.sh.err -V script06_assembly_DRR267108qsub.sh 
qsub_beta -o script06_assembly_DRR267110qsub.sh.out -e script06_assembly_DRR267110qsub.sh.err -V script06_assembly_DRR267110qsub.sh 

# hifiasm-metaの実行（ロングリードHiFi）【qsubでジョブを投入する場合】
qsub_beta -o script06_assembly_DRR267102qsub.sh.out -e script06_assembly_DRR267102qsub.sh.err -V script06_assembly_DRR267102qsub.sh 
qsub_beta -o script06_assembly_DRR267105qsub.sh.out -e script06_assembly_DRR267105qsub.sh.err -V script06_assembly_DRR267105qsub.sh 
qsub_beta -o script06_assembly_DRR267107qsub.sh.out -e script06_assembly_DRR267107qsub.sh.err -V script06_assembly_DRR267107qsub.sh 
qsub_beta -o script06_assembly_DRR267109qsub.sh.out -e script06_assembly_DRR267109qsub.sh.err -V script06_assembly_DRR267109qsub.sh 

# gfaをfasta形式に変換する
cat assembly/DRR267102_hifiasm_meta.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267102_hifiasm_meta.p_ctg.fasta

#統計値の確認
seqkit stat assembly/DRR267104_spades/contigs.fasta assembly/DRR267102_hifiasm_meta.p_ctg.fasta
