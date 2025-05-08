#!/bin/bash

#SBATCH --ntasks=10
#SBATCH --time=2-00
#SBATCH --qos=bbdefault
#SBATCH --account=catonim-epi-switch

set -e


module purge
module load  bear-apps/2022b/live
module load  Java/17.0.6
module load SAMtools/1.17-GCC-12.2.0
module load  GATK/4.4.0.0-GCCcore-12.2.0-Java-17

#input requires are (1) bismark bam file, (2) sample name, (3) flow cell (usually found as part of the sample name). 
bsmk_bam_location=$1
sample_name=$2
flow_cell=$3
# sample_dir: where the directory where the picard modified file will be placed.
# sorted_name: directory where the sorted output will placed (supposed to be an output directory) 
# ref_location: location of the reference genome.
sample_dir=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/tools/Pic_Bis_out/${sample_name}
sorted_name=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/tools/Pic_Bis_out/${sample_name}/sorted_${sample_name}
ref_location=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/tools/GCF_901000735.1_CavTom2PMs-1.0_genomic.fa
#recal_file=/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/tools/Pic_Bis_out/${sample_name}_recal.csv



mkdir ${sample_dir}
#Needs picard.jar (see tools in data/). This adds headers to the bam file generated from bismark,
#otherwise BisSNP is not happy
java -Xmx4g -jar picard.jar AddOrReplaceReadGroups \
  I=${bsmk_bam_location} \
  O=${sample_dir} \
  RGID=${sample_name_}_RG \
  RGLB=Unknown \
  RGPL=ILLUMINA \
  RGPU=${flow_cell} \
  RGSM=${sample_name} \
  CREATE_INDEX=true

#This sorts the bam file generated from bismark
samtools sort -o ${sorted_name} ${sample_dir} 

#This indexes the bam file generated from bismark
samtools index ${sorted_name}

#Generates a recalibration file for BisSNP to use. These are optional. Discuss if they are needed.
#java -Xmx10g -jar BisSNP-0.80.jar -R referenceGenome.fa -I sample.withRG.realigned.mdups.bam \
#-T BisulfiteCountCovariates -cov ReadGroupCovariate -cov QualityScoreCovariate \ 
#-cov CycleCovariate -recalFile ${recal_file} -nt 10

#java -Xmx10g -jar BisSNP-0.80.jar -R ${ref_location} -I ${sorted_name}
#-o ${sample_name}_sorted_recal.bam -T BisulfiteTableRecalibration
#-recalFile recalFile_before.csv -maxQ 40

#BisSNP caller. Requires BisSNP-0.80.jar (see tools in data/).
java -Xmx4g -jar BisSNP-0.80.jar -R ${ref_location} \
  -t 10  -T BisulfiteGenotyper -I ${sorted_name} \
  -vfn1 ${sample_name}_cpg.raw.vcf -vfn2 ${sample_name}_snp.raw.vcf


#Generates a summary table and graph for SNP amount found at each chromosome. 
#Produces a summary file 
gatk VariantsToTable \
    -V ${sample_name}_snp.raw.vcf \
    -O ${sample_name}_table.txt \
    -F CHROM -F TYPE

##Produces a counts table with SNPs per chromosome. 
 awk '{ count[$1]++ } END { for (chromosome in count) print chromosome, count[chromosome] }' ${sample_name}_table.txt > ${sample_name}_summary_count.txt



#Trialled analysis to test this works. Deprecated in actual pipeline. 

#samtools sort -o sorted_A3_9319_with_RG.bam A3_9319_with_RG.bam
#samtools index sorted_A3_9319_with_RG.bam
#java -Xmx4g -jar BisSNP-0.71.1.jar -R GCF_901000735.1_CavTom2PMs-1.0_genomic.fa -T BisulfiteGenotyper -I sorted_A3_9319_with_RG.bam -vfn1 A3_9319_cpg.raw.vcf -vfn2 A3_9319_snp.raw.vcf
#java -Xmx4g -jar BisSNP-0.80.jar -R GCF_901000735.1_CavTom2PMs-1.0_genomic.fa -T BisulfiteGenotyper -I sorted_A3_9319_with_RG.bam -vfn1 A3_9319_cpg.raw.vcf -vfn2 A3_9319_snp.raw.vcf
