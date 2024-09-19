#!/bin/bash

# Created by: David Jin
# email: zjin25@g.ucla.edu
# date = 7/21/2024

# Promp user for the inputs to step 5: featureCounts.sh

echo "What is the absolute path to hold the job messages/error? Make sure you have a slash at the end, aka '/'"
read job_message_path
echo $'\n'

echo "What is the directory under /u/project/arboleda/DATA/ATACseq/ that you want to run featureCount? Make sure you have a slash at the end, aka '/'"
read concat_dir_path
echo $'\n'

#echo "What is the absolute path to the featureCounts directory you created? Make sure you have a slash at the end, aka '/'"
#read feature_count_path
#echo $'\n'
ATAC_path=/u/project/arboleda/DATA/ATACseq/
feature_count_path=${ATAC_path}${concat_dir_path}featureCounts/

#echo "What is the absolute path to the mapped directory you created during mapping&peak calling step? Make sure you have a slash at the end, aka '/'"
#read mapped_path
#echo $'\n'
mapped_path=${ATAC_path}${concat_dir_path}mapped/
#echo "What is the absolute path to the peaks directory you created during mapping&peak calling step? Make sure you have a slash at the end, aka '/'"
#read peaks_path
#echo $'\n'
peaks_path=${ATAC_path}${concat_dir_path}peaks/

echo "Do you want to specify the project name (optional)? Answer 'yes' or 'no'. A default name will be used if answered 'no'"
read specify_name

if [ "${specify_name}" == "yes" ]; then
    # read in input name
    echo "Enter the project name. Make sure you have a slash, aka '/' in the name."
    read input_project_name
    project_name=$(echo "$input_project_name" | tr -d '/')
elif [ "${specify_name}" == "no" ]; then 
    # create default name
    sign="peaks/" 
    name=${peaks_path%${sign}} 
    project_name=$(basename -- ${name})
fi

echo "What is your name? Answer in FirstName-LastName format"
read user_name
echo $'\n'

# Now make a new copy of the template script and insert user inputs
template_location="/u/project/arboleda/DATA/Scripts/User-ATACseq/template-files/template_script_FeatureCounts.sh"

new_file_path="/u/project/arboleda/DATA/Scripts/User-ATACseq/User-ATACseq-FeatureCounts"
current_date=$(date +%Y-%m-%d)

user_script="${new_file_path}/${user_name}_${current_date}_submit_FeatureCounts_array.sh"

cp ${template_location} ${user_script}
# Change permission
chmod u+x,g+x,g+w ${user_script}

# Insert changes (using | because paths contain /)
sed -i "s|{OUTPUT_MESSAGE_PATH}|${job_message_path}|g" ${user_script}
sed -i "s|{FEATURE_COUNT_PATH}|${feature_count_path}|g" ${user_script}
sed -i "s|{MAPPED_PATH}|${mapped_path}|g" ${user_script}
sed -i "s|{PEAKS_PATH}|${peaks_path}|g" ${user_script}
sed -i "s|{PROJECT_NAME}|${project_name}|g" ${user_script}
echo "${user_script} Created"
echo $'\n'
# Submit New Script
job_name=${user_name}_submit_FeatureCounts_array_${current_date}
qsub -N ${job_name} ${user_script}
