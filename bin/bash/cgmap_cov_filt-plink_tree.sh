#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> #minumum of 2 days is recommended
#SBATCH --mem=<mem_limit> #244G minimum is recommended
#SBATCH --array=<0- no of coverage_to_filter_by> #number of files in cov_list.txt minus 1 e.g 0-1 for 2 cov values
#SBATCH --qos=<your_qos> #e.g. bbdefault
#SBATCH --output=./slurm_logs/slurm-%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<your_email_address>
#SBATCH --job-name=<set_job_name>

set -e
module purge; module load bluebear
module load bear-apps/2022b
module load VCFtools/0.1.16-GCC-12.2.0
module load bear-apps/2022b
module load BCFtools/1.17-GCC-12.2.0
module load bear-apps/2022b
module load vcflib/1.0.9-foss-2022b-R-4.3.1
module load bear-apps/2020a
module load PLINK/1.9b_6.24-x86_64


#set coverage parameters
cov_list=($(<file_path_to_list_of_coverage_values_to_filter_by))
cov_input=${cov_list[${SLURM_ARRAY_TASK_ID}]}  

#set input and output directory
dir=<dir_path_to_files>
VCF_IN=$dir/merged/cgmap_merged.vcf.gz
VCF_OUT=cgmap_filt_cov_$cov_input



#make directories
mkdir -p $dir/merged_cov_filt/plink
mkdir -p $dir/merged_cov_filt/trees



echo ""
echo "-------------------------------"


echo  "I am array index ${SLURM_ARRAY_TASK_ID} and filtering ${VCF_IN} with ${cov_input} coverage"

echo ""
echo "-------------------------------"

#filter by coverage
bcftools view -i "MIN(FMT/DP)>=${cov_input}" $VCF_IN -Oz -o $dir/merged_cov_filt/$VCF_OUT.vcf.gz

#convert to plink
echo ""
echo "-------------------------------"
echo " converting $VCF_OUT to plink"
plink --vcf $dir/merged_cov_filt/$VCF_OUT.vcf.gz  --allow-extra-chr --make-bed --out $dir/merged_cov_filt/plink/$VCF_OUT


echo ""
echo "-------------------------------"

echo ""
echo "-------------------------------"
echo " final no of snp after filtering ${VCF_IN} with ${cov_input} coverage"

bcftools view -H $dir/merged_cov_filt/$VCF_OUT.vcf.gz | wc -l


echo ""
echo "-------------------------------"
echo ""
echo "-------------------------------"
echo "activating virtual environment for creating tree"
module purge; module load bluebear
module load bear-apps/2022b
module load Miniforge3/24.1.2-0

eval "$(${EBROOTMINIFORGE3}/bin/conda shell.bash hook)"
source "${EBROOTMINIFORGE3}/etc/profile.d/mamba.sh"


#requires conda environment with vk phylo installed
#make sure to run conda_env.sh to create the environment before running this script
CONDA_ENV_PATH="<path_to_your_conda_environment>"

# Activate the environment
mamba activate "${CONDA_ENV_PATH}"

echo  "creating tree for: ${VCF_OUT}"

vk phylo tree upgma $dir/merged_cov_filt/$VCF_OUT.vcf.gz > $dir/merged_cov_filt/trees/$VCF_OUT.tree



echo ""



echo ""
echo "-------------------------------"

echo "done"
