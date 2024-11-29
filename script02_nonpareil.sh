#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241129
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

# 解析環境構築
conda activate env_metagenome
conda install nonpareil --channel bioconda

# ディレクトリ作成
mkdir nonpareil

# nonpareilの実行
nonpareil -s QC/DRR267104_merge.extendedFrags.fastq -f fastq -T kmer -b nonpareil/DRR267104 -t 4
nonpareil -s QC/DRR267106_merge.extendedFrags.fastq -f fastq -T kmer -b nonpareil/DRR267106 -t 4
nonpareil -s QC/DRR267108_merge.extendedFrags.fastq -f fastq -T kmer -b nonpareil/DRR267108 -t 4
nonpareil -s QC/DRR267110_merge.extendedFrags.fastq -f fastq -T kmer -b nonpareil/DRR267110 -t 4
