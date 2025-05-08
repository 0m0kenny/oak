#!/bin/bash

#SBATCH --ntasks=50
#SBATCH --time=1:00:00
#SBATCH --qos=bbdefault
#SBATCH --mail-type=ALL 
#SBATCH --account=cazierj-msc-bioinf
#SBATCH --constraint=icelake

set -e

module purge; module load bluebear
module load bear-apps/2019b/live
module load Bismark/0.22.3-foss-2019b
module load Python/3.7.4-GCCcore-8.3.0 

# Genome indexing and preprocessing

echo "Genome indexing...."

bismark_genome_preparation /rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/hazel_ref_gen/GCF_901000735.1/fasta_ref

echo "Genome indexing done!!!"