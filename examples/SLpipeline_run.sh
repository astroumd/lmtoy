#! /bin/bash
#
#    an obsnum watcher, which then runs the pipeline
#

# trap errors
set -e

version="SLpipeline: 7-dec-2021"

# source lmtoy_functions.sh

# default input parameters
data=${DATA_LMT:-data_lmt}
work=${WORK_LMT:-.}
debug=0
sleep=10

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do
    export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

run=$work/SLpipeline.d

if [ ! -d $run ]; then
    echo Directory $run does not exist
    exit 0
fi

if [ ! -e $run/data_lmt.log ]; then
    echo Creating $run/data_lmt.log, be patient, this could be some time
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.log
fi

nobs=$(cat $run/data_lmt.log | grep -wv Cal | wc -l)
 on0=$(head -1 $run/data_lmt.log | awk '{print $2}')
 on1=$(tail -1 $run/data_lmt.log | awk '{print $2}')
  d0=$(head -1 $run/data_lmt.log | awk '{print $1}')
  d1=$(tail -1 $run/data_lmt.log | awk '{print $1}')
    
echo OK, $run/data_lmt.log is ready: Found $nobs non-Cal obsnums from $on0 to $on1
echo "DATE-OBS's from run $d0 to $d1"

# looping to find new obsnums (@todo skip Cal)
while [ $sleep -ne 0 ]; do
    echo -n "checking "
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.lag
    on2=$(tail -1 $run/data_lmt.lag | awk '{print $2}')
    echo "$on2"
    if [ $on1 != $on2 ]; then
	tail -1 $run/data_lmt.lag
	echo Found new obsnum=$on2
	SLpipeline.sh obsnum=$on2 rsync=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
	cp $run/data_lmt.lag $run/data_lmt.log
	on1=$on2
    fi
    sleep $sleep
done    
