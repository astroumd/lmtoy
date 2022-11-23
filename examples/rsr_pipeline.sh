#! /bin/bash
#
#  A simple LMT RSR pipeline in bash.
#
#  Note: this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#        in the current directory, parameters will be read from it.
#        If it does not exist, it will be created on the first run and you can edit 
#        it for subsequent runs
#        If ProjectId is set, this is the subdirectory, within which obsnum is set
#
#

version="rsr_pipeline: 10-oct-2022"

echo "LMTOY>> $version"

#--HELP   
# input parameters (only obsnum is required)
#            - start or restart
obsnum=0
obsid=""
newrc=0
pdir=""
path=${DATA_LMT:-data_lmt}

xlines=""     # set to a comma separated list of freq,dfreq pairs where strong lines are
badboard=""   # set to a comma separated list of bad boards
badcb=""      # set to a comma separated list of (chassis/board) combinations, badcb=2/3,3/5
#            - procedural
admit=0
#            - debug
debug=0
#--HELP

if [ -z $1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in "$@"; do
  export "$arg"
done

# 
source lmtoy_functions.sh

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
    for arg in "$@"; do
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

blanking=rsr.$obsnum.blanking     # for  rsr_sum    - produced by rsr_blanking
badlags=rsr.$obsnum.badlags       # for  rsr_xxx    - produced by badlags.py
rfile=rsr.$obsnum.rfile           # for  rsr_driver - produced by rsr_rfile

if [ $first == 1 ]; then
    # bootstrap  $blanking and $rfile; these are just commented lines w/ examples
    rsr_blanking $obsnum     > $blanking
    rsr_rfile    $obsnum     > $rfile
fi

if [ $obsnum != 0 ]; then
    echo "LMTOY>> Processing badboard=$badboard and badcb=$badcb"

    # should deprecate badboard <--------------------------------------------  deprecate?
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

#             redo CLI again
for arg in "$@"; do
  export "$arg"
done

lmtoy_rsr1
