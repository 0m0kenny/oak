wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20231018.zip 
unzip plink_linux_x86_64_20231018.zip 

export PATH=$PATH:/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data

#input files: test.vcf;  #output files: test.ped; test.map
plink --vcf /rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/A3_9319_1/A3_9319_1_snp.raw.vcf --recode --out A3_9319_1_rawvcf --allow-extra-chr --double-id

head A3_9319_1_rawvcf.map 
#################################################
install.packages("CMplot")

library(data.table)
library(CMplot)
map1 = fread("/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/A3_9319_1_rawvcf.map",header = F)
head(map1)

mm = map1 %>% dplyr::select(SNP = 2,Chromosome=1,Position = 4)
head(mm)

CMplot(mm,plot.type="d",bin.size=1e6,col=c("darkgreen", "yellow", "red"),
       file="tiff",dpi=300,file.output=TRUE, verbose=TRUE)

CMplot(mm,plot.type="d",bin.size=1e6,col=c("darkgreen", "yellow", "red"),
       file="tiff",dpi=300,file.output=FALSE, verbose=TRUE)

################################################################################


