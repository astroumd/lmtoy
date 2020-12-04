#! /bin/bash


src=M51
obsnum=91112

p_dir=$src_data
s_nc=$src.nc
s_fits=$src.fits


process_otf_map2.py -p $p_dir -o $s_nc -O $obsnum \
		    --pix_list 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 \
		    -b 0 \
		    --stype 2 \
		    --b_regions [[200,380],[580,800]] \
		    --l_region [400,600] \
		    --slice [200,800] \
		    --eliminate_list 0


grid_data.py --program_path spec_driver_fits \
	     -i $s_nc -o $s_fits \
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
