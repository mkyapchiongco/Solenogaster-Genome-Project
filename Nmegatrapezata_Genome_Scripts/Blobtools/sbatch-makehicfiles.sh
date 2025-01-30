#!/bin/bash
#SBATCH --job-name=ALLHIC
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

module load python/python3/3.9.6
module load miniconda3/base
module load java/1.7.0

HIC_R1=/grps2/kmk/2020-08-31_Macrogen_chiton_radula_transcriptoms_other_transcriptomes_and_Hi-C/AP212_Hi-C/AP212_Hi-C_R1.fastq.gz
HIC_R2=/grps2/kmk/2020-08-31_Macrogen_chiton_radula_transcriptoms_other_transcriptomes_and_Hi-C/AP212_Hi-C/AP212_Hi-C_R2.fastq.gz

###Make .assembly file using apg2assembly.py from juicebox_scripts
#python /kmk/scripts/juicebox_scripts/juicebox_scripts/agp2assembly.py groups.agp groups.assembly

###Make .hic Files. Two ways to do this, because we used Diploid mode we did not do the pruning step, method 1 using prune.bam to make the file. So we are using Method II 
##Method 2:Re-mapping Hi-C reads uisng choromap

#conda activate /grps2/kmk/Meghan/.chromap

## build index
#chromap -i -r edited_out_JBAT.FINAL.filtered.fa -o index

## alignment
#chromap --preset hic -x index -r edited_out_JBAT.FINAL.filtered.fa -1 $HIC_R1 -2 $HIC_R2 -o aln.pairs

#conda deactivate 

## Convert .pair file to merged_nodups.txt formats
#grep -v '#' aln.pairs | \
 # awk '{if($6!="+") $6=16; else $6=0; if($7!="+") $7=16; else $7=0} \
  #$2<=$4{print $6, $2, $3, 0, $7, $4, $5, 1, "1 - - 1  - - -" } \
 # $4<$2{print $7, $4, $5, 0, $6, $2, $3, 1, "1 - - 1  - - -" }' > out.links.txt

## creates a .hic file 
bash /kmk/scripts/3d-dna/visualize/run-assembly-visualizer.sh -p false edited_out_JBAT.FINAL.filtered.fa out.links.txt

#this is not working for some reason. No idea why. Not sure next steps 
