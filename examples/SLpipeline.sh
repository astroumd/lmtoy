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

version="SLpipeline: 12-nov-2021"

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
tar=1
admit=1
sleep=2
nproc=1

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

if [ $nproc -gt 0 ]; then
    export OMP_NUM_THREADS=$nproc
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

pidir=$work/$ProjectId
pdir=$pidir/$obsnum
if [ $restart != 0 ]; then
    echo Cleaning $pdir
    sleep $sleep
    rm -rf $pdir
fi

if [ -e $pidir/PI_pars.rc ]; then
    echo "Found PI parameters in $pidir/PI_pars.rc"
    source $pidir/PI_pars.rc
fi


if [ $instrument = "SEQ" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing SEQ in $pdir for $src (use restart=1 if you need a fresh start)"
	first=0
	date >> $pdir/date.log
    else
	echo "Processing SEQ in $pdir for $src"
	first=1
	mkdir -p $pdir
    fi
    sleep $sleep
    seq_pipeline.sh pdir=$pdir $* > $pdir/lmtoy_$obsnum.log 2>&1
    seq_summary.sh $pdir/lmtoy_$obsnum.log
    date >> $pdir/date.log	
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing RSR in $pdir for $src (use restart=1 if you need a fresh start)"
	first=0
	date >> $pdir/date.log
    else
	echo "Processing RSR for $ProjectId $obsnum $src"
	first=1
	mkdir -p $pdir
	echo $obsnum > $pdir/rsr.obsnum
	lmtinfo.py $DATA_LMT $obsnum > $pdir/lmtoy_$obsnum.rc
	date > $pdir/date.log	
    fi
    sleep $sleep
    rsr_pipeline.sh pdir=$pdir $* > $pdir/lmtoy_$obsnum.log 2>&1
    rsr_summary.sh $pdir/lmtoy_$obsnum.log
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "1MM" ]; then
    # 
    if [ -d $pdir ]; then
	echo "Re-Processing 1MM in $pdir for $src"
    else
	echo "Processing 1MM in $pdir for $src"
    fi
    sleep $sleep
    mkdir -p $pdir
    (cd $pdir; process_ps.py --obs_list $obsnum --pix_list 2 --bank 0 -p $DATA_LMT )
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
