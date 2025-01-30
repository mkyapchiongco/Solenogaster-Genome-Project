#!/bin/bash
#SBATCH --job-name=STAR
#SBATCH --mem=500G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH -o slurm_output-STAR.%J
#SBATCH -e slurm_output-STAR.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

module load bio/bowtie/2.2.5
module load bio/samtools/1.10
module load bio/cufflinks/2.2.1
module load bio/bioinfo-java
module load java/1.8.0 
module load python/python2/2.6

FORWARD_PE_READS=/grps2/kmk/Meghan/Epimenia_babai_genome/Epimenia_babai_transcritpome_SRA/EBab_combined_1P.fq
REVERSE_PE_READS=/grps2/kmk/Meghan/Epimenia_babai_genome/Epimenia_babai_transcritpome_SRA/EBab_combined_2P.fq
BASENAME=Ebab
GENOME=/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/ManualEdits/out_JBATMod.FINAL.fa

#Epimenia transcriptome data taken from:
#sftp://kmkocot@uahpc.ua.edu/grps2/kmk/2020-08-31_Macrogen_chiton_radula_transcriptoms_other_transcriptomes_and_Hi-C/Epimenia_babai
#raw transcriptome reads from https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR6926338 SRA# SRR6926338, same reads as in the Ken Halanych folder on UAHPC just had these already
#combined and ran in /grps2/kmk/Meghan/E

#Run star
mkdir star_genome
/kmk/scripts/STAR/STAR --runThreadN 16 --runMode genomeGenerate --genomeDir star_genome --genomeFastaFiles $GENOME
/kmk/scripts/STAR/STAR --runThreadN 16 --genomeDir star_genome --readFilesIn $FORWARD_PE_READS $REVERSE_PE_READS
samtools view -bS Aligned.out.sam > RNAseq.bam

#Do some clean-up (you will want to manually remove duplicate .fastq files later)
rm -rf *.sam
gzip $FORWARD_PE_READS 
gzip $REVERSE_PE_READS

