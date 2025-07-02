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
module load bear-apps/2020a
module load PLINK/1.9b_6.24-x86_64


echo ""
echo "-------------------------------------------------"

outdir="<path_to_directory_for_output_files>"

mkdir -p "$outdir"

ref_genome='<path_to_ref_genome.fai file>'

echo ""
echo "getting file names"

#save all file names
find results/results \
 -name *.vcf > $outdir/qrob_vcf_paths


cat $outdir/qrob_vcf_paths | while read file; do
  filename=$(basename "$file")

  if [[ "$filename" == *snp* ]]; then
    type="bsnp"
    echo "extracting and changing sample name of $type $filename to main name then Sorting"
    echo $file | sed -E 's#.*/(.*?)_F.*#\1#' > $outdir/name.txt
    bcftools reheader -s $outdir/name.txt "$file" | bcftools sort -Oz -o "$outdir/sorted_${filename}.gz"
    echo "Indexing $type $filename "
    bcftools index -t "$outdir/sorted_${filename}.gz"
  elif [[ "$filename" == *bayes* ]]; then
    type="cgmap"
    echo "Adding contig to $type $filename then extracting and changing sample name and sorting"
    echo $file | sed -E 's#.*/(.*?)_F.*#\1#' > $outdir/name.txt
    bcftools reheader --fai $ref_genome \
    "$file" | bcftools reheader -s $outdir/name.txt | bcftools sort -Oz -o "$outdir/sorted_${filename}.gz"
    echo "Indexing reheadered and sorted $type $filename "
    bcftools index -t "$outdir/sorted_${filename}.gz"
  fi

done


# Extract sample names (no lanes)

find "$outdir" -name "sorted_*" | \
  sed -E 's#.*/sorted_([^_]+)_.*#\1#' | sort -u > "$outdir/sample_names"

#remove duplicate sample names
sort -u "$outdir/sample_names" -o "$outdir/sample_names"


# Create directory for merged files

mkdir -p "$outdir/merged"


# Concatenate by sample
echo ""

cat "$outdir/sample_names" | while read sample; do
  echo "Concatenating bsnp files..."
  bcftools concat "$outdir"/sorted_"$sample"_*_snp.raw.vcf.gz \
    --rm-dups exact -a -Oz -o "$outdir/merged/${sample}_concat_bsnp.vcf.gz"
  echo "Concatenating cgmap files..."
  bcftools concat $outdir/sorted_"$sample"_*_bayes.vcf.gz \
    --rm-dups exact -a -Oz -o "$outdir/merged/${sample}_concat_cgmap.vcf.gz"
done


# Index all concatenated files
echo ""
echo "Indexing concatenated VCFs..."
for vcf in $outdir/merged/*.vcf.gz; do
  echo "Indexing $vcf"
  bcftools index "$vcf"
done


# Merge all into one

echo ""
echo
echo "Merging all bsnp VCFs..."
bcftools merge $outdir/merged/*_concat_bsnp.vcf.gz -Oz -o $outdir/merged/bsnp_merged.vcf.gz

#get the number of SNPs in the merged VCF
echo " no of snp in ${outdir}/merged/bsnp_merged.vcf.gz" >> $outdir/merged/snp_counts
bcftools view -H $outdir/merged/bsnp_merged.vcf.gz | wc -l >> $outdir/merged/snp_counts

echo ""
echo "--------------------------------------------------"
echo "Merging all cgmap (bayes) VCFs..."
bcftools merge $outdir/merged/*_concat_cgmap.vcf.gz -Oz -o $outdir/merged/cgmap_merged.vcf.gz
#get the number of SNPs in the merged VCF
echo " no of snp in $outdir/merged/cgmap_merged.vcf.gz" >> $outdir/merged/snp_counts
bcftools view -H $outdir/merged/cgmap_merged.vcf.gz | wc -l >> $outdir/merged/snp_counts

#convert to plink format
mkdir -p "$outdir/merged/plink"

bsnp_VCF_IN="$outdir/merged/bsnp_merged.vcf.gz"
bsnp_VCF_OUT="$outdir/merged/plink/bsnp_merged_plink.vcf.gz"
cgmap_VCF_IN="$outdir/merged/cgmap_merged.vcf.gz"
cgmap_VCF_OUT="$outdir/merged/plink/cgmap_merged_plink.vcf.gz"

echo ""
echo "-------------------------------------------------"
echo " converting bsnp merged vcf to bed format via plink "
plink --vcf $bsnp_VCF_IN --allow-extra-chr --make-bed --out $bsnp_VCF_OUT

echo ""
echo "-------------------------------------------------"
echo " converting cgmap merged vcf to bed format via plink "
plink --vcf $cgmap_VCF_IN --allow-extra-chr --make-bed --out $cgmap_VCF_OUT



echo "done!"