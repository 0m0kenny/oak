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

# extract all the snp.raw.vcf from bis-snp a mergelist
echo ""
echo "-------------------------------------------------"
outdir="/bsnp_files"
#create outdirectory to store the results
mkdir -p "$outdir"
find results/results -name *_snp.raw.vcf > "$outdir/bsnp_vcf"
echo "total no of results from bis-snp (make sure this matches the number of files expected!)"
wc -l bsnp_vcf


# need to compress and index the files before merging
echo ""
echo "-------------------------------------------------"
cat $outdir/bsnp_vcf | while read file 
do
filename=$(basename "$file")
echo "compressing $filename"
bgzip -c "$file" > "$outdir/${filename}.gz"
echo "sorting $filename"
bcftools sort "$outdir/${filename}.gz" -Oz -o "$outdir/sorted_${filename}.gz"
echo "indexing $filename"
bcftools index -t "$outdir/sorted_${filename}.gz"
done

#extract the main names from the sorted files without lane numbers
echo ""
echo "-------------------------------------------------"
echo "extract the main names from the sorted files without lane numbers!"
find "$outdir" -name sorted_*.vcf.gz | sed -E 's#.*/sorted_(.*)_L[0-9]\.vcf\.gz#\1#' | sort -u > sample_names


#for loop to find then change sample name to main file name
echo ""
echo "-------------------------------------------------"
echo "creating new directory called sorted2 to store vcfs with changed sample names"
mkdir -p "$outdir/sorted2"

cat $outdir/sample_names | while read file 
do
  echo $file > $outdir/name.txt
  for inputfile in $outdir/sorted_"$file"_*.vcf.gz
  do
    echo "changing $inputfile sample name to $file"
    bcftools reheader -s $outdir/name.txt "$inputfile" -o $outdir/sorted2/$(basename "$inputfile")
  done
done

echo ""
echo "-------------------------------------------------"
echo "creating new directory called merged to store merged vcfs"
mkdir -p "$outdir/merged"

#need to index the sorted2 files first before concatenating

cat $outdir/sample_names | while read file 
do
  for vcf in $outdir/sorted2/sorted_"$file"_*.vcf.gz
  do
    if [ ! -f "$vcf.tbi" ]; then
      echo "Indexing $vcf"
      bcftools index -t "$vcf"
    fi
  done

  # Concatenate the VCF files after ensuring they are indexed
  echo "concatenating $file"
  bcftools concat $outdir/sorted2/sorted_"$file"_*.vcf.gz \
  --rm-dups exact -a -Oz -o $outdir/merged/"$file"_merged.vcf.gz
done

#merge the files into one big file after indexing
cat $outdir/sample_names | while read file
do
  for vcf in $outdir/merged/"$file"_*.vcf.gz
  do
    echo "Indexing $vcf"
    bcftools index "$vcf"
  done
done

#merge the files
bcftools merge $outdir/merged/*.vcf.gz -Oz -o $outdir/merged/bsnp_all_merged.vcf.gz
