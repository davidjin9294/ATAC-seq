#!/bin/bash

# Created by: David Jin (zjin25@g.ucla.edu)

# Read in count data file and make sure it exists.
echo "What is the absolute path to the count data file?"
read count_data_file_path
echo '\n'
if [ ! -f "${count_data_file_path}" ]; then
    echo "File does not exist. Exiting."
    exit
fi

# Read in annotation file and make sure it exists.
echo "What is the absolute path to the annotation file?"
read annotation_file_path
echo '\n'
if [ ! -f "${annotation_file_path}" ]; then
    echo "File does not exist. Exiting."
    exit
fi

# Process countdata
read -r paths < "${count_data_file_path}"

# Create a copy of the count data file and store changes in the copy. 
# (This does waste some storage. We can make changes in the original file if that's better)
directory_name=$(dirname "${count_data_file_path}")
base_name=$(basename "${count_data_file_path}")
countFixed_file_name="${base_name%.*}_countFixed.txt"
cp "${count_data_file_path}" ${directory_name}/${countFixed_file_name}


# Initialize array to store the modified names
replace_paths=()
for path in $paths; do
    name=$(basename "$path")
    replace_paths+=( "$name" )
done
new_paths_string=$(echo ${replace_paths[*]} | sed 's/\.bam//g')

# Replace the column name of the count data file copy
sed -i "1s/.*/$new_paths_string/" ${directory_name}/${countFixed_file_name}

# Process annotation file. This is removing the unnecessary information following PeakID surrounded by ().
replace_annot_string=$(head -1 ${annotation_file_path} | sed 's/([^)]*)//g')

# Store change.
sed -i "1s|.*|$replace_annot_string|" ${annotation_file_path} # Using | here as delimiter because / exists in $replace_annot_string

# Make sure the name exists. Start from the second line because the first line is PeakID.
awk 'NR >1 {
  id=$1
  if (length($id) > 255) {
      id=substr(id, 0, 255)
  }
  print id
}' "${annotation_file_path}" | sort > annoted_list_id_temp.txt

awk 'NR >1 {
  id=$1
  if (length($id)>255){
    id=substr(id,0,255)
  }
  print id
}' "${directory_name}/${countFixed_file_name}" | sort > feature_count_id_temp.txt


if diff --speed-large-files annoted_list_id_temp.txt feature_count_id_temp.txt; then
    echo "All ID Matched"
else
    echo "NOT ALL ID Matched"
fi
rm annoted_list_id_temp.txt feature_count_id_temp.txt
