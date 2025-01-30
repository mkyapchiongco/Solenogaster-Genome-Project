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

#Load relevant modules 

module load java/1.8.202
module load bio/samtools/1.10
module load python/python3/3.6.5
module load bio/bioinfo-gcc

#This script uses the Arima Hi-C mapping pipeline for input into the YAHS software for genome scaffolding. https://github.com/ArimaGenomics/mapping_pipeline/blob/master/01_mapping_arima.sh
#obtain scripts used in this pipeline from Arima github here: https://github.com/ArimaGenomics/mapping_pipeline 
#GENOME=/grps2/kmk/Meghan/Epimenia_babai_genome/2022-04-29_Epimenia_phasedassebmly_nohap_Blobtools/hifiasm.hic.p_ctg.filtered.fasta
SRA='E_babai_Hi-C_R' #Basename of Hi-C fastq files, Ex: Mine are E_babai_Hi-C_R1 and E_babai_Hi-C_R2, script below $SRA\1.fastq.gz so it will label it correctly.
LABEL='Epimenia_hic' #overall experiment name
BWA='/kmk/scripts/bwa/bwa' #bwa software directory
SAMTOOLS=samtools #samtools software directory
IN_DIR='/grps2/kmk/2020-10-07_Macrogen_Hi-C_dragonfy_nuc_and_mt_and_radula_transcritpomes' #path to gzipped fastq files
REF='hifiasm.hic.p_ctg.filtered.fasta' #path to reference sequences.fa (your assembly)
FAIDX='$REF.fai' #leave this as is
PREFIX='hifiasm.hic.p_ctg.filtered.fasta' #bwa index file name
RAW_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/bam_out' #path to write out bams. mdkir directory in advance and give path or have script mkdir
FILT_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/bam_out/filtered_bam' #path to write out filtered bams 
FILTER='/kmk/scripts/mapping_pipeline/filter_five_end.pl' #path to the filter_five_end.pl script Arima script 
COMBINER='/kmk/scripts/mapping_pipeline/two_read_bam_combiner.pl' #path to two_read_bam_combiner.pl Arima script 
STATS='/kmk/scripts/mapping_pipeline/get_stats.pl' #path to the get_stats.pl script from Arima 
PICARD='/kmk/scripts/picard/build/libs/picard.jar' #picard jar file location
TMP_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/temp' #path to write out temporary files 
PAIR_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/22023-03-30_Ebab_YAHS/bam_out/paired' #path to write out paired bams 
REP_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/bam_out/duplicated' #path to write out duplicated files 
REP_LABEL=$LABEL\_rep1 #Do not need unless you have replicates of the Hi-C data 
MERGE_DIR='/grps2/kmk/Meghan/Epimenia_babai_genome/2023-03-30_Ebab_YAHS/bam_out/merged' #path to final merged alignments for any replicates. 
MAPQ_FILTER=10
CPU=12

echo "### Step 0: Check output directories exist & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR

#echo "### Step 0: Index reference" # Run only once! Skip this step if you have already generated BWA index files
$BWA index -a bwtsw -p $PREFIX $REF

#echo "### Step 1.A: FASTQ to BAM (1st)"
$BWA mem -t $CPU $REF $IN_DIR/$SRA\1.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_1.bam

#echo "### Step 1.B: FASTQ to BAM (2nd)"
$BWA mem -t $CPU $REF $IN_DIR/$SRA\2.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_2.bam

#echo "### Step 2.A: Filter 5' end (1st)"
$SAMTOOLS view -h $RAW_DIR/$SRA\_1.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_1.bam

#echo "### Step 2.B: Filter 5' end (2nd)"
$SAMTOOLS view -h $RAW_DIR/$SRA\_2.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_2.bam

echo "### Step 3A: Pair reads & mapping quality filter"
perl $COMBINER $FILT_DIR/$SRA\_1.bam $FILT_DIR/$SRA\_2.bam $SAMTOOLS $MAPQ_FILTER | $SAMTOOLS view -bS -t $FAIDX - | $SAMTOOLS sort -@ $CPU -o $TMP_DIR/$SRA.bam -

echo "### Step 3.B: Add read group"
java -Xmx4G -Djava.io.tmpdir=temp/ -jar $PICARD AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none

echo "### Step 4: Mark duplicates"
java -Xmx30G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp/ -jar $PICARD MarkDuplicates INPUT=$PAIR_DIR/$SRA.bam OUTPUT=$REP_DIR/$REP_LABEL.bam METRICS_FILE=$REP_DIR/metrics.$REP_LABEL.txt TMP_DIR=$TMP_DIR ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE

$SAMTOOLS index $REP_DIR/$REP_LABEL.bam

perl $STATS $REP_DIR/$REP_LABEL.bam > $REP_DIR/$REP_LABEL.bam.stats

echo "Finished Mapping Pipeline through Duplicate Removal
