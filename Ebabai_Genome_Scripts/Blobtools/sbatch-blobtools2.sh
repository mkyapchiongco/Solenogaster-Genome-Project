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


#Input files used:
GENOME=/grps2/kmk/Meghan/Epimenia_babai_genome/2021-12-28_Epimenia_Hifiasm_HiCReadsCleaned_IncreasedHetero/hifiasm.hic.p_ctg.fasta
HIF_READS=/grps2/kmk/Meghan/Epimenia_babai_genome/2021-09-29_ExtractHifi/Ebabai_allhifireads.fa
#/grps2/kmk/Meghan/Epimenia_babai_genome/2021-12-28_Epimenia_Hifiasm_HiCReadsCleaned_IncreasedHetero/busco_out/BUSCO/run_metazoa_odb10/full_table.tsv

##Diamond 
/kmk/scripts/diamond blastx --threads 16 --sensitive --index-chunks 1 --block-size 10 --max-target-seqs 1 --evalue 1e-25 --query $GENOME --outfmt 6 --db /kmk/databases/Uniprot_reference_proteomes/reference_proteomes.dmnd --outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore --out EP_Phase.blast


#Map trimmed PE reads to genome

/kmk/scripts/minimap2-2.22_x64-linux/minimap2 -ax map-hifi -I 400G -t 16 $GENOME $HIF_READS -o EP_Phase_mapping.sam
samtools view -S -b EP_Phase_mapping.sam > EP_EP_Phase_mapping.bam
samtools sort -@48 -O BAM EP_Phase_mapping.bam -o EP_Phase_mapping_sorted.bam
samtools coverage -o Ep_Phase_cov.txt EP_Phase_mapping_sorted.bam

conda activate /kmk/scripts/.blobtools2

#Create BlobDir
/kmk/scripts/blobtoolkit2/blobtools2/blobtools create --threads 16 --fasta $GENOME EP_Phase_BlobDir 

##Add BUSCO
/kmk/scripts/blobtools-2.6.3/blobtools add --busco full_table.tsv /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/EP_Phase_BlobDir

##Add coverage as txt file

/kmk/scripts/blobtools-2.6.3/blobtools add --text Ep_Phase_cov.txt --text-header --text-cols 'id=identifier,meandepth=my_reads_cov' /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/EP_Phase_BlobDir

##Add meandepth value on y-axis
#/kmk/scripts/blobtools-2.6.3/blobtools add --key plot.y=my_reads_cov /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/EP_Phase_BlobDir

##Add hits from uniprot
#INCORRECT CORRECCT BELOW/kmk/scripts/blobtools-2.6.3/blobtools add --hits EP_Phase.blast --taxrule bestsumorder --taxdump /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/EP_Phase_BlobDir 
/kmk/scripts/blobtools-2.6.3/blobtools add --hits EP_Phase.blast --taxrule bestsumorder --taxdump /kmk/databases/new_taxdump /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir



#conda deactivate

