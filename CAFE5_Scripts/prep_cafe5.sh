##################################################### CAFE PREP #####################################################
#To Run Cafe you need 1. Ultrametric Tree 2. Counts file of each OG 2*. Can run Interproscan before and have it in the counts file OR can add it later on and have the desc. header for CAFE counts be (null) more on that below. 
#CAFE5 Github https://github.com/hahnlab/CAFE5

######################### 1. Get Ultrametric Tree #########################
#####R8s config file- I used script prep_r8s.py by CAFE5 and modified it to add more dates based on R8s manual.#######
#Config file used- r8s_ctl_File.txt

###RUN R8s

/home/apodomenia/bin/r8s1.81/src/r8s -b -f r8s_ctl_file.txt > r8s_tmp.txt 

tail -n 1 r8s_tmp.txt | cut -c 16- > ultrametric_tree.txt #puts the output into a tree file for input into CAFE5



######################### 2. Get Counts File #########################

#Take Output of OrthoFinder Results/Orthogroups/Orthogroups.GeneCount.tsv to format for CAFE5
	#Need to:
	#Remove the total colum
	#Add Desc to first column and what this column will be (can have it be (null)) and then add the interproscan results to the OGs later
#Got help with https://github.com/davidemms/OrthoFinder/issues/512

awk 'OFS="\t" {$NF=""; print}' Orthogroups.GeneCount.tsv > tmp && awk '{print "(null)""\t"$0}' tmp > cafe.input.tsv && sed -i '1s/(null)/Desc/g' cafe.input.tsv && rm tmp

#Use CafeTutorial file to filter for groups with high copy number variation
# Script Found at- https://github.com/hahnlab/CAFE5
python3 clade_and_size_filter.py -i cafe.input.tsv -o filtered.cafe.input.txt -s 2> filtered.log

##Make sure the names line up with names on tree because OrthoFinder changes them in the output


######################### 2*. INTERPROSCAN #########################
#took the list of OGs that were filtered with the scripts from CAFE tutorial (the final one used for input into CAFE) and made a file of the names 

awk '{print $2, $2}' cafe.input.filtered.named.txt > OGNames_usedcafe.txt #used input for CAFE so only running on OGs that were analyzed
xargs -a OGNames_usedcafe.txt cp -t ../../../Filtered_OGList #ran in OrthoFinder output (unedited_sequences)

#Make sure files have the OG named with the sequence, so changing the heading to have OG Included
##Append OG Name on to the line of each on OG
for FILENAME in *.fa 
do 
awk '/^>/ { print $0 FILENAME; next } { print $0 }' $FILENAME > filename_$FILENAME.txt
sed -i 's/OG/_OG/g' filename_$FILENAME.txt
done

#Get longest Orthologs from each file 
for FILENAME in *.fa.txt
do
awk '/^>/ {if(N>0) printf("\n"); printf("%s\t\t",$0);N++;next;} {printf("%s",$0);} END {if(N>0) printf("\n");}' $FILENAME > $FILENAME"_oneline.txt" #get all on one line 
awk 'length > max_length { max_length = length; longest_line = $0 } END { print longest_line }' $FILENAME"_oneline.txt" > $FILENAME"_Longest.fa" #Print longest line 
sed -i 's/\t/\n/2;P;D;' $FILENAME"_Longest.fa"  #make it two lines again 
done 

rm *_oneline.txt
cat *_Longest.fa > sig_longest_orthologs.fa 
#can delete what you need now

##Ran Interproscan on the longest sequence in the relevant OGs

######################### PROCEED TO RUN CAFE5 #########################