#! /bin/bash
#
#  SLpipeline:      given an obsnum, figure out what kind of SL observation it is
#                   and delegate the work to whoever it can do
#                   $ADMIT allowed to be present. Various tar files can be created as well.
#
#  Note this script can be run from anywhere, but will work from $WORK_LMT
#
#
#  @todo   optional PI parameters
#          option to have a data+time ID in the name, by default it will be blank?

_version="SLpipeline: 25-jun-2024"

echo ""
echo "LMTOY>> VERSION $(cat $LMTOY/VERSION)"
echo "LMTOY>> $_version"

#--HELP   
                               # required input is either obsnum= or obsnums=
obsnum=0                       #    obsnum=  for a single observation
obsnums=0                      #    obsnums= for combinations of existing obsnums, comma separated list

                               # the remainder are optional parameters
debug=0         # add bash debug (1)
error=0         # add bash error (1)
restart=0       # 1=force single fresh restart  2=restart + autorun  (always deletes old obsnum)
nese=0          # 0=work all on nese    1=raw on nese, work on /work    2=raw from /work, work on /work [placeholder]
exist=0         # if set, and the obsnum exists, skip running pipeline 
tap=0           # save the TAP in a tar/zip file? (used on malt)
srdp=1          # save the SRDP in a tar/zip file in $PID/4dv
sdfits=1        # save the calibrated spectra in SDFITS (or netCDF) in $PID/4dv
raw=0           # save the RAW data in a tar/zip file in the $PID
chunk=10g       # chunksize for zippping up what used to be a tar file (use 0 to get back to tar)
grun=1          # save the script generator?
admit=0         # run ADMIT ?
meta=1          # 1 or 2:  1=activate update for frontend db (for dataverse)
sleep=2         # add few seconds before running, allowing quick interrupt
nproc=1         # number of processors to use (keep it at 1)
rsync=""        # rsync address for the TAP file (used at LMT/malt)
oid=""          # experimental parallel processing using __$oid  == currently not in use ==
goal=Science    # Science, or override with: Pointing,Focus
webrun=""       # optional directive for webrun to do parameter checking (SEQ/map, SEQ/Bs, RSR, ....)
qagrade=""      # if given, the final grade recorded for the archive (QAFAIL enforces -1)
public=""       # if given, the public data for archiving. Default is 1 year after today. Example:  2020-12-31

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

time=/usr/bin/time

#             set up LMTOY, parse command line so it's merged with the script parameters
#             deal with brainwasted windows : in ldate
source lmtoy_functions.sh
lmtoy_args "$@"
ldate=$(lmtoy_date | sed s/:/-/g)

#             put in bash debug mode, and report some settings
if [ $debug -gt 0 ]; then
    set -x
    set -e
    which python
    python --version
    test_mpl
fi
#             put in bash error trap mode
if [ $error -gt 0 ]; then
    set -e
    set -u
fi

#             get the obsnum= (or obsnums=); also sets obsnum_list for archive
lmtoy_decipher_obsnums
if [ $obsnum = 0 ]; then
    echo No valid obsnum= or obsnums= given
    exit 1
fi

#             set number of processors (for now should be fixed at 1 if not present)
if [ -z "$OMP_NUM_THREADS" ]; then
    if [ $nproc -gt 0 ]; then
	export OMP_NUM_THREADS=$nproc
    fi
fi
echo "LMTOY>> OMP_NUM_THREADS=$OMP_NUM_THREADS"

#             report modules
if [ "$(which module)" != "" ]; then
    echo "$(module list)"
else
    echo "LMTOY>> No modules loaded"
fi

#             bootstrap information on the obsnum to figure out the instrument dependent workflow 
[ ! -d $WORK_LMT/tmp ] && mkdir -p $WORK_LMT/tmp
rc0=$WORK_LMT/tmp/lmtoy_${obsnum}.rc
lmtinfo.py $obsnum > $rc0
if [ $? != 0 ]; then
    # some error (typically OBSNUM did not exist)
    cat $rc0
    rm -f $rc0    
    exit 1
fi
source $rc0
rm -f $rc0
unset rc0

#             ensure again....just in case
if [ $obsnum = 0 ]; then
    echo "LMTOY>> No valid obsnum found, 2nd time. Should never happen."
    exit 1
fi

#             cannot handle Cal observations here (or Stay,VlbiSched, On, Idle, CrossScan)
if [ "$obspgm" = "Cal" ]; then
    echo "LMTOY>> Cannot process a 'Cal' obsnum=$obsnum"
    exit 1
fi

#             set pdir = root directory below which all obsnum directories will exist
pidir=$WORK_LMT/$ProjectId     # temporary
if [ $obsnums = 0 ]; then
    pdir=$pidir/${obsnum}
else
    pdir=$pidir/${on0}_${on1}
fi
if [ $exist == 1 ] && [ -d $pidir/$obsnum ]; then
    echo "LMTOY>> Skipping work for $pidir/$obsnum, it already exists"
    exit 0
fi
if [ $restart -lt 0 ]; then
    if [ -d $pdir ]; then
	echo "LMTOY>> Warning: restart=-1 and $pdir already exists"
	exit 0
    fi
fi
if [ $restart -gt 0 ]; then
    echo "LMTOY>> Cleaning $pdir in $sleep seconds...."
    sleep $sleep
    rm -rf $pdir
fi

# this is not officially endorsed yet, it may even disappear from LMTOY
if [ -e $pidir/PI_pars.rc ]; then
    echo "LMTOY>> Found PI parameters in $pidir/PI_pars.rc"
    source $pidir/PI_pars.rc
fi

# warning: we're not using obsgoal from ifproc, but our own goal=     
# we basically force everything Science (but see Pointing below)
if [ $goal == "Science" ]; then

    if [ $obspgm == "Map" ] || [ $obspgm == "Lissajous" ]; then
	# @todo what if there is an RSR map ?
	echo "LMTOY>> $obspgm mode with instrument=$instrument and map_coord=$map_coord"
	if [ -d $pdir ]; then
	    echo "LMTOY>> Re-Processing SEQ/Map in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date >> $pdir/date.log
	else
	    echo "LMTOY>> Processing SEQ/Map in $pdir for $src"
	    mkdir -p $pdir
	    first=1
	    lmtoy_date >> $pdir/date.log
	fi
	sleep $sleep
	echo "$_lmtoy_args" >> $pdir/lmtoy_args.log
	if [ $obsnums = 0 ]; then
	    echo "LMTOY>> seq_pipeline.sh pdir=$pdir $*"
	    $time         seq_pipeline.sh pdir=$pdir $*   > $pdir/lmtoy_$obsnum.log 2>&1
	    # seq now allows a 2nd run, looping over the banks with improved keys
	    if [ $restart = 2 ]; then
		echo "LMTOY>> Re-running in restart=2 auto-re-run mode"
	    fi
	else
	    obsnum=${on0}_${on1}
	    cd $WORK_LMT
	    echo "LMTOY>> seq_combine.sh             $*"
	    $time         seq_combine.sh             $*    > $pdir/lmtoy_$obsnum.log 2>&1
	fi
	log=$pdir/lmtoy_$obsnum.log
	cp $pdir/lmtoy_$obsnum.log $pdir/lmtoy_${obsnum}_$ldate.log	    
	seq_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log	
	echo Logfile also in: $pdir/lmtoy_$obsnum_$ldate.log
    
    elif [ $instrument = "RSR" ]; then
	
	if [ -d $pdir ]; then
	    echo "Re-Processing $obspgm RSR in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date                         >> $pdir/date.log
	else
	    echo "Processing $obspgm RSR for $ProjectId $obsnum $src in $pdir"
	    mkdir -p $pdir
	    first=1
	    lmtoy_date                          > $pdir/date.log
	    if [ $obsnums = 0 ]; then
		echo $obsnum                    > $pdir/rsr.obsnum
		#  $rc0 ?
		# lmtinfo.py $obsnum            > $pdir/lmtoy_$obsnum.rc
	    fi
	fi
	sleep $sleep
	echo "$_lmtoy_args" >> $pdir/lmtoy_args.log	
	if [ $obsnums = 0 ]; then
	    echo "LMTOY>> rsr_pipeline.sh pdir=$pdir $*"
	    $time         rsr_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
	else
	    obsnum=${on0}_${on1}
	    cd $WORK_LMT
	    echo "LMTOY>> rsr_combine.sh             $*"
	    $time         rsr_combine.sh             $*     > $pdir/lmtoy_$obsnum.log 2>&1
	fi
	log=$pdir/lmtoy_$obsnum.log	
	rsr_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log
        cp $pdir/lmtoy_$obsnum.log $pdir/lmtoy_$obsnum_$ldate.log	
	echo Logfile also in: $pdir/lmtoy_$obsnum_$ldate.log

    elif [ $instrument = "1MM" ]; then
	
	# @todo   only tested for one case
	if [ -d $pdir ]; then
	    echo "Re-Processing 1MM $obspgm data in $pdir for $src"
	else
	    echo "Processing new 1MM $obspgm data in $pdir for $src"
	    mkdir -p $pdir	    
	fi
	sleep $sleep
	echo "$_lmtoy_args" >> $pdir/lmtoy_args.log	
	if [ $obspgm == "Ps" ]; then
	    echo "LMTOY>> seqps_pipeline.sh pdir=$pdir $*"
	    $time         seqps_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
	    seq_summary.sh $pdir/lmtoy_$obsnum.log
	    lmtoy_date >> $pdir/date.log
	    cp $pdir/lmtoy_$obsnum.log $pdir/lmtoy_$obsnum_$ldate.log
	    echo Logfile also in: $pdir/lmtoy_$obsnum_$ldate.log
	else
	    echo "Skipping unknown obspgm=$obspgm for 1MM"
	fi
	
    elif [ $instrument = "SEQ" ] && [ $obspgm = "Bs" ]; then
	
	if [ -d $pdir ]; then
	    echo "Re-Processing SEQ $obspgm data in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date                             >> $pdir/date.log
	else
	    echo "Processing new SEQ $obspgm data in $pdir for $src"
	    first=1
	    mkdir -p $pdir	
	fi
	sleep $sleep
	echo "$_lmtoy_args" >> $pdir/lmtoy_args.log
	#
	echo "LMTOY>> seqbs_pipeline.sh pdir=$pdir $*"
	$time         seqbs_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
	seq_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log
	cp $pdir/lmtoy_$obsnum.log $pdir/lmtoy_$obsnum_$ldate.log
	echo Logfile also in: $pdir/lmtoy_$obsnum_$ldate.log
	
    elif [ $instrument = "SEQ" ] && [ $obspgm = "Ps" ]; then
	
	if [ -d $pdir ]; then
	    echo "Re-Processing SEQ $obspgm data in $pdir for $src (use restart=1 if you need a fresh start)"
	    first=0
	    lmtoy_date                             >> $pdir/date.log
	else
	    echo "Processing new SEQ $obspgm data in $pdir for $src"
	    first=1
	    mkdir -p $pdir	
	fi
	sleep $sleep
	echo "$_lmtoy_args" >> $pdir/lmtoy_args.log
	#
	echo "LMTOY>> seqps_pipeline.sh pdir=$pdir $*"
	$time         seqps_pipeline.sh pdir=$pdir $*     > $pdir/lmtoy_$obsnum.log 2>&1
	seq_summary.sh $pdir/lmtoy_$obsnum.log
	lmtoy_date >> $pdir/date.log
	cp $pdir/lmtoy_$obsnum.log $pdir/lmtoy_$obsnum_$ldate.log
	echo Logfile also in: $pdir/lmtoy_$obsnum_$ldate.log
	
    else
	echo "Unknown instrument $instrument"
	tar=0
    fi
else
    # not a "Science" goal
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

# record obsnum_list for the archiver
echo "obsnum_list=$obsnum_list"              >> $pdir/lmtoy_$obsnum.rc

# record the processing time
echo "date=\"$(lmtoy_date)\"     # end "     >> $pdir/lmtoy_$obsnum.rc

# record the pipeline version
echo "lmtoy_version=$(cat $LMTOY/VERSION)"   >> $pdir/lmtoy_$obsnum.rc

# record the qagrade, if one was given
if [ ! -z $qagrade ]; then
    echo "qagrade=$qagrade"                  >> $pdir/lmtoy_$obsnum.rc
fi

# record the public date, if one was given
if [ ! -z $public ]; then
    echo "date_public=$public"               >> $pdir/lmtoy_$obsnum.rc
fi

# visually challenged folks 
if [ ! -e $pdir/000README.html ]; then
    (cd $pdir ; ln -sf README.html 000README.html)
fi

# directory for dvpipe products for archive ingestion, also for links for PI
dir4dv=$WORK_LMT/${ProjectId}/dir4dv/${ProjectId}/${obsnum}
mkdir -p $dir4dv
echo "LMTOY>> using dir4dv=$dir4dv"

# make a metadata yaml file for later ingestion into DataVerse
if [ $meta -gt 0 ]; then
    cd $pdir
    echo "LMTOY>> make metadata ($meta) for DataVerse in $pdir"
    if [ $meta -gt 1 ]; then
	# @todo will this work reliably on NFS mounted media?
	db=$WORK_LMT/example_lmt.db
	flock --verbose $db.flock mk_metadata.py -y $pdir/${obsnum}_lmtmetadata.yaml -f $db $pdir 
    else
        mk_metadata.py -y $pdir/${obsnum}_lmtmetadata.yaml $pdir
	cp $pdir/${obsnum}_lmtmetadata.yaml $dir4dv
	cp $pdir/lmtoy_${obsnum}*rc $dir4dv	
    fi
fi
# produce TAP, RSRP, RAW tar files, whichever are requested.

#        ensure we are in $WORK_LMT ("cd $WORK_LMT" doesn't work if it's ".")
cd $WORK_LMT

if [ $tap != 0 ]; then
    echo "Creating Timely Analysis Products (TAP) with admit=$admit in ${pdir}_TAP.tar"
    products="rc md tab txt png pdf log apar html yaml cubestat ifproc rfile obsnum badlags blanking resources"
    rm -f $pdir/tar.log
    touch $pdir/tar.log
    for ext in $products; do
	find $ProjectId/$obsnum -name \*$ext  >> $pdir/tar.log
    done
    tar -cf ${pdir}_TAP.tar `cat $pdir/tar.log`
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
    echo "Creating Scientific Ready Data Producs (SRDP) in $dir4dv/${obsnum}_SRDP. (chunk=$chunk)"
    if [ $chunk = 0 ]; then
	tar -cf $dir4dv/${obsnum}_SRDP.tar --exclude="*.nc,*.tar" $ProjectId/$obsnum
    else
	rm -rf             $dir4dv/${obsnum}_SRDP.zip
	zip -s $chunk  -qr $dir4dv/${obsnum}_SRDP.zip $ProjectId/$obsnum	-x \*.nc
    fi
fi

if [ $sdfits != 0 ]; then
    echo "Creating spectra (SDFITS) in $dir4dv/${obsnum}_SDFITS. (chunk=$chunk)"
    count=$(ls -1 $ProjectId/$obsnum/*.nc 2>/dev/null | wc -l)
    if [ $count -gt 0 ]; then
	if [ $chunk = 0 ]; then
	    tar -cf $dir4dv/${obsnum}_SDFITS.tar $ProjectId/$obsnum/README_files.md $ProjectId/$obsnum/*.nc
	else
	    rm -rf             $dir4dv/${obsnum}_SDFITS.zip
	    zip -s $chunk  -qr $dir4dv/${obsnum}_SDFITS.zip $ProjectId/$obsnum/README_files.md $ProjectId/$obsnum/*.nc
	fi
    else
	if [ $chunk = 0 ]; then
	    tar -cf $dir4dv/${obsnum}_SDFITS.tar $ProjectId/$obsnum/README_files.md
	else
	    rm -rf             $dir4dv/${obsnum}_SDFITS.zip
	    zip -s $chunk  -qr $dir4dv/${obsnum}_SDFITS.zip $ProjectId/$obsnum/README_files.md
	fi
    fi
fi

if [ $raw != 0 ] && [ $obsnums = 0 ]; then
    # ensure only for obsnums = 0
    if [ $chunk = 0 ]; then
	echo "Creating raw (RAW) tar for $pdir for $obsnum $calobsnum in $pidir/${obsnum}_RAW.tar"
	lmtar $ProjectId/${obsnum}_RAW.tar $calobsnum $obsnum
    else
	echo "Creating raw (RAW) tar for $pdir for $obsnum $calobsnum in $pidir/${obsnum}_RAW.zip"
	lmzip $ProjectId/${obsnum}_RAW.zip $calobsnum $obsnum
    fi
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

if [ $debug -gt 0 ]; then
    # report matplotlib environment again
    test_mpl
fi
dump_vars $pdir/bash_vars.txt

# final reminder of parameters
lmtoy_report

# record of the log file ?
# cp $pdir/lmtoy_$obsnum.log cp $pdir/lmtoy_$obsnum.log.$date
