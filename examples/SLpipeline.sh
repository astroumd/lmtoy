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

version="SLpipeline: 5-jul-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    exit 0
else
    echo "LMTOY>> $version"
fi


# debug
# set -x
debug=0

# input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=0

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

rc=/tmp/lmtoy_${obsnum}.rc
lmtinfo.py $path $obsnum > $rc

source $rc

if [ $obspgm = "cal" ]; then
    echo "Cannot process a 'cal' obsnum, pick a better obsnum"
    exit 1
fi

if [ $instrument = "SEQ" ]; then
    pdir=$ProjectId/$obsnum
    mkdir -p $pdir
    echo Processing SEQ in $ProjectId/$obsnum for $src
    ./lmtoy_reduce.sh pdir=$ProjectId/$obsnum obsnum=$obsnum viewspec=1 viewcube=0 makewf=1 > $pdir/lmtoy_$obsnum.log 2>&1
    # ADMIT processing done by lmtoy_reduce.sh
elif [ $instrument = "RSR" ]; then
    echo Processing RSR for $ProjectId $obsnum
    
else
    echo Unknown instrument $instrument
fi
