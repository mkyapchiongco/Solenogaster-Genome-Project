#!/bin/bash
#SBATCH --job-name=RepeatModeler
#SBATCH --mem=256G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH -o slurm_output-RepeatModeler.%J
#SBATCH --qos threaded
#SBATCH -p threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@ua.edu


#Notes:
#This software is installed in: /share/apps/repeatmodeler/Repeatmodeler-2.0.3/hmmer-3.3.2/bin
#See https://www.repeatmasker.org/webrepeatmaskerhelp.html for instructions for use
#genome from/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/ManualEdits/out_JBATMod.FINAL.fa

GENOME=out_JBATMod.FINAL.fa
ABBREV=EBAB

#Load the modules needed for RepeatMasker and RepeatModeler
module load /share/apps/modulefiles/bio/repeatmodeler/2.0.3
module load bio/blast/2.9.0

#Make the RepeatModeler database
#BuildDatabase -engine rmblast -name $ABBREV $GENOME

#Run RepeatModeler
RepeatModeler -pa 2 -engine rmblast -LTRStruct -database $ABBREV --recoverDir ./RM_69462.MonApr31611562023 2>&1 | tee repeatmodeler.log

#Copy the repeat database to the working directory
cp ./*/consensi.fa.classified .

#Increase the BLASTDB_LMDB_MAP_SIZE variable to 2 gigabytes (BLASTDB_LMDB_MAP_SIZE=2000000000) or however it needs to be for your genome file
export BLASTDB_LMDB_MAP_SIZE=2000000000

#Run RepeatMasker
RepeatMasker -pa 2 -s -gccalc -xsmall -gff -html -lib consensi.fa.classified $GENOME 2>&1 | tee repeatmasker.log
