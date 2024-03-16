#! /bin/bash
#
#    an obsnum watcher, which then runs the SL pipeline
#    alternatives to look into:    inotify   entr

# trap errors
#set -e

version="SLpipeline: 16-mar-2024"

#--HELP

rsync1=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
rsync2=lmtslr_umass_edu@unity:/nese/toltec/dataprod_lmtslr/work_lmt/%s
rsync=$rsync2                   # rsync address, normally unity
dryrun=0                        # dryrun for testing
unity=1                         # not used yet
key="(Science|LineCheck)"       # Science or LineCheck or ???
new=1                           # force a new run
rsr=0                           # not used yet
lmtinfo=1                       # sync local with the official one in $DATA_LMT
data=${DATA_LMT:-data_lmt}      # don't change
work=${WORK_LMT:-.}             # don't change
debug=0                         # lots extra output
sleep=60                        # sleep between check for new data

# This script should run on malt in $WORK_LMT/SLpipeline.d - it will watch for new data coming
# in, and when it matches a criterion, will run the SLpipeline.sh for that obsnum, create the TAP
# and rsync it to the correct directory on unity.
#

#--HELP

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi
#             simple keyword=value command line parser for bash - don't make any changing below
for arg in "$@"; do
  export "$arg"
done

#             useful functions
source lmtoy_functions.sh

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

run=$work/SLpipeline.d

printf_red "This is SLpipeline_run version $version in $run"

if [ ! -d $run ]; then
    echo "Directory $run does not exist"
    exit 0
fi
cd $run

#  force a new run
if [ $new = 1 ]; then
    rm -f $run/data_lmt.log
fi

#  
if [ ! -e $run/data_lmt.log ]; then
    echo Creating $run/data_lmt.log, be patient, this could be some time
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.log
fi

nobs=$(cat $run/data_lmt.log | egrep $key | wc -l)
 on0=$(egrep $key $run/data_lmt.log | head -1 | awk '{print $2}')
 on1=$(egrep $key $run/data_lmt.log | tail -1 | awk '{print $2}')
  d0=$(egrep $key $run/data_lmt.log | head -1 | awk '{print $1}')
  d1=$(egrep $key $run/data_lmt.log | tail -1 | awk '{print $1}')
    
echo "OK, $run/data_lmt.log is ready: Found $nobs $key obsnums from $on0 to $on1"
echo "DATE-OBS's from run $d0 to $d1"
echo "# $(date +%Y-%m-%dT%H:%M:%S) - new run w/ $version" >> rsync.log


# looping to find new Science obsnums 
while [ $sleep -ne 0 ]; do
    ls -ltr $DATA_LMT/ifproc/           | tail -3
    ls -ltr $DATA_LMT/RedshiftChassis1/ | tail -3 
    echo -n "checking at $(lmtoy_date)"
    lmtinfo.py $data | grep ^2 | grep -v failed | sort > $run/data_lmt.lag
    echo ""
    if [ $lmtinfo == 1 ]; then
	cp $run/data_lmt.lag $data/data_lmt.log
    fi
    tail -3 $run/data_lmt.lag
    on2=$(egrep $key $run/data_lmt.lag | tail -1 | awk '{print $2}')
    echo "$on2"
    if [ $on1 != $on2 ]; then
	pid=$(egrep $key $run/data_lmt.lag | tail -1 | awk '{print $7}')
	goal=$(egrep $key $run/data_lmt.lag | tail -1 | awk '{print $4}')
	tail -1 $run/data_lmt.lag
	printf_red Found new obsnum=$on2 pid=$pid
	if [ -e SLpipeline.in ]; then
	    extra=$(grep -v ^# SLpipeline.in)
	else
	    extra=""
	fi
	if [ $goal == "LineCheck" ]; then
	    extra="$extra linecheck=1"
	fi
	echo "Found extra args:   $extra"
	if [ $dryrun = 0 ]; then
	    # ensure the rsync directory exists and use a symlink on unity
	    ssh lmtslr_umass_edu@unity mkdir -p work_lmt/$pid
	    # run pipeline here and copy TAP accross
	    SLpipeline.sh obsnum=$on2 restart=1 tap=1 rsync=$rsync $extra
	    # local log
	    echo "$(date +%Y-%m-%dT%H:%M:%S) $on2 $pid" >> rsync.log
	    # untap the TAP on unity
	    ssh lmtslr_umass_edu@unity "(cd work_lmt/$pid; ../do_untap *TAP.tar)"
	    (cd $WORK_LMT/$pid; mk_summary1.sh > README.html)
	    # maintaining the last 100...
	    tail -100 rsync.log | tac > last100.log
	    mk_last100.sh last100.log > last100.html
	    rsync -av last100.log last100.html $(printf $rsync lmtoy_run/)
	else
	    echo SLpipeline.sh obsnum=$on2 restart=1 rsync=$rsync $extra
	fi
	cp $run/data_lmt.lag $run/data_lmt.log
	on1=$on2
    fi
    sleep $sleep
done    
