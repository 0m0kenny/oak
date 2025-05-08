import subprocess

# Full path to the Bismark executable
bismark_executable = "/rds/bear-apps/2019b/EL8-cas/software/Bismark/0.22.3-foss-2019b/bismark"

# Path to the reference genome
genome_path = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/hazel_ref_gen/GCF_901000735.1/GCF_901000735.1_CavTom2PMs-1.0_genomic.fa"

# Paths to mate 1 and mate 2 files
mate1_file = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out01/A3_9319_FKDN230267093-1A_H5LN7DSX7_L4_1.fq.gz"
mate2_file = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out01/A3_9319_FKDN230267093-1A_H5LN7DSX7_L4_2.fq.gz"

# Output directory for Bismark
output_directory = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/Bismark_output"
error_directory = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/Bismark_output"

# SLURM job parameters
job_params = {
    "job_name": "bismark_test",
    "output": "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/data/Bismark_output/",  
    "nodes": 1,
    "tasks_per_node": 4,
    "email": "sxn318@student.bham.ac.uk",  
    "mail_type": "ALL",  
    "time_limit": "1:00:00"  
}

# Bismark command and arguments
bismark_command = [
    bismark_executable,  
    "--genome", genome_path,
    "--output_dir", output_directory,  
    "-1", mate1_file,
    "-2", mate2_file
]

# Combine SLURM parameters and Bismark command
full_command = [
    "sbatch",
    f"--job-name={job_params['job_name']}",
    f"--output={job_params['output']}",
    f"--nodes={job_params['nodes']}",
    f"--ntasks-per-node={job_params['tasks_per_node']}",
    f"--mail-user={job_params['email']}",
    f"--mail-type={job_params['mail_type']}",
    f"--time={job_params['time_limit']}",
    "--wrap", " ".join(bismark_command)
]

# Run the SLURM command
subprocess.run(full_command)

