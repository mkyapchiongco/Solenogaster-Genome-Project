#!/bin/bash
#SBATCH --job-name=CAFE5
#SBATCH --mem=200G
#SBATCH -c 16 #cores per task
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -o slurm_output-Trinity.%J
#SBATCH -p highmem
#SBATCH --qos highmem
#SBATCH --mail-type=ALL
#SBATCH --mail-user=


#https://github.com/hahnlab/CAFE5/blob/master/docs/tutorial/tutorial.md

module load mpi/openmpi/intel/4.1.1
module load mpi/openmpi/gcc/4.1.1
module load python/python3/3.9.6shared

#Required Options:
 #  --infile, -i                        Path to tab delimited gene families file to be analyzed - Required for estimation.
  # --tree, -t                  Path to file containing newick formatted tree - Required for estimation.
#dos2unix -ascii InputCafe.txt #run to make sure the .txt file of the gene families are in the correct format
/kmk/scripts/CAFE5/bin/cafe5 -i filtered.cafe.input.txt -t ultrametric_tree.txt -p -e -o BaseOut_ErrorEst
/kmk/scripts/CAFE5/bin/cafe5 -i filtered.cafe.input.txt -t ultrametric_tree.txt -p -k 3 -o Gamma3 ##To use gamma model 
/kmk/scripts/CAFE5/bin/cafe5 -i filtered.cafe.input.txt -t ultrametric_tree.txt -p -k 2 -o Gamma2 #testing gamma rate of 2 
/kmk/scripts/CAFE5/bin/cafe5 -i filtered.cafe.input.txt -t ultrametric_tree.txt -p -k 1 -o Gamma1


##Error Model- Estimate with error model 
scp ./BaseOut_ErrorEst/Base_error_file.txt .


#make sure for running with -e to specify error file there is no spaces ex: -eBase_error_file.txt
/kmk/scripts/CAFE5/bin/cafe5 -t ultrametric_tree.txt -i filtered.cafe.input.txt -p -eBase_error_model.txt -o RunWErrorModel 


##Within each output directory can run to get a list of significant families 
grep "y" Base_family_results.txt > Significant_families.txt
grep "y" Gamma_family_results.txt > Significant_families.txt
awk '$2 < .01 {print $0}' Gamma_family_results.txt > Sig_at_p.01.txt

##Within each output directory can run to get a list of significant families 
echo $'#nexus\nbegin trees;'>Significant_trees.tre
grep "*" Gamma_asr.tre >>Significant_trees.tre #adjust model here either base or gamma
echo "end;">>Significant_trees.tre
