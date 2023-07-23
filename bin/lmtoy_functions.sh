#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations
#   beware, in bash shell variables are common variables between this and the caller

lmtoy_version="20-jul-2023"

echo "LMTOY>> lmtoy_functions $lmtoy_version via $0"

function lmtoy_version {
    local v=$(cat $LMTOY/VERSION)
    local d=$(date -u +%Y-%m-%dT%H:%M:%S)
    local g=$(cd $LMTOY; git rev-list --count HEAD)
    local h=$(uname -a)
    echo "$v  $g  $d  $h"
}

function lmtoy_date {
    # standard ISO date, by default in local time.   Use "-u" to switch to UT time
    date +%Y-%m-%dT%H:%M:%S $*
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
    printf_red "LMTOY>> ProjectId=$ProjectId  obsnum=$obsnum oid=$oid obspgm=$obspgm  obsgoal=$obsgoal date_obs=$date_obs"
}

function lmtoy_args {
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
    # save them (they are saved in lmtoy_args.log)
    _lmtoy_args="$@"
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
    echo OBSNUM: $obsnum
    echo OBSNUMS: $obsnums
    echo OBSNUMS1: $obsnums1
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

function show_vars {
    # helper function to show value of shell variables using bash dynamic variables
    # meant to be stored in an rc file
    for _arg in "$@"; do
	echo "${_arg}=${!_arg}"
    done
    
}

function qac_select {
    msg=$(grep ^$1 $LMTOY/etc/qac_stats.log | sed s/$1//)
    if [ -z "$msg" ]; then
	printf_red Warning: No qac_select for $1
    else
	printf_green $msg
    fi
    
}

function lmtoy_rsr1 {
    # input:  first, obsnum, badlags, blanking, rfile, ....

    # New order of reduction for single obsnum cases
    #  1. run rsr_driver to get a "first" spectrum, with whatever badlags are in dreampyrc
    #  2. get Tsys0, which also gives some badcb0= (which we ignore)
    #  3. run badlags, this also gives some badcb1=
    #  4. try rsr_driver again, just to apply these badlags
    #  5. get Tsys1, now done with the badlags. these also give a badcb2=, which we could use
    #  6. final rsr_driver, using badlags and badcb1,badcb2
    #  7. final rsr_sum,    using badlags and badcb1,badcb2

    # log the version
    lmtoy_version > lmtoy.rc
    # set the dreampy.log logger filename in the local OBSNUM directory
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
	echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf0.pdf -p -b $blo $t1 $t2"
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf0.pdf -p -b $blo $t1 $t2   > rsr_driver0.log 2>&1
	mv rsr.driver.png rsr.driver0.png
	# 2.
	echo "LMTOY>> rsr_tsys.py -s $obsnum"
	rsr_tsys.py -s $obsnum   > rsr_tsys0.log   2>&1
	mv rsr.tsys.png rsr.tsys0.png
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
	echo "LMTOY>> badlags.py -d -s $bopts --spike $spike $obsnum"
	badlags.py -d -s $bopts --spike $spike $obsnum > rsr_badlags.log 2>&1
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
	
	# 4.
	echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf.pdf -p -b $blo $t1 $t2 --badlags $badlags"
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf.pdf -p -b $blo $t1 $t2 --badlags $badlags > rsr_driver1.log 2>&1	


	# Tsys plot:  rsr.tsys.png  - only done for single obsnum - also lists BADCB's
	#             rsr.spectra.png - another way to view each chassis spectrum
	#             Only make this plot for single obsnum's
	if [ "$obsnum" -gt 0 ]; then
	    # 5.
	    echo "LMTOY>> rsr_tsys.py -b $badlags    -s $obsnum"
	    echo "LMTOY>> rsr_tsys.py -b $badlags -t -s $obsnum"
	    rsr_tsys.py -b $badlags    -s $obsnum         > rsr_tsys2.log 2>&1
	    rsr_tsys.py -b $badlags -t -s $obsnum         > rsr_tsys1.log 2>&1
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
	echo "PJT1 obsnum=$obsnum obsnums=$obsnums"	
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
	echo "PJT3 obsnum=$obsnum obsnums=$obsnums"
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
    echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t1 $t2 $f $nbs"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t1 $t2 $f $nbs   > rsr_driver_nbs.log 2>&1
    mv rsr.driver.png rsr.driver_nbs.png
    echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t1 $t2 $f"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t1 $t2 $f   > rsr_driver.log 2>&1
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
	    rsr_spectra.py -s -o $spec1 $s1
	    rsr_spectra.py -s -o $spec2 $s2
	    
	    rsr_spectra.py -s old/$spec1 $spec1
	    mv rsr.spectra.png rsr.spectra.cmp1.png
	    rsr_spectra.py -s old/$spec2 $spec2
	    mv rsr.spectra.png rsr.spectra.cmp2.png
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
    echo "LMTOY>> rsr_spectra.py -s  $zoom   --title $src $spec1 $spec2"
    rsr_spectra.py -s     $zoom --title "$src .$wpre" $spec1 $spec2
    mv rsr.spectra.png rsr.spectra_zoom.png
    rsr_spectra.py -s           --title "$src .$wpre" $spec1 $spec2
    rsr_spectra.py -s -g        --title "$src .$wpre" $spec1 $spec2

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
	tabplot  $spec1 line=1,1 color=2 ycoord=0        yapp=${spec1}.sp.$dev/$dev  debug=-1
	tabplot  $spec2 line=1,1 color=2 ycoord=0        yapp=${spec2}.sp.$dev/$dev  debug=-1
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

	# regress on the driver.sum.txt file
	#regress=$(tabstat $spec1 2 bad=0 robust=t qac=t | txtpar - p0=1,4)
	regress=$(tabstat $spec1 2 bad=0 robust=t qac=t)
	echo "regress=\"$regress\"" >> $rc

	if [ $obsgoal = "LineCheck" ]; then
	    echo "LMTOY>> LineCheck"
	    rm -f spec1.tab spec2.tab
	    #  good for I17208, I12112, I10565
	    xrange=106:111
	    echo  "# tabnllsqfit $spec1 fit=gauss1d xrange=$xrange"      > linecheck.log
	    tabnllsqfit $spec1 fit=gauss1d xrange=$xrange out=spec1.tab >> linecheck.log  2>&1
	    echo  "# tabnllsqfit $spec2 fit=gauss1d xrange=$xrange"     >> linecheck.log
	    tabnllsqfit $spec2 fit=gauss1d xrange=$xrange out=spec2.tab >> linecheck.log  2>&1
	    #   catch bad fits
	    echo  "rms= 0"                                              >> linecheck.log
	    echo  "rms= 0"                                              >> linecheck.log
	    if [ -s spec1.tab ]; then
		tabplot spec1.tab 1 2,3,4 111-4 111 line=1,1 color=2,3,4 ycoord=0 yapp=spec1.$dev/$dev
	    fi
	    if [ -s spec2.tab ]; then
		tabplot spec2.tab 1 2,3,4 111-4 111 line=1,1 color=2,3,4 ycoord=0 yapp=spec2.$dev/$dev
	    fi

	    printf_red LineCheck1 $(txtpar linecheck.log %1*1000,%2*1000,%3,%4/%3*c/1000*2.355 p0=a=,1,2 p1=b=,1,2 p2=c=,1,2 p3=d=,1,2)
	    printf_red LineCheck2 $(txtpar linecheck.log %1*1000,%2*1000,%3,%4/%3*c/1000*2.355 p0=a=,2,2 p1=b=,2,2 p2=c=,2,2 p3=d=,2,2)
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

    echo "LMTOY>> Parameter file used: $rc"
    echo "LMTOY>> obsnum=$obsnum"
    
    rsr_readme $obsnum $src > README.html
    
    cp $LMTOY/docs/README_rsr.md README_files.md

} # function rsr1


function lmtoy_seq1 {
    # input: obsnum, ... (lots)
    # this will process a single bank in an $obsnum; $bank and $oid needs to be set

    # log the version
    lmtoy_version >> lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    # record
    echo "LMTOY>> rc=$rc rc1=$rc1 bank=$bank oid=$oid"

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
	process_otf_map2.py \
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

	echo "LMTOY>> stats_wf"
	stats_wf.py -s -b ${s_on}.bstats.tab    ${s_on}.wf.fits > stats_wf0.tab
	mv stats_wf0.png ${s_on}.wf0.png
	stats_wf.py -s                       -t ${s_on}.wf.fits > stats_wf1.tab
	mv stats_wf1.png ${s_on}.wf1.png	
	delta=$(tabtrend ${s_on}.bstats.tab 2 | tabstat - robust=t qac=t | txtpar - p0=QAC,1,4)
	tabpeak ${s_on}.bstats.tab delta=5*$delta > ${s_on}.birdies.tab	
    fi
    

    #  convert SpecFile to FITScube
    if [ $makecube = 1 ]; then
	echo "LMTOY>> grid_data native"
	grid_data.py \
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
	grid_data.py \
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

	    # hack
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.cubespecs.tab
	    echo -n "cubespec : ";  tail -1  $s_on.cubespec.tab
	    echo -n "cubespecs: ";  tail -1  $s_on.cubespecs.tab

	    source $rc
	    echo "TAB_PLOT   ${s_on} bank=$bank vminmax=$vmin,$vmax"
	    echo "# tmp file to plot full spectral range for ${s_on} bank=$bank"   > full_spectral_range
	    nemoinp "$vmin,0.0" newline=f                                         >> full_spectral_range
	    nemoinp "$vmax,0.0" newline=f                                         >> full_spectral_range
	    tabmath ${s_on}.cubespec.tab  - %1/1000,%2 all > cubespec.tab
	    tabmath ${s_on}.cubespecs.tab - %1/1000,%2 all > cubespecs.tab
	    #   set the height at 1-sigma of the RMS in the smoothed (cubespecs) spectrum
	    h=$(tabtrend cubespecs.tab 2 | tabstat -  | txtpar - %1*1.0 p0=disp,1,2)
	    #   box coordinates, assumed we did dv=,dw=      @todo use the uactually used b_ parameters
	    b=$(echo $vlsr,$dv,$dw | tabmath - - %1-%2-%3,-$h,%1-%2,$h,%1+%2,-$h,%1+%2+%3,$h all | tabcsv -)
	    tab_plot.py -s --xrange $vmin,$vmax --xlab "VLSR (km/s)" --ylab "Ta* (K)" \
			--boxes $b \
			--title "${s_on} Vminmax=$vmin,$vmax" \
			cubespec.tab cubespecs.tab full_spectral_range
	    mv tab_plot.png spectrum_${bank}.png
	    
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

    # maskmoment
    if [ $maskmoment = 1 ]; then
	echo "LMTOY>> Running maskmoment vlsr=$vlsr"
	mm1.py $s_on.nf.fits   $vlsr > maskmoment.nf.log   2>&1
	# hack
	mm1.py $s_on.nfs.fits  $vlsr > maskmoment.nfs.log  2>&1
    else
	echo "LMTOY>> skipping maskmoment"	
    fi
    
    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: rc=$rc"
    
    # seq_readme > $pdir/README.html
    cp $LMTOY/docs/README_sequoia.md README_files.md
    echo "LMTOY>> Making summary index.html for bank=$bank"
    grep bank= $rc
    echo "LMTOY>> Making summary index.html for oid=$oid"
    mk_index.sh
    # cheat and rename it for all files access
    mv index.html README.html
    
} # lmtoy_seq1

function lmtoy_bs1 {
    # input: obsnum, ... (lots)
    # this will process a single bank in an $obsnum

    # log the version
    lmtoy_version > lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi
    spec=${src}_${obsnum}__${oid}.txt
    echo "LMTOY>> spectrum in $spec"

    # for a waterfall -> bs-2.png
    echo "LMTOY>> process_bs.py --obs_list $obsnum--pix_list $pix_list --use_cal --block -2 --stype $stype --bank $bank"
    process_bs.py --obs_list $obsnum --pix_list $pix_list --use_cal --block -2 --stype $stype --bank $bank

    # full average -> bs-1.png
    echo "LMTOY>> process_bs.py --obs_list $obsnum -o $spec --pix_list $pix_list --use_cal --block -1 --stype $stype  --bank $bank"
    process_bs.py --obs_list $obsnum -o $spec --pix_list $pix_list --use_cal --block -1 --stype $stype --bank $bank
    seq_spectra.py -s $spec
    seq_spectra.py -s -z $spec

    out4=$(tabmath $spec - %2*1000 all | tabstat -  qac=t robust=t label=$spec)
    printf_red $out4
    
    # tsys
    dev=$(yapp_query png vps)
    tabplot $spec ycol=3,4 ymin=0 ymax=400 xlab="VLSR (km/s)" ylab="Tsys (K)"  yapp=tsys.$dev/$dev
    convert tsys.$dev tsys.jpg
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing"

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
    # this will process a single bank in an $obsnum

    # log the version
    lmtoy_version > lmtoy.rc
    # keep an IFPROC header
    if [ ! -e lmtoy_$obsnum.ifproc ]; then
	ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    fi

    # for a waterfall -> bs-2.png
    process_ps.py --obs_list $obsnum -o junk2.txt --pix_list $pix_list --use_cal --block -2 --stype $stype

    # full average -> bs-1.png
    echo "LMTOY>> process_ps.py --obs_list $obsnum -o ${src}_${obsnum}.txt --pix_list $pix_list --use_cal --block -1 --stype $stype"
    process_ps.py --obs_list $obsnum -o ${src}_${obsnum}.txt --pix_list $pix_list --use_cal --block -1 --stype $stype
    seq_spectra.py -s ${src}_${obsnum}.txt
    seq_spectra.py -s -z ${src}_${obsnum}.txt

    out4=$(tabmath ${src}_${obsnum}.txt - %2*1000 all | tabstat -  qac=t robust=t label=${src}_${obsnum}.txt)
    printf_red $out4
    
    # tsys
    dev=$(yapp_query png vps)
    tabplot ${src}_${obsnum}.txt ycol=3,4 ymin=0 ymax=400 xlab="VLSR (km/s)" ylab="Tsys (K)"  yapp=tsys.$dev/$dev
    convert tsys.$dev tsys.jpg
    
    if [ -n "$NEMO" ]; then
	echo "LMTOY>> Some NEMO post-processing"

    fi
    
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing (TBD)"
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi
    
    
    echo "LMTOY>> Parameter file used: $rc"
    
    seqps_readme $obsnum $src > $pdir/README.html
    # cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    # mk_index.sh
    # cheat and rename it for all files access
    # mv index.html README.html
    
} # lmtoy_ps1
