#! /bin/bash
#
#  Example OTF sequoia data reduction path for IRC+10216
#  
#  CPU: 133.67user 5.61system 2:18.90elapsed 100%CPU

#/usr/bin/time process_otf_map2.py -c IRC_process.txt
#/usr/bin/time grid_data.py -c IRC_grid.txt
#exit 0

# input parameters
src=IRC
obsnum=79448
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

# bug? tsys 220 vs. 110 seems to make no diff
#  convert RAW to SpecFile
process_otf_map2.py -p $p_dir \
		    -o $s_nc \
		    --obsnum $obsnum \
		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		    --bank 0 \
		    --tsys 220.0 \
		    --stype 2 \
		    --x_axis VLSR \
		    --b_order 0 \
		    --b_regions [[-250,-150],[150,300]] \
		    --l_region [[-100,100]] \
		    --slice [-350,350] \
		    --eliminate_list 0

# bug:   even if pix_list=10 figure 5 still shows all pixels
#  pointings:  -240 .. 270    -259 .. 263      510x520
if [ $viewspec = 1 ]; then
view_spec_file.py -i $s_nc \
		  --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		  --rms_cut 10.0 \
		  --plot_range=-1,3
fi
# --show_all_pixels \
# --show_pixel 10 \



#  convert SpecFile to FITScube
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     --resolution  11.0 \
	     --cell        5.5 \
	     --pix_list    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
	     --rms_cut     4 \
	     --x_extent    300 \
	     --y_extent    300 \
	     --otf_select  1 \
	     --rmax        3 \
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
    fitsccd $s_fits - | ccdstat - robust=t planes=0 > $s_fits.cubestat
    fitsccd $s_fits - | ccdstat - robust=t 
fi

# Looks like 2nd line is Acetaldehyde at 115.38210620 GHz
# rms_cut 1  -> 0.218
#         3     0.189
#         4     0.188   (rmax=3, for rmax=1 this is 0.13)
# bug? otf_select=2 decreased RMS by factor 2, but signal not as much.... S/N depends on this too?
#         
# just doing pixel 10 gave 0.144 rms..... ???
# RMS:
# fitsccd $s_fits - | ccdstat - robust=t

echo Done with $s_fits

