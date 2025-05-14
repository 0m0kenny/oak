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


echo "calculating fst"

# make sure to have individual files with the list of individuals in each population in a pop folder
#read the vcftools documentation for more information on file prep.

vcf=<path_to_your_filtered_vcf_file>
outputdir=<path_to_your_output_directory>/fst
mkdir -p $outputdir
popdir=<path_to_your_population_directory>

#calculate fst 
vcftools --gzvcf $vcf \
--weir-fst-pop $popdir/pop1 \
--weir-fst-pop $popdir/pop2 \
--out $outputdir/pop1vspop2



#for loop to calculate fst within a population i.e pop1 vs pop1 etc
for pop in $popdir/pop1 \
	$popdir/pop2 \
	$popdir/pop3 \
			
	do
		echo "Processing $pop"
		vcftools --gzvcf $vcf \
		--weir-fst-pop $outputdir/"$pop" \
		--weir-fst-pop $outputdir/"$pop" \
		--out $outdir/"$pop"
	done

echo "done"
