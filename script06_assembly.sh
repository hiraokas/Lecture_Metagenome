#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241129
#  - ref: https://ablab.github.io/spades/
#============================================================================================================

# 解析環境構築
# SPAdes最新バージョン(4.0)では、要求されるpythonのバージョンが高い（>3.8）など、他のツールとは条件が異なるため、conda環境を別に作成した
conda create --name env_assembly spades==4 hifiasm_meta bandage --channel bioconda --channel conda-forge
conda activate env_assembly

# 作業ディレクトリの作成
mkdir assembly

# metaSPAdesの実行（ショートリード）【ローカル環境で実行する場合】
spades.py -1 QC/DRR267104_QC_1.fastq -2 QC/DRR267104_QC_2.fastq --meta -o assembly/DRR267104_spades/ --memory 20 --threads 4

# hifiasm-metaの実行（ロングリードHiFi）【ローカル環境で実行する場合】
mkdir assembly/DRR267102_hifiasm_meta/  #事前に出力ディレクトリを作成する必要がある
hifiasm_meta -o assembly/DRR267102_hifiasm_meta/DRR267102 data/DRR267102.sra.fastq -t 4

# metaSPAdesの実行（ショートリード）【qsubでジョブを投入する場合】
#sbatch ${tmpfile} --output QSUB/${b}.out --error QSUB/${b}.err"
sbatch script06_assembly_DRR267104qsub.sh --output script06_assembly_DRR267104qsub.sh.out --error script06_assembly_DRR267104qsub.sh.err
sbatch script06_assembly_DRR267106qsub.sh --output script06_assembly_DRR267106qsub.sh.out --error script06_assembly_DRR267106qsub.sh.err
sbatch script06_assembly_DRR267108qsub.sh --output script06_assembly_DRR267108qsub.sh.out --error script06_assembly_DRR267108qsub.sh.err
sbatch script06_assembly_DRR267110qsub.sh --output script06_assembly_DRR267110qsub.sh.out --error script06_assembly_DRR267110qsub.sh.err

# hifiasm-metaの実行（ロングリードHiFi）【qsubでジョブを投入する場合】
sbatch script06_assembly_DRR267102qsub.sh --output script06_assembly_DRR267102qsub.sh.out --error script06_assembly_DRR267102qsub.sh.err
sbatch script06_assembly_DRR267105qsub.sh --output script06_assembly_DRR267105qsub.sh.out --error script06_assembly_DRR267105qsub.sh.err
sbatch script06_assembly_DRR267107qsub.sh --output script06_assembly_DRR267107qsub.sh.out --error script06_assembly_DRR267107qsub.sh.err
sbatch script06_assembly_DRR267109qsub.sh --output script06_assembly_DRR267109qsub.sh.out --error script06_assembly_DRR267109qsub.sh.err

# gfaをfasta形式に変換する
cat assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.fasta
cat assembly/DRR267105_hifiasm_meta/DRR267105.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267105_hifiasm_meta/DRR267105.p_ctg.fasta
cat assembly/DRR267107_hifiasm_meta/DRR267107.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267107_hifiasm_meta/DRR267107.p_ctg.fasta
cat assembly/DRR267109_hifiasm_meta/DRR267109.p_ctg.gfa |awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267109_hifiasm_meta/DRR267109.p_ctg.fasta

#統計値の確認
seqkit stat assembly/DRR267104_spades/contigs.fasta assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.fasta
