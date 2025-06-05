#!/bin/bash
#SBATCH --ntasks=10  #edit sbtach commands according to your needs and HPC configuration
#SBATCH --time=<time_limit> 
#SBATCH --mem=<mem_limit> 
#SBATCH --qos=<your_qos> #e.g. bbdefault
#SBATCH --output=./slurm_logs/slurm-%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=<your_email_address>
#SBATCH --job-name=<set_job_name>

set -e 

module purge; module load bluebear
module load bear-apps/2022a/live
module load bear-apps/2022b/live
module load Java/17.0.6

reference_genome="<path_to_ref_genome_folder>" # the folder where the ref genome is in
reference_name="<ref_genome_filename>"
pipeline_loc="<full_path_to_the_pipeline_location>"

force_flag=$1 #argument when running stript (--force) to delete any existing .dict file


echo "creating dictionary for ${reference_name}"

#if .dict file is not present
if [ ! -f "${reference_genome}/${reference_name%.fa}.dict" ]; then

    java -Xmx4g -jar ${pipeline_loc}/tools/picard.jar CreateSequenceDictionary \
    R=${reference_genome}/${reference_name} \
    TRUNCATE_NAMES_AT_WHITESPACE=true NUM_SEQUENCES=2147483647 VERBOSITY=INFO QUIET=false \
    VALIDATION_STRINGENCY=STRICT COMPRESSION_LEVEL=5 MAX_RECORDS_IN_RAM=500000 CREATE_INDEX=false \
    CREATE_MD5_FILE=false 
#else if it's present and the --force flag exist
elif [ "$force_flag" == "--force" ]; then
    echo "Force flag detected. Deleting existing dictionary: ${reference_name%.fa}.dict"
    rm "${reference_genome}/${reference_name%.fa}.dict"

    echo "recreating dictionary for ${reference_name}"
    java -Xmx4g -jar ${pipeline_loc}/tools/picard.jar CreateSequenceDictionary \
    R=${reference_genome}/${reference_name} \
    TRUNCATE_NAMES_AT_WHITESPACE=true NUM_SEQUENCES=2147483647 VERBOSITY=INFO QUIET=false \
    VALIDATION_STRINGENCY=STRICT COMPRESSION_LEVEL=5 MAX_RECORDS_IN_RAM=500000 CREATE_INDEX=false \
    CREATE_MD5_FILE=false 
else
    echo "Dictionary file already exists at ${reference_genome}/${reference_name%.fa}.dict. Use --force to overwrite."
fi

echo "done"