Scripts to create a "knock-off" SilkSlider anlysis written by Kevin M. Kocot. 
Purpose- finds glycine rich sequences following same strategy used in McDougall et al. 2016. [PLoS ONE 11(7) e015928] then runs signalp5 to ID transcripts with signal peptides and then Deep TMHMM tp exclude sequences with transmembrane domain

#script name: find_silk-like_proteins.sh
##INPUT: file named <something>.aa (no periods allowed other than the one before .aa)
##in same directory running it also need to have accessory scripts find_glycine-rich_seqs.py and select_contigs.pl
##FINAL OUT: file named input.aa.glycine-rich.signalp5.deeptmhmm containing glycine-rich sequences with signal peptide and without one or more transmembrane domains

Original SilkSlider github: https://github.com/wwood/SilkSlider
