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
conda activate assembler
spades.py -1 QC/DRR267106_QC_1.fastq.gz -2 QC/DRR267106_QC_2.fastq.gz --threads 8 --meta -o assembly/DRR267106_spades/
