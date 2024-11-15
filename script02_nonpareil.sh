#============================================================================================================
#  By Satoshi Hiraoka
#  hiraokas@jamstec.go.jp
#  Created:  20241014
#  History:  20241014
#  - ref: http://nonpareil.readthedocs.io/en/latest/curves.html
#============================================================================================================

#解析環境構築
conda activate metagenome
conda install nonpareil -c bioconda

#gzファイルの解凍
gunzip QC/DRR267106_QC_1.fastq.gz --keep

#gxファイルの解凍
gunzip QC/DRR267104_QC_1.fastq.gz
gunzip QC/DRR267106_QC_1.fastq.gz
gunzip QC/DRR267108_QC_1.fastq.gz
gunzip QC/DRR267110_QC_1.fastq.gz


#nonpareilの実行
nonpareil -s QC/DRR267104_QC_1.fastq  -T kmer -b QC/DRR267104.nonpareil -t 4 -f fastq 
nonpareil -s QC/DRR267106_QC_1.fastq  -T kmer -b QC/DRR267106.nonpareil -t 4 -f fastq 
nonpareil -s QC/DRR267108_QC_1.fastq  -T kmer -b QC/DRR267108.nonpareil -t 4 -f fastq 
nonpareil -s QC/DRR267110_QC_1.fastq  -T kmer -b QC/DRR267110.nonpareil -t 4 -f fastq 
