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

module purge 
module load bluebear 
module load bear-apps/2021b
module load Bismark/0.24.2-foss-2021b

reference_genome="<path_to_ref_genome_folder>" # the folder where the ref genome is in
reference_name="<ref_genome_filename>"
echo ""
echo "creating bismark index"
bismark_genome_preparation --bowtie2 --verbose ${reference_genome} /

echo ""
echo "creating .fai file"
samtools faidx ${reference_genome}/${reference_name}