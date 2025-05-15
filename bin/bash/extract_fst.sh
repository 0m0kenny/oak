#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#         Extracting the Mean and Weighted FST scores from the slurmlogs   #
#         or the fst.log file if calculated locally                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#use the following lines if fst scores calculated via slurm and the slurmlogs are saved in a directory
awk '/Weir and Cockerham mean Fst estimate:/ {print $7}'  <path_to_the_bsnp_slurmlog> \
| cat >> "$fst_path/bsnp_means.txt"
awk '/Weir and Cockerham weighted Fst estimate:/ {print $7}'  <path_to_the_bsnp_slurmlog> \
| cat >> "$fst_path/bsnp_weighted.txt"

awk '/Weir and Cockerham mean Fst estimate:/ {print $7}'  <path_to_the_cgmap_slurmlog> \
| cat >> "$fst_path/cgmap_means.txt"
awk '/Weir and Cockerham weighted Fst estimate:/ {print $7}'  <path_to_the_cgmap_slurmlog> \
| cat >> "$fst_path/cgmap_weighted.txt"


#uncomment the following lines if the fst scores were calculated locally so the fst .log files were saved individually

# bsnp_fst_path=<path_to_the_bsnp_fst_log_files> 

# for inputfile in $bsnp_fst_path/*.log
# do
#   filename=$(basename "$inputfile")
#   # Extract the mean FST score and weighted FST score from individual logfiles
 
#   echo "Extracting mean and weighted fst from $filename..."
#   awk '/Weir and Cockerham mean Fst estimate:/ {print $7}'  <path_to_the_bsnp_slurmlog> \
#   | cat >> "$fst_path/bsnp_means.txt"
#   awk '/Weir and Cockerham weighted Fst estimate:/ {print $7}'  <path_to_the_bsnp_slurmlog> \
#   | cat >> "$fst_path/bsnp_weighted.txt"

# done


# cgmap_fst_path=<path_to_the_cgmap_fst_log_files>


# for inputfile in $cgmap_fst_path/*.log
# do
#   filename=$(basename "$inputfile")

#   # Extract the mean FST score and weighted FST score from individual logfiles
#   echo "Extracting mean and weighted fst from $filename..."

#   awk '/Weir and Cockerham mean Fst estimate:/ {print $7}'  <path_to_the_cgmap_slurmlog> \
#   | cat >> "$fst_path/cgmap_means.txt"
#   awk '/Weir and Cockerham weighted Fst estimate:/ {print $7}'  <path_to_the_cgmap_slurmlog> \
#   | cat >> "$fst_path/cgmap_weighted.txt"
# done

