#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> #minumum of 2 days is recommended
#SBATCH --mem=<mem_limit> #244G minimum is recommended
#SBATCH --array=<0- no of sequencing data> #number of files in input_list.txt minus 1 e.g 0-1 for 2 files
#SBATCH --qos=<your_qos> #e.g. bbdefault
#SBATCH --output=./slurm_logs/slurm-%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<your_email_address>
#SBATCH --job-name=<set_job_name>


FILENAME_LIST=($(<input_list.txt))  # Creates an indexed array from the contents of input_list.txt
INPUT_FILENAME=${FILENAME_LIST[${SLURM_ARRAY_TASK_ID}]}  # Look-up using array index

echo "I am array index ${SLURM_ARRAY_TASK_ID} and am processing file: ${INPUT_FILENAME}"

nextflow run main_hazex_v.2.nf --paired_reads="${INPUT_FILENAME}/*{1,2}.fq.gz" \
--reference_genome="<full_path_to_reference_genome>" \
--reference_name="reference_name" --index_requirement="<0_or_1>" \
--pipeline_loc="<full_path_to_directory_where_pipeline_is_located>" \