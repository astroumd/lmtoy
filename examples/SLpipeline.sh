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

version="SLpipeline: 21-apr-2022"

echo ""
echo "LMTOY>> $version"


# default input parameters
obsnum=0                       # obsnum or obsnums can be used for single 
obsnums=0                      # or combinations of existing obsnums
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
rsync=""
rc=""
goal=Science

if [ -z "$1" ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM             ...         (process a single obsnum)"
    echo "               obsnums=ON1,ON2,ON3,...   ...         (combine previously processed obsnums)"
    echo "Optional SLpipeline parameters:"
    echo "  path=$path"
    echo "  work=$work"
    echo "  debug=$debug"
    echo "  restart=$restart"
    echo "  tap=$tap"
    echo "  srdp=$srdp"
    echo "  raw=$raw"
    echo "  admit=$admit"
    echo "  sleep=$sleep"
    echo "  nproc=$nproc"
    echo "  rsync=$rsync"
    echo "  rc=$rc"
    echo "  goal=$goal    (Science, or override with: Pointing Focus)"
    echo "Optional instrument specific pipeline can be added as well but are not known here"
    echo "  To Unity:  rsync=lmtslr_umass_edu@unity:/nese/toltec/dataprod_lmtslr/work_lmt/%s"
    echo "  To UMD:    rsync=teuben@lma.astro.umd.edu:/lma1/teuben/LMT/work_lmt/%s"

    exit 0
fi

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do
  export $arg
done

# global rc ?
if [ -n "$rc" ]; then
    echo "LMTOY>> source $rc"
    source $rc
fi

# 
source lmtoy_functions.sh


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
if [ -z "$OMP_NUM_THREADS" ]; then
    if [ $nproc -gt 0 ]; then
	export OMP_NUM_THREADS=$nproc
    fi
fi
echo "OMP_NUM_THREADS=$OMP_NUM_THREADS"

#             bootstrap
rc=/tmp/lmtoy_${obsnum}.$$.rc
lmtinfo.py $obsnum > $rc
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
if [ $restart = "-1" ]; then
    if [ -d $pdir ]; then
	echo "Warning: restart=-1 and $pdir already exists"
	exit 0
    fi
fi
if [ $restart = "1" ]; then
    echo Cleaning $pdir in $sleep seconds....
    sleep $sleep
    rm -rf $pdir
fi

# ?
if [ -e $pidir/PI_pars.rc ]; then
    echo "Found PI parameters in $pidir/PI_pars.rc"
    source $pidir/PI_pars.rc
fi

# warning: we're not using obsgoal, but our own goal=
if [ $goal == "Science" ]; then

if [ $obspgm == "Map" ] || [ $obspgm == "Lissajous" ]; then
    echo "Map mode with instrument=$instrument"
    if [ -d $pdir ]; then
	echo "Re-Processing Map in $pdir for $src (use restart=1 if you need a fresh start)"
	first=0
	date >> $pdir/date.log
    else
	echo "Processing SEQ/Map in $pdir for $src"
	first=1
	mkdir -p $pdir
    fi
    sleep $sleep
    if [ $obsnums = 0 ]; then
	echo "LMTOY>> seq_pipeline.sh pdir=$pdir $*"
	$time         seq_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
    else
	obsnum=${on0}_${on1}
	cd $work
	echo "LMTOY>> seq_combine.sh             $*"
	$time         seq_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
    fi
    seq_summary.sh $pdir/lmtoy_$obsnum.log
    date >> $pdir/date.log	
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "RSR" ]; then
    if [ -d $pdir ]; then
	echo "Re-Processing $obspgm RSR in $pdir for $src (use restart=1 if you need a fresh start)"
	first=0
	date                             >> $pdir/date.log
    else
	echo "Processing $obspgm RSR for $ProjectId $obsnum $src in $pdir"
	first=1
	mkdir -p $pdir
	if [ $obsnums = 0 ]; then
	    echo $obsnum                  > $pdir/rsr.obsnum
	    lmtinfo.py $obsnum            > $pdir/lmtoy_$obsnum.rc
	fi
	date                              > $pdir/date.log
    fi
    sleep $sleep
    if [ $obsnums = 0 ]; then
	echo "LMTOY>> rsr_pipeline.sh pdir=$pdir $*"
	$time         rsr_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
    else
	obsnum=${on0}_${on1}
	cd $work
	echo "LMTOY>> rsr_combine.sh             $*"
	$time         rsr_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
    fi
    rsr_summary.sh $pdir/lmtoy_$obsnum.log
    date >> $pdir/date.log
    echo Logfile in: $pdir/lmtoy_$obsnum.log
elif [ $instrument = "1MM" ]; then
    # @todo   only tested for one case
    if [ -d $pdir ]; then
	echo "Re-Processing $obspgm 1MM in $pdir for $src"
    else
	echo "Processing $obspgm 1MM in $pdir for $src"
    fi
    sleep $sleep
    if [ $obspgm == "Ps" ]; then
	mkdir -p $pdir
	(cd $pdir; process_ps.py --obs_list $obsnum --pix_list 2 --bank 0 -p $DATA_LMT )
    else
	echo "Skipping unknown obspgm=$obspgm"
    fi
else
    echo "Unknown instrument $instrument"
    tar=0
fi

else
    if [ -d $pdir ]; then
	echo "Re-Processing $obspgm/$obsgoal in $pdir for $src"
    else
	echo "Processing $obspgm/$obsgoal in $pdir for $src"
	mkdir -p $pdir
	lmtinfo.py $obsnum > $pdir/lmtoy_$obsnum.rc
    fi
    sleep $sleep
    
    if [ $goal == "Pointing" ]; then
	# benchmarks:   1mm=93560  seq=92984
	echo Running linepoint.py $obsnum
	cd $pdir
	python $LMTOY/LinePointing/linepoint.py $obsnum > lmtoy_$obsnum.log
	echo "Results in $pdir"
    fi
    lmtoy_report
    exit 0
fi

# produce TAP, RSRP, RAW tar files, whichever are requested.


#        ensure we are in $WORK_LMT ("cd $WORK_LMT" doesn't work if it's ".")
cd $work

if [ $tap != 0 ]; then
    echo "Creating Timely Analysis Products (TAP) with admit=$admit in ${pdir}_TAP.tar"
    products="rc md tab txt png pdf log apar html cubestat ifproc rfile obsnum badlags blanking resources"
    rm -f $pdir/tar.log
    touch $pdir/tar.log
    for ext in $products; do
	find $ProjectId/$obsnum -name \*$ext  >> $pdir/tar.log
    done
    tar cf ${pdir}_TAP.tar `cat $pdir/tar.log`
fi
 
if [ $srdp != 0 ]; then
    echo "Creating Scientific Ready Data Producs (SRDP) in $pidir/${obsnum}_SRDP.tar"
    tar cf $ProjectId/${obsnum}_SRDP.tar $ProjectId/$obsnum
fi

if [ $raw != 0 ]; then
    echo "Creating raw (RAW) tar for $pdir for $obsnum $calobsnum in $pidir/${obsnum}_RAW.tar"
    lmtar $ProjectId/${obsnum}_RAW.tar $calobsnum $obsnum
fi

#  rsync TAP data to a remote?   e.g. rsync=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
if [ -n "$rsync" ]; then
    ls -l ${pdir}_TAP.tar
    rsync1=$(printf $rsync $ProjectId)
    echo rsync -av ${pdir}_TAP.tar $rsync1
    rsync -av ${pdir}_TAP.tar $rsync1
fi

# final reminder of parameters
lmtoy_report
