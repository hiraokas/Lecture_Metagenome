#!/bin/bash
#SBATCH --time   12:00:00
#SBATCH --nodes  1-1
#SBATCH --ntasks 8
#SBATCH --mem-per-cpu 8g
#SBATCH --job-name  script06_assembly_DRR267102sbatch
#SBATCH --partition epyc

source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate env_assembly
spades.py -1 QC/DRR267110_QC_1.fastq -2 QC/DRR267110_QC_2.fastq --threads 8 --meta -o assembly/DRR267110_spades/ -m 60
