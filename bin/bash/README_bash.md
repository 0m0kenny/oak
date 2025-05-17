## :leaves: Documentation for each file :leaves:

This is a description of what each script does. STANDALONE can be seen as "wrapper" scripts themselves, which use DEPENDENCY script to carry out their function. 
DEPENDENCY scripts are quite important especially as they allow parallelization with sbatch. 


1) **Reads_quality.sh**: carrys out quality control and trimming of reads passed as arguments. (3) DEPENDENCY

3) **Reads_runner.sh**: orchestrates running of quality control and trimming by launching multiple jobs using extracted reads names. STANDALONE

4) **Bismark_align.sh**: carrys out a sigle genome alignment using Bismark. The reference genome, ordered mates dir, mate1 file, mate2 file are all parameters that need to be passed for this two work. (5) DEPENDENCY  

5) **BS_director.sh**: is a multi-faced scripts that coordinates the creationg of reads mates, followed by launching alignment jobs. Other script required is Bismark_align.sh. (STANDALONE)

6) **BisSNP_caller.sh**: is a script carrying out SNP calling for one BAM file using BisSNP. (STANDALONE)
 
7) **CGmap_caller.sh**: is a script carrying out SNP calling for one BAM file using CGmap. (STANDALONE)

8) **confirm_output.sh**: is a script counting total number of results (useful when running multiplejob.sh to confirm all input files ran)

9) **bsnp_merge_lanes.sh**: is a script that concatentates bis-snp '*.snp.raw.vcf' files with multiple lanes into one vcf file then merges all vcfs into one big merged file.

10) **cgmap_contig.sh**: is a script that adds contig info to the cgmap '*_bayes.vcf' files from the reference genome. This is necessary before attempting to index, sort or merge these files.

9) **cgmap_merge.sh**: is a script that concatentates cgmap '*_bayes.vcf' files with multiple lanes into one vcf file then merges all vcfs into one big merged file.

10) **subset_vcf.sh**: is a script that subsets the merged vcf files and extracts site quality, allelic frequency and mean depth coverage for further evaluation in the '../R/stats.Rmd' file. Requires the vcflib package (version 1.0.9).

11) **filter_vcf.sh**: is a script that filters the merged vcf files using PLINK (version 1.9b). You can add more parameters as needed. 

12) **wcfst_matrix.sh**: is a script that calculates fst scores via vcftools (Weir and Cockernam Method) for between population diversity.

13) **extract_fst.sh**: is a script that extracts the mean and weighted fst scores from the slurm logs or the fstlogs if fst calculated locally.

14) **recalc_meanfst.sh**: is a script that recalculates the mean FST score, after replacing negative values with 0.

11) **vcf_to_plink.sh**: is a script that converts the merged vcf files to .bed format via PLINK (version 1.9b). You can add more parameters as needed. This allows for a more efficient use in R.