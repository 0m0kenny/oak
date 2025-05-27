
library(heatmaply)
library(dplyr)
library(ggplot2)
library(reshape)
library(tidyr)
library(tidyverse)
options(bitmapType='cairo')
library("vcfR")
library("tibble")



#original fst with all lanes no filtering, computed same pop to same pop too
bsnp_mfst <- read.csv("bsnp_mfst.csv",  row.names = 1)
cgmap_mfst <- read.csv("cgmap_mfst.csv", row.names = 1)



min(bsnp_mfst)
max(bsnp_mfst)
min(cgmap_mfst)
max(cgmap_mfst)



# Convert to long format
long_bsnp_wfst <- bsnp_mfst %>%
  rownames_to_column(var = "Population1") %>%
  pivot_longer(
    cols = -Population1,
    names_to = "Population2",
    values_to = "FST")

long_bsnp_mfst <- cgmap_mfst %>%
  rownames_to_column(var = "Population1") %>%
  pivot_longer(
    cols = -Population1,
    names_to = "Population2",
    values_to = "FST")
 


### clustering for bsnp

# Calculate hierarchical clustering for rows and columns
whc_rows <- hclust(dist(bsnp_mfst))
whc_cols <- hclust(dist(t(bsnp_mfst)))

# Create dendrograms
wrow_dendro <- as.dendrogram(whc_rows)
wcol_dendro <- as.dendrogram(whc_cols)

# Create the heatmap with dendrograms using heatmaply
heatmaply(bsnp_mfst, Rowv = wrow_dendro, Colv = wcol_dendro,
          scale_fill_gradient_fun = ggplot2::scale_fill_gradient(
    limits = c(-0.00, 0.06)
  ), main = "Weir & Cockerham Mean FST (Bis-SNP) (Filtered)",xlab = "Oak Tree Population", ylab = "Oak Tree Population")



# Calculate hierarchical clustering for rows and columns
whc_rows <- hclust(dist(cgmap_mfst))
whc_cols <- hclust(dist(t(cgmap_mfst)))

# Create dendrograms
wrow_dendro <- as.dendrogram(whc_rows)
wcol_dendro <- as.dendrogram(whc_cols)

# Create the heatmap with dendrograms using heatmaply
heatmaply(cgmap_mfst, Rowv = wrow_dendro, Colv = wcol_dendro,
          scale_fill_gradient_fun = ggplot2::scale_fill_gradient(
    limits = c(-0.00, 0.06)
  ), main = "Weir & Cockerham Mean FST (CGmapTools) (Filtered)",xlab = "Oak Tree Population", ylab = "Oak Tree Population")

