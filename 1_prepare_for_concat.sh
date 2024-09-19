
#!/bin/bash

#written by Angela Wei, contact angelawei@g.ucla.edu
# Modified by: David Jin (zjin25@g.ucla.edu)
#8 Aug 2023

#READ BEFORE USING
#this is to clean up directories, like 230822_Truseq_QC_IL (where it was sequenced off a nextseq 500/550), where
#1 - it is contained in /u/project/arboleda/DATA/RNAseq
#2 - the subdirectories are in the format "SampleName_L0*", ex from suggested directory CACO2_Vangl2_1_L001_ds.11395257785940fdb28ef933f885f506
#3 - within the subdirectories are 2 fastq.gz files (paired reads) and NOTHING else
	#these reads have the same naming format: "Sample-Name_S*_L*_R*_001.fastq.gz"
#4 - you need to call this script INSIDE the experiment directory in question

#HOW TO USE THIS SCRIPT
#while inside the directory you would like to organize, type the following:
#"bash /u/project/arboleda/DATA/Scripts/Data-Cleaning/clean_lane_directories.sh"
#and then press "enter"
 
current_directory="$( pwd )/"

before_number_of_total_reads=$( ls ./**/*fastq.gz | wc -l )

#slides are denoted by "Sample-Name_S*"
#if there are "spaces" in the sample name, they are denoted by "-"
#ex B7-tet
slide_sign="_S"

#move reads out of the lane dir into experiment folder
#rmdir will only work if the dir is empty
#this loop will only go through subdirectories; it is ok if there are non-directories
for lane_dir in $current_dir*/
do
echo "This is the directory "$lane_dir
cd ${lane_dir}
mv * ..
cd ..
rmdir ${lane_dir}
done

#declare an array to hold all possible read names
#the read names differ from the sample names because the read names have different "S##" 
declare -a possible_read_names

#get possble sample names from the reads
#keep the string in front of the slide number
for read in ${current_directory}*.fastq.gz
do
echo "This is the read path"${read}
read_name=$(basename -- ${read})
simple_read_name=${read_name%$slide_sign*}
echo "This is the simple read name" ${simple_read_name}
possible_read_names+=( "${simple_read_name}" )
echo ""
done
echo "All of the entries in possible_read_names" ${possible_read_names[@]}

#get the unique sample names
declare -a unique_sample_names
unique_sample_names=($(echo "${possible_read_names[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
echo "Unique sample names: "${unique_sample_names[@]}

#make directories that are named for each unique sample
#then move the samples that start with "Sample-Name_*" into the right directory
#add group write permissions to new directories
for sample_name in "${unique_sample_names[@]}"
do
mkdir ${sample_name}
chmod g+w ${sample_name}
mv ${sample_name}_*.fastq.gz $sample_name
done

after_number_of_total_reads=$( ls ./**/*fastq.gz | wc -l )
echo "Number of reads, before/after: "$before_number_of_total_reads $after_number_of_total_reads

echo "Do you want to separate samples into different directories (you should answer yes if you are doing ATACseq with multiple samples)? Answer yes, or no."

read split

# if no, just exit
if [ "$split" == "no" ]; then
    exit
fi

if [ "$split" == "yes"]; then
    # if yes, grep the sample names
    sample_names=""
    for dir in *; do
	if [ -d "$dir" ]; then
            sample_names+="$dir\n"
	fi
    done 
    # get unique names
    names=$(echo -e "$sample_names" | cut -d '-' -f 1 | sort -u)
    echo "Unique sample names found:"$names

    current_dir=$(pwd)
    for sample_name in $names; do
	echo "Creating directory:"${current_dir}_${sample_name}
	mkdir -p ${current_dir}_${sample_name}
	# add group writing permission 
	chmod g+w ${current_dir}_${sample_name}
	# move sample directories into these newly created directories
	mv ${sample_name}-* ${current_dir}_${sample_name}
	echo $'\n'
    done
    echo "Make sure your current directory is empty, then change directory into the parent directory with command 'cd ..'"
    echo "If the current directory is not empty, move the files manually to the desired directories." 
    echo "All the samples have been moved to the directories created above. Remove the empty directories with command 'rmdir {NAME}' if you wish." 
fi

