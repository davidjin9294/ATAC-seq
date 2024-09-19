
#!/bin/bash

#author: aileen a. nava, David Jin (zjin25@g.ucla.edu)
#date: 1/12/24
#purpose: this script will visualize the reults from "ExperimentDir_concat_featurecounts.txt.summary"

#notes about script:
    #run this script AFTER requesting interactive session
    #run this script WHILE inside the ATACseq featurecount output folder
        #this should be here "/u/project/arboleda/DATA/ATACseq/ExperimentDir_concat/featureCounts/"


######################################################################################################################

# Get experiment name
echo "What is the concat directory under /u/project/arboleda/DATA/ATACseq/ that has the featureCounts data? Make sure you have a slash at the end, aka '/'"
read concat_dir


current_dir=/u/project/arboleda/DATA/ATACseq/${concat_dir}featureCounts/
experiment_dir=$(dirname -- ${current_dir})
experiment_name=$(basename -- ${experiment_dir})


#call multiqc
source /u/local/Modules/default/init/modules.sh
module load python/3.7.3

source /u/project/arboleda/DATA/software/python_envs/multiqc1.7_python3.7.2/bin/activate

multiqc -n ${experiment_name}_featureCounts_multiQC -o ${current_dir} ${current_dir}*txt.summary

deactivate

chmod g+w *
