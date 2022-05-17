#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations
#   beware, shell variables are common variables between this and the caller

lmtoy_version="17-may-2022"

echo "LMTOY>> READING lmtoy_functions $lmtoy_version via $0"

function lmtoy_version {
    v=$(cat $LMTOY/VERSION)
    d=$(date -u +%Y-%m-%dT%H:%M:%S)
    echo "$v   $d"
}

function lmtoy_report {
    printf_red "LMTOY>> ProjectId=$ProjectId  obsnum=$obsnum  obspgm=$obspgm  obsgoal=$obsgoal oid=$oid"
    
}



function lmtoy_decipher_obsnums {
    # input:    obsnums
    # output:   on0, on1, obsnum
    
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
    # input:  first, obsnum, badlags, blanking, ....

    # log the version
    lmtoy_version > lmtoy.rc 

    # FIRST get the badlags - this is a file that can be edited by the user in later re-runs
    # output: rsr.$obsnum.badlags badlags.png
    #         rsr.$obsnum.rfile and rsr.$obsnum.blanking  - can be modified if #BADCB's have been found
    if [[ ! -e $badlags ]]; then
	python $LMTOY/examples/badlags.py -s $obsnum   > rsr_badlags.log 2>&1
	mv rsr.badlags $badlags
	rsr_badcb -r $badlags >> $rfile 
	rsr_badcb -b $badlags >> $blanking
    fi

    #   We have two similar scripts of difference provenance that produce a final spectrum
    #   they only differ in the way blanking and baseline subtraction happens, and the idea
    #   is that this should become one final program.
    #   On the other hand, it's a good check if the two are producing the same spectrum
    
    # spec1:    output spectrum rsr.$obsnum.driver.txt
    spec1="rsr.${obsnum}.driver.sum.txt"
    b="--badlags $badlags"
    r="--rfile $rfile"
    l="--exclude 110.51 0.15 108.65 0.3 85.2 0.4"
    o="-o $spec1"
    w="-w rsr.wf.pdf"
    blo=0
    if [[ $first == 1 ]]; then
	# first time, do a run with no badlags or rfile and no exlude baseline portions
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum $o -w rsr.wf0.pdf -p -b $blo    > rsr_driver0.log 2>&1	
    fi
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r $l $o $w -p -b $blo          > rsr_driver.log 2>&1
    #  ImageMagick:   this step can fail with some weird security policy error :-(
    #  edit /etc/ImageMagick-*/policy.xml    
    convert rsr.wf.pdf rsr.wf.png
    
    # spec2: output spectrum rsr.$obsnum.blanking.sum.txt
    spec2=${blanking}.sum.txt
    python $LMTOY/examples/rsr_sum.py -b $blanking  $b  --o1 $blo                         > rsr_sum.log 2>&1

    # Tsys plot:  rsr.tsys.png  - only for single obsnum
    if [[ -z "$obsnums" ]]; then
	python $LMTOY/examples/rsr_tsys.py -s $obsnum                                     > rsr_tsys.log 2>&1
    fi

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
    ifproc.sh $obsnum > lmtoy_$obsnum.ifproc

    #  convert RAW to SpecFile (hardcoded parameters are hardcoded for a good resaon)
    if [ $makespec = 1 ]; then
	echo "LMTOY>> process_otf_map2 in 2 seconds"
	sleep 2
	if [ $otf_cal = 1 ]; then
	    use_otf_cal="--use_otf_cal"
	else
	    use_otf_cal=""
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
	    --x_axis VLSR \
	    --b_order $b_order \
	    --b_regions $b_regions \
	    --l_region $l_regions \
	    --slice $slice \
	    --eliminate_list 0
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
	view_spec_point.py \
	    -i $s_nc \
	    --pix_list $pix_list \
	    --rms_cut $rms_cut \
	    --location $location \
	    --plots ${s_on}_specpoint,png,1
	
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
    fi
    

    #  convert SpecFile to FITScube
    if [ $makecube = 1 ]; then
	echo "LMTOY>> grid_data"
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

	# cleanup from a previous run
	rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.rms.ccd $s_on.head1 \
	   $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd \
	   $s_on.wt2.fits $s_on.wt3.fits $s_on.wtn.fits $s_on.wtr.fits $s_on.wtr3.fits $s_on.wtr4.fits \
	   $s_on.mom0.fits $s_on.mom1.fits $s_on.rms.fits \
	   $s_on.peak.fits $s_on.ccd.fits

	if [ -e $s_fits ]; then
	    fitsccd $s_fits $s_on.ccd    axistype=1
	    fitsccd $w_fits $s_on.wt.ccd axistype=1

	    # get size and use nz1-nz2 to exclude from the axis for the rms (mom=-2) map
	    # @todo should use dv/dw:
	    # with m=nz/2/(1+dv/dw)    nz1=m nz2=nz-m
	    nz=$(ccdhead $s_on.ccd | txtpar - p0=Size,1,4)
	    nz1=$(nemoinp $nz/4 format=%d)
	    nz2=$(nemoinp $nz-$nz1)
	    
	    ccdspec $s_on.ccd > $s_on.spectab
	    ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat
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
	    ccdfits $s_on.wt2.ccd $s_on.wt2.fits fitshead=$w_fits ndim=2
	    # e.g. [[-646,-396],[-196,54]] -> -646,-396,-196,54
	    zslabs=$(echo $b_regions | sed 's/\[//g' | sed 's/\]//g')
	    echo SLABS: $b_regions == $zslabs
	    ccdslice $s_on.ccd - zslabs=$zslabs zscale=1000 | ccdmom - - mom=-2  | ccdmath - $s_on.wt3.ccd "%1"
	    ccdfits $s_on.wt3.ccd               $s_on.wt3.fits  fitshead=$w_fits  ndim=2
	    ccdmath $s_on.wt2.ccd,$s_on.wt3.ccd $s_on.wtr.ccd   %2/%1
	    ccdfits $s_on.wtr.ccd               $s_on.wtr.fits  fitshead=$w_fits  ndim=2
	    ccdmath $s_on.rms.ccd,$s_on.wt3.ccd $s_on.wtr3.ccd  %2/%1
	    ccdfits $s_on.wtr3.ccd              $s_on.wtr3.fits fitshead=$w_fits  ndim=2
	    fitsccd radiometer.rms.fits - | ccdmath -,$s_on.rms.ccd $s_on.wtr4.ccd %2/%1/1000
	    ccdfits $s_on.wtr4.ccd              $s_on.wtr4.fits fitshead=$w_fits  ndim=2

	    scanfits $s_fits $s_on.head1 select=header
	    ccdfits $s_on.n.ccd  $s_on.n.fits

	    scanfits $s_on.n.fits $s_on.data1 select=data
	    cat $s_on.head1 $s_on.data1 > $s_on.nf.fits
	    
	    ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.nfs.fits fitshead=$s_fits
	    
	    # QAC_STATS: 
	    printf_red $(ccdstat $s_on.ccd bad=0 qac=t robust=t label="${s_on}-full")
	    printf_red $(ccdsub  $s_on.ccd  - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="${s_on}-cent")
	    printf_red $(ccdsub  $s_on.wtr4.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 qac=t robust=t label="RMS/radiometer")	    

	    # hack
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.specstab
	    echo -n "spectab : ";  tail -1  $s_on.spectab
	    echo -n "specstab: ";  tail -1  $s_on.specstab
	    
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
	if [ -e $s_on.nf.fits ]; then
	    lmtoy_admit.sh $s_on.nf.fits
	else
	    lmtoy_admit.sh $s_fits
	fi
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi
    
    
    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: $rc"
    
    # seq_readme > $pdir/README.html
    cp $LMTOY/docs/README_sequoia.md README_files.md
    
    echo "LMTOY>> Making summary index.html:"
    mk_index.sh
    # cheat and rename it for all files access
    mv index.html README.html
    
} # lmtoy_seq1
