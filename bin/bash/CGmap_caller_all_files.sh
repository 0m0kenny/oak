
#!/bin/bash

#SBATCH --ntasks=<no_of_task>
#SBATCH --time=<duration>
#SBATCH --constraint=<constraint>
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<email>
#SBATCH --job-name=CGmap_caller
#SBATCH --output=./slurm-logs/CGmap_caller_%j.out

set -e

module purge

module load bear-apps/2022a/
module load CGmapTools/0.1.3-foss-2022a


#the directory containing bismark output files
input_bam_dir="<path_to_bismark_output>"

#output directory
output_cgmap="<path_to_output>"

#reference location
reference_genome="<path_to_reference_genome>"

# Loop through each BAM file in the input directory
for bam_file in ${input_bam_dir}/*.bam
do
    #extracting the sample name from the BAM file name
    sample_name=$(basename "$bam_file" .bam)

    #creates output directory for the current sample if it doesn't exist
    mkdir -p "$output_cgmap/$sample_name"

   #sorting the BAM file by their genomic coordinates
    sorted_bam="${bam_file%.bam}.sorted.bam"
    samtools sort -o "$sorted_bam" "$bam_file"

    #indexing the sorted BAM file
    samtools index "$sorted_bam"

    #converting the sorted BAM file into input files for CGmap tools
    cgmaptools convert bam2cgmap -b "$sorted_bam" -g "$reference_genome" --rmOverlap -o "$output_cgmap/$sample_name"

    #define the paths for the CGmap files and VCF file
    ATCGmap_file="$output_cgmap/$sample_name/${sample_name}.ATCGmap.gz"
    sample_vcf="$output_cgmap/$sample_name/${sample_name}.vcf"

    #carry out SNP analysis using Bayesian method
    cgmaptools snv -m bayes --bayes-dynamicP -i "$ATCGmap_file" -v "$sample_vcf"
done
