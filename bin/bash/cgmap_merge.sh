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



cd cgmap_files
echo ""
echo "-------------------------------------------------"
outdir="sorted/"
mkdir -p "$outdir/sorted2"

#extract the main names from the sorted files without lane numbers
echo ""
echo "-------------------------------------------------"
echo "extracting the main names from the sorted files without lane numbers!"
find "$outdir" -name sorted_*.gz | sed -E 's#.*/sorted_(.*)_L[0-9]\.vcf\.gz#\1#' | sort -u > sample_names


#change sample names of to main file name
echo ""
echo "-------------------------------------------------"
cat sample_names | while read file 
do
  echo $file > name.txt
  for inputfile in $outdir/sorted_"$file"_*.vcf_withcontig.gz
  do
	  echo "changing sample name of  $inputfile"
    bcftools reheader -s name.txt "$inputfile" -o $outdir/sorted2/$(basename "$inputfile")
  done
done

#index and concatenate lanes
echo ""
echo "-------------------------------------------------"
mkdir -p merged
cat sample_names | while read file 
do
  for vcf in "$outdir/sorted2/sorted_"$file"_*.vcf_withcontig.gz"
  do
    echo "Indexing $vcf"
    bcftools index -t "$vcf"
  done
  echo "Concatenating $file"
  bcftools concat "$outdir/sorted2/sorted_"$file"_*.vcf_withcontig.gz" \
  --rm-dups exact -a -Oz -o merged/"$file"_merged.vcf.gz
done

#indexing the new files
echo ""
echo "-------------------------------------------------"
cat sample_names | while read file
do
  for vcf in merged/"$file"_*.vcf.gz
  do
    echo "Indexing $vcf"
    bcftools index "$vcf"
  done
done

#merge the files into one big merge
echo ""
echo "-------------------------------------------------"
echo "merging the files into one vcf"

bcftools merge merged/*.vcf.gz -Oz -o merged/cgmap_all_merged.vcf.gz




echo "done"
