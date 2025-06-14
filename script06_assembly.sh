#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241109
#  History:  20241129
#  - ref: https://ablab.github.io/spades/
#  - ref: https://github.com/xfengnefx/hifiasm-meta
#============================================================================================================

# 解析環境構築
# SPAdes最新バージョン(4.0)では、要求されるpythonのバージョンが高い（>3.8）など、他のツールとは条件が異なるため、conda環境を別に作成した
conda create --name env_assembly spades==4 hifiasm_meta bandage --channel bioconda --channel conda-forge
conda activate env_assembly

# 作業ディレクトリの作成
mkdir assembly

# metaSPAdesの実行（ショートリード）【ジョブスケジューラを利用しない場合】
spades.py -1 QC/DRR267104_QC_1.fastq -2 QC/DRR267104_QC_2.fastq --meta -o assembly/DRR267104_spades/ --memory 20 --threads 4

# hifiasm-metaの実行（ロングリードHiFi）【ジョブスケジューラを利用しない場合】
mkdir assembly/DRR267102_hifiasm_meta/  #事前に出力ディレクトリを作成する必要がある
hifiasm_meta -o assembly/DRR267102_hifiasm_meta/DRR267102 data/DRR267102.sra.fastq -t 4

# metaSPAdesの実行（ショートリード）【ジョブスケジューラを利用する場合】
sbatch script06_assembly_DRR267104sbatch.sh --output script06_assembly_DRR267104sbatch.sh.out --error script06_assembly_DRR267104sbatch.sh.err
sbatch script06_assembly_DRR267106sbatch.sh --output script06_assembly_DRR267106sbatch.sh.out --error script06_assembly_DRR267106sbatch.sh.err
sbatch script06_assembly_DRR267108sbatch.sh --output script06_assembly_DRR267108sbatch.sh.out --error script06_assembly_DRR267108sbatch.sh.err
sbatch script06_assembly_DRR267110sbatch.sh --output script06_assembly_DRR267110sbatch.sh.out --error script06_assembly_DRR267110sbatch.sh.err

sbatch script06_assembly_DRR267104sbatch_epyc.sh --output script06_assembly_DRR267104sbatch_epyc.sh.out --error script06_assembly_DRR267104sbatch_epyc.sh.err
sbatch script06_assembly_DRR267106sbatch_epyc.sh --output script06_assembly_DRR267106sbatch_epyc.sh.out --error script06_assembly_DRR267106sbatch_epyc.sh.err
sbatch script06_assembly_DRR267108sbatch_epyc.sh --output script06_assembly_DRR267108sbatch_epyc.sh.out --error script06_assembly_DRR267108sbatch_epyc.sh.err
sbatch script06_assembly_DRR267110sbatch_epyc.sh --output script06_assembly_DRR267110sbatch_epyc.sh.out --error script06_assembly_DRR267110sbatch_epyc.sh.err


# hifiasm-metaの実行（ロングリードHiFi）【ジョブスケジューラを利用する場合】
sbatch script06_assembly_DRR267102sbatch.sh --output script06_assembly_DRR267102sbatch.sh.out --error script06_assembly_DRR267102sbatch.sh.err
sbatch script06_assembly_DRR267105sbatch.sh --output script06_assembly_DRR267105sbatch.sh.out --error script06_assembly_DRR267105sbatch.sh.err
sbatch script06_assembly_DRR267107sbatch.sh --output script06_assembly_DRR267107sbatch.sh.out --error script06_assembly_DRR267107sbatch.sh.err
sbatch script06_assembly_DRR267109sbatch.sh --output script06_assembly_DRR267109sbatch.sh.out --error script06_assembly_DRR267109sbatch.sh.err
#???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????

# gfaをfasta形式に変換する（hifiasm-metaの場合）
cat assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.gfa | awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.fasta
cat assembly/DRR267105_hifiasm_meta/DRR267105.p_ctg.gfa | awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267105_hifiasm_meta/DRR267105.p_ctg.fasta
cat assembly/DRR267107_hifiasm_meta/DRR267107.p_ctg.gfa | awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267107_hifiasm_meta/DRR267107.p_ctg.fasta
cat assembly/DRR267109_hifiasm_meta/DRR267109.p_ctg.gfa | awk '/^S/{print ">"$2"\n"$3}' | fold > assembly/DRR267109_hifiasm_meta/DRR267109.p_ctg.fasta

# 統計値の確認
seqkit stat assembly/DRR267104_spades/contigs.fasta assembly/DRR267102_hifiasm_meta/DRR267102.p_ctg.fasta
seqkit stat assembly/*_hifiasm_meta/*.p_ctg.fasta
