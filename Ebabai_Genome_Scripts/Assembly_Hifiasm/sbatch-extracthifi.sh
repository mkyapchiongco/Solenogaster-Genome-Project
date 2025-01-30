#!/bin/bash
#SBATCH --job-name=extracthifi
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=600G
#SBATCH -o slurm_output-extracthifi.%J
#SBATCH -e slurm_error-extracthifi.%J
#SBATCH -p threaded
#SBATCH -q threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu


#You must load samtools before the conda environment otherwise samtools does not have the correct dependencies.
module load bio/samtools/1.10

#samtools cat -o C_nitidulum.bam -b bamlist.txt
#bamlist.txt is a list of all the bam files from UC Davis, line separated

#Load pbbioconda, extract hifi and convert to fasta
module load bio/pbbioconda
conda activate /grps2/kmk/Nick/scripts/pbconda
extracthifi /grps2/kmk/2021-05-27_UC_Davis_PacBio_HiFi_Epimenia/PB559_02_E.Babai_HiFi/r64069_20210520_184953/B1/0000002466/outputs/reads.bam Ebabai.bam_Hifi.bam

echo "done"


