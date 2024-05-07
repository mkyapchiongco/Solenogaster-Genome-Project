#!/bin/bash
#Downloaded domamins from- https://www.ebi.ac.uk/interpro/entry/pfam/PF00046/entry_alignments/?type=

#Now build an hmm database for the downloaded alignment
hmmbuild PF00046_uniprot.hmm PF00046.alignment.uniprot
/home/scutopus/bin/easel/miniapps/esl-sfetch --index augustus.hints.aa.fasta #needs to be indexed for extracting sequences 
hmmsearch --tblout myhits.tbl PF00046_uniprot.hmm augustus.hints.aa.fasta #want tabular output so we can extract the sequences

#Extract sequences
grep -v "^#" myhits.tbl > notags_myhits.tbl #output of hmmsearch has # before lines so remove 
awk '{print $1}' notags_myhits.tbl > hitlist.txt #print just first line of the file to get a list of hits
/home/scutopus/bin/easel/miniapps/esl-sfetch -f augustus.hints.aa.fasta hitlist.txt > myhits.fa #extract hits from file

#http://cryptogenomicon.org/extracting-hmmer-results-to-sequence-files-easel-miniapplications.html
