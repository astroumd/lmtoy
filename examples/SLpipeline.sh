#! /bin/bash
#
#  SLpipeline:      given an obsnum, figure out what kind of observation it is
#                   and delegate the work to whoever it can do
#                   $ADMIT allowed to be present. Various tar files can be created as well.
#
#
#  Note:   this will currently only reduce one OBSNUM, combinations done elsewhere
#
#  @todo   optional PI parameters
#          option to have a data+time ID in the name, by default it will be blank?

version="SLpipeline: 2-dec-2021"

echo "LMTOY>> $version"
if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    exit 0
fi

source lmtoy_functions.sh

# default input parameters
path=${DATA_LMT:-data_lmt}
work=${WORK_LMT:-.}
debug=0
restart=0
tap=1
srdp=0
raw=0
admit=1
sleep=2
nproc=1
obsnum=0      # obsnum or obsnums can be used for single 
obsnums=0     # or combinations of existing obsnums


#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
    python --version
    which python
fi

lmtoy_decipher_obsnums

if [ $obsnum = 0 ]; then
    echo No valid obsnum= or obsnums= given
    exit 1
fi

#             set number of processors
if [ -z $OMP_NUM_THREADS ]; then
    if [ $nproc -gt 0 ]; then
	export OMP_NUM_THREADS=$nproc
    fi
fi
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"

#             bootstrap
rc=/tmp/lmtoy_${obsnum}.$$.rc
lmtinfo.py $path $obsnum > $rc
source $rc
rm -f $rc

#             ensure again....just in case
if [ $obsnum = 0 ]; then
    echo No valid obsnum found, 2nd time. Should never happen. Possibly an unknown obsnum was given.
    exit 1
fi

#             cannot handle Cal observations here
if [ "$obspgm" = "Cal" ]; then
    echo "Cannot process a 'Cal' obsnum, pick a better obsnum"
    exit 1
fi

pidir=$work/$ProjectId
if [ $obsnums = 0 ]; then
    pdir=$pidir/$obsnum
else
    pdir=$pidir/${on0}_${on1}
fi
if [ $restart != 0 ]; then
    echo Cleaning $pdir in $sleep seconds....
    sleep $sleep
    rm -rf $pdir
fi

# ?
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
    if [ $obsnums = 0 ]; then
	echo "LMTOY>> seq_pipeline.sh pdir=$pdir $*"
	seq_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
    else
	obsnum=${on0}_${on1}
	echo "LMTOY>> seq_combine.sh             $*"
	seq_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
    fi
    seq_summary.sh $pdir/lmtoy_$obsnum.log
    date >> $pdir/date.log	
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing RSR in $pdir for $src (use restart=1 if you need a fresh start)"
	first=0
	date                             >> $pdir/date.log
    else
	echo "Processing RSR for $ProjectId $obsnum $src"
	first=1
	mkdir -p $pdir
	if [ $obsnums = 0 ]; then
	    echo $obsnum                  > $pdir/rsr.obsnum
	    lmtinfo.py $DATA_LMT $obsnum  > $pdir/lmtoy_$obsnum.rc
	fi
	date                              > $pdir/date.log
    fi
    sleep $sleep
    if [ $obsnums = 0 ]; then
	echo "LMTOY>> rsr_pipeline.sh pdir=$pdir $*"
	rsr_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
    else
	obsnum=${on0}_${on1}
	echo "LMTOY>> rsr_combine.sh             $*"
	rsr_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
    fi
    rsr_summary.sh $pdir/lmtoy_$obsnum.log
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "1MM" ]; then
    # @todo   only tested for one case
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
    tar=0
fi


# produce TAP, RSRP, RAW tar files, whichever are requested.

if [ $tap != 0 ]; then
    echo "Creating Timely Analysis Products (TAP) with admit=$admit in ${pdir}_TAP.tar"
    products="rc tab txt png pdf log apar html cubestat rfile obsnum badlags blanking"
    rm -f $pdir/tar.log
    touch $pdir/tar.log
    for ext in $products; do
	find $pdir -name \*$ext  >> $pdir/tar.log
    done
    tar cf ${pdir}_TAP.tar `cat $pdir/tar.log`
fi

if [ $srdp != 0 ]; then
    echo "Creating Scientific Ready Data Producs (SRDP) in $pidir/${obsnum}_SRDP.tar"
    (cd $pidir; tar cf ${obsnum}_SRDP.tar $obsnum)
fi

if [ $raw != 0 ]; then
    echo "Creating raw (RAW) tar for $pdir for $obsnum $calobsnum in $pidir/${obsnum}_RAW.tar"
    (cd $pidir; lmtar ${obsnum}_RAW.tar $calobsnum $obsnum)
fi
