#!/bin/bash

#takes as input a directory where raw reads are stored and lists them all.
directory=${1}
reads_list=${directory}/*.fq

index=0
index_1=1
#obtains list length
list_length=${#reads_list[@]}

#Loops over the list and submits multiple jobs.
while [[ ${index} -lt ${list_length} ]]
do
	# Defines pair ends. 
	pairend1=${reads_list[${index}]}
	pairend2=${reads_list[${index_1}]}

	# Schedule jobs and provide feedback regarding submission
    sbatch reads_quality.sh pairend1 pairend2

    #Keeps track of correct index
    index+=2
    index_1+=2
done