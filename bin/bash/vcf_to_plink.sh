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
module load BCFtools/1.17-GCC-12.2.0
module load bear-apps/2020a
module load PLINK/1.9b_6.24-x86_64

echo " converting cgmap vcf to bed format via plink "

VCF_IN=cgmap_filt.vcf.gz #path to filtered vcf file
VCF_OUT=cgmap_filt_plink.vcf.gz #output path

plink --vcf $VCF_IN --allow-extra-chr --make-bed --out $VCF_OUT

echo "total number of SNPS in $VCF_OUT"
bcftools view -H $VCF_OUT | wc -l

echo ""

echo " converting bsnp vcf to bed format via plink "

VCF_IN=bsnp_filt.vcf.gz
VCF_OUT=bsnp_filt_plink.vcf.gz

plink --vcf $VCF_IN --allow-extra-chr --make-bed --out $VCF_OUT

echo "total number of SNPS in $VCF_OUT"
bcftools view -H $VCF_OUT | wc -l

echo "done"