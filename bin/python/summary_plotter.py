#!/usr/bin/python 

import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt 


#txt takes inline argument of summary plot location obtained from BisSNP script and sample name
#Arg2 si sample_name being plotted
txt = str(sys.argv[1])
sample_name = str(sys.argv[2])
csv_save = "labelled_summary.csv"

#Creates csv file from input txt
with open(txt,"r", newline="") as csv_file:
    ln_list = list(csv_file.readlines())
    ln_list.insert(0," ")
    
    with open(csv_save, "w",newline="") as csv_out:
        for line in ln_list:
            str_line = line.strip("\n")
            mod_line = str_line.replace(" ",",")
            print(mod_line, file=csv_out) 

#Reads csv file and creates barplot
df = pd.read_csv(csv_save)
df.columns = ['Chromosomes','Counts']



#Checks for no mutations in chromosomes.
for chrom in ["NC_031855.1","NC_081541.1","NC_081542.1","NC_081543.1","NC_081544.1","NC_081545.1","NC_081546.1","NC_081547.1","NC_081548.1","NC_081549.1","NC_081550.1","NC_081551.1"]:
    if chrom not in list(df["Chromosomes"]):
        df = df._append({"Chromosomes": chrom, "Counts": 0},ignore_index=True)

df["Counts"] = df["Counts"].astype(int)
df["Chromosomes"] = df["Chromosomes"].astype("category")
df= df.sort_values(by="Chromosomes")
df["Chromosomes"] = ['Pltd','Chr 1', 'Chr 2', 'Chr 3', 'Chr 4', 'Chr 5', 'Chr 6', 'Chr 7', 'Chr 8', 'Chr 9', 'Chr 10', 'Chr 11']
print(df)


# Add labels and title 
plt.figure(figsize=(10,10))
sns.barplot(x="Chromosomes", y="Counts", data=df,hue="Counts",palette="viridis")
plt.xlabel('Chromosomes')
plt.ylabel('Counts')
plt.title(f'Boxplot of {sample_name} SNPs Chromosomes Counts')

# Outputs the plot
plt.savefig("SNPs_count.png")