#!/bin/bash
#SBATCH --job-name=BlobtoolsFilter
#SBATCH --mem=250G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #cores per task
#SBATCH -o slurm_output-Trinity.%J
#SBATCH -e slurm_error.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

module load bio/samtools/1.10
module load bio/minimap2/2.10
module load miniconda3/base

#USAGE: blobtools filter [options] /path/to/BlobDir

conda activate /kmk/scripts/.blobtools2

/kmk/scripts/blobtools-2.6.3/blobtools filter --json NEOM_Scaff_BlobDir.current.json --fasta edited_out_JBAT.FINAL.fa /grps2/kmk/Meghan/Neomenia_genome/2023-01-23_ScaffNeom_Blobtools/NEOM_Scaff_BlobDir

conda deactivate
