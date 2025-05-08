#!/bin/bash
#SBATCH --ntasks=<no_of_task>
#SBATCH --time=<duration>
#SBATCH --constraint=<constraint>
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<email>
#SBATCH --job-name=CGmap_caller
#SBATCH --output=./slurm-logs/CGmap_caller_%j.out

set -e

module purge 
module load bluebear 
module load bear-apps/2021b
module load Bismark/0.24.2-foss-2021b

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                             READ UNIQUE FILES NAME                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#Assign directories to variables. 
target_directory=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out02 # directory where trimmed reads are found
output_unz=../temporary_outs/unzipped_reads # output directory for unzipped reads
output_mates=../temporary_outs/mates # # output directory for generated mates

#Make directory if not exist
mkdir -p "${output_unz}"
mkdir -p "${output_mates}"



##Extract unique fasta file names 
indexed_genome=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/hazel_ref_gen/GCF_901000735.1/fasta_ref
#bismark_genome_preparation --verbose "${indexed_genome}"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~   Processing reads...    ~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
##Extract unique fasta file names 
name=()

for file in "${target_directory}"/*.fq.gz
do
#	echo "Decompressing ${file}..."
    file_name=$(basename "${file}")
	a=$(echo ${file_name} | cut -d'_' -f 1)
	b=$(echo ${file_name} | cut -d'_' -f 2)
	name+=("${a}_${b}")
	## Decompresses fasta files 
	file_name_no_ext="${file_name%.*}"
 	gzip -d -c "${file}" > "${output_unz}/${file_name_no_ext}.fq"
	echo "${file} decompressed!" 
done

#Extracts unique names from the array by assign a values as an associative array. 
declare -A unique_values
for nam in "${name[@]}"; do
    # Add each element as a key to the associative array
    unique_values["$nam"]=1
done

unique_names=("${!unique_values[@]}")
echo "${unique_names[@]}"

echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " MERGE FILES AND BISMARK ALIGNMENT   "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
##Iterates over unique names and fuses all read mates into 2 read files.
for name_short in "${unique_names[@]}"
do
	##Merges reads into two mates reads files
	file_name1="${name_short}_1.fq"
	file_name2="${name_short}_2.fq"
	cat ${output_unz}/${name_short}*_1.fq.fq > ${output_mates}/${file_name1}
	cat ${output_unz}/${name_short}*_2.fq.fq > ${output_mates}/${file_name2}
	wait
	echo "${name_short} mates created, launching bismark job..." 
	##Launches alignment jobs using custom bismark_align script using newly created files
	sbatch bismark_align.sh ${indexed_genome}  ${output_mates}/${file_name1} ${output_mates}/${file_name2}
	echo "${name_short} launched!"
done

 
