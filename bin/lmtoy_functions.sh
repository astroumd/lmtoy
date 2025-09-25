#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations
#   beware, in bash shell variables are common variables between this and the caller

lmtoy_version="25-sep-2025"

echo "LMTOY>> lmtoy_functions $lmtoy_version via $0"

function lmtoy_version {
    local v=$(cat $LMTOY/VERSION)
    local d=$(date -u +%Y-%m-%dT%H:%M:%S)
    local g=$(cd $LMTOY; git rev-list --count HEAD)
    local h=$(uname -a)
    echo "$v  $g  $d  $h"
}

function lmtoy_qagrade {
    # another way of setting grade (not used)
    echo "lmtoy_qagrade: $qagrade -> $1"
    qagrade=$1
}

function lmtoy_repo {
    # fine grained repo version
    local _repo=$(cd $LMTOY;git rev-list --count HEAD)
    echo $_repo
}

function lmtoy_date {
    # standard ISO date, by default in local time.   Use "-u" to switch to UT time
    # note that if used in filename, brainwasted windows doesn't know how to deal
    # with a :, so use $(lmtoy_date | sed s/:/-/g)
    date +%Y-%m-%dT%H:%M:%S $*
}

function lmtoy_timer {
    # timer (unfinished)
    if [ -z "$1" ]; then
	printf "$(expr $(date +%s) - $LMTOY_TIMER)s $$ $LMTOY_TIMER"
    else
	LMTOY_TIMER=$(date +%s)
	printf "[$LMTOY_TIMER start $$]"
    fi
}

function lmtoy_debug {
    # debug level for bash
    #  1:   -x
    #  2:   -e
    echo "lmtoy_debug: not implemented yet"
}

function lmtoy_error {
    # catch errors and errors in functions
    # See also https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
    #
    echo "lmtoy_error: catching"
    if [ "$1" != "0" ]; then
	echo "lmtoy_error: error $1 occured on $(caller)"
	#exit 1
    fi
}
trap 'lmtoy_error $? $LINENO' ERR

function lmtoy_report {
    echo "LMTOY>> xdg-open $WORK_LMT/$ProjectId/$obsnum/README.html"
    printf_red "LMTOY>> ProjectId=$ProjectId  obsnum=$obsnum bank=$bank obspgm=$obspgm  obsgoal=$obsgoal date_obs=$date_obs"
}

function lmtoy_args {
    # set the command line args as shell variables, and save them in _lmtoy_args
    # require arguments, but if -h/--help given, give the inline help
    if [ -z $1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ];then
	set +x
	awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
	exit 0
    fi
    # expect simple keyword=value command line parser for bash
    # eval does not work in functions, we use export instead to deal with arguments with spaces
    for arg in "$@"; do
	export "$arg"
    done
    # save them (for each run they are appended to lmtoy_args.log)
    _lmtoy_args="$@"
}

function show_args {
    # show the latest command line args
    echo "# <show_args>"
    for arg in ${_lmtoy_args}; do
	echo "$arg"
    done
    echo "# </show_args>"
}

function lmtoy_decipher_obsnums {
    # input:    obsnums
    #   obsnums  = comma separated list of obsnum's
    
    # output:   on0, on1, obsnum, obsnums1
    #   on0      = first obsnum in obsnums list
    #   on1      = last obnnum in obsnums list
    #   obsnum   = on0
    #   obsnums1 = space separate version of obsnums=
    
    if [[ $obsnums = 0 ]]; then
	obsnum_list=$obsnum
	return
    else
	obsnum_list=$obsnums	
    fi
    
    #             differentiate if obsnums is a file or list of obsnums
    #             set first and last obsnum, and make a list
    if [ -e $obsnums ]; then
	# obsnum is a file
	on0=$(grep -v ^# $obsnums | head -1 | awk '{print $1}')
	on1=$(grep -v ^# $obsnums | tail -1 | awk '{print $1}')
	obsnums1=$(grep -v ^# $obsnums | awk '{print $1}')
	obsnums=$(echo $obsnums1 | sed 's/ /,/g')
    else
	# obsnums is a comma separated list
	#         figure out the first obsnum, to inherit basic pars
	on0=$(echo $obsnums | awk -F, '{print $1}')
	on1=$(echo $obsnums | awk -F, '{print $NF}')
	obsnums1=$(echo $obsnums | sed 's/,/ /g')
    fi
    obsnum=${on0}
    if [ $debug = 1 ]; then
	echo OBSNUM: $obsnum
	echo OBSNUMS: $obsnums
	echo OBSNUMS1: $obsnums1
    fi
}

function printf_red {
    # could also use the tput command?
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    echo -e "${RED}$*${NC}"
}

function printf_green {
    # could also use the tput command?
    RED='\033[0;32m'
    NC='\033[0m' # No Color
    echo -e "${RED}$*${NC}"
}

function printf_green_file {
    my_file=$1
    while read -r line
    do
	printf_green "$line"
    done < "$my_file"
}

function show_vars {
    # helper function to show value of shell variables using bash dynamic variables
    # meant to be stored in an rc file
    echo "# <show_vars>"
    for _arg in "$@"; do
	echo "${_arg}=${!_arg}"
    done
    echo "# </show_vars>"    
}

function dump_vars {
    # dump all shell variables to a file
    dumpfile=$1
    set -o posix
    set | sort > $dumpfile
}

function qac_select {
    msg=$(grep ^$1 $LMTOY/etc/qac_stats.log | sed s/$1//)
    if [ -z "$msg" ]; then
	printf_red Warning: No qac_select for $1
    else
	printf_green $msg
    fi
    
}

function lmtoy_archive {
    # input:  obsnum pidir
    #         123456 $WORK_LMT/$PID
    # echo "lmtoy_archive: $1 $2"
    # @todo   when the Session-PL1 does not exist yet, make it and also "cp -al" the obsnum there
    #         ->  $PID/Session-PL1/$PID/$OBSNUM
    obsnum=$1
    pidir=$2
    db=$WORK_LMT/example_lmt.db
    pid=$(basename $pidir)
    #  need a new hierachy per obsnum, to deal with the DV ingestion workflow in upload_project.sh
    dir4dv_root=${pidir}/dir4dv/${obsnum}
    dir4dv=${dir4dv_root}/${pid}/${obsnum}
    if [ ! -d $dir4dv ]; then
	echo "LMTOY>>  no $dir4dv, return"
	return
    fi
    # @todo make it less verbose
    echo -n "pushd: "
    pushd $WORK_LMT/$pid/dir4dv/$obsnum
    mk_metadata.py -y ${dir4dv}/${obsnum}_lmtmetadata.yaml $dir4dv
    upload_project.sh in=. out=/tmp/dvout publish=1 verbose=0 overwrite=1
    # @todo if failed
    mk_metadata.py -z /tmp/dvout/${pid}_${obsnum}_output.yaml -f $db $dir4dv
    # we don't need flock anymore, since we run it serially and it's on NFS
    # flock --verbose $db.flock mk_metadata.py ...
    # we don't need an scp anymore,  toltec5 can see it as /nese/toltec/dataprod_lmtslr/work_lmt/example_lmt.db
    #scp $db toltec5:lmtsearch_web
    #   logging
    echo "$(lmtoy_date -u) $pid $obsnum" >> $WORK_LMT/dataverse.log
    #   cleanup $pid   @todo should  clean ${pidir}/dir4dv/${obsnum}/
    popd
    echo "Removing ${dir4dv_root}"
    rm -rf ${dir4dv_root}

}

function lmtoy_rsr1 {
    # input:  first, obsnum, badlags, blanking, rfile, ....

    echo "LMTOY>> _rsr1: $(lmtoy_timer $$)"

    # New order of reduction for single obsnum cases
    #  1. run rsr_driver to get a "first" spectrum, with whatever badlags are in dreampyrc
    #  2. get Tsys0, which also gives some badcb0= (which we ignore)
    #  3. run badlags, this also gives some badcb1=
    #  4. try rsr_driver again, just to apply these badlags
    #  5. get Tsys1, now done with the badlags. these also give a badcb2=, which we could use
    #  6. final rsr_driver, using badlags and badcb1,badcb2
    #  7. final rsr_sum,    using badlags and badcb1,badcb2

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header (even though RSR doesn't have it, we steal the name)
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # set the dreampy.log logger filename in the local OBSNUM directory (also needed for parallel processing)
    export DREAMPY_LOG='dreampy.log'

    # spec1:    output spectrum rsr.$obsnum.driver.txt
    # 
    spec1="rsr.${obsnum}.driver.sum.txt"
    b="--badlags $badlags"
    r="--rfile $rfile"
    o="-o $spec1"
    w="-w rsr.wf.pdf"
    t1="-r $rthr"
    t2="-t $cthr"
    f=""
    nbs=""
    nbs="--no-baseline-sub"
    do="--date_obs $date_obs"
    if [ "$xlines" != "" ]; then
	l="--exclude $(echo $xlines | sed 's/,/ /g')"
    else
	l=""
    fi
    
    # FIRST RUN - save initial attempts without badlags applied
    # Before july-2022 we reset with empty badlags entry in dreampy config with no bad lags
    # in order to be able to run serially with reproduceable results.
    # Now we make the dreampy config file read-only so we can run in parallel
    # as well as process old data. Thus we want all 'bad_lagsC' in dreampyrc to be ""
    if [[ $first == 1 ]]; then
	# 1.
	echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o $do $w -p -b $blo $t1 $t2"
       	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o $do $w -p -b $blo $t1 $t2   > rsr_driver0.log 2>&1
	mv rsr.driver.png rsr.driver0.png
        mv rsr.wf.pdf     rsr.wf0.pdf
	# 2.
	echo "LMTOY>> rsr_tsys.py -y rsr.tsys0.png $obsnum"
	rsr_tsys.py -y rsr.tsys0.png $obsnum  > rsr_tsys0.log   2>&1
	# we ignore any 'BADCB0' in here
    fi

    # FIRST get the badlags - this is a file that can be edited by the user in later re-runs
    # output: badlags=rsr.$obsnum.badlags and badlags.$obsnum.png
    #         rsr.$obsnum.rfile and rsr.$obsnum.blanking  - can be modified if #BADCB's have been found
    # Note this is only run for single obsnums
    if [[ ! -e rsr.$obsnum.badlags ]]; then
	# 3.  produces rsr.badlags
	bopts="--rms_max 0.05"
	bopts=""
	if [ "$shortlags" != "" ]; then
	    bopts="$bopts --short_min $(echo $shortlags | tabcols - 1)  --short_hi $(echo $shortlags | tabcols - 2)"
	fi
	echo "LMTOY>> badlags.py -d -y badlags.png $bopts --spike $spike $obsnum"
	badlags.py -d -y badlags.png $bopts --spike $spike $obsnum > rsr_badlags.log 2>&1
	if [ "$badlags" = 0 ]; then
	    echo "LMTOY>> no badlags requested, still making a plot - you almost never want to do this"
	    mv badlags.png badlags.$obsnum.png
	    echo "# badlags=0 was requested" > rsr.$obsnum.badlags
	elif [ -e "$badlags" ]; then
	    echo "LMTOY>> using badlags file $badlags"
	    cp $badlags rsr.$obsnum.badlags
	else
	    echo "LMTOY>> creating rsr.$obsnum.badlags"
	    mv badlags.png badlags.$obsnum.png
	    mv rsr.badlags rsr.$obsnum.badlags
	fi
	badlags=rsr.$obsnum.badlags
	# this gives 'BADCB1'
	
	# 4. redo rsr_driver but now with badlags applied
	echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o $do $w -p -b $blo $t1 $t2 --badlags $badlags"
        python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o $do $w -p -b $blo $t1 $t2 --badlags $badlags > rsr_driver1.log 2>&1	

	# Tsys plot:  rsr.tsys.png  - only done for single obsnum - also lists BADCB's
	#             rsr.spectra.png - another way to view each chassis spectrum
	#             Only make this plot for single obsnum's
	if [ "$obsnum" -gt 0 ]; then
	    # 5.
	    echo "LMTOY>> rsr_tsys.py -b $badlags -t -y rsr.spectrum.png $obsnum"
	    echo "LMTOY>> rsr_tsys.py -b $badlags    -y rsr.tsys.png     $obsnum"
	    rsr_tsys.py -b $badlags -t -y rsr.spectrum.png $obsnum         > rsr_tsys2.log 2>&1
	    rsr_tsys.py -b $badlags    -y rsr.tsys.png     $obsnum         > rsr_tsys1.log 2>&1
	    grep CB rsr_tsys0.log  > tab0
	    grep CB rsr_tsys2.log  > tab2
	    paste tab0 tab2 | awk '{print $0," ratio:",$11/$5}'  > rsr_tsys_badcb.log
	    rm -f tab0 tab2
	    # this Tsys2.log gave 'BADCB2' - and comparing CB0 with CB2 in rsr_tsys_badcb.log
	fi	

	# this step could be debatable, combining BADCB2 with BADCB1, or just keeping one
	# if no badcb was given, use the jitter version from tsys and badlags
	if [ $jitter = 1 ] || [ -z "$badcb" ]; then
	    echo "LMTOY>> BADCB inherited from rsr_tsys2.log"
	    grep '^#BADCB' rsr_tsys2.log >> $badlags
	    rsr_badcb -r $badlags >> $rfile 
	    rsr_badcb -b $badlags >> $blanking
	fi
	#echo "PJT1 obsnum=$obsnum obsnums=$obsnums"	
    elif [ ! -z "$obsnums" ]; then
	#  only for obsnum combinations
	echo "PJT2 obsnum=$obsnum obsnums=$obsnums"
    else
	#  only for a single obsnum re-run
	rsr_blanking $obsnum   > $blanking
	rsr_rfile    $obsnum   > $rfile
	echo "Using existing $badlags - forgetting initial settings"
	rsr_badcb -b $badlags >> $blanking
	rsr_badcb -r $badlags >> $rfile
	#echo "PJT3 obsnum=$obsnum obsnums=$obsnums"
    fi
    
    #   We have two similar scripts of difference provenance that produce a final spectrum
    #   they only differ in the way blanking and baseline subtraction happens, and the idea
    #   is that this should become one final program.
    #   On the other hand, it's a good check if the two are producing the same spectrum
    

    # 6.
    #   note, we're not using all the options for rsr_driver, .e.g
    #   -t, -f, -s, -r, -n
    if [ $sgf != 0 ]; then
	f="-f $sgf -n $notch"
    fi
    echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $do $b $r $l $o $w -p -b $blo $t1 $t2 $f $nbs"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $do $b $r $l $o $w -p -b $blo $t1 $t2 $f $nbs   > rsr_driver_nbs.log 2>&1
    mv rsr.driver.png rsr.driver_nbs.png
    echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $do $b $r $l $o $w -p -b $blo $t1 $t2 $f"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $do $b $r $l $o $w -p -b $blo $t1 $t2 $f   > rsr_driver.log 2>&1
    #  grab the total integration time from the driver @todo is this the right one?
    inttime=$(grep "Integration Time" $spec1 | awk '{print $4}')
    echo "inttime=$(printf %.1f $inttime) # sec" >> $rc

    #  ImageMagick:   this step can fail with some weird security policy error :-(
    #  edit /etc/ImageMagick-*/policy.xml:     rights="read | write" pattern="PDF"
    #  One solution:  copy $LMTOY/etc/policy.xml to ~/.config/ImageMagick/policy.xml
    convert rsr.wf.pdf rsr.wf.png

    # 7.
    # spec2: output spectrum rsr.$obsnum.blanking.sum.txt
    #   @todo   should there not be a $t1 flag ?
    spec2=${blanking}.sum.txt
    echo "LMTOY>> rsr_sum.py -b $blanking  $b  --o1 $blo $t2"
    rsr_sum.py -b $blanking  $b  --o1 $blo $t2              > rsr_sum.log 2>&1


    if [ $bandstats = 1 ]; then
	# band stats
	echo "band stats old $spec1"
	rsr_stats.sh in=$spec1 label=old
	echo "band stats old $spec2"
	rsr_stats.sh in=$spec2 label=old
    fi

    # for a combination we should rely on the individual obsnum spectra, which can then
    # be combined, weighted ideally (for driver, but averaged for blanking)
    # the "old/" directory will contain the old badly combined spectra
    if [ $obsnums != 0 ]; then
	if [ $weighted == 1 ]; then
	    echo "LMTOY>> new weighted average method"
	    mkdir -p old
	    cp $spec1 $spec2 old
	    s1=""
	    s2=""
	    for o in $(cat rsr.obsnum); do
		s1="$s1 $(echo ../$o/rsr.$o.driver.sum.txt)"
		s2="$s2 $(echo ../$o/rsr.$o.blanking.sum.txt)"
		# ls -l ../$o/rsr.$o.driver.sum.txt ../$o/rsr.$o.blanking.sum.txt
	    done
	    #echo S1=$s1
	    #echo S2=$s2
	    rsr_spectra.py -y rsr.spectra.png -o $spec1 $s1
	    rsr_spectra.py -y rsr.spectra.png -o $spec2 $s2
	    
	    rsr_spectra.py -y rsr.spectra.cmp1.png old/$spec1 $spec1
	    rsr_spectra.py -y rsr.spectra.cmp2.png old/$spec2 $spec2
	    if [[ -n "$NEMO" ]]; then
		grep -v nan old/$spec1 | grep -v ^# > junk1a.tab
		grep -v nan     $spec1 | grep -v ^# > junk1b.tab
		grep -v nan old/$spec2 | grep -v ^# > junk2a.tab
		grep -v nan     $spec2 | grep -v ^# > junk2b.tab
		tabmath junk1a.tab,junk1b.tab cmp1.tab %1,%2-%5 all
		tabmath junk2a.tab,junk2b.tab cmp2.tab %1,%2-%4 all
		tabplot cmp1.tab  yscale=1e3 ymin=-1 ymax=1  yapp=cmp1.$dev/$dev 
		tabplot cmp2.tab  yscale=1e3 ymin=-1 ymax=1  yapp=cmp2.$dev/$dev 
		echo "cmp1.tab"
		rsr_stats.sh in=cmp1.tab label=dif
		echo "cmp2.tab"	    
		rsr_stats.sh in=cmp2.tab label=dif
		echo "band stats new $spec1"
		rsr_stats.sh in=$spec1 label=new
		echo "band stats new $spec2"
		rsr_stats.sh in=$spec2 label=new
	    fi
	    wpre="[w]"
	else
	    wpre=""
	fi
    else
	wpre=""
    fi
    
    
    # plot the two in one spectrum, one full range, one in a selected band.
    # the -g version makes an svg file for an alternative way to zoom in (TBD)
    if [ -z "$speczoom" ]; then
	zoom="--band $bandzoom"
    else
	zoom="--zoom $speczoom"	
    fi
    echo "LMTOY>> rsr_spectra.py -y rsr.spectra_zoom.png  $zoom --title $src $spec1 $spec2"
    rsr_spectra.py -y rsr.spectra_zoom.png $zoom --title "$src .$wpre" $spec1 $spec2
    rsr_spectra.py -y rsr.spectra.png            --title "$src .$wpre" $spec1 $spec2
    rsr_spectra.py -y rsr.spectra.svg            --title "$src .$wpre" $spec1 $spec2

    # convert ascii spectrum to sdfits (only handles the driver spectrum because of header)
    sp2sdfits.py $spec1

    # update the rc file (badcb here is deprecated)
    if [[ 0 = 1 ]]; then
	echo "BADCB deprecated here"
	nbadcb=$(grep '^#BADCB' $badlags | wc -l)
	echo nbadcb=$nbadcb >> $rc
	badcb=$(grep '^#BADCB' $badlags | awk '{printf("%d/%d ",$3,$4)}')
	echo badcb=\"$badcb\" >> $rc
    fi
    
    # NEMO summary spectra, some stats and peak analysis
    if [[ -n "$NEMO" ]]; then
	echo "LMTOY>> Some NEMO post-processing"
	dev=$(yapp_query png ps)
	tabplot  $spec1 line=1,1 color=2 ycoord=0        yapp=${spec1}.sp.$dev/$dev   debug=-1
	tabplot  $spec2 line=1,1 color=2 ycoord=0        yapp=${spec2}.sp.$dev/$dev   debug=-1
	tabhist $spec1 2              robust=t xcoord=0  yapp=${spec1}.rms0.$dev/$dev debug=-1
	tabhist $spec2 2              robust=t xcoord=0  yapp=${spec2}.rms0.$dev/$dev debug=-1
	tabtrend $spec1 2 | tabhist - robust=t xcoord=0  yapp=${spec1}.rms1.$dev/$dev debug=-1
	tabtrend $spec2 2 | tabhist - robust=t xcoord=0  yapp=${spec2}.rms1.$dev/$dev debug=-1
	# QAC_STATS
	printf_red $(tabtrend $spec1 2 | tabstat - bad=0 robust=t qac=t label="trend_driver")
	printf_red $(tabtrend $spec2 2 | tabstat - bad=0 robust=t qac=t label="trend_blanking")
	echo  "PJT tabstat  $spec1 2 bad=0 robust=t qac=t"
	printf_red $(tabstat  $spec1 2 bad=0 robust=t qac=t)
	printf_red $(tabstat  $spec2 2 bad=0 robust=t qac=t)

	# for rc and archive yaml 
	nchan=$(tabrows $spec1|wc -l)
	rms=$(tabstat  $spec1 2 bad=0 robust=t qac=t | txtpar - p0=1,4)
	echo "nchan=$nchan" >> $rc
	echo "rms=$rms"     >> $rc
	
	# regress on the driver.sum.txt file
	#regress=$(tabstat $spec1 2 bad=0 robust=t qac=t | txtpar - p0=1,4)
	regress=$(tabstat $spec1 2 bad=0 robust=t qac=t)
	echo "regress=\"$regress\"" >> $rc

	if [ $obsgoal = "LineCheck" ]; then
	    echo "LMTOY>> LineCheck $linecheck $xlines"
	    rm -f spec1.tab spec2.tab
	    #  good for I17208, I12112, I10565
	    if [ $linecheck == 1 ]; then
		xrange=106:111
	    else
		xrange=$linecheck-2:$linecheck+2
	    fi
	    echo  "# tabnllsqfit $spec1 fit=gauss1d xrange=$xrange"      > linecheck.log
	    tabnllsqfit $spec1 fit=gauss1d xrange=$xrange out=spec1.tab >> linecheck.log  2>&1
	    echo  "# tabnllsqfit $spec2 fit=gauss1d xrange=$xrange"     >> linecheck.log
	    tabnllsqfit $spec2 fit=gauss1d xrange=$xrange out=spec2.tab >> linecheck.log  2>&1
	    #   catch bad fits
	    echo  "rms= 0"                                              >> linecheck.log
	    echo  "rms= 0"                                              >> linecheck.log
	    # if files are not zero size, they can be plotted....
	    if [ -s spec1.tab ]; then
		tabplot spec1.tab 1 2,3,4 111-4 111 line=1,1 color=2,3,4 ycoord=0 yapp=spec1.$dev/$dev
	    fi
	    if [ -s spec2.tab ]; then
		tabplot spec2.tab 1 2,3,4 111-4 111 line=1,1 color=2,3,4 ycoord=0 yapp=spec2.$dev/$dev
	    fi
	    # gaussian fit  (base,peak: mK  freq: GHz  FWHM: km/s)
	    linecheck1="$(txtpar linecheck.log %1*1000,%2*1000,%3,%4/%3*c/1000*2.355 p0=a=,1,2 p1=b=,1,2 p2=c=,1,2 p3=d=,1,2)"
	    linecheck2="$(txtpar linecheck.log %1*1000,%2*1000,%3,%4/%3*c/1000*2.355 p0=a=,2,2 p1=b=,2,2 p2=c=,2,2 p3=d=,2,2)"

	    # integral by summing under the profile  (K.km/s) of the first line in xlines=
	    if [ ! -z "$xlines" ]; then
		xc=$(echo $xlines | tabcols - 1)
		dx=$(echo $xlines | tabcols - 2)
		int1=$(tabint $spec1 1 2 $xc-$dx $xc+$dx scale=c/$xc/1000)
		int2=$(tabint $spec2 1 2 $xc-$dx $xc+$dx scale=c/$xc/1000)
		a1=$(echo $linecheck1 | tabcols - 1)
		a2=$(echo $linecheck2 | tabcols - 1)
		int1=$(nemoinp $int1-2*$a1*$dx*c/$xc/1e6)
		int2=$(nemoinp $int2-2*$a2*$dx*c/$xc/1e6)
	    else
		int1=0
		int2=0
	        df=0
	    fi
	    # recall that Flux = 1.064 * Peak * Width

	    echo linecheck1="\"$linecheck1 $int1\"" >> $rc
	    echo linecheck2="\"$linecheck2 $int2\"" >> $rc
	    printf_red LineCheck1 $linecheck1 $int1
	    printf_red LineCheck2 $linecheck2 $int2

	fi

	# try and fit the 4 strongest peaks, with xlines= a line integral is computed
	peaks=1:4
	epeak=2
	echo "LMTOY>> rsr_peaks peaks=$peaks"
	rsr_peaks.sh in=$spec1 peak=$peaks epeak=$epeak xlines=$xlines fit=fit.driver   yapp=$dev  > rsr_peaks.log  2>&1
	rsr_peaks.sh in=$spec2 peak=$peaks epeak=$epeak xlines=$xlines fit=fit.blanking yapp=$dev >> rsr_peaks.log  2>&1

    else
	echo "LMTOY>> Skipping NEMO post-processing"
    fi


    # ADMIT
    if [[ $admit == 1 ]]; then
	echo "LMTOY>> ADMIT post-processing @todo bogus vlsr"
	echo "vlsr = 12387" >> ${spec1}.apar
	echo "vlsr = 12387" >> ${spec2}.apar
	lmtoy_admit.sh ${spec1}
	lmtoy_admit.sh ${spec2}
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi

    # record the "sdfits" file, currently nothing
    sdfits_file="*.fits"
    echo "sdfits_file=$sdfits_file"  >> $rc

    echo "LMTOY>> Parameter file used: $rc"
    echo "LMTOY>> obsnum=$obsnum"
    
    rsr_readme $obsnum $src > README.html   # TheSummary
    
    cp $LMTOY/docs/README_rsr.md README_files.md

} # function rsr1


function lmtoy_seq1 {
    time=/usr/bin/time
    # input: obsnum, ... (lots)
    # this will process a single bank in an $obsnum; $bank needs to be set

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # record
    echo "LMTOY>> rc=$rc rc1=$rc1 bank=$bank"
    if [ ! -e "$rc1" ]; then
	echo "PJT_WARNING: we should not need to do this $rc -> $rc1 copy here"
	#cp $rc $rc1
	#rc=$rc1
    fi

    # fix potential pix_list
    pix_list=$(pix_list.py $pix_list)

    #  convert RAW to SpecFile (hardcoded parameters are hardcoded for a good resaon)
    if [ $makespec = 1 ]; then
	echo "LMTOY>> process_otf_map2 in 2 seconds bank=$bank"
	sleep 2
	if [ $otf_cal = 1 ]; then
	    use_otf_cal="--use_otf_cal"
	else
	    use_otf_cal=""
	fi
	if [ -z $restfreq ]; then
	    use_restfreq=""
	else
	    use_restfreq="--restfreq $restfreq"
	    use_restfreq=""	    
	    echo "WARNING: resetting restfreq not supported yet"
	fi
	if [ $birdies_shift -ne 0 ]; then
	    _birdies=$(nemoinp $birdies | tabmath - - %1+$birdies_shift all | tabtranspose - - | tabcsv -)
	else
	    _birdies=$birdies
	fi
	use_tsys="--use_cal"
	# use_tsys="--tsys 150"
	$time process_otf_map2.py \
	    -p $DATA_LMT \
	    -o $s_nc \
	    --obsnum $obsnum \
	    --pix_list $pix_list \
	    --bank $bank \
	    --stype $stype \
	    $use_tsys \
	    $use_otf_cal \
	    $use_restfreq \
	    --map_coord $map_coord_use \
	    --x_axis VLSR \
	    --b_order $b_order \
	    --b_regions $b_regions \
	    --l_region $l_regions \
	    --slice $slice \
	    --eliminate_list $_birdies \
	    --offx $offx \
	    --offy $offy
	lmtinfo2.py $s_nc >> $rc
    fi

    # bug:  --use_otf_cal does not work here?? (maybe it does now)
    # bug?   x_axis FLSR doesn't seem to go into freq mode

    # bug:   even if pix_list=10 figure 5 still shows all pixels
    #  pointings:  -240 .. 270    -259 .. 263      510x520

    if [ $viewspec = 1 ]; then
	# waterfall plot etc. (several plots are made)
	echo "LMTOY>> view_spec_file"
	view_spec_file.py \
	    -i $s_nc \
            --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --plot_range=-1,1 \
	    --plots ${s_on}_specviews
    
	# show spectra, each pixel gets a different curve/color
	echo "LMTOY>> view_spec_point"	
	view_spec_point.py \
	    -i $s_nc \
	    --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --location $location \
	    --plots ${s_on}_specpoint,png,1
	 
	echo "LMTOY>> view_spec_point"	
	view_spec_point.py \
	    -i $s_nc \
	    --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --location $location \
	    --radius 20 \
	    --plots ${s_on}_specpoint,png,2
    fi
    
    #  convert SpecFile to waterfall in fits format
    if [ $makewf = 1 ]; then
	echo "LMTOY>> make_spec_fits (waterfall)"    
	rm -rf ${s_on}.wf.fits 
	make_spec_fits.py \
	    -i $s_nc \
	    -o ${s_on}.wf.fits \
	    --pix_list $pix_list
	
	
	rm -rf ${s_on}.wf10.fits 
	make_spec_fits.py \
	    -i $s_nc \
	    -o ${s_on}.wf10.fits \
	    --pix_list $pix_list \
	    --binning 10,1

	echo "LMTOY>> stats_wf.py -y ${s_on}.wf0.png  -b ${s_on}.bstats.tab    ${s_on}.wf.fits"
	echo "LMTOY>> stats_wf.py -y ${s_on}.wf1.png  -t                       ${s_on}.wf.fits"
        stats_wf.py -y ${s_on}.wf0.png  -b ${s_on}.bstats.tab    ${s_on}.wf.fits > stats__${bank}_wf0.tab
	stats_wf.py -y ${s_on}.wf1.png  -t                       ${s_on}.wf.fits > stats__${bank}_wf1.tab
	delta=$(tabtrend ${s_on}.bstats.tab 2 | tabstat - robust=t qac=t | txtpar - p0=QAC,1,4)
	tabpeak ${s_on}.bstats.tab delta=5*$delta > ${s_on}.birdies.tab

	# stats__${bank}_wf0.tab can be used to estimate bad beams; use 5-sigma above the mean
	clip=$(tabstat stats__${bank}_wf0.tab 2 qac=t robust=t | txtpar - %1+5*%2 p0=1,3 p1=1,4)
	bb=pix_list=$(tabmath  stats__${bank}_wf0.tab - -%1 all "selfie=ifgt(%2,$clip,1,0)")
	echo "LMTOY>> bad beams might be $bb"
	if [ ! -e pix_list__${bank}.txt ]; then
	    echo $bb | sed 's/ /,/g' > pix_list__${bank}.txt
	fi

	# another whole-plane style stats
	if [ ! -e stats__${bank}_wf.tab ]; then
	    echo "first stats"
	    fitsccd ${s_on}.wf.fits - | ccdstat - planes=0 > stats__${bank}_wf.tab
	    cp stats__${bank}_wf0.tab first_stats__${bank}_wf0.tab
	    cp stats__${bank}_wf1.tab first_stats__${bank}_wf1.tab
	else
	    echo "skipping first stats"
	fi
	
    fi

    #  convert SpecFile to FITScube
    if [ $makecube = 1 ]; then
	echo "LMTOY>> grid_data native"
	$time grid_data.py \
	    --program_path spec_driver_fits \
	    -i $s_nc \
	    -o $s_fits \
	    -w $w_fits \
	    --resolution  $resolution \
	    --cell        $cell \
	    --pix_list    $pix_list \
	    --rms_cut     $rms_cut \
	    --x_extent    $x_extent \
	    --y_extent    $y_extent \
	    --otf_select  $otf_select \
	    --rmax        $rmax \
	    --otf_a       $otf_a \
	    --otf_b       $otf_b \
	    --otf_c       $otf_c \
	    --edge        $edge \
	    --sample      $sample \
	    --n_samples   256 \
	    --noise_sigma $noise_sigma

	echo "LMTOY>> grid_data smooth"
	echo "@todo this needs a new option to bin in channel space"
	s_fits2=$s_fits.fits
	w_fits2=$w_fits.fits
	$time grid_data.py \
	    --program_path spec_driver_fits \
	    -i $s_nc \
	    -o $s_fits2 \
	    -w $w_fits2 \
	    --resolution  $(nemoinp 2*$resolution) \
	    --cell        $cell \
	    --pix_list    $pix_list \
	    --rms_cut     $rms_cut \
	    --x_extent    $x_extent \
	    --y_extent    $y_extent \
	    --otf_select  $otf_select \
	    --rmax        $rmax \
	    --otf_a       $otf_a \
	    --otf_b       $otf_b \
	    --otf_c       $otf_c \
	    --edge        $edge \
	    --sample      $sample \
	    --n_samples   256 \
	    --noise_sigma $noise_sigma
	
    fi

    # bug:  when rmax=5  r=12/c=2.4  malloc(): unsorted double linked list corrupted

    # limits controls figure 5, but not figure 3, which is scaled for the whole map
    # @todo  tmax_range   tint_range
    if [ $viewcube = 1 ]; then
	echo "LMTOY>> view_cube"
	view_cube.py -i $s_fits \
		     --v_range=$v_range \
		     --v_scale=1000 \
		     --location=$location \
		     --scale=0.000278 \
		     --limits=-$x_extent,$x_extent,-$y_extent,$y_extent \
		     --tmax_range=-1,12 \
		     --tint_range=-1,400 \
		     --plot_type TMAX \
		     --interpolation bilinear
    fi
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing"
	echo "        @todo rid the code of fits header stealing"
	dev=$(yapp_query png ps)
	
	# cleanup from a previous run
	rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.rms.ccd $s_on.head1 \
	   $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd $s_on.cube3.ccd \
	   $s_on.wt2.fits $s_on.wt3.fits $s_on.wtn.fits $s_on.wtr.fits $s_on.wtr3.fits $s_on.wtr4.fits \
	   $s_on.mom0.fits $s_on.mom1.fits $s_on.rms.fits \
	   $s_on.peak.fits $s_on.ccd.fits $s_on.ns.fits

	if [ -e $s_fits ]; then
	    # convert to CCD
	    fitsccd $s_fits $s_on.ccd    axistype=1
	    fitsccd $w_fits $s_on.wt.ccd axistype=1

	    # get size and use nz1-nz2 to exclude from the axis for the rms (mom=-2) map
	    # @todo should use dv/dw:
	    # with m=nz/2/(1+dv/dw)    nz1=m nz2=nz-m
	    nz=$(ccdhead $s_on.ccd | txtpar - p0=Size,1,4)
	    nz1=$(nemoinp $nz/4 format=%d)
	    nz2=$(nemoinp $nz-$nz1)
	    
	    ccdspec $s_on.ccd > $s_on.cubespec.tab
	    ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat.tab
	    echo "LMTOY>> STATS  $s_on.ccd     centerbox robust"
	    ccdsub  $s_on.ccd -    centerbox=0.5,0.5 | ccdstat - bad=0 robust=t qac=t label=on
	    echo "LMTOY>> STATS  $s_on.wt.ccd  centerbox robust"
	    ccdsub  $s_on.wt.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t qac=t label=wt
	    
	    # convert flux flat to noise flat
	    #wmax=$(ccdstat $s_on.wt.ccd  | grep ^Min | awk '{print $6}')
	    wmax=$(ccdstat $s_on.wt.ccd  | txtpar - p0=Min,1,6)
	    
	    ccdmath $s_on.wt.ccd $s_on.wtn.ccd "sqrt(%1/$wmax)"
	    ccdmath $s_on.ccd,$s_on.wtn.ccd $s_on.n.ccd '%1*%2' replicate=t
	    ccdmom $s_on.n.ccd - mom=0	        | ccdmath - $s_on.mom0.ccd %1/1000
	    ccdmom $s_on.n.ccd - mom=1 rngmsk=t | ccdmath - $s_on.mom1.ccd %1/1000
	    ccdmom $s_on.n.ccd - mom=8	        | ccdmath - $s_on.peak.ccd %1*1000	    
	    #ccdsub $s_on.n.ccd - z=1:$nz1,$nz2:$nz | ccdmom -  $s_on.rms.ccd  mom=-2
	    ccdsub $s_on.ccd - z=1:$nz1,$nz2:$nz | ccdmom -  - mom=-2 | ccdmath - $s_on.rms.ccd %1*1000
	    # stats on the cube where there is no emission; inner 40% of map, excluding central channels (in mK)
	    ccdsub $s_on.ccd - centerbox=0.4,0.4,1 | ccdsub - - z=1:$nz1,$nz2:$nz | ccdmath - $s_on.cube3.ccd %1*1000
	    _stats=($(ccdstat $s_on.cube3.ccd bad=0 qac=t | txtpar - p0=1,4 p1=1,8))
	    rms3=${_stats[0]}
	    srat=${_stats[1]}
            ccdhist $s_on.cube3.ccd -8*$rms3 8*$rms3 ylog=t blankval=0 residual=false bins=32 \
		    xlab="Intensity [mK]" headline="RMS: $rms3 mK  Sratio: $srat" \
		    yapp=$s_on.hist.$dev/$dev
	    cp $s_on.cube3.ccd junk.pjt
	    
	    # ccdmom $s_on.n.ccd - $s_on.rms.ccd  mom=-2 arange=0:$nz1,$nz2:$nz-1

	    #ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "ifne(%1,0,2/(%1*%1),0)"
	    ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "%1/sqrt(2)"
	    ccdfits $s_on.wt2.ccd $s_on.wt2.fits # fitshead=$w_fits ndim=2
	    # e.g. [[-646,-396],[-196,54]] -> -646,-396,-196,54
	    zslabs=$(echo $b_regions | sed 's/\[//g' | sed 's/\]//g')
	    echo SLABS: $b_regions == $zslabs
	    ccdslice $s_on.ccd - zslabs=$zslabs zscale=1000 | ccdmom - - mom=-2  | ccdmath - $s_on.wt3.ccd "%1"
	    ccdfits $s_on.wt3.ccd               $s_on.wt3.fits  # fitshead=$w_fits  ndim=2
	    ccdmath $s_on.wt2.ccd,$s_on.wt3.ccd $s_on.wtr.ccd   %2/%1
	    ccdfits $s_on.wtr.ccd               $s_on.wtr.fits  # fitshead=$w_fits  ndim=2
	    ccdmath $s_on.rms.ccd,$s_on.wt3.ccd $s_on.wtr3.ccd  %2/%1
	    ccdfits $s_on.wtr3.ccd              $s_on.wtr3.fits # fitshead=$w_fits  ndim=2
	    fitsccd radiometer.rms.fits - | ccdmath -,$s_on.rms.ccd $s_on.wtr4.ccd %2/%1/1000
	    ccdfits $s_on.wtr4.ccd              $s_on.wtr4.fits # fitshead=$w_fits  ndim=2
	    mv radiometer.rms.fits $s_on.radiometer.fits

	    scanfits $s_fits $s_on.head1 select=header
	    ccdfits $s_on.n.ccd  $s_on.n.fits

	    scanfits $s_on.n.fits $s_on.data1 select=data
	    cat $s_on.head1 $s_on.data1 > $s_on.nf.fits

	    # hack : a better smooth cube?
	    #     !! new 2024 alternative:   ccdsmooth - - dir=z smooth=1/6::6 | ccdslice - - zrange=-6
	    fitsccd $s_on.fits.fits - |\
		ccdsub - - nzaver=4 |\
		ccdslice - - zrange=1:$nz:4 |\
		ccdmath -,$s_on.wtn.ccd - '%1*%2' replicate=t |\
		ccdfits - $s_on.nfs.fits # fitshead=$s_on.fits.fits

	    # this was the old smooth, it detects too many lines
	    ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.ns.fits # fitshead=$s_fits
	    
	    # QAC_STATS:
	    out1=$(ccdstat $s_on.ccd bad=0 qac=t robust=t label="${s_on}-full")
	    out2=$(ccdsub  $s_on.ccd  - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="${s_on}-cent")
	    out3=$(ccdsub  $s_on.wtr4.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="RMS/radiometer")

	    regress=$(ccdsub  $s_on.ccd  - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="${s_on}-cent")
	    echo "regress=\"$regress\"" >> $rc
	    
	    printf_red $out1
	    printf_red $out2
	    printf_red $out3

	    rms=$(echo $out2  | txtpar - "%1*1000" p0=-cent,1,4)
	    rms0=$(echo $out3 | txtpar - p0=radiometer,1,3)
	    echo "rms=$rms     # rms[mK] in center"      >> $rc
	    echo "rms0=$rms0   # RMS/radiometer ratio"   >> $rc

	    nchan=$(ccdhead $s_on.ccd  | txtpar - p0=Size,1,4)
	    echo "nchan=$nchan" >> $rc

	    # add a smooth cube version as well
	    # @todo  it seems the WCS of the nfs is off by 1
	    # @todo  use not central (ref) pixel, but use the location=  pipeline parameter
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.cubespecs.tab
	    echo -n "cubespec : ";  tail -1  $s_on.cubespec.tab
	    echo -n "cubespecs: ";  tail -1  $s_on.cubespecs.tab


	    source $rc
	    echo "TAB_PLOT   ${s_on} bank=$bank vminmax=$vmin,$vmax"
	    echo "# tmp file to plot full spectral range for ${s_on} bank=$bank"   > full_spectral_range
	    nemoinp "$vmin,0.0" newline=f                                         >> full_spectral_range
	    nemoinp "$vmax,0.0" newline=f                                         >> full_spectral_range
	    tabmath ${s_on}.cubespec.tab  - %1/1000,%2 all > native
	    tabmath ${s_on}.cubespecs.tab - %1/1000,%2 all > smooth-4x4x4
	    #   RMS in baseline region
	    #   set the height at 1-sigma of the RMS in the smoothed (4x4x4) spectrum ($hs)
	    hn=$(tabtrend native       2 | tabstat - qac=t robust=t  | txtpar - %1*1.0 p0=QAC,1,4)	    
	    hs=$(tabtrend smooth-4x4x4 2 | tabstat - qac=t robust=t  | txtpar - %1*1.0 p0=QAC,1,4)
	    echo "rms_baseline_n=$hn" >> $rc
	    echo "rms_baseline_s=$hs" >> $rc
	    echo "# straight line where vlsr is"          > vlsr
	    nemoinp "$vlsr,-$hs" newline=f               >> vlsr
	    nemoinp "$vlsr,$hs"  newline=f               >> vlsr
	    #   flux
	    center_flux_n=$(sort -n native       | tabint -)
	    center_flux_s=$(sort -n smooth-4x4x4 | tabint -)
	    echo "center_flux_n=$center_flux_n    # central pixel" >> $rc
	    echo "center_flux_s=$center_flux_s    # central pixel" >> $rc	    
	    #   box coordinates, assumed we did dv=,dw=      @todo use the uactually used b_ parameters
	    b=$(echo $vlsr,$dv,$dw | tabmath - - %1-%2-%3,-$hs,%1-%2,$hs,%1+%2,-$hs,%1+%2+%3,$hs all | tabcsv -)
	    #   baseline range
	    br=$(echo $vlsr,$dv,$dw | tabmath - - %1-%2-%3,%1+%2+%3 all)
	    tab_plot.py --xrange $vmin,$vmax --xlab "VLSR (km/s)" --ylab "Ta* (K)" \
			--irange 1,$nchan0 \
			--boxes $b \
			--title "${s_on} VLSR_range: $vmin $vmax" \
			-y spectrum_${bank}.png \
			native smooth-4x4x4 vlsr full_spectral_range 
	    tab_plot.py --xlab "VLSR (km/s)" --ylab "Ta* (K)" \
			--boxes $b \
			--title "${s_on} VLSR_range: $br" \
			-y spectrum_${bank}_zoom.png \
			native smooth-4x4x4 vlsr
	    
	    # NEMO plotting ?
	    if [ $viewnemo = 1 ]; then
		dev=$(yapp_query png ps)
		ccdplot $s_on.mom0.ccd yapp=$s_on.mom0.$dev/$dev
		ccdplot $s_on.peak.ccd yapp=$s_on.peak.$dev/$dev		
		ccdplot $s_on.mom1.ccd yapp=$s_on.mom1.$dev/$dev
		ccdplot $s_on.rms.ccd  yapp=$s_on.rms.$dev/$dev
		ccdplot $s_on.wt.ccd   yapp=$s_on.wt.$dev/$dev
		ccdplot $s_on.wt2.ccd  yapp=$s_on.wt2.$dev/$dev
		ccdplot $s_on.wt3.ccd  yapp=$s_on.wt3.$dev/$dev
		ccdplot $s_on.wtn.ccd  yapp=$s_on.wtn.$dev/$dev
		ccdplot $s_on.wtr.ccd  yapp=$s_on.wtr.$dev/$dev
		ccdplot $s_on.wtr3.ccd yapp=$s_on.wtr3.$dev/$dev
		ccdplot $s_on.wtr4.ccd yapp=$s_on.wtr4.$dev/$dev
	    fi
	    
	    # Plotting via APLPY
	    if [ 1 = 1 ]; then
		ccdfits $s_on.mom0.ccd  $s_on.mom0.fits ndim=2
		ccdfits $s_on.peak.ccd  $s_on.peak.fits ndim=2
		ccdfits $s_on.mom1.ccd  $s_on.mom1.fits ndim=2
		ccdfits $s_on.rms.ccd   $s_on.rms.fits  ndim=2
		ccdfits $s_on.wtn.ccd   $s_on.wtn.fits  ndim=2
		fitsplot.py $s_on.mom0.fits --hist
		fitsplot.py $s_on.peak.fits --hist
		fitsplot.py $s_on.mom1.fits --hist
		fitsplot.py $s_on.rms.fits --hist
		fitsplot.py $s_on.wt.fits --hist
		fitsplot.py $s_on.wt2.fits --hist
		fitsplot.py $s_on.wt3.fits --hist
		fitsplot.py $s_on.wtn.fits --hist
		fitsplot.py $s_on.wtr.fits --hist
		fitsplot.py $s_on.wtr3.fits --hist
		fitsplot.py $s_on.wtr4.fits --hist
	    fi

	    # remove useless files
	    if [ $clean -eq 1 ]; then
		rm -f $s_on.n.fits $s_on.head1 $s_on.data1 *.ccd
	    fi
	    
	    echo "LMTOY>> Created $s_on.nf.fits and $s_on.nfs.fits"
	else
	    echo "LMTOY>> Problems finding $s_fits. Skipping NEMO work."
	fi
	
    fi
    
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing"
	if [ -e $s_on.nfs.fits ]; then
	    lmtoy_admit.sh $s_on.nfs.fits
	fi
	if [ -e $s_on.ns.fits ]; then
	    lmtoy_admit.sh $s_on.ns.fits
	fi
	if [ -e $s_on.nf.fits ]; then
	    lmtoy_admit.sh $s_on.nf.fits
	else
	    # this will likely look awful since the edges are more noisy
	    lmtoy_admit.sh $s_fits
	fi
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi

    if [ $maskmoment == 1 ]; then
	# @todo   this can fail (e.g. for bench2 79448) due to too much emission?
	echo "LMTOY>> Running maskmoment $s_on.nf.fits vlsr=$vlsr"
	mm1.py --vlsr $vlsr --beam 25 $s_on.nf.fits > maskmoment__${bank}.nf.log   2>&1
	# hack
	mm1.py --vlsr $vlsr --beam 35 $s_on.nfs.fits > maskmoment__${bank}.nfs.log  2>&1
    else
	echo "LMTOY>> skipping maskmoment"	
    fi

    # record the "sdfits" file, currently just the nc files, future might be real (sd)fits files
    sdfits_file="*.nc"
    echo "sdfits_file=$sdfits_file"  >> $rc
    
    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: rc=$rc"
    
    # seq_readme > $pdir/README.html
    cp $LMTOY/docs/README_sequoia.md README_files.md
    echo "LMTOY>> Making summary index.html for bank=$bank rc=$rc"
    grep bank= $rc
    echo "LMTOY>> Making summary index.html for bank=$bank"
    mk_index.sh
    # cheat and rename it for all files access
    cp index.html README.html
    
    # record the processing time, since this is a bank specific rc file
    echo "date=\"$(lmtoy_date)\"     # end " >> $rc
    
} # lmtoy_seq1

function lmtoy_seq2 {
    time=/usr/bin/time
    # input: obsnum, ... (lots)
    # this "seq2" is really optimized for "1mm", where only beams 0..3 are
    # used, and beams 0,2 are the two polarizations to be added for bank=0
    # and beams 1,3 the two polarizations for bank=1
    

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # record
    echo "LMTOY>> rc=$rc rc1=$rc1 bank=$bank"
    if [ ! -e "$rc1" ]; then
	echo "PJT_WARNING: we should not need to do this $rc -> $rc1 copy here"
	#cp $rc $rc1
	#rc=$rc1
    fi

    # fix potential pix_list
    pix_list=$(pix_list.py $pix_list)

    #  convert RAW to SpecFile (hardcoded parameters are hardcoded for a good resaon)
    if [ $makespec = 1 ]; then
	echo "LMTOY>> process_otf_map2 in 2 seconds bank=$bank"
	sleep 2
	if [ $otf_cal = 1 ]; then
	    use_otf_cal="--use_otf_cal"
	else
	    use_otf_cal=""
	fi
	if [ -z $restfreq ]; then
	    use_restfreq=""
	else
	    use_restfreq="--restfreq $restfreq"
	    use_restfreq=""	    
	    echo "WARNING: resetting restfreq not supported yet"
	fi
	# @todo apply birdie_shift here too ?
	$time process_otf_map2.py \
	    -p $DATA_LMT \
	    -o $s_nc \
	    --obsnum $obsnum \
	    --pix_list $pix_list \
	    --bank $bank \
	    --stype $stype \
	    --use_cal \
	    $use_otf_cal \
	    $use_restfreq \
	    --map_coord $map_coord_use \
	    --x_axis VLSR \
	    --b_order $b_order \
	    --b_regions $b_regions \
	    --l_region $l_regions \
	    --slice $slice \
	    --eliminate_list $birdies
	lmtinfo2.py $s_nc >> $rc
    fi

    # bug:  --use_otf_cal does not work here?? (maybe it does now)
    # bug?   x_axis FLSR doesn't seem to go into freq mode


    # bug:   even if pix_list=10 figure 5 still shows all pixels
    #  pointings:  -240 .. 270    -259 .. 263      510x520

    if [ $viewspec = 1 ]; then
	# waterfall plot
	echo "LMTOY>> view_spec_file"
	view_spec_file.py \
	    -i $s_nc \
            --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --plot_range=-1,1 \
	    --plots ${s_on}_specviews
    
	# show spectra, each pixel gets a different curve/color
	echo "LMTOY>> view_spec_point"	
	view_spec_point.py \
	    -i $s_nc \
	    --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --location $location \
	    --plots ${s_on}_specpoint,png,1
	 
	echo "LMTOY>> view_spec_point"	
	view_spec_point.py \
	    -i $s_nc \
	    --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --location $location \
	    --radius 20 \
	    --plots ${s_on}_specpoint,png,2
    fi
    
    #  convert SpecFile to waterfall in fits format
    if [ $makewf = 1 ]; then
	echo "LMTOY>> make_spec_fits (waterfall)"    
	rm -rf ${s_on}.wf.fits 
	make_spec_fits.py \
	    -i $s_nc \
	    -o ${s_on}.wf.fits \
	    --pix_list $pix_list
	
	
	rm -rf ${s_on}.wf10.fits 
	make_spec_fits.py \
	    -i $s_nc \
	    -o ${s_on}.wf10.fits \
	    --pix_list $pix_list \
	    --binning 10,1

	echo "LMTOY>> stats_wf.py -y ${s_on}.wf0.png  -b ${s_on}.bstats.tab    ${s_on}.wf.fits"
	stats_wf.py -y ${s_on}.wf0.png  -b ${s_on}.bstats.tab    ${s_on}.wf.fits > stats__${bank}_wf0.tab
	stats_wf.py -y ${s_on}.wf1.png  -t                       ${s_on}.wf.fits > stats__${bank}_wf1.tab
	delta=$(tabtrend ${s_on}.bstats.tab 2 | tabstat - robust=t qac=t | txtpar - p0=QAC,1,4)
	tabpeak ${s_on}.bstats.tab delta=5*$delta > ${s_on}.birdies.tab

	# stats__${bank}_wf0.tab can be used to estimate bad beams; use 5-sigma above the mean
	clip=$(tabstat stats__${bank}_wf0.tab 2 qac=t robust=t | txtpar - %1+5*%2 p0=1,3 p1=1,4)
	bb=pix_list=$(tabmath  stats__${bank}_wf0.tab - -%1 all "selfie=ifgt(%2,$clip,1,0)")
	echo "LMTOY>> bad beams might be $bb"
	if [ ! -e pix_list__${bank}.txt ]; then
	    echo $bb | sed 's/ /,/g' > pix_list__${bank}.txt
	fi

    fi
    

    #  convert SpecFile to FITScube
    if [ $makecube = 1 ]; then
	echo "LMTOY>> grid_data native"
	$time grid_data.py \
	    --program_path spec_driver_fits \
	    -i $s_nc \
	    -o $s_fits \
	    -w $w_fits \
	    --resolution  $resolution \
	    --cell        $cell \
	    --pix_list    $pix_list \
	    --rms_cut     $rms_cut \
	    --x_extent    $x_extent \
	    --y_extent    $y_extent \
	    --otf_select  $otf_select \
	    --rmax        $rmax \
	    --otf_a       $otf_a \
	    --otf_b       $otf_b \
	    --otf_c       $otf_c \
	    --edge        $edge \
	    --sample      $sample \
	    --n_samples   256 \
	    --noise_sigma $noise_sigma

	echo "LMTOY>> grid_data smooth"
	echo "@todo this needs a new option to bin in channel space"
	s_fits2=$s_fits.fits
	w_fits2=$w_fits.fits
	$time grid_data.py \
	    --program_path spec_driver_fits \
	    -i $s_nc \
	    -o $s_fits2 \
	    -w $w_fits2 \
	    --resolution  $(nemoinp 2*$resolution) \
	    --cell        $cell \
	    --pix_list    $pix_list \
	    --rms_cut     $rms_cut \
	    --x_extent    $x_extent \
	    --y_extent    $y_extent \
	    --otf_select  $otf_select \
	    --rmax        $rmax \
	    --otf_a       $otf_a \
	    --otf_b       $otf_b \
	    --otf_c       $otf_c \
	    --edge        $edge \
	    --sample      $sample \
	    --n_samples   256 \
	    --noise_sigma $noise_sigma
	
    fi

    # bug:  when rmax=5  r=12/c=2.4  malloc(): unsorted double linked list corrupted

    # limits controls figure 5, but not figure 3, which is scaled for the whole map
    # @todo  tmax_range   tint_range
    if [ $viewcube = 1 ]; then
	echo "LMTOY>> view_cube"
	view_cube.py -i $s_fits \
		     --v_range=$v_range \
		     --v_scale=1000 \
		     --location=$location \
		     --scale=0.000278 \
		     --limits=-$x_extent,$x_extent,-$y_extent,$y_extent \
		     --tmax_range=-1,12 \
		     --tint_range=-1,400 \
		     --plot_type TMAX \
		     --interpolation bilinear
    fi
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing"
	echo "        @todo rid the code of fits header stealing"

	# cleanup from a previous run
	rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.rms.ccd $s_on.head1 \
	   $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd \
	   $s_on.wt2.fits $s_on.wt3.fits $s_on.wtn.fits $s_on.wtr.fits $s_on.wtr3.fits $s_on.wtr4.fits \
	   $s_on.mom0.fits $s_on.mom1.fits $s_on.rms.fits \
	   $s_on.peak.fits $s_on.ccd.fits $s_on.ns.fits

	if [ -e $s_fits ]; then
	    # convert to CCD
	    fitsccd $s_fits $s_on.ccd    axistype=1
	    fitsccd $w_fits $s_on.wt.ccd axistype=1

	    # get size and use nz1-nz2 to exclude from the axis for the rms (mom=-2) map
	    # @todo should use dv/dw:
	    # with m=nz/2/(1+dv/dw)    nz1=m nz2=nz-m
	    nz=$(ccdhead $s_on.ccd | txtpar - p0=Size,1,4)
	    nz1=$(nemoinp $nz/4 format=%d)
	    nz2=$(nemoinp $nz-$nz1)
	    
	    ccdspec $s_on.ccd > $s_on.cubespec.tab
	    ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat.tab
	    echo "LMTOY>> STATS  $s_on.ccd     centerbox robust"
	    ccdsub  $s_on.ccd -    centerbox=0.5,0.5 | ccdstat - bad=0 robust=t qac=t label=on
	    echo "LMTOY>> STATS  $s_on.wt.ccd  centerbox robust"
	    ccdsub  $s_on.wt.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t qac=t label=wt
	    
	    # convert flux flat to noise flat
	    wmax=$(ccdstat $s_on.wt.ccd  | grep ^Min | awk '{print $6}')
	    #wmax=$(ccdstat $s_on.wt.ccd  | txtpar - p0=Min,1,6)
	    
	    ccdmath $s_on.wt.ccd $s_on.wtn.ccd "sqrt(%1/$wmax)"
	    ccdmath $s_on.ccd,$s_on.wtn.ccd $s_on.n.ccd '%1*%2' replicate=t
	    ccdmom $s_on.n.ccd - mom=0	        | ccdmath - $s_on.mom0.ccd %1/1000
	    ccdmom $s_on.n.ccd - mom=1 rngmsk=t | ccdmath - $s_on.mom1.ccd %1/1000
	    ccdmom $s_on.n.ccd - mom=8	        | ccdmath - $s_on.peak.ccd %1*1000	    
	    #ccdsub $s_on.n.ccd - z=1:$nz1,$nz2:$nz | ccdmom -  $s_on.rms.ccd  mom=-2
	    ccdsub $s_on.ccd - z=1:$nz1,$nz2:$nz | ccdmom -  - mom=-2 | ccdmath - $s_on.rms.ccd %1*1000
	    # ccdmom $s_on.n.ccd - $s_on.rms.ccd  mom=-2 arange=0:$nz1,$nz2:$nz-1

	    #ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "ifne(%1,0,2/(%1*%1),0)"
	    ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "%1/sqrt(2)"
	    ccdfits $s_on.wt2.ccd $s_on.wt2.fits # fitshead=$w_fits ndim=2
	    # e.g. [[-646,-396],[-196,54]] -> -646,-396,-196,54
	    zslabs=$(echo $b_regions | sed 's/\[//g' | sed 's/\]//g')
	    echo SLABS: $b_regions == $zslabs
	    ccdslice $s_on.ccd - zslabs=$zslabs zscale=1000 | ccdmom - - mom=-2  | ccdmath - $s_on.wt3.ccd "%1"
	    ccdfits $s_on.wt3.ccd               $s_on.wt3.fits  # fitshead=$w_fits  ndim=2
	    ccdmath $s_on.wt2.ccd,$s_on.wt3.ccd $s_on.wtr.ccd   %2/%1
	    ccdfits $s_on.wtr.ccd               $s_on.wtr.fits  # fitshead=$w_fits  ndim=2
	    ccdmath $s_on.rms.ccd,$s_on.wt3.ccd $s_on.wtr3.ccd  %2/%1
	    ccdfits $s_on.wtr3.ccd              $s_on.wtr3.fits # fitshead=$w_fits  ndim=2
	    fitsccd radiometer.rms.fits - | ccdmath -,$s_on.rms.ccd $s_on.wtr4.ccd %2/%1/1000
	    ccdfits $s_on.wtr4.ccd              $s_on.wtr4.fits # fitshead=$w_fits  ndim=2
	    mv radiometer.rms.fits $s_on.radiometer.fits
	    
	    scanfits $s_fits $s_on.head1 select=header
	    ccdfits $s_on.n.ccd  $s_on.n.fits

	    scanfits $s_on.n.fits $s_on.data1 select=data
	    cat $s_on.head1 $s_on.data1 > $s_on.nf.fits

	    # hack : a better smooth cube?
	    fitsccd $s_on.fits.fits - |\
		ccdsub - - nzaver=4 |\
		ccdslice - - zrange=1:$nz:4 |\
		ccdmath -,$s_on.wtn.ccd - '%1*%2' replicate=t |\
		ccdfits - $s_on.nfs.fits # fitshead=$s_on.fits.fits

	    # this was the old smooth, it detects too many lines
	    ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.ns.fits # fitshead=$s_fits
	    
	    # QAC_STATS:
	    out1=$(ccdstat $s_on.ccd bad=0 qac=t robust=t label="${s_on}-full")
	    out2=$(ccdsub  $s_on.ccd  - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="${s_on}-cent")
	    out3=$(ccdsub  $s_on.wtr4.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="RMS/radiometer")

	    regress=$(ccdsub  $s_on.ccd  - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="${s_on}-cent")
	    echo "regress=\"$regress\"" >> $rc
	    
	    printf_red $out1
	    printf_red $out2
	    printf_red $out3

	    rms=$(echo $out2  | txtpar - "%1*1000" p0=-cent,1,4)
	    rms0=$(echo $out3 | txtpar - p0=radiometer,1,3)
	    echo "rms=$rms     # rms[mK] in center"      >> $rc
	    echo "rms0=$rms0   # RMS/radiometer ratio"   >> $rc

	    nchan=$(ccdhead $s_on.ccd  | txtpar - p0=Size,1,4)
	    echo "nchan=$nchan" >> $rc

	    # add a smooth cube version as well
	    # @todo  it seems the WCS of the nfs is off by 1
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.cubespecs.tab
	    echo -n "cubespec : ";  tail -1  $s_on.cubespec.tab
	    echo -n "cubespecs: ";  tail -1  $s_on.cubespecs.tab

	    source $rc
	    echo "TAB_PLOT   ${s_on} bank=$bank vminmax=$vmin,$vmax"
	    echo "# tmp file to plot full spectral range for ${s_on} bank=$bank"   > full_spectral_range
	    nemoinp "$vmin,0.0" newline=f                                         >> full_spectral_range
	    nemoinp "$vmax,0.0" newline=f                                         >> full_spectral_range
	    tabmath ${s_on}.cubespec.tab  - %1/1000,%2 all > native
	    tabmath ${s_on}.cubespecs.tab - %1/1000,%2 all > smooth-4x4x4
	    #   RMS in baseline region
	    #   set the height at 1-sigma of the RMS in the smoothed (4x4x4) spectrum ($hs)
	    hn=$(tabtrend native       2 | tabstat - qac=t robust=t  | txtpar - %1*1.0 p0=QAC,1,4)	    
	    hs=$(tabtrend smooth-4x4x4 2 | tabstat - qac=t robust=t  | txtpar - %1*1.0 p0=QAC,1,4)
	    echo "rms_baseline_n=$hn" >> $rc
	    echo "rms_baseline_s=$hs" >> $rc
	    echo "# straight line where vlsr is"          > vlsr
	    nemoinp "$vlsr,-$hs" newline=f               >> vlsr
	    nemoinp "$vlsr,$hs"  newline=f               >> vlsr
	    #   flux
	    center_flux_n=$(sort -n native       | tabint -)
	    center_flux_s=$(sort -n smooth-4x4x4 | tabint -)
	    echo "center_flux_n=$center_flux_n    # central pixel" >> $rc
	    echo "center_flux_s=$center_flux_s    # central pixel" >> $rc	    
	    #   box coordinates, assumed we did dv=,dw=      @todo use the uactually used b_ parameters
	    b=$(echo $vlsr,$dv,$dw | tabmath - - %1-%2-%3,-$hs,%1-%2,$hs,%1+%2,-$hs,%1+%2+%3,$hs all | tabcsv -)
	    #   baseline range
	    br=$(echo $vlsr,$dv,$dw | tabmath - - %1-%2-%3,%1+%2+%3 all)
	    tab_plot.py --xrange $vmin,$vmax --xlab "VLSR (km/s)" --ylab "Ta* (K)" \
			--boxes $b \
			--title "${s_on} VLSR_range: $vmin $vmax" \
			-y spectrum_${bank}.png \
			native smooth-4x4x4 vlsr full_spectral_range 
	    tab_plot.py --xlab "VLSR (km/s)" --ylab "Ta* (K)" \
			--boxes $b \
			--title "${s_on} VLSR_range: $br" \
			-y spectrum_${bank}_zoom.png \
			native smooth-4x4x4 vlsr
	    
	    # NEMO plotting ?
	    if [ $viewnemo = 1 ]; then
		dev=$(yapp_query png ps)
		ccdplot $s_on.mom0.ccd yapp=$s_on.mom0.$dev/$dev
		ccdplot $s_on.peak.ccd yapp=$s_on.peak.$dev/$dev		
		ccdplot $s_on.mom1.ccd yapp=$s_on.mom1.$dev/$dev
		ccdplot $s_on.rms.ccd  yapp=$s_on.rms.$dev/$dev
		ccdplot $s_on.wt.ccd   yapp=$s_on.wt.$dev/$dev
		ccdplot $s_on.wt2.ccd  yapp=$s_on.wt2.$dev/$dev
		ccdplot $s_on.wt3.ccd  yapp=$s_on.wt3.$dev/$dev
		ccdplot $s_on.wtn.ccd  yapp=$s_on.wtn.$dev/$dev
		ccdplot $s_on.wtr.ccd  yapp=$s_on.wtr.$dev/$dev
		ccdplot $s_on.wtr3.ccd yapp=$s_on.wtr3.$dev/$dev
		ccdplot $s_on.wtr4.ccd yapp=$s_on.wtr4.$dev/$dev
	    fi
	    
	    # Plotting via APLPY
	    if [ 1 = 1 ]; then
		ccdfits $s_on.mom0.ccd  $s_on.mom0.fits ndim=2
		ccdfits $s_on.peak.ccd  $s_on.peak.fits ndim=2
		ccdfits $s_on.mom1.ccd  $s_on.mom1.fits ndim=2
		ccdfits $s_on.rms.ccd   $s_on.rms.fits  ndim=2
		ccdfits $s_on.wtn.ccd   $s_on.wtn.fits  ndim=2
		fitsplot.py $s_on.mom0.fits --hist
		fitsplot.py $s_on.peak.fits --hist
		fitsplot.py $s_on.mom1.fits --hist
		fitsplot.py $s_on.rms.fits --hist
		fitsplot.py $s_on.wt.fits --hist
		fitsplot.py $s_on.wt2.fits --hist
		fitsplot.py $s_on.wt3.fits --hist
		fitsplot.py $s_on.wtn.fits --hist
		fitsplot.py $s_on.wtr.fits --hist
		fitsplot.py $s_on.wtr3.fits --hist
		fitsplot.py $s_on.wtr4.fits --hist
	    fi

	    # remove useless files
	    if [ $clean -eq 1 ]; then
		rm -f $s_on.n.fits $s_on.head1 $s_on.data1 *.ccd
	    fi
	    
	    echo "LMTOY>> Created $s_on.nf.fits and $s_on.nfs.fits"
	else
	    echo "LMTOY>> Problems finding $s_fits. Skipping NEMO work."
	fi
	
    fi
    
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing"
	if [ -e $s_on.nfs.fits ]; then
	    lmtoy_admit.sh $s_on.nfs.fits
	fi
	if [ -e $s_on.ns.fits ]; then
	    lmtoy_admit.sh $s_on.ns.fits
	fi
	if [ -e $s_on.nf.fits ]; then
	    lmtoy_admit.sh $s_on.nf.fits
	else
	    # this will likely look awful since the edges are more noisy
	    lmtoy_admit.sh $s_fits
	fi
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi

    if [ $maskmoment == 1 ]; then
	# @todo   this can fail (e.g. for bench2 79448) due to too much emission?
	echo "LMTOY>> Running maskmoment $s_on.nf.fits vlsr=$vlsr"
	mm1.py --vlsr $vlsr --beam 25 $s_on.nf.fits > maskmoment__${bank}.nf.log   2>&1
	# hack
	mm1.py --vlsr $vlsr --beam 35 $s_on.nfs.fits > maskmoment__${bank}.nfs.log  2>&1
    else
	echo "LMTOY>> skipping maskmoment"	
    fi
    
    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: rc=$rc"
    
    # seq_readme > $pdir/README.html
    cp $LMTOY/docs/README_sequoia.md README_files.md
    echo "LMTOY>> Making summary index.html for bank=$bank rc=$rc"
    grep bank= $rc
    echo "LMTOY>> Making summary index.html for bank=$bank"
    mk_index.sh
    # cheat and rename it for all files access
    cp index.html README.html

    # record the processing time, since this is a bank specific rc file
    echo "date=\"$(lmtoy_date)\"     # end " >> $rc
    
} # lmtoy_seq2

function lmtoy_bs1 {
    # input: obsnum, ... (lots)
    # this will process a single bank=$bank in an $obsnum

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # record
    echo "LMTOY>> rc=$rc rc1=$rc1 bank=$bank"
    
    spec=${src}_${obsnum}__${bank}.txt
    echo "LMTOY>> spectrum will be in $spec"

    # waterfall -> bs-2.png
    echo "LMTOY>> process_bs.py --obs_list $obsnum --pix_list $pix_list --use_cal --block -2 --stype $stype --bank $bank"
                  process_bs.py --obs_list $obsnum --pix_list $pix_list --use_cal --block -2 --stype $stype --bank $bank
    mv bs-2.png  bs-2__${bank}.png

    # full average -> bs-1.png   (final Bs spectrum)
    echo "LMTOY>> process_bs.py --obs_list $obsnum --pix_list $pix_list --use_cal --block -1 --stype $stype --bank $bank -o $spec"
                  process_bs.py --obs_list $obsnum --pix_list $pix_list --use_cal --block -1 --stype $stype --bank $bank -o $spec
    mv bs-1.png  bs-1__${bank}.png
    
    title="LMT $instrument/$obspgm bank=${bank}"
    seq_spectra.py -t "$title" -y seq.spectra__${bank}.png $spec
    seq_spectra.py -t "$title" -y seq.spectra__${bank}.svg $spec    

    # QAC robust stats off the spectrum
    out4=$(tabmath $spec - %2*1000 all | tabstat -  qac=t robust=t label=$spec)
    printf_red $out4
    
    # tsys
    dev=$(yapp_query png vps)
    #tabplot $spec ycol=3,4 ymin=0 ymax=400 xlab="VLSR (km/s)" ylab="Tsys (K)"  color=2,3 yapp=tsys__${bank}.$dev/$dev
    tabplot $spec ycol=3,4 xlab="VLSR (km/s)" ylab="Tsys (K)"  color=2,4 line=1,1 yapp=tsys__${bank}.$dev/$dev
    convert tsys__${bank}.$dev tsys__${bank}.jpg
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing (TBD)"
	bw="$(nemoinp 800*1e6/2048)"
	tsys=115
	rms0=$(nemoinp "1000*$tsys/sqrt($bw*$inttime)")
	echo "NEMO: inttime=$inttime s  bw=$bw Hz  tsys=$tsys K  rms0=$rms0 K"
    fi
    
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing (TBD)"
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi
    
    
    echo "LMTOY>> Parameter file used: $rc"
    
    seqbs_readme $obsnum $src > $pdir/README.html
    # cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    # mk_index.sh
    # cheat and rename it for all files access
    # mv index.html README.html
    
} # lmtoy_bs1


function lmtoy_ps1 {
    # input: obsnum, ... (lots)
    # this will process a single bank=$bank in an $obsnum

    # for 1MM only roach0 is used, so bank=0 is needed, and oid= is used to identify the "bank" being 0 or 1
    # we thus hardcode the bank itself to be 0,so it looks at the right roach
    if [ $instrument = "1MM" ]; then
	if [ $bank == 0 ]; then
	    pix_list=0,2
	elif [ $bank == 1 ]; then
	    pix_list=1,3
	else
	    echo "LMTOY>> Illegal bank $bank"
            exit 0
	fi
	echo "LMTOY>> 1MM overriding pix_list=$pix_list bank=$bank"
    fi

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # record
    echo "LMTOY>> rc=$rc rc1=$rc1 bank=$bank"

    spec=${src}_${obsnum}__${bank}.txt
    echo "LMTOY>> spectrum will be in $spec"
    
    # full average final Ps spectrum
    sargs="--slice [-40,40]"
    echo "LMTOY>> process_ps.py --obs_list $obsnum --pix_list $pix_list --use_cal --stype $stype --bank $bank -o $spec $sargs"
                  process_ps.py --obs_list $obsnum --pix_list $pix_list --use_cal --stype $stype --bank $bank -o $spec $sargs
    title="LMT Spectrum $instrument/$obspgm"
    seq_spectra.py -t "$title $bank" -y seq.spectra__${bank}.png $spec
    seq_spectra.py -t "$title $bank" -y seq.spectra__${bank}.svg $spec

    title="LMT Tsys $instrument/$obspgm"    
    seq_spectra.py -t "$title $bank" -y seq.tsys__${bank}.png -c 3 $spec
    seq_spectra.py -t "$title $bank" -y seq.tsys__${bank}.svg -c 3 $spec

    # QAC robust stats off the spectrum in mK
    out4=$(tabmath $spec - %2*1000 all | tabstat -  qac=t robust=t label=$spec)
    printf_red $out4

    # for rc and archive yaml
    nchan=$(tabrows $spec|wc -l)    
    rms=$(tabstat  $spec 2 bad=0 robust=t qac=t | txtpar - p0=1,4)
    echo "nchan=$nchan" >> $rc    
    echo "rms=$rms"     >> $rc
    echo "nchan0=8192"  >> $rc    # @todo fix
    echo "bank=$bank"   >> $rc
    
    # tsys
    #dev=$(yapp_query png vps)
    #tabplot $spec ycol=3,4 ymin=0 ymax=400 xlab="VLSR (km/s)" ylab="Tsys (K)"  yapp=tsys.$dev/$dev
    #convert tsys.$dev tsys.jpg
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing"

    fi
    
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing (TBD)"
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi

    echo "date=\"$(lmtoy_date)\"     # end " >> $rc    
    
    
    echo "LMTOY>> Parameter file used: $rc"
    
    seqps_readme $obsnum $src > $pdir/README.html
    # cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    # mk_index.sh
    # cheat and rename it for all files access
    # mv index.html README.html
    
} # lmtoy_ps1


