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


# extract all the .bayes.vcf from results folders
echo ""
echo "-------------------------------------------------"
outdir= "/cgmap_files"

#create outdirectory to store the results
mkdir cgmap_files
mkdir -p cgmap_files/sorted

find results/results -name *_bayes.vcf >  $outdir/cgmap_vcf
echo "total no of results from cgmaptools (make sure this matches the number of files expected!)"
wc -l cgmap_vcf

echo ""
echo "-------------------------------------------------"
cat $outdir/cgmap_vcf | while read file
do
  filename=$(basename "$file")

  # Reheader the gzipped CGmap VCF using contigs from reference genome
  # Note: You need to provide the path to the reference genome indexed FASTA file
  echo "adding contig names to $filename"
  bcftools reheader --fai data/references/<reference_genome>.fa.fai \
  "$file" -o "$outdir/${filename}_withcontig"

  # Compress the CGmap VCF
  echo "compressing $filename"
  bgzip -c "$outdir/${filename}_withcontig" > "$outdir/${filename}_withcontig.gz"

  # Sort the reheadered VCF
  echo "sorting $filename"
  bcftools sort  "$outdir/${filename}_withcontig.gz" -Oz -o "$outdir/sorted/sorted_${filename}_withcontig.gz"

  # Index the sorted file
  echo "indexing $filename"
  tabix -p vcf "$outdir/sorted/sorted_${filename}_withcontig.gz"
done


echo "done"
