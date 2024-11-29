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
spades.py -1 QC/DRR267110_QC_1.fastq -2 QC/DRR267110_QC_2.fastq --threads 4 --meta -o assembly/DRR267110_spades/ -m 60
