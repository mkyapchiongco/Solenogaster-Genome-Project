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

FORWARD_PE_READS=forward.fastq
REVERSE_PE_READS=reverse.fastq
BASENAME=NEOM
GENOME=/grps2/kmk/Meghan/Neomenia_genome/2023-02-22_Neomenia_RepeatModeler_Masker/edited_out_JBAT.FINAL.filtered.fa.masked

#Run star
mkdir star_genome
/kmk/scripts/STAR/STAR --runThreadN 16 --runMode genomeGenerate --genomeDir star_genome --genomeFastaFiles $GENOME
/kmk/scripts/STAR/STAR --runThreadN 16 --genomeDir star_genome --readFilesIn $FORWARD_PE_READS $REVERSE_PE_READS
samtools view -bS Aligned.out.sam > RNAseq.bam

#Do some clean-up (you will want to manually remove duplicate .fastq files later)
rm -rf *.sam
