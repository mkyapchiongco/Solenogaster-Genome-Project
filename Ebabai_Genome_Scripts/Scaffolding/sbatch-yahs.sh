#!/bin/bash
#SBATCH --job-name yahs
#SBATCH --mem=500G
#SBATCH -n 1 #tasks
#SBATCH -N 1 #nodes
#SBATCH -c 16 #number of cores per task
#SBATCH -o slurm_output.%J
#SBATCH -e slurm_error.%J
#SBATCH -p threaded
#SBATCH --qos threaded
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mkyapchiongco@crimson.ua.edu
module load java/1.8.202
module load bio/samtools/1.10
module load python/python3/3.6.5
module load bio/bioinfo-gcc

GENOME=hifiasm.hic.p_ctg.filtered.fasta
BAM=/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/bam_out/duplicated/Epimenia_hic_rep1.bam
#Have to make sure you have the updated juicer tools and make sure that it is softlinked (installation correct on UAHPC as of 10/24/22; if need to do again then follow instructions on Aidan lab github)
#Issues with an error from juicer "No reads in Hi-C contact matrices. This could be because the MAPQ filter is set too high (-q) or because all reads map to the same fragment."
#Made sure to re-dowload yahs to version 2.1.2 https://github.com/c-zhou/yahs/issues/4 and use the newest versions of juciertools.jar and yahs


# for some reason it didnt make an .fai file so 
#samtools faidx $GENOME -o hifiasm.hic.p_ctg.filtered.fasta.fai

#Runs YAHS
#/kmk/scripts/yahs/yahs hifiasm.hic.p_ctg.filtered.fasta $BAM -e GATC #-e denotes the sequence of the restriction enzyme used 

#Convert the HiC Alignment file (BAM file) to a file required by juicer_tools. Uses juicer pre (provided with the yahs software)
#Three arguments are teh alignments of HiC reads to contigs, teh scaffold AGP file and the contig FASTA idnex file
#(/kmk/scripts/yahs/juicer pre yahs.out.bin yahs.out_scaffolds_final.agp hifiasm.hic.p_ctg.filtered.fasta.fai | sort -k2,2d -k6,6d -T ./ --parallel=8 -S32G | awk 'NF' > alignments_sorted.txt.part) && (mv alignments_sorted.txt.part alignments_sorted.txt)

#Generate HiC contact matrix using juicer_tools
#takes the sorted alignment file generated in the step above, the output file name, and the file for scaffold sizes
#The file for scaffold sizes should contain two columns - scaffold name and scaffold size, which can be taken from the first two columns of the log file output by juicer . Code to do so below (takes the fai file and prints out the first two columns to a file called scaffolds_final.chrom.sizes
	#Below what is written in the run_yahs.sh file in /kmk/scripts/yahs/scripts
	## this is an easier way especially when we have >2G scaffolds which need scaling
#cat slurm_error. | grep "PRE_C_SIZE" | cut -d' ' -f2- > scaffolds_final.chrom.sizes

(java -jar -Xmx32G /kmk/scripts/juicer/juicer_tools_1.19.02.jar pre alignments_sorted.txt out.hic.part scaffolds_final.chrom.sizes) && (mv out.hic.part out.hic)

#Generate files for manual curation using JBAT 
#hic-to-contigs.bin (can be replaced with the original BED/BAM file with some sacrifice in running time) and scaffolds_final.agp are the outputs of YaHS
/kmk/scripts/yahs/juicer pre -a -o out_JBAT yahs.out.bin yahs.out_scaffolds_final.agp hifiasm.hic.p_ctg.filtered.fasta.fai >out_JBAT.log 2>&1

#With the output in the out_JBAT folder run juicer pre with out_JBAT.txt file
(java -jar -Xmx32G /kmk/scripts/juicer/scripts/juicer_tools.1.9.9_jcuda.0.8.jar pre out_JBAT.txt out_JBAT.hic.part <(cat out_JBAT.log  | grep PRE_C_SIZE | awk '{print $2" "$3}')) && (mv out_JBAT.hic.part out_JBAT.hic)

#The out_JBAT.hic and out_JBAT.assembly can be loaded into JBAT for editing
