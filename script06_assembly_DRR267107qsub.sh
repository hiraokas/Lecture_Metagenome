#!/bin/bash
#$ -pe def_slot 8
#$ -l s_vmem=8G
#$ -l mem_req=8G
#$ -l d_rt=12:00:00
#$ -l s_rt=12:00:00
#$ -l medium
#$ -M YOUR_EMAIL_ADDRESS@ac.jp
#$ -V
#$ -cwd
#$ -S /bin/bash

source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate env_assembly
mkdir assembly/DRR267107_hifiasm_meta/
hifiasm_meta -o assembly/DRR267107_hifiasm_meta/DRR267107 data/DRR267107.sra.fastq -t 4
