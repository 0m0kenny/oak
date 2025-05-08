#!/bin/bash

#SBATCH --ntasks=10
#SBATCH --time=15:00
#SBATCH --qos=bbdefault


set -e

module purge; module load bluebear
module load bear-apps/2021b/live
module load FastQC/0.11.9-Java-11
module load fastp/0.23.2-GCC-11.2.0
#bash script carrying out quality control and trimming on of one paired end read set.


#reads in untrimmed sequences (passed as script parameters). Also keeps only the base name. 
read1_path=$1 # reads argument path to mate read 1
read2_path=$2 # reads argument path to mate read 2
out_path=$3 # specify output directory for trimmed and checked reads.
read1_name=$(basename "${read1_path}") #extract name and extension of the read1 from path
read2_name=$(basename "${read2_path}") #extract name and extension of the read2 from path

#trimms paired sequences. This takes ~45seconds
fastp -i "${read1_path}" -I "${read2_path}" -o "${out_path}/${read1_name}"  -O "${out_path}/${read2_name}" 


#retrieves trimmed sequences
trimmed1="${out_path}/${read1_name}"
trimmed2="${out_path}/${read2_name}"

#conducts QC on trimmed sequences
fastqc "${trimmed1}" -t 10 -o ${trimmed1}
fastqc "${trimmed2}" -t 10 -o ${trimmed2}

