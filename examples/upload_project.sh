#!/bin/bash 

#-------------------------------------------------------------
# Script to prepare and upload projects to LMT Dataverse
#
# Command line arguments, key=value.
# Valid arguments are:
#
# envfile  - file with API credentials
# in - input directory with project/obsnum/*.tar
# out - output dir
# overwrite - overwrite the output dir.  
#             If 1, existing directory will be removed. 
#             If anything else , script will exit if $out exists.
# verbose  - If non-zero, echo dvpipe commands before executing
# @TODO add a project= key allow selection of specific project?
#-------------------------------------------------------------

#-------------------------------------------------------------
# Defaults:
#-------------------------------------------------------------
envfile=su_prod.env
in=data_prod  # Ask Zhiyuan, this may be required to be data_prod in dvpipe
out=ready_for_upload
overwrite=0
verbose=0

#-------------------------------------------------------------
# simple keyword=value command line parser for bash
#-------------------------------------------------------------
for arg in "$@"; do
  export "$arg"
done

#-------------------------------------------------------------
# report
#-------------------------------------------------------------
echo "envfile:  $envfile"
echo "in:       $in"
echo "out:      $out"
echo "overwrite: $overwrite"
echo "verbose:  $verbose"

#-------------------------------------------------------------
# Error checking
#-------------------------------------------------------------
if [ ! -f "$envfile" ]; then
    echo "#### Error: Authentication file ${envfile} does not exist."
    exit 255
fi

if [ ! -f "$in" ]; then
    echo "#### Error: Input directory ${in} does not exist."
    exit 255
fi

if [ "$overwrite" -eq 1 ]; then 
    /bin/rm -rf $out
fi
if [ -d "$out" ]; then
    echo "#### Error: $out exists. Use 'overwrite=1' to automatically remove it"
    exit 255
fi

#-------------------------------------------------------------
# Do the work
#-------------------------------------------------------------
# create the YAMLs needed by dataverse in $out
for directory in ${in}/*; do
    if [ "$verbose" -ne 0 ]; then
        echo "dvpipe -c config_prod.yaml -e ${envfile} -g lmtslr create_index -d $directory -o ${out}"
    fi
    echo dvpipe -c config_prod.yaml -e ${envfile} -g lmtslr create_index -d $directory -o ${out}
done;

# upload and publish (-b major)
for index in ${out}/*.yaml; do
    if [ "$verbose" -ne 0 ]; then
        echo "dvpipe -c config_prod.yaml -e ${envfile} -g dataset upload -a none -b major -i $index -p lmtdata"
    fi
    echo dvpipe -c config_prod.yaml -e ${envfile} -g dataset upload -a none -b major -i $index -p lmtdata
done
