#
#

#  Directories (or symlinks to) the data
DATA_DIRS = IRC_data M31_data M51_data

#  takes 20'44" (with NEMO, 20'20" without)
all:   # $(DATA_DIRS)
	/usr/bin/time ./irc_reduce.sh              > irc_79488.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85776 > m31_85776.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85778 > m31_85778.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85824 > m31_85824.log 2>&1
	/usr/bin/time ./m51_reduce.sh              > m51_91112.log 2>&1

IRC_data:
	@echo For the IRC benchmark:  The directory IRC_data does not exist yet
	@echo and needs to manually created or symlinked to where the IRC_data are, e.g.
	@echo ""
	@echo "     ln -s /your_big_disk/data_lmt  IRC_data"
	@echo ""
	@echo "If @UMD: tar zxf /n/chara/teuben/LMT/IRC_data.tar.gz"
	@echo "Else:    contact us"
	@echo ""
	@echo "The same holds for the other test data, M31_data and M51_data"
	@exit 1

new:   bench11 bench31 bench51

old_new:
	/usr/bin/time ./lmtoy_reduce.sh obsnum=79448 > lmtoy_79448.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85776 > lmtoy_85776.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85778 > lmtoy_85778.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85824 > lmtoy_85824.log 2>&1
	/usr/bin/time ./lmtoy_combine.sh  obsnum=85776,85778,85824 > lmtoy_85776_3.log  2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=90911 > lmtoy_90911.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=91112 > lmtoy_91112.log 2>&1

# take about 1'41"
bench: # IRC_data
	@echo "Running benchmark"
	OMP_NUM_THREADS=1 /usr/bin/time ./irc_reduce.sh > irc_bench.log 2>&1
	@echo "Result:"
	@grep QAC_STATS irc_bench.log
	@echo "Should see, With the new edge blanking"
	@echo "QAC_STATS: IRC_79448.fits.ccd 0.0153953 0.503169 -66.2138 75.2123  0 0.0720699"
	@tail -2 irc_bench.log

# takes about 14"
bench1: # IRC_data
	@echo "Running quick test for 1 pixel"
	/usr/bin/time ./irc_reduce.sh pix_list=1 > irc_bench1.log 2>&1

# a plot bench for
bench2: IRC_data IRC_79448.nc
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2a
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2b -z -3
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2c -z -3 --radius 10
	@echo xdg-open bench2a.1.png 
	@echo xdg-open bench2b.1.png
	@echo xdg-open bench2c.1.png

bench11: # IRC_data
	/usr/bin/time ./lmtoy_reduce.sh obsnum=79448 > lmtoy_79448.log 2>&1

bench31: # M31_data
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85776 > lmtoy_85776.log   2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85778 > lmtoy_85778.log   2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=85824 > lmtoy_85824.log   2>&1
	/usr/bin/time ./lmtoy_combine.sh  obsnum=85776,85778,85824 > lmtoy_85776_3.log 2>&1
	/usr/bin/time ./nemo_combine.sh                        >  lmtoy_85776_nemo.log 2>&1

bench51: # M51_data
	/usr/bin/time ./lmtoy_reduce.sh obsnum=90911 > lmtoy_90911.log   2>&1
	/usr/bin/time ./lmtoy_reduce.sh obsnum=91112 > lmtoy_91112.log   2>&1
	/usr/bin/time ./lmtoy_combine.sh        obsnum=90911,91112 > lmtoy_90911_2.log 2>&1


ONT=1 2 4
bench4:
	@echo ONT=$(ONT)
	-@for i in $(ONT); do\
	(echo $$i;OMP_NUM_THREADS=$$i /usr/bin/time ./irc_reduce.sh > irc$$i.log 2>&1); done


test1:
	echo ./irc_reduce.sh > test1.log 2>&1
	./irc_reduce.sh makespec=0 pix_list=0,1,2,3     > test1a.log 2>&1; mv IRC_79448.fits test1a.fits
	./irc_reduce.sh makespec=0 pix_list=4,5,6,7     > test1b.log 2>&1; mv IRC_79448.fits test1b.fits
	./irc_reduce.sh makespec=0 pix_list=8,9,10,11   > test1c.log 2>&1; mv IRC_79448.fits test1c.fits
	./irc_reduce.sh makespec=0 pix_list=12,13,14,15 > test1d.log 2>&1; mv IRC_79448.fits test1d.fits

	./irc_reduce.sh makespec=0 pix_list=0,4,8,12    > test1e.log 2>&1; mv IRC_79448.fits test1e.fits
	./irc_reduce.sh makespec=0 pix_list=1,5,9,13    > test1f.log 2>&1; mv IRC_79448.fits test1f.fits
	./irc_reduce.sh makespec=0 pix_list=2,6,10,14   > test1g.log 2>&1; mv IRC_79448.fits test1g.fits
	./irc_reduce.sh makespec=0 pix_list=3,7,11,15   > test1h.log 2>&1; mv IRC_79448.fits test1h.fits

# RSR script example for obnum=33551  IRAS 10565+2448
#  https://iopscience.iop.org/article/10.1088/0004-6256/138/3/858/pdf
#  10 59 18.1 24 32 34 ;   1.4h   0.60 mK
#     -p doesn't seem to do anything
# Without the -o you get the default:
#     I10565_rsr_spectrum_bandspec.txt   (this is the -o file)
#     I10565_rsr_spectrum.txt            (not created if -o absent)

rsr:
	@echo python ../RSR_driver/rsr_driver.py rsr.obsnum -w rsr.wf.pdf -o rsr.tab -p -b 3
	python ../RSR_driver/rsr_driver.py rsr.obsnum -w rsr.wf.pdf
	tabplot I10565_rsr_spectrum.txt xmin=104 xmax=112 line=1,1 ycoord=0 point=2,0.05 \
		xlab='GHz' ylab='K (T_A)' headline=obsnum=33551 

rsr_plot:
	tabplot I10565_rsr_spectrum.txt xmin=104 xmax=112  line=1,1 ycoord=0 point=2,0.05 \
		xlab='GHz' ylab='K (T_A)' headline=obsnum=33551 yapp=I10565_rsr_spectrum.png/png
