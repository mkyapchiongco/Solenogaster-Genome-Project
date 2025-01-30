#!/bin/bash
#SBATCH --job-name=hifiasm
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH --mem=999G #memory used
#SBATCH -o slurm_output-hifiasm.%J
#SBATCH -e slurm_error-hifiasm.%J
#SBATCH -p threaded
#SBATCH -q threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@uahpc.ua.edu

export DK_ROOT=/share/apps/dotkit
. /share/apps/dotkit/bash/.dk_init

use java1.8.0


HIFIREADS=/grps2/kmk/Meghan/Neomenia_genome/2022-07-01_NEOM_AllHiFi_Hifiasm/NEOM_AllHiFi.fasta 

##Need to use the cleaned reads that are cleaned with the hifiasm assembly
/kmk/scripts/hifiasm-0.16/hifiasm -t 16 -l 3 --h1 /grps2/kmk/Meghan/Neomenia_genome/2022-04-22_Matlock_NEOM_Hifi_HiC/NEOM_Hifi_matlock_cleanedBlob1_F.fastq --h2 /grps2/kmk/Meghan/Neomenia_genome/2022-04-22_Matlock_NEOM_Hifi_HiC/NEOM_Hifi_matlock_cleanedBlob2_R.fastq $HIFIREADS

awk '/^S/{print ">"$2"\n"$3}' hifiasm.asm.hic.p_ctg.gfa | fold > hifiasm.hic.p_ctg.fasta
