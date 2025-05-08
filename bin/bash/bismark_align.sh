#!/bin/bash

#SBATCH --ntasks=10
#SBATCH --time=2-00
#SBATCH --qos=castles
#SBATCH --account=cazierj-msc-bioinf

set -e

module purge; module load bluebear
module load bear-apps/2019b/live
module load Bismark/0.22.3-foss-2019b
module load Python/3.7.4-GCCcore-8.3.0 

indexed_genome=$1
mate1=$2
mate2=$3
out=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/Bismark_output/Aligned_trim_02

bismark --bowtie2 -p 10 --parallel 5 --genome ${indexed_genome} -1 ${mate1} -2 ${mate2}  -o ${out}

# Compress mates files
gzip ${mate1}
gzip ${mate2}
