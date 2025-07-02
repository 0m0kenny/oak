#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> #minumum of 2 days is recommended
#SBATCH --mem=<mem_limit> #244G minimum is recommended
#SBATCH --array=<0- no_of_files> #number of files in filt_allele_in.txt minus 1 e.g 0-1 for 2 cov values
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
module load bear-apps/2020a
module load PLINK/1.9b_6.24-x86_64


echo ""
echo "-------------------------------------------------"

FILENAME_LIST=($(<filt_allele_in))  #input file with the list of vcf files to filter 
VCF_IN=${FILENAME_LIST[${SLURM_ARRAY_TASK_ID}]}
output_name=($(<filt_allele_out)) #outputfile name 
VCF_OUT=${output_name[${SLURM_ARRAY_TASK_ID}]}

echo  "I am array index ${SLURM_ARRAY_TASK_ID} and processing ${VCF_IN}"

out_dir="<path_to_directory_for_output_files>"

echo " indexing $VCF_IN.gz"
bcftools index -t $VCF_IN.gz

#remove snps that have ref c and alt t or ref g and alt a
echo " filtering $VCF_IN.gz"
bcftools view -e '(REF="C" && ALT="T") || (REF="G" && ALT="A")' $VCF_IN.gz -Oz -o $out_dir/$VCF_OUT.vcf.gz



#convert to plink
echo ""
echo "-------------------------------"
echo " converting $VCF_OUT to plink"
plink --vcf $out_dir/$VCF_OUT.vcf.gz  --allow-extra-chr --make-bed --out $out_dir/plink/$VCF_OUT



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


CONDA_ENV_PATH="<path_to_conda_env>/conda_env"  #path to the conda environment with vk phylo installed

# Activate the environment
mamba activate "${CONDA_ENV_PATH}"

echo ""
echo  "creating tree for: ${VCF_OUT}"
vk phylo tree upgma $out_dir/$VCF_OUT.vcf.gz > $out_dir/trees/$VCF_OUT.tree



echo ""
echo "-------------------------------"

echo "done"

