#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> #minumum of 2 days is recommended
#SBATCH --mem=<mem_limit> #244G minimum is recommended
#SBATCH --qos=<your_qos> #e.g. bbdefault
#SBATCH --output=./slurm_logs/slurm-%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<your_email_address>
#SBATCH --job-name=<set_job_name>


set -e

module purge; module load bluebear

module load bear-apps/2022b
module load Miniforge3/24.1.2-0

echo ""
echo "-------------------------------"
echo "setting up conda environment"
eval "$(${EBROOTMINIFORGE3}/bin/conda shell.bash hook)" 
source "${EBROOTMINIFORGE3}/etc/profile.d/mamba.sh"

CONDA_ENV_PATH="<set_path_to_save_your_conda_environment>"

export CONDA_PKGS_DIRS="/scratch/${USER}/conda_pkgs" 

# Create the environment. Only required once.
echo ""
echo "-------------------------------"
echo " creating environment and installing vcf-kit and dependencies"
conda config --add channels bioconda
conda config --add channels conda-forge
mamba create --yes --prefix "${CONDA_ENV_PATH}" \
  danielecook::vcf-kit=0.2.6 \
  "bwa>=0.7.17" \
  "samtools>=1.10" \
  "bcftools>=1.10" \
  "blast>=2.2.31" \
  "muscle=3.8.31" \
  "primer3>=2.5.0" \
  "phylip=3.697"

# changed muscle>=3.8.31" to muscle=3.8.31 to avoid error with newer versions
#added phylip 3.697 to avoid error with vcf-kit
mamba activate "${CONDA_ENV_PATH}"
