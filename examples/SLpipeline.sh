#! /bin/bash
#
#  SLpipeline:      give an obsnum, figure out what kind of observation it is
#                   and delegate the work to whoever it can do
#                   $ADMIT allowed to be present.
#
#
#  Note:   this will currently only reduce one OBSNUM
#
#  @todo   optional PI parameters
#          htaccess

version="SLpipeline: 27-jul-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    exit 0
else
    echo "LMTOY>> $version"
fi

# default input parameters
path=${DATA_LMT:-data_lmt}
work=${WORK_LMT:-.}
obsnum=0
debug=0

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

if [ $obsnum = 0 ]; then
    echo No valid obsnum= given
    exit 1
fi

#             bootstrap
rc=/tmp/lmtoy_${obsnum}.$$.rc
lmtinfo.py $path $obsnum > $rc
source $rc
rm -f $rc

if [ $obspgm = "Cal" ]; then
    echo "Cannot process a 'Cal' obsnum, pick a better obsnum"
    exit 1
fi

if [ $instrument = "SEQ" ]; then
    pdir=$work/$ProjectId/$obsnum
    if [ -d $pdir ]; then
	echo Re-Processing SEQ in $ProjectId/$obsnum for $src
    else
	echo Processing SEQ in $ProjectId/$obsnum for $src
    fi
    mkdir -p $pdir
    lmtoy_reduce.sh pdir=$ProjectId/$obsnum $* > $pdir/lmtoy_$obsnum.log 2>&1    
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    echo Processing RSR for $ProjectId $obsnum
    echo Not Implemented yet
else
    echo Unknown instrument $instrument
fi
