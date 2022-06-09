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

version="rsr_pipeline: 5-may-2021"

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
badboard=""   # set to a comma separated list of bad boards
badcb=""      # set to a comma separated list of (chassis/board) combinations, badcb=2/3,3/5
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
    # anything to check to see from a previous run
    first=0
else
    first=1
fi

blanking=rsr.$obsnum.blanking     # for  rsr_driver
badlags=rsr.$obsnum.badlags       # for  rsr_driver
rfile=rsr.$obsnum.rfile           # for  rsr_sum

if [ $first == 1 ]; then
    # bootstrap  $blanking and $rfile
    rsr_blanking $obsnum     > $blanking
    rsr_rfile    $obsnum     > $rfile
fi

if [ $obsnum != 0 ]; then
    echo "LMTOY>> Processing badboard=$badboard and badcb=$badcb"
    
    if [[ ! -z "$badboard" ]]; then
	echo "# setting badboard=$badboard" >> $blanking
	echo "# setting badboard=$badboard" >> $rfile
	for b in $(echo $badboard | sed 's/,/ /g'); do
	    for c in 0 1 2 3; do
		echo "$obsnum $c {$b: [(70,115)]}" >> $blanking
		echo "$obsnum,$c,$b"               >> $rfile
	    done
	done
    fi
    if [[ ! -z "$badcb" ]]; then
	# badcb needs to be formatted as "c1/b1,c2/b2,....."
	echo "# setting badcb=$badcb" >> $blanking
	echo "# setting badcb=$badcb" >> $rfile
	cbs=$(echo $badcb | sed 's/,/ /g')
	for cb in $cbs; do
	    cb0=( $(echo $cb | sed 's./. .'))
	    c=${cb0[0]}
	    b=${cb0[1]}
	    echo "$obsnum $c {$b: [(70,115)]}" >> $blanking
	    echo "$obsnum,$c,$b"               >> $rfile
	done
    fi
    # note $badlags is created by badlags.py
fi

lmtoy_rsr1
