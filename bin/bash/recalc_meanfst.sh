#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#         Recalculating the Mean FST scores from the .weir.fst files       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

bsnp_fst_path=<path_to_the_bsnp.weir.fst_files>
output_file="$fst_path/bsnp_new_means.txt"
> "$output_file" 


for inputfile in $bsnp_fst_path/*.weir.fst
do
  filename=$(basename "$inputfile")
  # Extract the mean FST score, ignoring lines with "nan" and replacing negative values with 0
 
  echo "Recalculating mean from $filename..."
  mean=$(grep -v "nan" "$inputfile" | \
         awk '$3 ~ /^-/ {$3 = 0}1' | awk 'NR > 1 { total += $3; count++ } END { print total / count }')

  echo -e "${filename}\t${mean}" >> "$output_file"
done


cgmap_fst_path=<path_to_the_cgmap.weir.fst_files>
output_file="$fst_path/cgmap_new_means.txt"
> "$output_file" 


for inputfile in $cgmap_fst_path/*.weir.fst
do
  filename=$(basename "$inputfile")
  # Extract the mean FST score, ignoring lines with "nan" and replacing negative values with 0
 
  echo "Recalculating mean from $filename..."
  mean=$(grep -v "nan" "$inputfile" | \
         awk '$3 ~ /^-/ {$3 = 0}1' | awk 'NR > 1 { total += $3; count++ } END { print total / count }')

  echo -e "${filename}\t${mean}" >> "$output_file"
done

