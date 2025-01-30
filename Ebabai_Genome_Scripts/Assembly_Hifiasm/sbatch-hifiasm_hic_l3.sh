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
module load bio/hifiasm

/kmk/scripts/hifiasm-0.16/hifiasm -t 16 -l 3 --h1 /grps2/kmk/Meghan/Epimenia_babai_genome/2021-06-09_MatlockEp_hifiasmhicmode/Ebab_cleaned_matlock_cleaned1.fq --h2 /grps2/kmk/Meghan/Epimenia_babai_genome/2021-06-09_MatlockEp_hifiasmhicmode/Ebab_cleaned_matlock_cleaned2.fq /grps2/kmk/Meghan/Epimenia_babai_genome/2021-09-29_ExtractHifi/Ebabai_allhifireads.fa

awk '/^S/{print ">"$2"\n"$3}' hifiasm.asm.hic.p_ctg.gfa | fold > hifiasm.hic.p_ctg.fasta

awk '/^S/{print ">"$2"\n"$3}' hifiasm.asm.hic.hap1.p_ctg.gfa | fold > hifiasm.asm.hic.hap1.p_ctg.fasta
awk '/^S/{print ">"$2"\n"$3}' hifiasm.asm.hic.hap2.p_ctg.gfa | fold > hifiasm.asm.hic.hap2.p_ctg.fasta


