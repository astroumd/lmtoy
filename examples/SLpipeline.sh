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

version="SLpipeline: 5-nov-2021"

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
sleep=2

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
    sleep $sleep
    rm -rf $pdir
fi


if [ $instrument = "SEQ" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing SEQ in $pdir for $src (use restart=1 if you need a fresh start)"
    else
	echo "Processing SEQ in $pdir for $src"
    fi
    sleep $sleep
    mkdir -p $pdir
    lmtoy_reduce.sh pdir=$pdir $* > $pdir/lmtoy_$obsnum.log 2>&1
    readme_seq > $pdir/README.html
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing RSR in $pdir for $src (use restart=1 if you need a fresh start)"
    else
	echo "Processing RSR for $ProjectId $obsnum $src"
	mkdir -p $pdir
	echo $obsnum > $pdir/rsr.obsnum
	lmtinfo.py $DATA_LMT $obsnum > $pdir/lmtoy_$obsnum.rc
	rsr_blanking $obsnum > $pdir/rsr.blanking
	echo '#   for rsr_driver'      > $pdir/rsr.rfile
	echo '#  obsnum,chassis,band' >> $pdir/rsr.rfile
    fi
    sleep $sleep

    # rsr_pipeline.sh pdir=$pdir $*
    
    pushd $pdir

    
    # output: rsr.badlags sbc.png
    if [ ! -e rsr.badlags ]; then
        python $LMTOY/examples/seek_bad_channels.py $obsnum                      > rsr4.log 2>&1
    fi
    # output: $src_rsr_spectrum.txt
    b=""
    b="--badlags rsr.badlags"
    r="--rfile rsr.rfile"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r -w rsr.wf.pdf -p -b 3  > rsr1.log 2>&1    
    # output: rsr.obsnum.sum.txt
    python $LMTOY/examples/rsr_sum.py -b rsr.obsnum    $b                           > rsr2.log 2>&1

    # output: rsr.blanking.sum.txt
    python $LMTOY/examples/rsr_sum.py -b rsr.blanking  $b                           > rsr3.log 2>&1

    # NEMO summary spectra
    dev=$(yapp_query png ps)
    tabplot ${src}_rsr_spectrum.txt    line=1,1 color=2 ycoord=0      yapp=${src}_rsr_spectrum.sp.$dev/$dev  debug=-1
    tabplot rsr.obsnum.sum.txt         line=1,1 color=2 ycoord=0      yapp=rsr.obsnum.sum.sp.$dev/$dev       debug=-1
    tabplot rsr.blanking.sum.txt       line=1,1 color=2 ycoord=0      yapp=rsr.blanking.sum.sp.$dev/$dev     debug=-1
    tabtrend ${src}_rsr_spectrum.txt 2 | tabhist - robust=t xcoord=0  yapp=${src}_rsr_spectrum.rms.$dev/$dev debug=0
    tabtrend rsr.obsnum.sum.txt      2 | tabhist - robust=t xcoord=0  yapp=rsr.obsnum.sum.rms.$dev/$dev      debug=0
    tabtrend rsr.blanking.sum.txt    2 | tabhist - robust=t xcoord=0  yapp=rsr.blanking.sum.rms.$dev/$dev    debug=0

    # ADMIT
    lmtoy_admit.sh rsr.blanking.sum.txt
    lmtoy_admit.sh ${src}_rsr_spectrum.txt
    
    #
    rsr_readme > README.html
    popd
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
