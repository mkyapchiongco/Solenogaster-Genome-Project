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
#CANT HAVE PYTHON LOADED 

#Input files used:
GENOME=/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/edited_out_JBAT.FINAL.fa
HIF_READS=/grps2/kmk/Meghan/Neomenia_genome/2022-07-01_NEOM_AllHiFi_Hifiasm/NEOM_AllHiFi.fasta
#/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/ManualEdits_BUSCO_QUAST/busco_out/BUSCO/run_metazoa_odb10
	#Above is path for used BUSCO inout

conda activate /kmk/scripts/.blobtools2

#Create BlobDir
/kmk/scripts/blobtoolkit2/blobtools2/blobtools create --threads 16 --fasta $GENOME NEOM_Scaff_BlobDir 

##Add BUSCO
/kmk/scripts/blobtools-2.6.3/blobtools add --busco full_table.tsv NEOM_Scaff_BlobDir 

##Add coverage as txt file

/kmk/scripts/blobtools-2.6.3/blobtools add --text NEOM_Scaff_cov.txt --text-header --text-cols 'id=identifier,meandepth=my_reads_cov' NEOM_Scaff_BlobDir 

##Add meandepth value on y-axis
#/kmk/scripts/blobtools-2.6.3/blobtools add --key plot.y=my_reads_cov NEOM_Scaff_BlobDir 

##Add hits from uniprot
/kmk/scripts/blobtools-2.6.3/blobtools add --hits NEOM_Scaff.blast --taxrule bestsumorder --taxdump /kmk/databases/new_taxdump NEOM_Scaff_BlobDir 

conda deactivate
