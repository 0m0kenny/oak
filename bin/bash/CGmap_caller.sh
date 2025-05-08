#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=5:00
#SBATCH --constraint=icelake


set -e

module purge; module load bluebear
module load bear-apps/2022a
module load CGmapTools/0.1.2-GCC-11.3.0

#Define variables
bam_file=$1
sample_name=$2
reference_genome=$3
CGmap_file=${sample_name}.CGmap
ATCGmap_file=${sample_name}.ATCGmap
sample_vcf=${sample_name}.vcf
sample_intersect=${sample_name}

#Convert BAM file into input files for CGmap tools
cgmaptools convert bam2cgmap -b ${bam_file} -g ${reference_genome} --rmOverlap -o ${sample_name}


#Carrys out SNP analysis using bayesian method. Slower but more precise.  
cgmaptools snv -m bayes --bayes-dynamicP -i ${ATCGmap_file} -v ${sample_vcf}

#Further analysis can be carried out (differential methylation) could be carried out. Usinf CGMap tools look at intersect, dms, dmr. 
