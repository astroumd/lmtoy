#! /bin/bash
#
#  A simple LMT OTF pipeline in bash.
#  Really should be written in python, but hey, here we go.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#          in the current directory, parameters will be read from it.
#          If it does not exist, it will be created on the first run and you can edit it
#          for subsequent runs
#
# There is no good mechanism here to make a new variable depend on re-running a certain task on which it depends
# that's perhaps for a more advanced pipeline

version="lmtoy_reduce: 12-feb-2021"

if [ -z $1 ]; then
    echo "LMTOY>>  Usage: path=DATA_LMT obsnum=OBSNUM ..."
    echo "LMTOY>>  $version"
    echo ""
    echo "See lmtoy_reduce.md for examples on usage"
    exit 0
fi


# debug
# set -x
debug=0

# input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=79448
obsid=""
newrc=0
#            - procedural
makespec=1
makewf=1
makecube=1
viewspec=0
viewcube=0
#            - meta parameters that will compute other parameters for SLR scripts
extent=400
dv=100
dw=250
#            - parameters that directly match the SLR scripts
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=-4
location=0,0
resolution=12.5   # will be computed from skyfreq
cell=6.25         # will be computed from resolution/2
rmax=3
otf_select=1
otf_a=1.1
otf_b=4.75
otf_c=2
noise_sigma=1
b_order=0
stype=2
sample=-1

# unset a view things, since setting them will give a new meaning
unset vlsr

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${obsnum}.rc
if [ -e $rc ] && [ $newrc = 0 ]; then
    echo "LMTOY>> reading $rc"
    source $rc
    newrc=0
    # read cmdline again to override the old rc values
    for arg in $*; do\
       export $arg
    done
else
    newrc=1
fi


if [ $newrc = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path"
    echo "# $version"                            > $rc
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    echo "# obsnum=$obsnum" >> $rc

    if [ ! -d ${path}/ifproc ]; then
	echo There is no ifproc directory in ${path}
	rm $rc
	exit 1
    fi
    if [ ! -d ${path}/spectrometer ]; then
	echo There is no spectrometer directory in ${path}
	rm $rc	
	exit 1
    fi
    if [ ! -d ${path}/spectrometer/roach0 ]; then
	echo There is no spectrometer/roach0 directory in ${path}
	rm $rc	
	exit 1
    fi
    
    ifproc=$(ls ${path}/ifproc/*${obsnum}*.nc)
    if [ -z $ifproc ]; then
	rm -f $rc
	echo No matching obsnum=$obsnum and path=$path
	echo The following rc files are present:
	ls lmtoy_*.rc | sed s/lmtoy_// | sed s/.rc//
	exit 0
    fi
    echo "# Using ifproc=$ifproc" >> $rc
    echo "path=$path"             >> $rc

    # lmtinfo grabs some useful parameters from the ifproc file
    lmtinfo.py $path $obsnum | tee -a $rc
    source $rc
    
    #   w0   v0   v1     w1
    v0=$(echo $vlsr - $dv | bc -l)
    v1=$(echo $vlsr + $dv | bc -l)
    w0=$(echo $v0 - $dw | bc -l)
    w1=$(echo $v1 + $dw | bc -l)

    b_order=$b_order
    b_regions=[[$w0,$v0],[$v1,$w1]]
    l_regions=[[$v0,$v1]]
    slice=[$w0,$w1]
    v_range=$v0,$v1
    x_extent=$extent
    y_extent=$extent

    echo "# based on vlsr=$vlsr, dv=$dv,  dw=$dw" >> $rc
    echo b_order=$b_order           >> $rc
    echo b_regions=$b_regions       >> $rc
    echo l_regions=$l_regions       >> $rc
    echo slice=$slice               >> $rc
    echo v_range=$v_range           >> $rc

    echo x_extent=$x_extent         >> $rc
    echo y_extent=$y_extent         >> $rc
    
    echo pix_list=$pix_list         >> $rc
    
    echo rmax=$rmax                 >> $rc
    echo otf_a=$otf_a               >> $rc
    echo otf_b=$otf_b               >> $rc
    echo otf_c=$otf_c               >> $rc
    echo sample=$sample             >> $rc
    

    echo "LMTOY>> this is your startup $rc file:"
    cat $rc
    echo "LMTOY>> Sleeping for 5 seconds, you can  abort, edit $rc, then continuing"
    sleep 5
fi

#             derived parameters (you should not have to edit these)
p_dir=${path}
s_on=${src}_${obsnum}
s_nc=${s_on}.nc
s_fits=${s_on}.fits
w_fits=${s_on}.wt.fits


#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi


# -----------------------------------------------------------------------------------------------------------------



#  convert RAW to SpecFile (hardcoded parameters are hardcoded for a good resaon)
if [ $makespec = 1 ]; then
    echo "LMTOY>> process_otf_map2 in 2 seconds"
    sleep 2
    process_otf_map2.py \
	-p $p_dir \
	-o $s_nc \
	--obsnum $obsnum \
	--pix_list $pix_list \
	--bank 0 \
	--stype $stype \
	--use_cal \
	--x_axis VLSR \
	--b_order $b_order \
	--b_regions $b_regions \
	--l_region $l_regions \
	--slice $slice \
	--eliminate_list 0
fi
#		    --slice [-1000,1000] \
#		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \

# bug:  --use_otf_cal does not work here
# bug?   x_axis FLSR doesn't seem to go into freq mode



# bug:   even if pix_list=10 figure 5 still shows all pixels
#  pointings:  -240 .. 270    -259 .. 263      510x520

if [ $viewspec = 1 ]; then
    echo "LMTOY>> view_spec_file"
    view_spec_file.py \
	-i $s_nc \
        --pix_list $pix_list \
	--rms_cut $rms_cut \
	--plot_range=-1,3
fi
# --show_all_pixels \
    # --show_pixel 10 \

# show spectra, each pixel gets a different curve/color
view_spec_point.py \
    -i $s_nc \
    --pix_list $pix_list \
    --rms_cut $rms_cut \
    --location $location \
    --plots ${src}_specpoint,png,1

view_spec_point.py \
    -i $s_nc \
    --pix_list $pix_list \
    --rms_cut $rms_cut \
    --location $location \
    --radius 20 \
    --plots ${src}_specpoint,png,2

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
    echo "LMTOY>>    Some NEMO post-processing"

    # cleanup, just in case
    rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.mom2.ccd $s_on.head1 \
       $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd

    if [ -e $s_fits ]; then
	fitsccd $s_fits $s_on.ccd    axistype=1
	fitsccd $w_fits $s_on.wt.ccd axistype=1

	ccdspec $s_on.ccd > $s_on.spectab
	ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat
	echo "LMTOY>>    STATS  $s_on.ccd     centerbox robust"
	ccdsub  $s_on.ccd -    centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
	echo "LMTOY>>    STATS  $s_on.wt.ccd  centerbox robust"
	ccdsub  $s_on.wt.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t

	# convert flux flat to noise flat
	wmax=$(ccdstat $s_on.wt.ccd  | grep ^Min | awk '{print $6}')

	ccdmath $s_on.wt.ccd $s_on.wtn.ccd "sqrt(%1/$wmax)"
	ccdmath $s_on.ccd,$s_on.wtn.ccd $s_on.n.ccd '%1*%2' replicate=t
	ccdmom $s_on.n.ccd $s_on.mom0.ccd  mom=0	
	ccdmom $s_on.n.ccd $s_on.mom1.ccd  mom=1 rngmsk=t
	ccdmom $s_on.n.ccd $s_on.mom2.ccd  mom=-2

	scanfits $s_fits $s_on.head1 select=header
	ccdfits $s_on.n.ccd  $s_on.n.fits

	scanfits $s_on.n.fits $s_on.data1 select=data
	cat $s_on.head1 $s_on.data1 > $s_on.nf.fits

	ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.nfs.fits fitshead=$s_fits

	# hack
	fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.specstab
	echo -n "spectab : ";  tail -1  $s_on.spectab
	echo -n "specstab: ";  tail -1  $s_on.specstab

	# remove useless files
	rm -f $s_on.n.fits $s_on.head1 $s_on.data1 $s_on.ccd $s_on.wt.ccd

	echo "LMTOY>> Created $s_on.nf.fits and $s_on.nfs.fits"

    else
	echo "LMTOY>> Problems finding $s_fits. Skipping NEMO work."
    fi
    
fi

if [ ! -z $ADMIT ]; then
    echo "LMTOY>> Some ADMIT post-processing"
    if [ -e $s_on.nf.fits ]; then
	runa1 $s_on.nf.fits
    else
	runa1 $s_fits
    fi
fi

echo "LMTOY>> Created $s_fits and $w_fits"
echo "LMTOY>> Parameter file used: $rc"

