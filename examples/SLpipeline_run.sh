#! /bin/bash
#
#    an obsnum watcher, which then runs the pipeline
#

# trap errors
#set -e

version="SLpipeline: 27-apr-2022"

rsync1=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
rsync2=lmtslr_umass_edu@unity:/nese/toltec/dataprod_lmtslr/work_lmt/%s
rsync=$rsync2
dryrun=0
key=Science
new=1
rsr=0

function printf_red {
    # could also use the tput command?
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    echo -e "${RED}$*${NC}"
}

# source lmtoy_functions.sh - not needed (yet)

# default input parameters
data=${DATA_LMT:-data_lmt}
work=${WORK_LMT:-.}
debug=0
sleep=60

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

#  force a new run
if [ $new = 1 ]; then
    rm -f $run/data_lmt.log
fi

#  
if [ ! -e $run/data_lmt.log ]; then
    echo Creating $run/data_lmt.log, be patient, this could be some time
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.log
fi

nobs=$(cat $run/data_lmt.log | grep $key | wc -l)
 on0=$(grep $key $run/data_lmt.log | head -1 | awk '{print $2}')
 on1=$(grep $key $run/data_lmt.log | tail -1 | awk '{print $2}')
  d0=$(grep $key $run/data_lmt.log | head -1 | awk '{print $1}')
  d1=$(grep $key $run/data_lmt.log | tail -1 | awk '{print $1}')
    
echo "OK, $run/data_lmt.log is ready: Found $nobs $key obsnums from $on0 to $on1"
echo "DATE-OBS's from run $d0 to $d1"

# looping to find new Science obsnums 
while [ $sleep -ne 0 ]; do
    ls -ltr $DATA_LMT/ifproc/           | tail -3
    ls -ltr $DATA_LMT/RedshiftChassis1/ | tail -3 
    echo -n "checking "
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.lag
    echo ""
    tail -3 $run/data_lmt.lag
    on2=$(grep $key $run/data_lmt.lag | tail -1 | awk '{print $2}')
    echo "$on2"
    if [ $on1 != $on2 ]; then
	tail -1 $run/data_lmt.lag
	printf_red Found new obsnum=$on2
	if [ -e SLpipeline.in ]; then
	    extra=$(grep -v ^# SLpipeline.in)
	else
	    extra=""
	fi
	echo "Found extra args:   $extra"
	if [ $dryrun = 0 ]; then
	    # @todo   ensure the rsync directory exists
	    SLpipeline.sh obsnum=$on2 restart=1 tap=1 rsync=$rsync $extra
	    source $WORK_LMT/*/$on2/lmtoy_${on2}.rc
	    (cd $ProjectId; mk_summary1.sh > README.html)
	else
	    echo SLpipeline.sh obsnum=$on2 restart=1 rsync=$rsync $extra
	fi
	cp $run/data_lmt.lag $run/data_lmt.log
	on1=$on2
    fi
    sleep $sleep
done    
