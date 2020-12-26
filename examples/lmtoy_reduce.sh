#! /bin/bash
#
#  A simple OTF pipeline in bash.
#  Really should be written in python, but hey, here we go.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "$obsnum.rc"
#          in the current directory, parameters will be read from it.

# debug
# set -x
debug=0

# input parameters (defaults are for the IRC benchmark)
src=IRC
obsnum=79448

makespec=1
makecube=1
viewspec=0
viewcube=0
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=4
location=0,0
# 
extent=300
vlsr=-29
dv=100
dw=250
# these should  be computed
#b_regions=[[-250,-150],[150,300]]
#l_regions=[[-100,100]]
#slice=[-350,350]
#v_range=-100.0,100.0



#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

if [ $debug = 1 ]; then
    set -x
fi

#             process the parameter file
rc=lmtoy_${obsnum}.rc
if [ -e $rc ]; then
    echo "LMTOY>> reading $rc"
    source $rc
    newrc=0
else
    newrc=1
fi

#             derived parameters
p_dir=${src}_data
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits
w_fits=${src}_${obsnum}.w.fits

#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

if [ $newrc = 1 ]; then
    echo "# obsnum=$obsnum" > $rc
    echo src=$src          >> $rc
    echo vlsr=$vlsr        >> $rc    
    
    ifproc=$(ls ${p_dir}/ifproc/*${obsnum}*.nc)
    echo "# Using $ifproc" >> $rc
    
    vlsr2=$(ncdump $ifproc | grep Header.Source.Velocity | tail -1 | awk '{print $3}')
    echo vlsr=$vlsr2 >> $rc
    
    #   w0   v0   v1     w1
    v0=$(echo $vlsr - $dv | bc -l)
    v1=$(echo $vlsr + $dv | bc -l)
    w0=$(echo $v0 - $dw | bc -l)
    w1=$(echo $v1 + $dw | bc -l)

    b_regions=[[$w0,$v0],[$v1,$w1]]
    l_regions=[[$v0,$v1]]
    slice=[$w0,$w1]
    v_range=$v0,$v1

    echo b_regions=$b_regions       >> $rc
    echo l_regions=$l_regions       >> $rc
    echo slide=$slice               >> $rc
    echo v_range=$v_range           >> $rc

    echo "LMTOY>> this is your startup $rc file:"
    cat $rc
    exit 0
fi


# -----------------------------------------------------------------------------------------------------------------



#  convert RAW to SpecFile
if [ $makespec = 1 ]; then
    echo "LMTOY>> process_otf_map2 in 2 seconds"
    sleep 2
    process_otf_map2.py \
	-p $p_dir \
	-o $s_nc \
	--obsnum $obsnum \
	--pix_list $pix_list \
	--bank 0 \
	--stype 2 \
	--use_cal \
	--x_axis VLSR \
	--b_order 0 \
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
	--rms_cut 10.0 \
	--plot_range=-1,3
fi
# --show_all_pixels \
# --show_pixel 10 \



#  convert SpecFile to FITScube
if [ $makecube = 1 ]; then
    echo "LMTOY>> grid_data"
    grid_data.py \
	--program_path spec_driver_fits \
	-i $s_nc \
	-o $s_fits \
	-w $w_fits \
	--resolution  11.0 \
	--cell        5.5 \
	--pix_list    $pix_list \
	--rms_cut     $rms_cut \
	--x_extent    $extent \
	--y_extent    $extent \
	--otf_select  1 \
	--rmax        3 \
	--otf_a       1.1 \
	--otf_b       4.75 \
	--otf_c       2 \
	--n_samples   256 \
	--noise_sigma 1
fi

# bug:  when rmax=5  r=12/c=2.4  malloc(): unsorted double linked list corrupted

# limits controls figure 5, but not figure 3, which is scaled for the whole map
if [ $viewcube = 1 ]; then
    echo "LMTOY>> view_cube"
    view_cube.py -i $s_fits \
		 --v_range=$v_range \
		 --v_scale=1000 \
		 --location=$location \
		 --scale=0.000278 \
		 --limits=-$extent,$extent,-$extent,$extent \
		 --tmax_range=-1,12 \
		 --tint_range=-1,400 \
		 --plot_type TMAX \
		 --interpolation bilinear
fi

if [ ! -z $NEMO ]; then
    fitsccd $s_fits $s_fits.ccd error=1
    ccdstat $s_fits.ccd bad=0 robust=t planes=0 > $s_fits.cubestat
    ccdsub  $s_fits.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
    fitsccd $w_fits - | ccdsub - - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t    
    rm $s_fits.ccd
fi

if [ ! -z $ADMIT ]; then
    runa1 $s_fits
fi

echo "LMTOY>> Done with $s_fits"

