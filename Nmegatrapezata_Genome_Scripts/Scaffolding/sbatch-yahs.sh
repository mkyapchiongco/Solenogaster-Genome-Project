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

SRA='AP212_Hi-C_R'
LABEL='Neom_hic'
BWA='/kmk/scripts/bwa/bwa'
SAMTOOLS=samtools
IN_DIR='/grps2/kmk/2020-08-31_Macrogen_chiton_radula_transcriptoms_other_transcriptomes_and_Hi-C/AP212_Hi-C'
REF='hifiasm.hic.p_ctg.fasta'
FAIDX='$REF.fai'
PREFIX='bwa_index_name'
RAW_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out'
FILT_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/filtered_bam'
FILTER='/kmk/scripts/mapping_pipeline/filter_five_end.pl'
COMBINER='/kmk/scripts/mapping_pipeline/two_read_bam_combiner.pl'
STATS='/kmk/scripts/mapping_pipeline/get_stats.pl'
PICARD='/kmk/scripts/picard/build/libs/picard.jar'
TMP_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/temp'
PAIR_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/paired'
REP_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/duplicated'
REP_LABEL=$LABEL\_rep1
MERGE_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/merged'
MAPQ_FILTER=10
CPU=12
BAM=/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/duplicated/Neom_hic_rep1.bam

export PATH=/kmk/scripts/juicer/scripts/:$PATH
#samtools faidx $REF -o $REF.fai
#/kmk/scripts/yahs/yahs hifiasm.hic.p_ctg.fasta $BAM -e GATC

#(/kmk/scripts/yahs/juicer pre yahs.out.bin yahs.out_scaffolds_final.agp hifiasm.hic.p_ctg.fasta.fai | sort -k2,2d -k6,6d -T ./ --parallel=8 -S32G | awk 'NF' > alignments_sorted.txt.part) && (mv alignments_sorted.txt.part alignments_sorted.txt)

#(java -jar -Xmx32G /kmk/scripts/juicer/scripts/juicer_tools.jar pre alignments_sorted.txt out.hic.part scaffolds_final.chrom.sizes) && (mv out.hic.part out.hic)
#Re-running below on 12/28/22 to see if generation of new out agp file will work for what is going on with making manual edits to final fasta file
#(java -jar -Xmx32G /kmk/scripts/juicer/scripts/juicer_tools.1.9.9_jcuda.0.8.jar pre alignments_sorted.txt out.hic.part scaffolds_final.chrom.sizes) && (mv out.hic.part out.hic)

#Make editable files for JBAT
#/kmk/scripts/yahs/juicer pre -a -o out_JBAT yahs.out.bin yahs.out_scaffolds_final.agp hifiasm.hic.p_ctg.fasta.fai >out_JBAT.log 2>&1

(java -jar -Xmx32G /kmk/scripts/juicer/scripts/juicer_tools.1.9.9_jcuda.0.8.jar pre out_JBAT.txt out_JBAT.hic.part <(cat out_JBAT.log  | grep PRE_C_SIZE | awk '{print $2" "$3}')) && (mv out_JBAT.hic.part out_JBAT.hic)
