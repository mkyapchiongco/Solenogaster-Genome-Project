#!/bin/bash
#SBATCH --job-name hifiasm
#SBATCH --mem=500G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH -o slurm_output.%J
#SBATCH -e slurm_error.%J
#SBATCH -p ultrahigh
#SBATCH -q loko
#SBATCH -A loko_grp
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

module load python/python3/3.6.5
module load bio/samtools/1.9
module load bio/bioinfo-gcc
module load java/1.8.202

samtools fasta Ebabai.bam_Hifi.bam > Ebabai_allhifireads.fa


