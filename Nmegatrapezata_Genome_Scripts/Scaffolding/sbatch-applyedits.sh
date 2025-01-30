#!/bin/bash
#SBATCH --job-name=yahs
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH --mem=999G #memory used
#SBATCH -o slurm_output.%J
#SBATCH -e slurm_error.%J
#SBATCH -p threaded
#SBATCH -q threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@uahpc.ua.edu

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

module load java/1.8.202
module load bio/samtools/1.10
module load python/python3/3.6.5
module load bio/bioinfo-gcc

#contigs.fa is your orignal assembly that was not scaffolded
#out.JBAT.review.assembly is your manual edits 
#out_JBAT.liftover.agp is yproduced by jucebox running the pre command you ran for the generation of the initial assembly file
#SAMPLE SCRIPT #juicer post -o out_JBAT out_JBAT.review.assembly out_JBAT.liftover.agp contigs.fa

/kmk/scripts/yahs/juicer post -o edited_out_JBAT 2022-01-23_NEOM_out_JBAT.review.assembly out_JBAT.liftover.agp hifiasm.hic.p_ctg.fasta
