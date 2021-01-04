#! /bin/bash
#
#  Example OTF sequoia data reduction path for M51 with 2 bad pixels (0,5)
#
#  CPU: 301.25user 23.80system 5:38.07elapsed 96%CPU 
#
#


# input parameters (not everything has been put in a parameter here)
path=/lmt_data
src=M51
obsnum=91112
makespec=1
viewspec=0
viewcube=0
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
pix_list=1,2,3,4,6,7,8,9,10,11,12,13,14,15
noise_sigma=1  

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


# derived parameters
if [ -d $path ]; then
    p_dir=$path
else
    p_dir=${src}_data
    echo "Warning: assuming you have $p_dir (or a symlink) where the M51 data are"
fi    
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits
w_fits=${src}_${obsnum}.wt.fits

# pixel 0 is all bad, 1 has issues, but it's below channel 820 or so
# 5 is bad hte first 11,000 samples (out of 24,000 or so), causing stripes.
# but until we can select by time, wew need to remove as well
# with view_spec_point you can see pixel 2 might not be good, as at -80,-70 it's not going along
# the spectral feature at 500 km/s, but nothing odd shows up in the waterfall plot

#  convert RAW to SpecFile
if [ $makespec = 1 ]; then
process_otf_map2.py -p $p_dir \
		    -o $s_nc \
		    -O $obsnum \
		    --pix_list $pix_list \
		    --bank 0 \
		    --stype 2 \
		    --use_cal \
		    --x_axis VLSR \
		    --b_order 0 \
		    --b_regions [[200,380],[580,800]] \
		    --l_region [400,600] \
		    --slice [200,800] \
		    --eliminate_list 0
fi

#  bug?    --eliminate_list 0 didn't remove it if 0 was in pix_list

if [ $viewspec = 1 ]; then
view_spec_file.py -i $s_nc \
		  --pix_list $pix_list \		  
		  --rms_cut 10.0 \
		  --plot_range=-1,3
fi
# --show_all_pixels \
# --show_pixel 10 \


#  convert SpecFile to FITS
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     -w $w_fits \
	     --resolution 12.5 \
	     --cell 6.25 \
	     --pix_list $pix_list \
	     --rms_cut 10 \
	     --x_extent 400 \
	     --y_extent 400 \
	     --otf_select 1 \
	     --rmax 3 \
	     --otf_a 1.1 \
	     --otf_b 4.75 \
	     --otf_c 2 \
	     --n_samples 256 \
	     --noise_sigma $noise_sigma


if [ $viewcube = 1 ]; then
view_cube.py -i $s_fits \
	     --v_range=400,600 \
	     --v_scale=1000 \
	     --location=-6,-6 \
	     --scale=0.000278 \
	     --limits=-400,400,-400,400 \
	     --tmax_range=0.0,1.4 \
	     --tint_range=-1,50 \
	     --plot_type TINT \
	     --interpolation bilinear
fi


if [ ! -z $NEMO ]; then
    if [ -e $s_fits ]; then
	fitsccd $s_fits $s_fits.ccd
	ccdstat $s_fits.ccd bad=0 robust=t planes=0 > $s_fits.cubestat
	ccdsub  $s_fits.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
	ccdstat $s_fits.ccd bad=0 qac=t
	fitsccd $w_fits - | ccdsub - - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t    
	rm $s_fits.ccd
    fi
fi

if [ ! -z $ADMIT ]; then
    runa1 $s_fits
fi

echo Done with $s_fits
