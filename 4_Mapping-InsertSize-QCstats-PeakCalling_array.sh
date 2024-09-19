#!/bin/bash

# Created by: David Jin
# email: zjin25@g.ucla.edu
# date = 7/21/2024

# Promp user for the inputs to step 4: Mapping-InsertSize-QCstats-PeakCalling_array.sh

echo "What is the concat directory under /u/project/arboleda/DATA/ATACseq/ are you running mapping and peak calling? Make sure you have a slash at the end, aka'/'"
read directory
echo $'\n'
output_path=/u/project/arboleda/DATA/ATACseq/${directory}

echo "What is the absolute path to hold the job messages/error? Make sure you have a slash at the end, aka '/'"
read job_message_path
echo $'\n'

echo "How many jobs are you running? Make sure the input is an integer. If you are not sure, try wc -l sample_pathway_list_reorganized_concat.txt"
read num_of_job
echo $'\n'

#echo "What is the absolute path to hold the ATAC-seq output files? Make sure you have a slash at the end, aka'/'"
#read output_path
#echo $'\n'

echo "What is your read length? Check multiqc report if you are not sure"
read read_length
echo $'\n'

echo "What is your name? Answer in FirstName-LastName format"
read user_name
echo $'\n'

# Now make a new copy of the template script and insert user inputs
template_location="/u/project/arboleda/DATA/Scripts/User-ATACseq/template-files/template_script_Mapping-InsertSize-QCstats-PeakCalling_array.sh"

new_file_path="/u/project/arboleda/DATA/Scripts/User-ATACseq/User-ATACseq-ReadMapping-PeakCalling"
current_date=$(date +%Y-%m-%d)

user_script="${new_file_path}/${user_name}_${current_date}_submit_Mapping-insertSize-QCstats-PeakCalling_array.sh"

cp ${template_location} ${user_script}
# Change permission
chmod u+x,g+x,g+w ${user_script}

# Insert changes (using | because paths contain /)
sed -i "s|{OUTPUT_MESSAGE_PATH}|${job_message_path}|g" ${user_script}
sed -i "s/{NUM_OF_JOBS}/${num_of_job}/g" ${user_script}
sed -i "s|{ATAC_SEQ_OUTPUT_PATH}|${output_path}|g" ${user_script}
sed -i "s/{READ_LENGTH}/${read_length}/g" ${user_script}
echo "${user_script} Created"
echo $'\n'

# Submit New Script
job_name=${user_name}_submit_Mapping-insertSize-QCstats-PeakCalling_array_${current_date}
qsub -N ${job_name} ${user_script}
