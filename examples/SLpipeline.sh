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
#          htaccess control ?
#          option to have a data+time ID in the name, by default it should be blank

version="SLpipeline: 11-oct-2021"

echo "LMTOY>> $version"
if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    exit 0
fi

# default input parameters
path=${DATA_LMT:-data_lmt}
work=${WORK_LMT:-.}
obsnum=0
debug=0
restart=0
tar=0

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

if [ $obsnum = 0 ]; then
    echo No valid obsnum found
    exit 1
fi


if [ "$obspgm" = "Cal" ]; then
    echo "Cannot process a 'Cal' obsnum, pick a better obsnum"
    exit 1
fi

pdir=$work/$ProjectId/$obsnum
if [ $restart != 0 ]; then
    echo Cleaning $pdir
    sleep 2
    rm -rf $pdir
fi


if [ $instrument = "SEQ" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing SEQ in $pdir for $src (use restart=1 if you need a fresh start)"
    else
	echo "Processing SEQ in $pdir for $src"
    fi
    mkdir -p $pdir
    lmtoy_reduce.sh pdir=$pdir $* > $pdir/lmtoy_$obsnum.log 2>&1    
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    echo Processing RSR for $ProjectId $obsnum
    mkdir -p $pdir
    echo $obsnum > $pdir/rsr.obsnum
    python $LMTOY/RSR_driver/rsr_driver.py $pdir/rsr.obsnum   -w  $pdir/rsr.wf.pdf -p -b 3 
    # python ../RSR_driver/rsr_driver.py rsr1.obsnum -w rsr1.wf.pdf -p -b 3 --exclude 110.51 0.15 108.65 0.3 
    # python ../RSR_driver/rsr_driver.py rsr2.obsnum -w rsr2.wf.pdf -p -b 3 --exclude 110.51 0.15 108.65 0.3 85.2 0.4 > rsr2.log
elif [ $instrument = "1MM" ]; then
    # 
    process_ps.py --obs_list $obsnum --pix_list 2 --bank 0 -p $DATA_LMT 
else
    echo Unknown instrument $instrument
fi


# produce Quick-Look tar file

if [ $tar != 0 ]; then
    echo Processing tar for $pdir
    rm -f $pdir/tar.log
    touch $pdir/tar.log
    for ext in rc tab txt log apar html png pdf cubestat; do
	find $pdir -name \*$ext  >> $pdir/tar.log
    done
    tar zcf $pdir.tar `cat $pdir/tar.log`
fi
