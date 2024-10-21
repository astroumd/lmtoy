#!/bin/bash

# @todo add a project= key allow selection of specific project?
# @todo Ask Zhiyuan, is $in required to be data_prod in dvpipe?
#--HELP 
#-------------------------------------------------------------
# Script to prepare and upload projects to LMT Dataverse (14-may-2024)
#
# Command line arguments, key=value.
# Valid arguments are:
#
# dryrun    - If non-zero, just echo commands, don't execute them
# dvname    - Name of the dataverse to upload to. Default: lmtdata
# envfile   - file with API credentials  [$HOME/.ssh/su_prod.env]
# in        - input directory with project/obsnum/*.zip
# out       - output dir, default: 'ready_for_upload'
# overwrite - overwrite the output dir.  
#             If 1, existing directory will be removed. 
#             If anything else , script will exit if $out exists.
# publish   - Upload and publish the data to dataverse after preparation
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
publish=1
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
echo "publish:   $publish"
echo "verbose:   $verbose"

if [ $verbose = 0 ]; then
    gflag=""
else
    gflag="-g"
fi
    

# hardcoded
yaml=$LMTOY/etc/config_prod.yaml


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
mkdir $out

# Probably here, you have to run mk_metadata meta=2

#-------------------------------------------------------------
# Do the work
#-------------------------------------------------------------
# create the YAMLs needed by dataverse in $out
for directory in ${in}/*; do
    cmd="dvpipe -c $yaml -e ${envfile} $gflag lmtslr create_index -d $directory -o ${out}"
    if [ "$verbose" -ne 0 ] || [ $dryrun -ne 0 ] ; then
        echo "$cmd"
    fi
    if [ "$dryrun" -eq 0 ];then
        #dvpipe -c $yaml -e ${envfile} $gflag lmtslr create_index -d $directory -o ${out}
	eval $cmd
    fi
done;

# upload and publish (-b major)
if [ "$publish" -eq 1 ]; then
    for index in ${out}/*.yaml; do
        if [ "$verbose" -ne 0 ] || [ $dryrun -ne 0 ] ; then
            echo "dvpipe -c $yaml -e ${envfile} $gflag dataset upload -a update -b major -i $index -p $dvname"
        fi
        if [ "$dryrun" -eq 0 ];then
            dvpipe -c $yaml -e ${envfile} $gflag dataset upload -a update -b major -i $index -p $dvname
        fi
    done
fi
