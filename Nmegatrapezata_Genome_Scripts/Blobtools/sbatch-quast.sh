#!/bin/bash
#SBATCH --job-name=quast
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH --mem=20G
#SBATCH -o slurm_output-quast.%J
#SBATCH -e slurm_error-quast.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

me=`whoami`

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init
use quast

quast.py -s -t 16 --plots-format pdf ../edited_out_JBAT.FINAL.filtered.fa

