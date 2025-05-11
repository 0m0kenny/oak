#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#         Confirming the result output match expected output               #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#finding total no of files expected in results folder
#first extract all filenames in reads directory and subdirectories and store names in a file
echo ""
echo "-----------------------------------------------------------"
echo "getting all file names in the reads directory"
find data/reads/ -name *.fq.gz | cat > reads_names

#count total no of lines which is the total no of files
echo ""
echo "total no of files"
wc -l reads_names

#then count number of files that have '1.fq.gz' and '2.fq.gz' 
#the total number should be equal since they should have read pairs 1 and 2
echo ""
echo "total no of lines in reads names with 1.fq.gz"
grep -c '1.fq.gz' reads_names

echo ""
echo "total no of lines in reads names with 2.fq.gz"
grep -c '2.fq.gz' reads_names



#now do the same for results section but only getting folder names
echo ""
echo "-----------------------------------------------------------"
echo "getting all folder names in results directory"
find results/results/ -type d | cat > results_names

#count no of lines
echo ""
echo "total no of results"
wc -l results_names


#search list of file names to see which is missing
#first get only the filename without readpairs (remove '_1.fq.gz') and links in both files
echo ""
echo "-----------------------------------------------------------"
echo "getting missing results"
awk -F'/' '{ split($NF, a, "_[12]\\.fq\\.gz"); print a[1] }' reads_names > reads_names2
awk -F'/' '{ print $NF }' results_names > results_names2

#find which files are missing in results
grep -Fxv -f results_names2 reads_names2 | cat > missing_results
#remove duplicate names
sort missing_results | uniq > missing_results2

echo "list of files missing in results"
cat missing_results2
