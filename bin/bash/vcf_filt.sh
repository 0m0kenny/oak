#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> 
#SBATCH --mem=<mem_limit> 
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


#set global variables
bsnp_VCF_IN=<path_merged_bsnp_vcf>
bsnp_VCF_OUT=bsnp_filt.vcf.gz

cgmap_VCF_IN=<path_merged_bsnp_vcf>
cgmap_VCF_OUT=cgmap_filt.vcf.gz

# set filters
#can add extra filters here if needed
#QUAL=3
bsnp_MIN_DEPTH=10 #10x is a good rule of thumb as a minimum cutoff for read depth
bsnp_MAX_DEPTH=15.3 #a good rule of thumb is the mean depth x 2


# perform the filtering with vcftools
# vcftools --gzvcf $VCF_IN --minQ $QUAL --min-meanDP $MIN_DEPTH --max-meanDP $MAX_DEPTH  --recode --stdout | gzip -c > \
# $VCF_OUT


echo ""
echo "------------------------------------------------"

#total no of snps in bsnp vcf after filtering"
echo "total no of snps in bsnp vcf before filtering"
bcftools view -H $bsnp_VCF_IN | wc -l

echo "filtering bsnp vcf"
vcftools --gzvcf $bsnp_VCF_IN  --min-meanDP $bsnp_MIN_DEPTH --max-meanDP $bsnp_MAX_DEPTH \
--recode --stdout | gzip -c > $bsnp_VCF_OUT

echo "total no of snps in bsnp vcf after filtering"
bcftools view -H $bsnp_VCF_OUT | wc -l

#do the same for cgmap vcf
echo ""
echo "------------------------------------------------"

#total no of snps in cgmap vcf after filtering"
echo "total no of snps  in cgmap vcf before filtering"
bcftools view -H $cgmap_VCF_IN | wc -l

echo "filtering cgmap vcf"
vcftools --gzvcf $cgmap_VCF_IN  --min-meanDP $cgmap_MIN_DEPTH --max-meanDP $cgmap_MAX_DEPTH \
--recode --stdout | gzip -c > $cgmap_VCF_OUT

#total no of snps in cgmap vcf after filtering"
echo "total no of snps left in cgmap vcf after filtering"
bcftools view -H $cgmap_VCF_OUT | wc -l
echo "done"
