#! /bin/bash
#
#  A simple LMT RSR pipeline in bash.
#  Really should be written in python, but hey, here we go.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#          in the current directory, parameters will be read from it.
#          If it does not exist, it will be created on the first run and you can edit it
#          for subsequent runs
#          If ProjectId is set, this is the subdirectory, within which obsnum is set
#
# There is no good mechanism here to make a new variable depend on re-running a certain task on which it depends
# that's perhaps for a more advanced pipeline
#

version="rsr_pipeline: 22-nov-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    echo ""
    echo "RSR pipeline"
    exit 0
else
    echo "LMTOY>> $version"
fi

source lmtoy_functions.sh

# debug
# set -x
debug=0

# input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=0
obsid=""
newrc=0
pdir=""
badboard=-1     # set to -1 if no board is bad, or pick one 0..5
#            - procedural
admit=1

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do
    export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#             see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${obsnum}.rc
if [ -e $rc ] && [ $newrc = 0 ]; then
    echo "LMTOY>> reading $rc"
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    for arg in $*; do
        echo "$arg" >> $rc
    done
    source ./$rc
    newrc=0
else
    newrc=1
fi


if [ $newrc = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path - not implemented"
else
    echo "LMTOY>> updating"
fi

#             derived parameters (you should not have to edit these)
p_dir=${path}
s_on=${src}_${obsnum}
s_nc=${s_on}.nc


#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

# -----------------------------------------------------------------------------------------------------------------

if [ -e rsr.wf0.pdf ]; then
    first=0
else
    first=1
fi

blanking=rsr.$obsnum.blanking
rfile=rsr.$obsnum.rfile
badlags=rsr.$obsnum.badlags

if [ $first == 1 ]; then
    rsr_blanking $obsnum     > $blanking
    rsr_rfile    $obsnum     > $rfile
    # special case when board0 is bad
    if [ $badboard = 0 ]; then
	for c in 0 1 2 3; do
	    echo "$obsnum $c {0: [(70,80)]}" >> $blanking
	    echo "$obsnum,$c,0"              >> $rfile
	done
    fi

    # note $badlags is created by seed_bad_channels
    
fi


lmtoy_rsr1
