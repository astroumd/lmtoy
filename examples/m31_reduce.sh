#! /bin/bash
#
#  Example OTF sequoia data reduction path for M31 (3 obsnum available)
#              pixel 3 bad in some data for some of the time
#
#  CPU: 240.51user  7.17system 4:12.49elapsed 98%CPU
#       985.39user 14.67system 4:37.48elapsed 360%CPU
#


# input parameters
src=M31
obsnum=85776
makespec=1
viewspec=0
viewcube=0



#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


# derived parameters
p_dir=${src}_data
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits

echo Valid obsnum= for M31 are:  85776 85778 85824
echo will created $s_fits
sleep 2

# 85776 - pixel 3 is bad in the first 1/3 of the observation
# 85778 - pixel 3 only bad for a short range
# 85824 - all data seem ok

#  convert RAW to SpecFile
if [ $makespec = 1 ]; then
process_otf_map2.py -p $p_dir \
		    -o $s_nc \
		    -O $obsnum \
		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		    --bank 0 \
		    --stype 2 \
		    --use_cal \
		    --x_axis VLSR \
		    --b_order 1 \
		    --b_regions [[-620,-320],[-220,80]] \
		    --l_region [[-320,-220]] \
		    --slice [-620,80] \
		    --eliminate_list 0
fi

#  -215 200    -190 221   415 x 420
if [ $viewspec = 1 ]; then
view_spec_file.py -i $s_nc \
		  --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		  --rms_cut 10.0 \
		  --plot_range=-1,3
fi

#  convert SpecFile to FITS (use 1.15 lambda/D as the resolution)
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     --resolution  12.5 \
	     --cell        6.25 \
	     --pix_list    0,1,2,4,5,6,7,8,9,10,11,12,13,14,15 \
	     --rms_cut     10 \
	     --x_extent    250 \
	     --y_extent    250 \
	     --otf_select  1 \
	     --rmax        3 \
	     --otf_a       1.1 \
	     --otf_b       4.75 \
	     --otf_c       2 \
	     --n_samples   256 \
	     --noise_sigma 1

# 45,74 is the bright spot in the NE, -70,-120 the one in the SW
if [ $viewcube = 1 ]; then
view_cube.py -i $s_fits \
	     --v_range=-320.0,-220.0 \
	     --v_scale=1000 \
	     --location=45,74 \
	     --scale=0.000278 \
	     --limits=-240,240,-240,240 \
	     --tmax_range=-0.5,1.5 \
	     --tint_range=-1,25 \
	     --plot_type TINT \
	     --interpolation bilinear
fi

if [ ! -z $NEMO ]; then
    fitsccd $s_fits $s_fits.ccd
    ccdstat $s_fits.ccd bad=0 robust=t planes=0 > $s_fits.cubestat
    ccdsub  $s_fits.ccd - 30:50 30:50 | ccdstat - bad=0 robust=t
    ccdstat $s_fits.ccd bad=0 qac=t
    rm $s_fits.ccd    
fi

if [ ! -z $ADMIT ]; then
    runa1 $s_fits
fi

echo Done with $s_fits
echo Valid obsnum= for M31 are:  85776 85778 85824

# RMS/PEAK in cubes, all pixel=3 removed
# obsnum  process_otf_map2
# 85776   0.102 1.44
# 85778   0.107 1.58
# 85824   0.116 1.38

