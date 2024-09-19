#!/bin/bash

# Author: Aileen A. Nava, David Jin
# email: Aileennava@ucla.edu, zjin25@g.ucla.edu
# date = 1/2/2024

# Modified by: David Jin
# email: zjin25@g.ucla.edu
# date = 7/21/2024

# purpose:
    #within "ExperimentalDir_concat", this script will:
        #(1) reorganize concat reads into 1 folder called "_RAWconcat" to be able to process with AW atac-seq mapping/peak calling scripts.
        #(2) create a new "sample_pathway_list_reorganize_concat.txt" with updated sample paths after moving/reorganizing to /DATA/ATACseq/
    
# prerequisites:
    # (1) assumes ExperimentalDir_concat was generated with AW concat/fastqc scripts below and permissions have been set to chmod+u+rwx
    #       1st script: 
    #           "/u/project/arboleda/DATA/Scripts/Data-Cleaning/clean_lane_directories_from_nextseq500-550.sh"
    #       2nd to 4th scripts: 
    #           "/u/project/arboleda/angelawe/RNAseq_Scripts/concatenation_scripts/generate_user_submit_concat_array.sh"
    #           "/u/project/arboleda/angelawe/RNAseq_Scripts/concatenation_scripts/concat_array.sh"
    #           "/u/project/arboleda/angelawe/RNAseq_Scripts/concatenation_scripts/qc_concat.sh"

    # (2) assumes ExperimentalDir_concat contains original outputs from running AW's "qc_concat.sh"
    # ExperimentalDir_concat = "/AN007E-MS_Final-Run-corrected_IPSC-ATACseq_concat/" and contains:
    #     folder1: "/AN007E-MS_Final-Run-corrected_IPSC-ATACseq_concat_qc/"
    #     folder2: "/AN007E-MS_Final-Run-corrected_IPSC-ATACseq_concat_r1/"
    #     folder3: "/AN007E-MS_Final-Run-corrected_IPSC-ATACseq_concat_r2/"
    #     file1: "sample_pathway_list.txt"

    # (3) YOU NEED TO BE SITTING IN THIS ExperimentalDir_concat WHEN YOU RUN THIS SCRIPT.
################################################################################################

# Set/Change ExperimentalDir_concat to the actual FullName_of_Concat_Folder
echo "What is the name of the directory with the concatenated read in /u/project/arboleda/DATA/ATACseq/ ? Make sure it ends with a slash, aka '/'"
read ExperimentalDir_concat

ExperimentalDir_concat=$(basename $ExperimentalDir_concat)

# Set absolute paths
current_directory="$(pwd)/"
echo "Current Directory: ${current_directory}"
source_r1="${current_directory}${ExperimentalDir_concat}_r1/"
source_r2="${current_directory}${ExperimentalDir_concat}_r2/"
destination="${current_directory}_RAWconcat/"
output_log="${current_directory}output_log_reorganize_concat_reads.txt"
error_log="${current_directory}error_log_reorganize_concat_reads.txt"

# Count the number of files before organization
before_r1_count=$(find ${source_r1} -type f -name '*_r1.fastq.gz' | wc -l)
before_r2_count=$(find ${source_r2} -type f -name '*_r2.fastq.gz' | wc -l)

# Create the destination directory if it doesn't exist
mkdir -p "${destination}"

# Generate a list of unique sample names
sample_names_r1=$(basename -a $(find ${source_r1} -type f -name '*_r1.fastq.gz') | sed 's/_r1.fastq.gz//' | sort -u)
sample_names_r2=$(basename -a $(find ${source_r2} -type f -name '*_r2.fastq.gz') | sed 's/_r2.fastq.gz//' | sort -u)
all_sample_names=($(echo "${sample_names_r1} ${sample_names_r2}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "List of unique sample names: ${all_sample_names[@]}"

# Move read1 files
for sample_name in "${all_sample_names[@]}"
do
    new_subdir="${destination}/${sample_name}"
    
    echo "Moving read1 files for sample: ${sample_name}"
    echo "New subdirectory: ${new_subdir}"
    
    mkdir -p "${new_subdir}"
    find ${source_r1} -type f -name "${sample_name}_*r1.fastq.gz" -exec mv {} "${new_subdir}/" \; >> "${output_log}" 2>> "${error_log}"
    
    echo "Moved to: ${new_subdir}"
    echo ""
done

# Move read2 files
for sample_name in "${all_sample_names[@]}"
do
    new_subdir="${destination}/${sample_name}"
    
    echo "Moving read2 files for sample: ${sample_name}"
    echo "New subdirectory: ${new_subdir}"
    
    find ${source_r2} -type f -name "${sample_name}_*r2.fastq.gz" -exec mv {} "${new_subdir}/" \; >> "${output_log}" 2>> "${error_log}"
    
    echo "Moved to: ${new_subdir}"
    echo ""
done

# Count the number of files after organization
after_r1_count=$(ls "${destination}"*/*r1.fastq.gz | wc -l)
after_r2_count=$(ls "${destination}"*/*r2.fastq.gz | wc -l)

# Print counts
echo "Number of files before organization (read1): ${before_r1_count}"
echo "Number of files before organization (read2): ${before_r2_count}"
echo "Number of files after organization (read1): ${after_r1_count}"
echo "Number of files after organization (read2): ${after_r2_count}"

# Print names of new subdirectories
echo "New subdirectories in ${destination}:"
ls "${destination}"

# Create the updated sample_pathway_list
sample_pathway_list="${current_directory}sample_pathway_list_reorganized_concat.txt"
echo "Writing all the sample pathways into a .txt"
for dir in ${destination}*
do
    echo "${dir%}/" >> ${sample_pathway_list}
done

total_sample_number=$(wc -l < ${sample_pathway_list})

echo "Total sample number: $total_sample_number"


# Remove source_r1 and source_r2 only if they are empty
if [ -z "$(ls -A ${source_r1})" ]; then
    echo "Removing ${source_r1}" >> "${output_log}" 2>> "${error_log}"
    rm -r "${source_r1}" 2>> "${error_log}"
fi

if [ -z "$(ls -A ${source_r2})" ]; then
    echo "Removing ${source_r2}" >> "${output_log}" 2>> "${error_log}"
    rm -r "${source_r2}" 2>> "${error_log}"
fi

# Print errors, if any
echo "Errors encountered during reorganization:"
cat "${error_log}"


