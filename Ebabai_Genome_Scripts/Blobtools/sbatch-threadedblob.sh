#!/bin/bash
#SBATCH --job-name=Blobtools
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


module load bio/samtools/1.10
module load bio/minimap2/2.10
module load miniconda3/base

#GENOME=/grps2/kmk/Meghan/Epimenia_babai_genome/2021-12-28_Epimenia_Hifiasm_HiCReadsCleaned_IncreasedHetero/hifiasm.hic.p_ctg.fasta
HIF_READS=/grps2/kmk/Meghan/Epimenia_babai_genome/2021-09-29_ExtractHifi/Ebabai_allhifireads.fa

#/kmk/scripts/minimap2-2.22_x64-linux/minimap2 -ax map-hifi -I 400G -t 16 hifiasm.hic.p_ctg.fasta $HIF_READS -o EP_Phase_mapping.sam
#samtools view -S -b EP_Phase_mapping.sam > EP_Phase_mapping.bam
#samtools sort -@48 -O BAM EP_Phase_mapping.bam -o EP_Phase_mapping_sorted.bam
samtools coverage -o Ep_Phase_cov.txt EP_Phase_mapping_sorted.bam

#conda activate /kmk/scripts/.blobtools2

#Create BlobDir
#/kmk/scripts/blobtoolkit2/blobtools2/blobtools create --threads 16 --fasta hifiasm.hic.p_ctg.fasta Ep_Phased_BlobDir

##Add BUSCO
#/kmk/scripts/blobtools-2.6.3/blobtools add --busco full_table.tsv /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir

##Add coverage as txt file

#/kmk/scripts/blobtools-2.6.3/blobtools add --text Ep_Phase_cov.txt --text-header --text-cols 'id=identifier,meandepth=my_reads_cov' /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir

##Add meandepth value on y-axis
#/kmk/scripts/blobtools-2.6.3/blobtools add --key plot.y=my_reads_cov /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir

##Add hits from uniprot
## MESSED UP HERE DO NOT USE /kmk/scripts/blobtools-2.6.3/blobtools add --hits EP_Phase.blast --taxrule bestsumorder --taxdump /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir

#/kmk/scripts/blobtools-2.6.3/blobtools add --hits EP_Phase.blast --taxrule bestsumorder --taxdump /kmk/databases/new_taxdump /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir

