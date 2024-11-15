#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241109
#  - ref: https://ablab.github.io/spades/
#============================================================================================================

#解析環境構築
#SPAdes最新バージョン(4.0)では、要求されるpythonのバージョンが高い（>3.8）など、他のツールとは条件が異なるため、conda環境を別に作成した
conda create -n assembler spades==4 hifiasm_meta bandage -c bioconda -c conda-forge  
conda activate assembler

#ディレクトリ作成
mkdir assembly

#metaSPAdesの実行（ショートリード）【ローカル環境で実行する場合（非奨励）】
spades.py -1 QC/DRR267104_QC_1.fastq.gz -2 QC/DRR267104_QC_2.fastq.gz --threads 4 --meta -o assembly/DRR267104_spades/

#hifiasm-metaの実行（ロングリードHiFi）【ローカル環境で実行する場合（非奨励）】
hifiasm_meta -o assembly/DRR267102_hifiasm_meta -t 4 data/DRR267102.sra.fastq

#metaSPAdesの実行（ショートリード）【qsubでジョブを投入する場合】
qsub_beta -o script06_assembly_DRR267104qsub.sh.out -e script06_assembly_DRR267104qsub.sh.err -V script06_assembly_DRR267104qsub.sh 
qsub_beta -o script06_assembly_DRR267106qsub.sh.out -e script06_assembly_DRR267106qsub.sh.err -V script06_assembly_DRR267106qsub.sh 

#hifiasm-metaの実行（ロングリードHiFi）【qsubでジョブを投入する場合】
qsub_beta -o script06_assembly_DRR267102qsub.sh.out -e script06_assembly_DRR267102qsub.sh.err -V script06_assembly_DRR267102qsub.sh 


cat assembly/DRR267102_hifiasm_meta.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > DRR267102_hifiasm_meta.contig.fa
