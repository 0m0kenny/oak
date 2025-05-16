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
module load VCFtools/0.1.16-GCC-12.2.0
module load bear-apps/2022b
module load BCFtools/1.17-GCC-12.2.0
module load bear-apps/2022b
module load vcflib/1.0.9-foss-2022b-R-4.3.1

echo " stats for merged vcf to figure out filtering parameters"

mkdir -p stats

#declare global variables- file paths to the merged vcf files and output files
cgmap_indir="cgmap_files/merged/cgmap_all_merged.vcf.gz"
bsnp_indir="bsnp_files/merged/bsnp_all_merged.vcf.gz"
SUBSET_cgmapVCF=stats/cgmap_merged_subset.vcf.gz
cgmap_OUT=stats/cgmap_subset_stats.vcf.gz
SUBSET_bsnpVCF=stats/bsnp_merged_subset.vcf.gz
bsnp_OUT=stats/bsnp_subset_stats.vcf.gz

echo ""
echo "-------------------------------------------------"
#random sample the vcf file
echo "random sampling 1% of total snp in cgmap merged vcf"
bcftools view $cgmap_indir | vcfrandomsample -r 0.01 > $SUBSET_cgmapVCF

echo "random sampling 1% of total snp in bsnp's merged vcf"
bcftools view $bsnp_indir | vcfrandomsample -r 0.01 > $SUBSET_bsnpVCF


#compress and index subset vcf
# compress vcf
echo ""
echo "-------------------------------------------------"
echo "compressing cgmap subset vcf"
bgzip $SUBSET_cgmapVCF
echo "compressing bsnp subset vcf"
bgzip $SUBSET_bsnpVCF

# index vcf
echo ""
echo "-------------------------------------------------"
echo "indexing cgmap subset vcf"
bcftools index -t $SUBSET_cgmapVCF
echo "indexing bsnp subset vcf"
bcftools index -t $SUBSET_bsnpVCF

#generate data about the subset
echo ""
echo "-------------------------------------------------"
echo "generating data about the subsets"


#get allelic freq for each snp
echo ""
echo "-------------------------------------------------"
echo "getting cgmap subset vcf allelic freq"
vcftools --gzvcf $SUBSET_cgmapVCF --freq2 --out $cgmap_OUT --max-alleles 2
echo "getting bsnp subset vcf allelic freq"
vcftools --gzvcf $SUBSET_bsnpVCF --freq2 --out $bsnp_OUT --max-alleles 2


#get mean depth coverage per site
echo "getting cgmap subset vcf mean depth coverage"
vcftools --gzvcf $SUBSET_cgmapVCF --site-mean-depth --out $cgmap_OUT
echo "getting bsnp subset vcf mean depth coverage"
vcftools --gzvcf $SUBSET_bsnpVCF --site-mean-depth --out $bsnp_OUT

#get site quality
echo "getting cgmap subset vcf site quality"
vcftools --gzvcf $SUBSET_cgmapVCF --site-quality --out $cgmap_OUT
echo "getting bsnp subset vcf site quality"
vcftools --gzvcf $SUBSET_bsnpVCF --site-quality --out $bsnp_OUT

echo "done"
