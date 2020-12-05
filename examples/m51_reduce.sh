#! /bin/bash
#
#  Example OTF sequoia data reduction path


/usr/bin/time process_otf_map.py -c M51_process.txt
/usr/bin/time grid_data.py       -c M51_grid.txt
exit 0

# input parameters
src=M51
obsnum=91112





#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


# derived parameters
p_dir=${src}_data
s_nc=${src}_${obsnum}.nc
s_fits=${src}_${obsnum}.fits

#  convert RAW to SpecFile
process_otf_map2.py -p $p_dir \
		    -o $s_nc \
		    -O $obsnum \
		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		    -b 0 \
		    --stype 2 \
		    --b_regions [[200,380],[580,800]] \
		    --l_region [400,600] \
		    --slice [200,800] \
		    --eliminate_list 0

#  convert SpecFile to FITS
grid_data.py --program_path spec_driver_fits \
	     -i $s_nc \
	     -o $s_fits \
	     --resolution 14.0 \
	     --cell  7.0 \
	     --pix_list 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
	     --rms_cut 10 \
	     --x_extent 300 \
	     --y_extent 300 \
	     --otf_select 1 \
	     --rmax 3 \
	     --otf_a 1.1 \
	     --otf_b 4.75 \
	     --otf_c 2 \
	     --n_samples 256 \
	     --noise_sigma 1
