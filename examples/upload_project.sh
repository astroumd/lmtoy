#!/bin/bash

# @todo add a project= key allow selection of specific project?
# @todo Ask Zhiyuan, is $in required to be data_prod in dvpipe?
#--HELP 
#-------------------------------------------------------------
# Script to prepare and upload projects to LMT Dataverse
#
# Command line arguments, key=value.
# Valid arguments are:
#
# dryrun    - If non-zero, just echo commands, don't execute them
# dvname    - Name of the dataverse to upload to. Default: lmtdata
# envfile   - file with API credentials  [$HOME/.ssh/su_prod.env]
# in        - input directory with project/obsnum/*.tar
# out       - output dir
# overwrite - overwrite the output dir.  
#             If 1, existing directory will be removed. 
#             If anything else , script will exit if $out exists.
# verbose   - If non-zero, echo dvpipe commands before executing
#
#-------------------------------------------------------------

#-------------------------------------------------------------
# Defaults:
#-------------------------------------------------------------
dryrun=0
dvname=lmtdata
envfile=$HOME/.ssh/su_prod.env
in=data_prod  
out=ready_for_upload
overwrite=0
verbose=0
#--HELP

#-------------------------------------------------------------
# simple keyword=value command line parser for bash
#-------------------------------------------------------------
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

for arg in "$@"; do
  export "$arg"
done

#-------------------------------------------------------------
# report
#-------------------------------------------------------------
echo "dryrun:    $dryrun"
echo "envfile:   $envfile"
echo "in:        $in"
echo "out:       $out"
echo "overwrite: $overwrite"
echo "verbose:   $verbose"

#-------------------------------------------------------------
# Error checking
#-------------------------------------------------------------
if [ ! -f "$envfile" ]; then
    echo "#### Error: Authentication file ${envfile} does not exist."
    exit 255
fi

if [ ! -d "$in" ]; then
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

# Probably here, you have to run mk_metadata meta=2

#-------------------------------------------------------------
# Do the work
#-------------------------------------------------------------
# create the YAMLs needed by dataverse in $out
for directory in ${in}/*; do
    if [ "$verbose" -ne 0 ] || [ $dryrun -ne 0 ] ; then
        echo "dvpipe -c config_prod.yaml -e ${envfile} -g lmtslr create_index -d $directory -o ${out} " 
    fi
    if [ "$dryrun" -eq 0 ];then
        dvpipe -c config_prod.yaml -e ${envfile} -g lmtslr create_index -d $directory -o ${out}
    fi
done;

# upload and publish (-b major)
for index in ${out}/*.yaml; do
    if [ "$verbose" -ne 0 ] || [ $dryrun -ne 0 ] ; then
        echo "dvpipe -c config_prod.yaml -e ${envfile} -g dataset upload -a none -b major -i $index -p $dvname"
    fi
    if [ "$dryrun" -eq 0 ];then
        dvpipe -c config_prod.yaml -e ${envfile} -g dataset upload -a none -b major -i $index -p $dvname
    fi
done
