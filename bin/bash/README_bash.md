## :leaves: Documentation for each file :leaves:

This is a description of what each script does. STANDALONE can be seen as "wrapper" scripts themselves, which use DEPENDENCY script to carry out their function. 
DEPENDENCY scripts are quite important especially as they allow parallelization with sbatch. 


1) **Reads_quality.sh**: carrys out quality control and trimming of reads passed as arguments. (3) DEPENDENCY

3) **Reads_runner.sh**: orchestrates running of quality control and trimming by launching multiple jobs using extracted reads names. STANDALONE

4) **Bismark_align.sh**: carrys out a sigle genome alignment using Bismark. The reference genome, ordered mates dir, mate1 file, mate2 file are all parameters that need to be passed for this two work. (5) DEPENDENCY  

5) **BS_director.sh**: is a multi-faced scripts that coordinates the creationg of reads mates, followed by launching alignment jobs. Other script required is Bismark_align.sh. (STANDALONE)

6) **BisSNP_caller.sh**: is a script carrying out SNP calling for one BAM file using BisSNP. (STANDALONE)
 
7) **CGmap_caller.sh**: is a script carrying out SNP calling for one BAM file using CGmap. (STANDALONE)
