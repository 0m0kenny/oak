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

set -e

module purge; module load bluebear 

module load bear-apps/2022b
module load Miniforge3/24.1.2-0

FILENAME_LIST=($(<vcf_list))  # Creates an indexed array from the contents of vcf_list.txt
INPUT_FILENAME=${FILENAME_LIST[${SLURM_ARRAY_TASK_ID}]}  # Look-up using array index
mkdir -p <path_to_output_directory>  # Ensure the output directory exists
output_dir=($(<vcf_list_out)) #make sure this file contains the output filenames
output_filename=${output_dir[${SLURM_ARRAY_TASK_ID}]}

echo ""
echo "-------------------------------"
#set up your environemt where vcf-kit is installed 
# can use the conda_env.sh script provided or create your own
echo "activating virtual environment"

eval "$(${EBROOTMINIFORGE3}/bin/conda shell.bash hook)"
source "${EBROOTMINIFORGE3}/etc/profile.d/mamba.sh"

# Set the path to your conda environment which has vcf-kit installed
# ensure the environment has been created (see conda_env.sh script)
CONDA_ENV_PATH="<path_to_your_conda_environment>"  

# Activate the environment
mamba activate "${CONDA_ENV_PATH}"



echo ""
echo "-------------------------------"
echo echo "I am array index ${SLURM_ARRAY_TASK_ID} and creating tree for: ${INPUT_FILENAME}"

vk phylo tree upgma ${INPUT_FILENAME} > ${output_filename}


echo ""
echo "-------------------------------"
echo "done"