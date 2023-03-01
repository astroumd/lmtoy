#! /bin/bash
#
#  SLpipeline:      given an obsnum, figure out what kind of SL observation it is
#                   and delegate the work to whoever it can do
#                   $ADMIT allowed to be present. Various tar files can be created as well.
#
#
#  @todo   optional PI parameters
#          option to have a data+time ID in the name, by default it will be blank?

_version="SLpipeline: 28-feb-2023"

echo ""
echo "LMTOY>> $_version"

#--HELP   
                               # required input is either obsnum= or obsnums=
obsnum=0                       #    obsnum=  can be used for a single observation
obsnums=0                      #    obsnums= for combinations of existing obsnums

                               # the remainder are optional parameters
path=${DATA_LMT:-data_lmt}     # - to be deprecated
work=${WORK_LMT:-.}            # - to be deprecated
debug=0         # add bash debug (1)
restart=0       # if set, force a fresh restart by deleting old obsnum pipeline results
exist=0         # if set, and the obsnum exists, skip running pipeline 
tap=0           # save the TAP in a tar file?
srdp=0          # save the SRDP in a tar file?
raw=0           # save the RAW data in a tar file?
grun=1          # save the script generator?
admit=0         # run ADMIT ?
meta=0          # activate update for frontend db (for dataverse)
sleep=2         # add few seconds before running, allowing quick interrupt
nproc=1         # number of processors to use (keep it at 1)
rsync=""        # rsync address for the TAP file (used at LMT/malt)
oid=""          # experimental
goal=Science    # Science, or override with: Pointing,Focus

#  Optional instrument specific pipeline can be added as well but are not known here
#  A few examples:
#    rsr_pipeline.sh --help
#    seq_pipeline.sh --help
#
#    To Unity:  rsync=lmtslr_umass_edu@unity:/nese/toltec/dataprod_lmtslr/work_lmt/%s
#    To UMD:    rsync=teuben@lma.astro.umd.edu:/lma1/teuben/LMT/work_lmt/%s
#
#  Running Benchmarks:
#    RSR:        SLpipeline.sh obsnum=33551 restart=1
#    SEQ:        SLpipeline.sh obsnum=79448 restart=1
#                SLpipeline.sh obsnums=97520,97520
#  Viewing:
#    $WORK_LMT/2014ARSRCommissioning/33551
#    $WORK_LMT/2018S1SEQUOIACommissioning/79448/
#    $WORK_LMT/2021-S1-US-3/97520_97521
#
#  Web viewing:
#    http://taps.lmtgtm.org/lmtslr/2023-S1-US-18/
#    http://taps.lmtgtm.org/lmtslr/lmtoy_run/
#
#--HELP

#             set up LMTOY, parse command line so it's merged with the script parameters
source lmtoy_functions.sh
lmtoy_args "$@"

#             put in bash debug mode
if [ $debug -gt 0 ]; then
    set -x
    set -e
    python --version
    which python
fi

#             get the obsnum= (or obsnums=)
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
[ ! -d $WORK_LMT/tmp ] && mkdir -p $WORK_LMT/tmp
rc0=$WORK_LMT/tmp/lmtoy_${obsnum}.rc
lmtinfo.py $obsnum > $rc0
source $rc0
rm -f $rc0
unset rc0

#             ensure again....just in case
if [ $obsnum = 0 ]; then
    echo No valid obsnum found, 2nd time. Should never happen. Possibly an unknown obsnum was given.
    exit 1
fi

#             cannot handle Cal observations here
if [ "$obspgm" = "Cal" ]; then
    echo "Cannot process a 'Cal' obsnum=$obsnum"
    exit 1
fi

pidir=$work/$ProjectId
if [ $obsnums = 0 ]; then
    pdir=$pidir/${obsnum}
else
    pdir=$pidir/${on0}_${on1}
fi
if [ $exist == 1 ] && [ -d $pidir/$obsnum ]; then
    echo Skipping work for $pidir/$obsnum, it already exists
    exit 0
fi

if [ "$oid" != "" ]; then
    pdir=${pdir}_${oid}
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

# warning: we're not using obsgoal, but our own goal=     @todo     use obsgoal et al.
if [ $goal == "Science" ]; then

    if [ $obspgm == "Map" ] || [ $obspgm == "Lissajous" ]; then
	echo "Map mode with instrument=$instrument"
	if [ -d $pdir ]; then
	    echo "Re-Processing Map in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date >> $pdir/date.log
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
	lmtoy_date >> $pdir/date.log	
	echo Logfile in: $pdir/lmtoy_$obsnum.log
	if [[ $first == 1 ]]; then
	    cp $pdir/lmtoy_$obsnum.log   $pdir/first.lmtoy_$obsnum.log	
	fi
    
    elif [ $instrument = "RSR" ]; then
	
	if [ -d $pdir ]; then
	    echo "Re-Processing $obspgm RSR in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date                        >> $pdir/date.log
	else
	    echo "Processing $obspgm RSR for $ProjectId $obsnum $src in $pdir"
	    first=1
	    mkdir -p $pdir
	    if [ $obsnums = 0 ]; then
		echo $obsnum                  > $pdir/rsr.obsnum
		#  $rc0 ?
		# lmtinfo.py $obsnum            > $pdir/lmtoy_$obsnum.rc
	    fi
	    lmtoy_date                          > $pdir/date.log
	fi
	sleep $sleep
	if [ $obsnums = 0 ]; then
	    echo "LMTOY>> rsr_pipeline.sh pdir=$pdir first=$first $*"
	    $time         rsr_pipeline.sh pdir=$pdir first=$first $*     > $pdir/lmtoy_$obsnum.log 2>&1
	else
	    obsnum=${on0}_${on1}
	    cd $work
	    echo "LMTOY>> rsr_combine.sh             $*"
	    $time         rsr_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
	fi
	rsr_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log
	echo Logfile in: $pdir/lmtoy_$obsnum.log
	if [[ $first == 1 ]]; then
	    cp $pdir/lmtoy_$obsnum.log   $pdir/first.lmtoy_$obsnum.log	
	fi

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
	
    elif [ $instrument = "SEQ" ] && [ $obspgm = "Bs" ]; then
	
	if [ -d $pdir ]; then
	    echo "Re-Processing $obspgm SEQ in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date                             >> $pdir/date.log
	else
	    first=1
	    mkdir -p $pdir	
	fi
	echo "LMTOY>> seqbs_pipeline.sh pdir=$pdir $*"
	$time         seqbs_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
	seq_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log	
	echo Logfile in: $pdir/lmtoy_$obsnum.log
	
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

# record the processing time
echo "date=\"$(lmtoy_date)\"     # end " >> $pdir/lmtoy_$obsnum.rc

# make a metadata yaml file for later ingestion into DataVerse
echo "LMTOY>> make metadata ($meta) for DataVerse"
if [ $meta = 0 ]; then
    mk_metadata.py -y  $pdir/lmtmetadata.yaml $pdir
else
    # @todo will this work reliably on NFS mounted media?
    db=$WORK_LMT/example_lmt.db
    flock --verbose $db.flock mk_metadata.py -y  $pdir/lmtmetadata.yaml -f $db $pdir 
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
 
if [ $grun != 0 ]; then
    echo "LMTOY>> Saving the script generator"
    gsaved=0
    gdir=$WORK_LMT/lmtoy_run/lmtoy_${ProjectId}
    if [ -e $gdir ]; then
	gsaved="$gdir"
	tar -zcf $ProjectId/$obsnum/lmtoy_${ProjectId}.tar.gz -C $WORK_LMT/lmtoy_run lmtoy_${ProjectId}
    fi
    if [ $gsaved == 0 ]; then
	echo "LMTOY>> No script generator for lmtoy_${ProjectId} was found"
    else
	echo "LMTOY>> Saved $ProjectId/$obsnum/lmtoy_${ProjectId}.tar.gz"
    fi
fi

if [ $srdp != 0 ]; then
    echo "Creating Scientific Ready Data Producs (SRDP) in $pidir/${obsnum}_SRDP.tar"
    tar cf $ProjectId/${obsnum}_SRDP.tar $ProjectId/$obsnum
fi

if [ $raw != 0 ] && [ $obsnums = 0 ]; then
    # ensure only for obsnums = 0
    echo "Creating raw (RAW) tar for $pdir for $obsnum $calobsnum in $pidir/${obsnum}_RAW.tar"
    lmtar $ProjectId/${obsnum}_RAW.tar $calobsnum $obsnum
fi

#  rsync TAP data to a remote?   e.g. rsync=teuben@lma.astro.umd.edu:/lma1/lmt/TAP_lmt
if [ -n "$rsync" ]; then
    ls -l ${pdir}_TAP.tar
    rsync1=$(printf $rsync $ProjectId)
    # ensure the directory exists
    ud=$(echo $rsync1 | awk -F: '{print $1,$2}')
    ssh ${ud[0]} mkdir -p ${ud[1]}
    echo rsync -av ${pdir}_TAP.tar $rsync1
    rsync -av ${pdir}_TAP.tar $rsync1
fi

# final reminder of parameters
lmtoy_report

# record of the log file ?
# cp $pdir/lmtoy_$obsnum.log cp $pdir/lmtoy_$obsnum.log.$date