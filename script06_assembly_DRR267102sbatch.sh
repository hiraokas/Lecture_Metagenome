#!/bin/bash
#SBATCH --time   12:00:00
#SBATCH --nodes  1-1
#SBATCH --ntasks 8
#SBATCH --mem-per-cpu 8g
#SBATCH --job-name  script06_assembly_DRR267102sbatch
#SBATCH --partition epyc

source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate env_assembly
mkdir assembly/DRR267102_hifiasm_meta/
hifiasm_meta -o assembly/DRR267102_hifiasm_meta/DRR267102 data/DRR267102.sra.fastq -t 8
