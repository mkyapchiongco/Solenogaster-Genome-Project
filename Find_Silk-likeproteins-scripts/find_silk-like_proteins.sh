#!/bin/bash

# This script and the associated python find_glycine-rich_seqs.py are a simplified knock-off of the SilkSlider pipeline published in McDougall et al. 2016. PLoS ONE 11(7): e015928. 
# See: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0159128
# Abstract: In nature, numerous mechanisms have evolved by which organisms fabricate biological structures with an impressive array of physical characteristics. Some examples of metazoan biological materials include the highly elastic byssal threads by which bivalves attach themselves to rocks, biomineralized structures that form the skeletons of various animals, and spider silks that are renowned for their exceptional strength and elasticity. The remarkable properties of silks, which are perhaps the best studied biological materials, are the result of the highly repetitive, modular, and biased amino acid composition of the proteins that compose them. Interestingly, similar levels of modularity/repetitiveness and similar bias in amino acid compositions have been reported in proteins that are components of structural materials in other organisms, however the exact nature and extent of this similarity, and its functional and evolutionary relevance, is unknown. Here, we investigate this similarity and use sequence features common to silks and other known structural proteins to develop a bioinformatics-based method to identify similar proteins from large-scale transcriptome and whole-genome datasets. We show that a large number of proteins identified using this method have roles in biological material formation throughout the animal kingdom. Despite the similarity in sequence characteristics, most of the silk-like structural proteins (SLSPs) identified in this study appear to have evolved independently and are restricted to a particular animal lineage. Although the exact function of many of these SLSPs is unknown, the apparent independent evolution of proteins with similar sequence characteristics in divergent lineages suggests that these features are important for the assembly of biological materials. The identification of these characteristics enable the generation of testable hypotheses regarding the mechanisms by which these proteins assemble and direct the construction of biological materials with diverse morphologies. The SilkSlider predictor software developed here is available at https://github.com/wwood/SilkSlider.

# Here's what they did:
# 1) Translate to AA
# 2) ORFs that were lacking an N-terminal methionine were removed from the analysis. 
# 3) Removed sequences that did not have a signal peptide using SignalP
# 4) Removed the signal peptide from remaining sequences using SignalP
# 5) Removed sequences that were predicted to have a transmembrane domain by TMHMM
# 6) Used a sliding window algorithm to identify sequences containing at least 25% glycine within an 80 amino acid window. 


for FILENAME in *.aa
do

# Find glycine-rich sequences with at least one 80 bp window that is >25% glycine
python ./find_glycine-rich_seqs.py $FILENAME > $FILENAME".glycine-rich"

# Run signalp on the & filter results to made a fasta file with just
signalp -fasta $FILENAME".glycine-rich"
grep "SP(Sec/SPI)" $FILENAME"_summary.signalp5" | awk '{print $1}' > select_file.txt
./select_contigs.pl -n select_file.txt $FILENAME".glycine-rich" $FILENAME".glycine-rich.signalp5"
rm -rf select_file.txt

# Run DeepTMHMM on output of signalp
# See: https://dtu.biolib.com/DeepTMHMM
# Install with: pip3 install pybiolib
biolib run DTU/DeepTMHMM --fasta $FILENAME".glycine-rich.signalp5"
grep TMhelix ./biolib_results/TMRs.gff3 | awk '{print $1}' > select_file.txt
./select_contigs.pl -n select_file.txt -i $FILENAME".glycine-rich.signalp5" $FILENAME".glycine-rich.signalp5.deeptmhmm"
rm -rf ./biolib_results
rm -rf select_file.txt

done





