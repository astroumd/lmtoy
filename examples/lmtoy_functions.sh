#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations

lmtoy_version="19-nov-2021"
echo "LMTOY>> READING lmtoy_functions $lmtoy_version from $0"

function lmtoy_decipher_obsnums {
    # input:    obsnums
    # output:   on0, on1, obsnum
    
    if [ $obsnums = 0 ]; then
	return
    fi
    
    #             differentiate if obsnums is a file or list of obsnums
    #             set first and last obsnum, and make a list
    if [ -e $obsnums ]; then
	# obsnum is a file
	on0=$(grep -v ^# $obsnums | head -1)
	on1=$(grep -v ^# $obsnums | tail -1)
	obsnums1=$(grep -v ^# $obsnums)
	obsnums=$(echo $obsnums1 | sed '/ /,/g')
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

function lmtoy_rsr1 {
    # input:  first, obsnum, badlags, blanking, ....
    

    #  @todo    use -t flag ?
    
    # first time, do a run with no badlags or rfile
    if [ $first == 1 ]; then
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  -w rsr.wf0.pdf -p -b 3   > rsr0.log 2>&1	
    fi
    
    # output: rsr.$obsnum.badlags sbc.png
    if [ ! -e $badlags ]; then
	python $LMTOY/examples/seek_bad_channels.py $obsnum                         > rsr4.log 2>&1
	mv rsr.badlags $badlags
    fi
    
    # output: $src_rsr_spectrum.txt
    b="--badlags $badlags"
    r="--rfile $rfile"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r -w rsr.wf.pdf -p -b 3  > rsr1.log 2>&1
    
    # output: rsr.obsnum.sum.txt
    python $LMTOY/examples/rsr_sum.py -b rsr.obsnum    $b                           > rsr2.log 2>&1

    # output: rsr.blanking.sum.txt
    python $LMTOY/examples/rsr_sum.py -b $blanking  $b                              > rsr3.log 2>&1

    
    # NEMO summary spectra
    if [ ! -z $NEMO ]; then
	echo "LMTOY>> Some NEMO post-processing"
	dev=$(yapp_query png ps)
	tabplot  ${src}_rsr_spectrum.txt    line=1,1 color=2 ycoord=0     yapp=${src}_rsr_spectrum.sp.$dev/$dev  debug=-1
	tabplot  rsr.obsnum.sum.txt         line=1,1 color=2 ycoord=0     yapp=rsr.obsnum.sum.sp.$dev/$dev       debug=-1
	tabplot  ${blanking}.sum.txt        line=1,1 color=2 ycoord=0     yapp=${blanking}.sum.sp.$dev/$dev      debug=-1
	tabtrend ${src}_rsr_spectrum.txt 2 | tabhist - robust=t xcoord=0  yapp=${src}_rsr_spectrum.rms.$dev/$dev debug=-1
	tabtrend rsr.obsnum.sum.txt      2 | tabhist - robust=t xcoord=0  yapp=rsr.obsnum.sum.rms.$dev/$dev      debug=-1
	tabtrend ${blanking}.sum.txt     2 | tabhist - robust=t xcoord=0  yapp=${blanking}.sum.rms.$dev/$dev     debug=-1
	tabstat  ${src}_rsr_spectrum.txt 2 bad=0 robust=t qac=t
	tabstat  rsr.obsnum.sum.txt      2 bad=0 robust=t qac=t
	tabstat  ${blanking}.sum.txt     2 bad=0 robust=t qac=t
    else
	echo "LMTOY>> Skipping NEMO"
    fi


    # ADMIT
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing" 
	lmtoy_admit.sh ${src}_rsr_spectrum.txt
	lmtoy_admit.sh rsr.obsnum.sum.txt
	lmtoy_admit.sh ${blanking}.sum.txt
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi


    # first time?
    if [ $first == 1 ]; then
	echo "RSR: first time run, preserving a few first run figures"
    fi

    echo "LMTOY>> Parameter file used: $rc"
    
    rsr_readme $obsnum $src > README.html


} # function rsr1


function lmtoy_seq1 {
    # input: obsnum, ... (lots)

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
	    --bank 0 \
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
    
    if [ ! -z $NEMO ]; then
	echo "LMTOY>> Some NEMO post-processing"

	# cleanup from a previous run
	rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.mom2.ccd $s_on.head1 \
	   $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd \
	   $s_on.wt2.fits $s_on.wt3.fits $s_on.wtr.fits

	if [ -e $s_fits ]; then
	    fitsccd $s_fits $s_on.ccd    axistype=1
	    fitsccd $w_fits $s_on.wt.ccd axistype=1
	    
	    ccdspec $s_on.ccd > $s_on.spectab
	    ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat
	    echo "LMTOY>> STATS  $s_on.ccd     centerbox robust"
	    ccdsub  $s_on.ccd -    centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
	    echo "LMTOY>> STATS  $s_on.wt.ccd  centerbox robust"
	    ccdsub  $s_on.wt.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
	    
	    # convert flux flat to noise flat
	    wmax=$(ccdstat $s_on.wt.ccd  | grep ^Min | awk '{print $6}')
	    
	    ccdmath $s_on.wt.ccd $s_on.wtn.ccd "sqrt(%1/$wmax)"
	    ccdmath $s_on.ccd,$s_on.wtn.ccd $s_on.n.ccd '%1*%2' replicate=t
	    ccdmom $s_on.n.ccd $s_on.mom0.ccd  mom=0	
	    ccdmom $s_on.n.ccd $s_on.mom1.ccd  mom=1 rngmsk=t
	    ccdmom $s_on.n.ccd $s_on.mom2.ccd  mom=-2
	    
	    ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "ifne(%1,0,2/(%1*%1),0)"
	    ccdfits $s_on.wt2.ccd $s_on.wt2.fits fitshead=$w_fits
	    # e.g. [[-646,-396],[-196,54]] -> -646,-396,-196,54
	    zslabs=$(echo $b_regions | sed 's/\[//g' | sed 's/\]//g')
	    echo SLABS: $b_regions == $zslabs
	    ccdslice $s_on.ccd - zslabs=$zslabs zscale=1000 | ccdmom - - mom=-2  | ccdmath - $s_on.wt3.ccd "ifne(%1,0,1/(%1*%1),0)"
	    ccdfits $s_on.wt3.ccd $s_on.wt3.fits fitshead=$w_fits
	    ccdmath $s_on.wt2.ccd,$s_on.wt3.ccd $s_on.wtr.ccd %2/%1
	    ccdfits $s_on.wtr.ccd $s_on.wtr.fits fitshead=$w_fits

	    scanfits $s_fits $s_on.head1 select=header
	    ccdfits $s_on.n.ccd  $s_on.n.fits

	    scanfits $s_on.n.fits $s_on.data1 select=data
	    cat $s_on.head1 $s_on.data1 > $s_on.nf.fits
	    
	    ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.nfs.fits fitshead=$s_fits
	    
	    # QAC_STATS:
	    ccdstat $s_on.ccd bad=0 qac=t
	    ccdsub  $s_on.ccd -  centerbox=0.5,0.5 | ccdstat - bad=0 qac=t

	    # hack
	    fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.specstab
	    echo -n "spectab : ";  tail -1  $s_on.spectab
	    echo -n "specstab: ";  tail -1  $s_on.specstab
	    
	    # NEMO plotting ?
	    if [ $viewnemo = 1 ]; then
		dev=$(yapp_query png ps)
		ccdplot $s_on.mom0.ccd yapp=$s_on.mom0.$dev/$dev
		ccdplot $s_on.mom1.ccd yapp=$s_on.mom1.$dev/$dev
		ccdplot $s_on.mom2.ccd yapp=$s_on.mom2.$dev/$dev
		ccdplot $s_on.wt.ccd   yapp=$s_on.wt.$dev/$dev
		ccdplot $s_on.wt2.ccd  yapp=$s_on.wt2.$dev/$dev
		ccdplot $s_on.wt3.ccd  yapp=$s_on.wt3.$dev/$dev
		ccdplot $s_on.wtn.ccd  yapp=$s_on.wtn.$dev/$dev
		ccdplot $s_on.wtr.ccd  yapp=$s_on.wtr.$dev/$dev
	    fi
	    
	    # testing 
	    if [ 1 = 0 ]; then
		fitsplot.py $s_on.mom0.fits
		fitsplot.py $s_on.mom1.fits
		fitsplot.py $s_on.mom2.fits
		fitsplot.py $s_on.wt.fits
		fitsplot.py $s_on.wt2.fits
		fitsplot.py $s_on.wt3.fits
		fitsplot.py $s_on.wtn.fits
		fitsplot.py $s_on.wtr.fits
	    fi
	    # remove useless files
	    if [ $clean -eq 1 ]; then
		rm -f $s_on.n.fits $s_on.head1 $s_on.data1 $s_on.ccd $s_on.wt.ccd $s_on.wt2.ccd  $s_on.wt3.ccd \
	           $s_on.n.ccd $s_on.wtr.ccd
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
    
    echo "LMTOY>> Making summary index.html:"
    mk_index.sh
    # cheat and rename it for all files access
    mv index.html README.html
    
} # lmtoy_seq1
