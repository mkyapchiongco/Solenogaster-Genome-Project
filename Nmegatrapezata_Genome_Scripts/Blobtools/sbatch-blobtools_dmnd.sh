#!/bin/bash
#SBATCH --job-name=BlobTools2
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 16
#SBATCH --mem=999G
#SBATCH -o slurm_output-BlobTools2.%J
#SBATCH -e slurm_error-BlobTools2.%J
#SBATCH -p ultrahigh
#SBATCH -q loko
#SBATCH -A loko_grp
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu


module load bio/samtools/1.10
module load bio/minimap2/2.10
module load miniconda3/base
#CANT HAVE PYTHON LOADED 


#Input files used:
GENOME=/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/edited_out_JBAT.FINAL.fa
HIF_READS=/grps2/kmk/Meghan/Neomenia_genome/2022-07-01_NEOM_AllHiFi_Hifiasm/NEOM_AllHiFi.fasta
#/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/ManualEdits_BUSCO_QUAST/
	#Above is path for used BUSCO inout
##Diamond 
/kmk/scripts/diamond blastx --threads 16 --sensitive --index-chunks 1 --block-size 10 --max-target-seqs 1 --evalue 1e-25 --query $GENOME --outfmt 6 --db /kmk/databases/Uniprot_reference_proteomes/reference_proteomes.dmnd --outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore --out NEOM_Scaff.blast


#Map trimmed PE reads to genome

/kmk/scripts/minimap2-2.22_x64-linux/minimap2 -ax map-hifi -I 400G -t 16 $GENOME $HIF_READS -o NEOM_Scaff_mapping.sam
samtools view -S -b NEOM_Scaff_mapping.sam > NEOM_Scaff_mapping.bam
samtools sort -@48 -O BAM NEOM_Scaff_mapping.bam -o NEOM_Scaff_mapping_sorted.bam
samtools coverage -o NEOM_Scaff_cov.txt NEOM_Scaff_mapping_sorted.bam
