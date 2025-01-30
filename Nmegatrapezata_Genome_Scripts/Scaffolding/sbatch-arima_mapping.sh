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

#genome from: /grps2/kmk/Meghan/Neomenia_genome/2022-07-03_NEOM_Hifiasm_2Cells_L3/hifiasm.hic.p_ctg.fasta

SRA='AP212_Hi-C_R'
LABEL='Neom_hic'
BWA='/kmk/scripts/bwa/bwa'
SAMTOOLS=samtools
IN_DIR='/grps2/kmk/2020-08-31_Macrogen_chiton_radula_transcriptoms_other_transcriptomes_and_Hi-C/AP212_Hi-C'
REF='hifiasm.hic.p_ctg.fasta'
FAIDX='$REF.fai'
PREFIX='hifiasm.hic.p_ctg.fasta'
RAW_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out'
FILT_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/filtered_bam'
FILTER='/kmk/scripts/mapping_pipeline/filter_five_end.pl'
COMBINER='/kmk/scripts/mapping_pipeline/two_read_bam_combiner.pl'
STATS='/kmk/scripts/mapping_pipeline/get_stats.pl'
PICARD='/kmk/scripts/picard/build/libs/picard.jar'
TMP_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/temp'
PAIR_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/paired'
REP_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/duplicated'
REP_LABEL=$LABEL\_rep1
MERGE_DIR='/grps2/kmk/Meghan/Neomenia_genome/2022-11-07_NEOM_YAHS/bam_out/merged'
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
#$BWA index -a bwtsw -p $PREFIX $REF

#echo "### Step 1.A: FASTQ to BAM (1st)"
#$BWA mem -t $CPU $REF $IN_DIR/$SRA\1.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_1.bam

#echo "### Step 1.B: FASTQ to BAM (2nd)"
#$BWA mem -t $CPU $REF $IN_DIR/$SRA\2.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_2.bam

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

echo "Finished Mapping Pipeline through Duplicate Removal"
