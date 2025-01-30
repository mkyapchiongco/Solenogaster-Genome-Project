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

module load bio/samtools/1.10
module load bio/minimap2/2.10
module load miniconda3/base
module load python/python3/3.9.6

#USAGE: blobtools filter [options] /path/to/BlobDir
conda activate /kmk/scripts/.blobtools2

/kmk/scripts/blobtools-2.6.3/blobtools filter --json /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir.current.json --fasta hifiasm.hic.p_ctg.fasta /grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/Ep_Phased_BlobDir
