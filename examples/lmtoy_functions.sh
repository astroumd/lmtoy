#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations
#   beware, shell variables are common variables between this and the caller

lmtoy_version="18-jan-2023"

echo "LMTOY>> READING lmtoy_functions $lmtoy_version via $0"

function lmtoy_version {
    v=$(cat $LMTOY/VERSION)
    d=$(date -u +%Y-%m-%dT%H:%M:%S)
    g=$(cd $LMTOY; git rev-list --count HEAD)
    h=$(uname -a)
    echo "$v  $g  $d  $h"
}

function lmtoy_report {
    printf_red "LMTOY>> ProjectId=$ProjectId  obsnum=$obsnum  obspgm=$obspgm  obsgoal=$obsgoal oid=$oid"
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
	return
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
    #  4. try rsr_driver, just to apply these badlags
    #  5. get Tsys1, now done with the badlags. these also give a badcb2=, which we could use
    #  6. final rsr_driver, using badlags and badcb1,badcb2
    #  7. final rsr_sum,    using badlags and badcb1,badcb2

    # log the version
    lmtoy_version > lmtoy.rc

    # spec1:    output spectrum rsr.$obsnum.driver.txt
    #       xlines=110.51,0.15,108.65,0.3,85.2,0.4    - example for I10565
    spec1="rsr.${obsnum}.driver.sum.txt"
    b="--badlags $badlags"
    r="--rfile $rfile"
    o="-o $spec1"
    w="-w rsr.wf.pdf"
    t=""
    t="-r 0.01"
    blo="1"
    if [ "$xlines" != "" ]; then
	l="--exclude $(echo $xlines | sed 's/,/ /g')"
    else
	l=""
    fi
    
    # deal with a first run -
    # Before july-2022 we reset with empty badlags entry in dreampy config with no bad lags
    # in order to be able to run serially with reproduceable results.
    # Now we make the dreampy config file read-only so we can run in parallel 
    _old_serial=0
    if [[ $first == 1 ]]; then
	# 1.
	if [[ $_old_serial == 1 ]]; then
	    echo '# empty badlags' > rsr.badlags
	    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf0.pdf -p -b $blo $t --badlags rsr.badlags   > rsr_driver0.log 2>&1
        else
	    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf0.pdf -p -b $blo $t > rsr_driver0.log 2>&1
	fi
	# 2.
	python $LMTOY/examples/rsr_tsys.py -s $obsnum            > rsr_tsys0.log  2>&1
	mv rsr.tsys.png rsr.tsys0.png
    fi

    # FIRST get the badlags - this is a file that can be edited by the user in later re-runs
    # output: rsr.$obsnum.badlags badlags.png
    #         rsr.$obsnum.rfile and rsr.$obsnum.blanking  - can be modified if #BADCB's have been found
    if [[ ! -e $badlags ]]; then
	#     only for a single obsnum run
	# 3.
	python $LMTOY/examples/badlags.py -s $obsnum   > rsr_badlags.log 2>&1
	#  -b bc_threshold
	#  -p plotmax
	
	# 4.
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf.pdf -p -b $blo $t --badlags rsr.badlags   > rsr_driver1.log 2>&1	

	# keep the old one (for the bad rsr_tsys.py parser)
	cp rsr.badlags $badlags

	# Tsys plot:  rsr.tsys.png  - only done for single obsnum - also lists BADCB's
	#             rsr.spectrum.png - another way to view each chassis spectrum
	#             -b will use fixed name 'rsr.badlags' for badlags
	if [[ -z "$obsnums" ]]; then
	    # 5.
	    python $LMTOY/examples/rsr_tsys.py -b    -s $obsnum         > rsr_tsys.log  2>&1
	    python $LMTOY/examples/rsr_tsys.py -b -t -s $obsnum         > rsr_tsys2.log 2>&1
	    grep CB rsr_tsys0.log  > tab0
	    grep CB rsr_tsys.log   > tab1
	    paste tab0 tab1 | awk '{print $0," ratio:",$11/$5}'  > rsr_tsys_badcb.log 
	fi	

	# this step could be debatable
	grep '#BADCB' rsr_tsys.log >> $badlags
	rsr_badcb -r $badlags >> $rfile 
	rsr_badcb -b $badlags >> $blanking
	echo "PJT1 obsnum=$obsnum obsnums=$obsnums"	
    elif [ ! -z "$obsnums" ]; then
	#  only for obsnum combinations
	echo "PJT2 obsnum=$obsnum obsnums=$obsnums"
    else
	#  only for a single obsnum run
	#  @todo initial settings lost
	echo "Using existing $badlags - forgetting initial settings"
	rsr_badcb -r $badlags > $rfile
	rsr_badcb -b $badlags > $blanking
	echo "PJT3 obsnum=$obsnum obsnums=$obsnums"
    fi
    
    #   We have two similar scripts of difference provenance that produce a final spectrum
    #   they only differ in the way blanking and baseline subtraction happens, and the idea
    #   is that this should become one final program.
    #   On the other hand, it's a good check if the two are producing the same spectrum
    

    # 6.
    #   note, we're not using all the options for rsr_driver, .e.g
    #   -t, -f, -s, -r, -n
    echo "LMTOY>> python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo $t          > rsr_driver.log 2>&1
    #  ImageMagick:   this step can fail with some weird security policy error :-(
    #  edit /etc/ImageMagick-*/policy.xml:     rights="read | write" pattern="PDF"
    #  One solution:  copy $LMTOY/etc/policy.xml to ~/.config/ImageMagick/policy.xml
    convert rsr.wf.pdf rsr.wf.png

    # 7.
    # spec2: output spectrum rsr.$obsnum.blanking.sum.txt
    spec2=${blanking}.sum.txt
    echo "LMTOY>>  python $LMTOY/examples/rsr_sum.py -b $blanking  $b  --o1 $blo"
    python $LMTOY/examples/rsr_sum.py -b $blanking  $b  --o1 $blo                         > rsr_sum.log 2>&1

    

    # plot the two in one spectrum, one full range, one the last band, closest to "CO"
    # the -z version makes an svg file for an alternative way to zoom in (TBD)
    # @todo a more interactive pan&zoom version ala matplotlib for online use
    python $LMTOY/examples/rsr_spectra.py -s -co $spec1 $spec2
    mv rsr.spectra.png rsr.spectra_co.png
    python $LMTOY/examples/rsr_spectra.py -s     $spec1 $spec2
    python $LMTOY/examples/rsr_spectra.py -s -z  $spec1 $spec2

    
    # NEMO summary spectra
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
	printf_red $(tabstat  $spec1 2 bad=0 robust=t qac=t)
	printf_red $(tabstat  $spec2 2 bad=0 robust=t qac=t)

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
	fi
    else
	echo "LMTOY>> Skipping NEMO post-processing"
    fi


    # ADMIT
    if [[ $admit == 1 ]]; then
	echo "LMTOY>> ADMIT post-processing"
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
    # this will process a single band in an $obsnum

    # log the version
    lmtoy_version > lmtoy.rc
    # keep an IFPROC header
    ifproc.sh $obsnum > lmtoy_$obsnum.ifproc
    # obsnumrc
    obsnumrc=lmtoy_$obsnum.rc

    #  convert RAW to SpecFile (hardcoded parameters are hardcoded for a good resaon)
    if [ $makespec = 1 ]; then
	echo "LMTOY>> process_otf_map2 in 2 seconds"
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
	    #use_restfreq=""	    
	    echo "WARNING: resetting restfreq not supported yet"
	fi
	process_otf_map2.py \
	    -p $p_dir \
	    -o $s_nc \
	    --obsnum $obsnum \
	    --pix_list $pix_list \
	    --bank $bank \
	    --stype $stype \
	    --use_cal \
	    $use_otf_cal \
	    $use_restfreq \
	    --x_axis VLSR \
	    --b_order $b_order \
	    --b_regions $b_regions \
	    --l_region $l_regions \
	    --slice $slice \
	    --eliminate_list $birdies
    fi
    #		    --slice [-1000,1000] \
	#		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \

    # bug:  --use_otf_cal does not work here?? (maybe it does now)
    # bug?   x_axis FLSR doesn't seem to go into freq mode


    # bug:   even if pix_list=10 figure 5 still shows all pixels
    #  pointings:  -240 .. 270    -259 .. 263      510x520

    if [ $viewspec = 1 ]; then
	echo "LMTOY>> view_spec_file"
	view_spec_file.py \
	    -i $s_nc \
            --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --plot_range=-1,3 \
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

	stats_wf.py  ${s_on}.wf.fits 0 > stats_wf0.tab
	stats_wf.py  ${s_on}.wf.fits 1 > stats_wf1.tab
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
	    
	    printf_red $out1
	    printf_red $out2
	    printf_red $out3

	    rms=$(echo $out2  | txtpar - "%1*1000" p0=-cent,1,4)
	    rms0=$(echo $out3 | txtpar - p0=radiometer,1,3)
	    echo "rms=$rms     # rms[mK] in center"      >> $obsnumrc
	    echo "rms0=$rms0   # RMS/radiometer radio"   >> $obsnumrc

	    # hack
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.cubespecs.tab
	    echo -n "cubespec : ";  tail -1  $s_on.cubespec.tab
	    echo -n "cubespecs: ";  tail -1  $s_on.cubespecs.tab
	    
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
    echo "LMTOY>> Running maskmoment vlsr=$vlsr"
    mm1.py $s_on.nf.fits   $vlsr > maskmoment.nf.log   2>&1
    # hack
    mm1.py $s_on.nfs.fits  $vlsr > maskmoment.nfs.log  2>&1
   
    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: $rc"
    
    # seq_readme > $pdir/README.html
    cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    mk_index.sh
    # cheat and rename it for all files access
    mv index.html README.html
    
} # lmtoy_seq1

function lmtoy_bs1 {
    # input: obsnum, ... (lots)
    # this will process a single band in an $obsnum

    # log the version
    lmtoy_version > lmtoy.rc
    ifproc.sh $obsnum > lmtoy_$obsnum.ifproc

    # for a waterfall -> bs-2.png
    process_bs.py --obs_list $obsnum -o junk2.txt --pix_list $pix_list --use_cal --block -2 --stype $stype

    # full average -> bs-1.png
    echo "LMTOY>> process_bs.py --obs_list $obsnum -o ${src}_${obsnum}.txt --pix_list $pix_list --use_cal --block -1 --stype $stype"
    process_bs.py --obs_list $obsnum -o ${src}_${obsnum}.txt --pix_list $pix_list --use_cal --block -1 --stype $stype
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
    
    seqbs_readme $obsnum $src > $pdir/README.html
    # cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    # mk_index.sh
    # cheat and rename it for all files access
    # mv index.html README.html
    
} # lmtoy_bs1
