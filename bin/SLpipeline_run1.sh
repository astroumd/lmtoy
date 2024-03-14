#! /bin/bash
#
#   helper code for the SLpipeline_run.sh obsnum watcher that
#   actually submits the pipeline commands to run on malt and
#   rsync to unity

# trap errors
#set -e

version="SLpipeline_run1: 14-mar-2024"

#--HELP

#Usage: SLpipeline_run1.sh OBSNUM PID  [extra args for SLpipeline.sh]
#
#This script does not allow CLI parameter assignment, but the following ones
#are hardcoded in this script
#

rsync1=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
rsync2=lmtslr_umass_edu@unity:/nese/toltec/dataprod_lmtslr/work_lmt/%s
rsync=$rsync2                   # rsync address, normally unity
debug=0                         # lots extra output

#--HELP

if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

obsnum=$1
pid=$2
shift
shift
extra=$*
echo EXTRA: $extra

#             useful functions
source lmtoy_functions.sh

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

run=$work/SLpipeline.d

printf_red "This is SLpipeline_run1 version $version in $run"


# ensure the rsync directory exists and use a symlink on unity
ssh lmtslr_umass_edu@unity mkdir -p work_lmt/$pid
# run pipeline here and copy TAP accross
SLpipeline.sh obsnum=$obsnum restart=1 tap=1 rsync=$rsync $extra
# local log
echo "$(date +%Y-%m-%dT%H:%M:%S) $obsnum $pid" >> rsync.log
# untap the TAP on unity
ssh lmtslr_umass_edu@unity "(cd work_lmt/$pid; ../do_untap *TAP.tar)"
(cd $WORK_LMT/$pid; mk_summary1.sh > README.html)
# maintaining the last 100...
tail -100 rsync.log | tac > last100.log
mk_last100.sh last100.log > last100.html
rsync -av last100.log last100.html $(printf $rsync lmtoy_run/)

