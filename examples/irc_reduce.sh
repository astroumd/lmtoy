#! /bin/bash
#
#  Example OTF sequoia data reduction path for IRC+10216
#  all pixels are pretty good, but with trimodal RMS distributions
#  due to the pre-2020 doppler tracking problem
#
#  This data is also the benchmark we always run. Even though these
#  were Sequoia commisioning data and have some header issues, for
#  the purpose of testing the workflow this is fine.
#
#  The benchmark runs in about 80" on a decent 2020 laptop.
#
#  see also lmtoy_reduce.sh for a more general approach


# input parameters
path=IRC_data
src=IRC
obsnum=79448
makespec=1
viewspec=0
viewcube=0
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=4
resolution=12.5
cell=6.25
rmax=3
x_axis=VLSR



#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


# derived parameters
if [ -d $path ]; then
    p_dir=$path
else
    p_dir=${DATA_LMT}
    echo "Warning: assuming you have $p_dir (or a symlink) where the IRC_data are"
fi    
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits
w_fits=${src}_${obsnum}.wt.fits

# bug? tsys 220 vs. 110 seems to make no pdiff
#  convert RAW to SpecFile
if [ $makespec = 1 ]; then
process_otf_map2.py -p $p_dir \
		    -o $s_nc \
		    --obsnum $obsnum \
		    --pix_list $pix_list \
		    --bank 0 \
		    --stype 2 \
		    --use_cal \
		    --x_axis $x_axis \
		    --b_order 0 \
		    --b_regions [[-250,-150],[150,300]] \
		    --l_region [[-100,100]] \
		    --slice [-350,350] \
		    --eliminate_list 0 
fi
#		    --slice [-1000,1000] \
#		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \

# bug:  --use_otf_cal does not work here
# feature:  --tsys=220.0  is ignored
# bug?   x_axis FLSR doesn't seem to go into freq mode



# bug:   even if pix_list=10 figure 5 still shows all pixels
#  pointings:  -240 .. 270    -259 .. 263      510x520
if [ $viewspec = 1 ]; then
view_spec_file.py -i $s_nc \
                  --pix_list $pix_list \
		  --rms_cut 10.0 \
		  --plot_range=-1,3
fi
# --show_all_pixels \
# --show_pixel 10 \



#  convert SpecFile to FITScube
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     -w $w_fits \
	     --resolution  $resolution \
	     --cell        $cell \
             --pix_list    $pix_list \
	     --rms_cut     $rms_cut \
	     --x_extent    300 \
	     --y_extent    300 \
	     --otf_select  1 \
	     --rmax        $rmax \
	     --otf_a       1.1 \
	     --otf_b       4.75 \
	     --otf_c       2 \
	     --n_samples   256 \
	     --noise_sigma 1


# bug:  when rmax=5  r=12/c=2.4  malloc(): unsorted double linked list corrupted

# limits controls figure 5, but not figure 3, which is scaled for the whole map
if [ $viewcube = 1 ]; then
view_cube.py -i $s_fits \
	     --v_range=-100.0,100.0 \
	     --v_scale=1000 \
	     --location=0.0,0.0 \
	     --scale=0.000278 \
	     --limits=-300,300,-300,300 \
	     --tmax_range=-1,12 \
	     --tint_range=-1,400 \
	     --plot_type TMAX \
	     --interpolation bilinear
fi

if [ ! -z $NEMO ]; then
    fitsccd $s_fits $s_fits.ccd error=1
    ccdstat $s_fits.ccd bad=0 robust=t planes=0 > $s_fits.cubestat
    ccdsub  $s_fits.ccd - centerbox=0.5,0.5 | ccdstat - robust=t bad=0
    ccdstat $s_fits.ccd bad=0 qac=t
    rm $s_fits.ccd
else
    echo NEMO not installed, no QAC_STATS for benchmark available.
    echo This is your FITS cube:
    ls -l $s_fits
fi

if [ ! -z $ADMIT ]; then
    runa1 $s_fits
fi

# Looks like 2nd line near VLSR=-310 is Acetaldehyde (CH3CHO) at 115.38210620 GHz
# but ADMIT has a hard time getting it right.
#       115.38240 SiC2 (Silicon Carbide)
#       115.3774  U
#       115.3871  U
# The two candidates differ by 0.68 km/s, within the same 1 km/s channel
# RA/DEC in IRCS (J2000) is : 09 47 57.40632 +13 16 43.5648

# QAC_STATS: IRC_79448.fits.ccd -0.0295232 25.0818 -7545.73 5872.96  0 -0.0455642

echo Done with $s_fits

#                RMS
# fitsccd IRC_79448.fits - | ccdsub - - 30:70 30:70 | ccdstat - robust=t bad=0
#                  0.183       15.2   (12.5" beam)
# std rmax=3:  rms=0.208  peak=15.2   (11" beam)
#     rmax=1:  rms=0.175  peak=14.6
#  rms_cut=1.3 rms=0.211  peak=15.4
# otf_select=2 rms=0.036  peak=7.6
