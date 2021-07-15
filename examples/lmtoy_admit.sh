#! /bin/bash
#
#  Running ADMIT within LMTOY
#
#  Because both LMTOY and ADMIT (via casa) have their own python, we need a
#  wrapper that loads ADMIT inside this script.
#


version="lmtoy_admit: 13-jul-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: fits_file(s)"
    echo ""
    exit 0
else
    echo "LMTOY>> $version"
fi


# debug
# set -x
debug=0


ffile=$1
pdir=""

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

#  put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#  exists?
if [ ! -e $ffile ]; then
    echo Warning: fits file $ffile does not exist, no ADMIT processing
    exit 0
fi    

#  see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


if [ -d $LMTOY/admit ]; then
    source $LMTOY/admit/admit_start.sh
    # debug: report version
    admit
elif [ ! -z $ADMIT ]; then
    echo Found no attached $LMTOY/admit, but found $ADMIT, so winging it.
    admit    
else    
    echo Warning: ADMIT was not attached to LMTOY
    exit 0
fi

if [ ! -z $ADMIT ]; then
    echo "LMTOY>> ADMIT post-processing"
    # hacking the admit run:
    apar=$ffile.apar
    touch $apar
    echo 'usePV = False'  >> $apar
    
    runa1 $ffile
fi

