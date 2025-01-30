#!/bin/bash
#SBATCH --job-name=RepeatModeler
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=999G
#SBATCH -o slurm_output.%J
#SBATCH -e slurm_error.%J
#SBATCH -p ultrahigh
#SBATCH -q loko
#SBATCH -A loko_grp
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

#Notes:
#This software is installed in: /share/apps/repeatmodeler/Repeatmodeler-2.0.3/hmmer-3.3.2/bin
#See https://www.repeatmasker.org/webrepeatmaskerhelp.html for instructions for use

GENOME=/grps2/kmk/Meghan/Neomenia_genome/2023-01-23_ScaffNeom_Blobtools/edited_out_JBAT.FINAL.filtered.fa
ABBREV=NEOM

#Load the modules needed for RepeatMasker and RepeatModeler
module load /share/apps/modulefiles/bio/repeatmodeler/2.0.3
module load bio/blast/2.9.0

#Make the RepeatModeler database
BuildDatabase -engine rmblast -name $ABBREV $GENOME

#Run RepeatModeler
RepeatModeler -pa 2 -engine rmblast -LTRStruct -database $ABBREV  2>&1 | tee repeatmodeler.log

#Copy the repeat database to the working directory
cp ./*/consensi.fa.classified .

#Increase the BLASTDB_LMDB_MAP_SIZE variable to 2 gigabytes (BLASTDB_LMDB_MAP_SIZE=2000000000) or however it needs to be for your genome file
export BLASTDB_LMDB_MAP_SIZE=2000000000

#Run RepeatMasker
RepeatMasker -pa 2 -s -gccalc -xsmall -gff -html -lib consensi.fa.classified $GENOME 2>&1 | tee repeatmasker.log
