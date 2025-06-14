#!/bin/bash
#SBATCH --time   24:00:00
#SBATCH --nodes  1-1
#SBATCH --ntasks 16
#SBATCH --mem-per-cpu 8g
#SBATCH --partition rome

source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate env_assembly
spades.py -1 QC/DRR267110_QC_1.fastq -2 QC/DRR267110_QC_2.fastq --threads 16 --meta -o assembly/DRR267110_spades/ -m 120
