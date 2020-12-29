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
otf_select=1
rmax=3
extent=250
resolution=12.5
cell=6.25
direct=0
pix_list=0,1,2,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=10
otf_b=4.75
n_samples=256
noise_sigma=0

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


# derived parameters
p_dir=${src}_data
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits
w_fits=${src}_${obsnum}.wt.fits

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
		    --pix_list $pix_list \
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
		  --pix_list $pix_list \
		  --rms_cut $rms_cut \
		  --plot_range=-1,3
fi

#  convert SpecFile to FITS (use 1.15 lambda/D as the resolution)
if [ $direct = 0 ]; then
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     -w $w_fits \
	     --resolution  $resolution \
	     --cell        $cell \
	     --pix_list    $pix_list \
	     --rms_cut     $rms_cut \
	     --x_extent    $extent \
	     --y_extent    $extent \
	     --otf_select  $otf_select \
	     --rmax        $rmax \
	     --otf_a       1.1 \
	     --otf_b       $otf_b \
	     --otf_c       2 \
	     --n_samples   $n_samples \
	     --noise_sigma $noise_sigma
else
    echo DIRECT call to spec_driver_fits
    set +x
    rm -f $s_fits
    spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     -w $w_fits \
	     -l $resolution \
	     -c $cell \
             -u [$pix_list] \
	     -z $rms_cut \
	     -x $extent \
	     -y $extent \
	     -f $otf_select \
	     -r $rmax \
	     -0 1.1 \
	     -1 $otf_b \
	     -2 2 \
	     -n $n_samples \
	     -s $noise_sigma
fi

echo Done

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
    ccdsub  $s_fits.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
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

