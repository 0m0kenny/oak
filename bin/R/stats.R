# This examines a subset of the merged bsnp/cgmap vcf to get an idea of the filtering parameters to use
## tutorial from  https://speciationgenomics.github.io/filtering_vcfs/

# load tidyverse package
library(tidyverse)


## get variant quality

bsnp_var_qual <- read_delim("bsnp_subset_stats.vcf.gz.lqual", delim = "\t",
           col_names = c("chr", "pos", "qual"), skip = 1)
cgmap_var_qual <- read_delim("cgmap_subset_stats.vcf.gz.lqual", delim = "\t",
           col_names = c("chr", "pos", "qual"), skip = 1)


### plot quality

bsnp_q <- ggplot(bsnp_var_qual, aes(qual)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
bsnp_q + theme_light()+xlim(0, 200)
cgmap_q <- ggplot(cgmap_var_qual, aes(qual)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
cgmap_q + theme_light()

#unsure why the quality only has 0 and 1 values. not sure what they represent. so will not filter by quality.



## get variant mean depth

bsnp_var_depth <- read_delim("bsnp_subset_stats.vcf.gz.ldepth.mean", delim = "\t",
           col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)
cgmap_var_depth <- read_delim("cgmap_subset_stats.vcf.gz.ldepth.mean", delim = "\t",
           col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)


### plot mean depth

bsnp_dp <- ggplot(bsnp_var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
bsnp_dp + theme_light()
cgmap_dp <- ggplot(cgmap_var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
cgmap_dp + theme_light()

#few variants with extremely high coverage so check depth in more detail


summary(bsnp_var_depth$mean_depth)
summary(cgmap_var_depth$mean_depth)

#most variants have a depth of 7-7.7x(bsnp) and 13-13.9x (cgmap) whereas there are some extreme outliers. redraw our plot to exclude these and get a better idea of the distribution of mean depth.



bsnp_dp <- ggplot(bsnp_var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
bsnp_dp + theme_light() +xlim(0,25)
cgmap_dp <- ggplot(cgmap_var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
cgmap_dp + theme_light() + xlim(0,100)

#We could set our minimum coverage at the 5 and 95% quantiles but we should keep in mind that the more reads that cover a site, the higher confidence our basecall is. 10x is a good rule of thumb as a minimum cutoff for read depth. 

#As the outliers show, some regions clearly have extremely high coverage and this likely reflects mapping/assembly errors and also paralogous or repetitive regions. We want to exclude these as they will bias our analyses. Usually a good rule of thumb is the mean depth x 2 - so set max depth for bsnp 15.3x and cgmap 27.8.



































