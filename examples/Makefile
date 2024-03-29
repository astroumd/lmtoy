#  Various examples, benchmarks, tests
#

TIME = /usr/bin/time
RSR_DRIVER = ../RSR_driver/rsr_driver.py

#  It is assumed your testdata are in $DATA_LMT

help:
	@echo no help

#  takes about 21' in old, and 7' in new
all:
	$(TIME) irc_reduce.sh              > irc_79448.log 2>&1
	$(TIME) m31_reduce.sh obsnum=85776 > m31_85776.log 2>&1
	$(TIME) m31_reduce.sh obsnum=85778 > m31_85778.log 2>&1
	$(TIME) m31_reduce.sh obsnum=85824 > m31_85824.log 2>&1
	$(TIME) m51_reduce.sh              > m51_91112.log 2>&1


new:   bench11 bench31 bench51

# takes about 1'41" on a fast 2021 machine, and 0'45 in fast_nc mode (now default)
bench:
	@echo "Running benchmark"
	OMP_NUM_THREADS=1 $(TIME) irc_reduce.sh > irc_bench.log 2>&1
	@echo "Result:"
	@grep QAC_STATS irc_bench.log
	@echo "Should see, With the new edge blanking"
	@echo "QAC_STATS: IRC_79448.fits.ccd 0.0153953 0.503169 -66.2138 75.2123  0 0.0720699"
	@tail -2 irc_bench.log

# takes about 14"
bench1:
	@echo "Running quick test for 1 pixel"
	$(TIME) irc_reduce.sh pix_list=1 > irc_bench1.log 2>&1

# a plot bench for
bench2: IRC_79448.nc
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2a
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2b -z -3
	view_spec_point.py -i IRC_79448.nc --pix_list 0,5,10,15 --plots bench2c -z -3 --radius 10
	@echo xdg-open bench2a.1.png 
	@echo xdg-open bench2b.1.png
	@echo xdg-open bench2c.1.png

#  extra parameters for lmtoy_reduce (now: seq_pipeline)
EXTRA=viewspec=1 makewf=1

# about 60"
bench11:
	$(TIME) lmtoy_reduce.sh obsnum=79448 $(EXTRA) > lmtoy_79448.log 2>&1

bench11b:
	$(TIME) ./SLpipeline.sh obsnum=79448
	grep REGRESSION 2018S1SEQUOIACommissioning/79448/IRC+10216_79448.nf.fits.log   | grep CO_115
	@echo "REGRESSION from ADMIT should show as:"
	@echo "REGRESSION : MOM0FLUX: x.CO_115.27120 52328.9 22475.1 0.0330578 -19.6361 -19.6361 0.361693"

bench31:
	$(TIME) lmtoy_reduce.sh obsnum=85776 $(EXTRA) > lmtoy_85776.log   2>&1
	$(TIME) lmtoy_reduce.sh obsnum=85778 $(EXTRA) > lmtoy_85778.log   2>&1
	$(TIME) lmtoy_reduce.sh obsnum=85824 $(EXTRA) > lmtoy_85824.log   2>&1
	$(TIME) lmtoy_combine.sh  obsnum=85776,85778,85824 > lmtoy_85776_3.log 2>&1
	$(TIME) nemo_combine.sh                        >  lmtoy_85776_nemo.log 2>&1

# needs 5.2GB
bench31a:
	mkdir -p M31a
	$(TIME) lmtoy_reduce.sh  obsnum=85776 $(EXTRA)      pdir=M31a > M31a/lmtoy_85776.log   2>&1
	$(TIME) lmtoy_reduce.sh  obsnum=85778 $(EXTRA)      pdir=M31a > M31a/lmtoy_85778.log   2>&1
	$(TIME) lmtoy_reduce.sh  obsnum=85824 $(EXTRA)      pdir=M31a > M31a/lmtoy_85824.log   2>&1
	$(TIME) lmtoy_combine.sh obsnum=85776,85778,85824   pdir=M31a > M31a/lmtoy_85776_3.log 2>&1
	$(TIME) nemo_combine.sh                             pdir=M31a > M31a/lmtoy_85776_n.log 2>&1

bench31b:
	$(TIME) SLpipeline.sh  obsnum=85776 b_order=1 pix_list=0,1,2,4,5,6,7,8,9,10,11,12,13,14,15
	$(TIME) SLpipeline.sh  obsnum=85778 b_order=1 pix_list=0,1,2,4,5,6,7,8,9,10,11,12,13,14,15
	$(TIME) SLpipeline.sh  obsnum=85824 b_order=1
	$(TIME) lmtoy_combine.sh obsnum=85776,85778,85824 pdir=2018-S1-MU-46

bench51:
	$(TIME) lmtoy_reduce.sh obsnum=90911 $(EXTRA) > lmtoy_90911.log   2>&1
	$(TIME) lmtoy_reduce.sh obsnum=91112 $(EXTRA) > lmtoy_91112.log   2>&1
	$(TIME) lmtoy_combine.sh        obsnum=90911,91112 > lmtoy_90911_2.log 2>&1

bench51b:
	$(TIME) SLpipeline.sh obsnum=90911 
	$(TIME) SLpipeline.sh obsnum=91112 
	$(TIME) lmtoy_combine.sh  obsnum=90911,91112 pdir=2018-S1-MU-8

bench31c:
	$(TIME) lmtoy_reduce.sh obsnum=85776 noise_sigma=0 > lmtoy_85776.log   2>&1
	$(TIME) lmtoy_reduce.sh obsnum=85778 noise_sigma=0 > lmtoy_85778.log   2>&1
	$(TIME) lmtoy_reduce.sh obsnum=85824 noise_sigma=0 > lmtoy_85824.log   2>&1
	$(TIME) lmtoy_combine.sh obsnum=85776,85778,85824 noise_sigma=0 > lmtoy_85776_3.log 2>&1
	$(TIME) nemo_combine.sh                        >  lmtoy_85776_nemo.log 2>&1


ONT=1 2 4
bench4:
	@echo ONT=$(ONT)
	-@for i in $(ONT); do\
	(echo -n "$$i ";OMP_NUM_THREADS=$$i $(TIME) irc_reduce.sh > irc$$i.log 2>&1); done
	-@for i in $(ONT); do\
	(echo -n "$$i ";grep CPU irc$$i.log); done


test1:
	echo irc_reduce.sh > test1.log 2>&1
	irc_reduce.sh makespec=0 pix_list=0,1,2,3     > test1a.log 2>&1; mv IRC_79448.fits test1a.fits
	irc_reduce.sh makespec=0 pix_list=4,5,6,7     > test1b.log 2>&1; mv IRC_79448.fits test1b.fits
	irc_reduce.sh makespec=0 pix_list=8,9,10,11   > test1c.log 2>&1; mv IRC_79448.fits test1c.fits
	irc_reduce.sh makespec=0 pix_list=12,13,14,15 > test1d.log 2>&1; mv IRC_79448.fits test1d.fits

	irc_reduce.sh makespec=0 pix_list=0,4,8,12    > test1e.log 2>&1; mv IRC_79448.fits test1e.fits
	irc_reduce.sh makespec=0 pix_list=1,5,9,13    > test1f.log 2>&1; mv IRC_79448.fits test1f.fits
	irc_reduce.sh makespec=0 pix_list=2,6,10,14   > test1g.log 2>&1; mv IRC_79448.fits test1g.fits
	irc_reduce.sh makespec=0 pix_list=3,7,11,15   > test1h.log 2>&1; mv IRC_79448.fits test1h.fits


# RSR benchmark

# RSR script example for obnum=33551  IRAS 10565+2448   cz=12921 km/s
 
#  https://iopscience.iop.org/article/10.1088/0004-6256/138/3/858/pdf (Chung et al. 2009)
#  RA 10 59 18.1 DEC  24 32 34 ;  tint 1.4h   rms 0.60 mK
#     -p doesn't seem to do anything
# Without the -o you get the default:
#     I10565_rsr_spectrum_bandspec.txt   (this is the -o file)
#     I10565_rsr_spectrum.txt            (not created if -o absent)
# 6 bands, of which band 4: [(104.30771875, 112.27646875)] where the CO line is

BADLAGS = --badlags rsr1.badlags

rsr1:
	cat rsr1.obsnum
	$(TIME) python $(RSR_DRIVER) rsr1.obsnum -w rsr1.wf.pdf -p -b 3 --exclude 110.51 0.15 108.65 0.3 $(BADLAGS) > rsr1.log 2>&1
	cp I10565_rsr_spectrum.txt I10565_rsr1_spectrum.txt
	@echo The following two plots should be "identical", but first one peaks at 46mK, second at 50mK.
	-tabplot I10565_rsr1_spectrum.txt         xcol=1 ycol=2  xmin=104 xmax=112 ymin=-10 ymax=50 line=1,1 ycoord=0 point=2,0.05 yscale=1000 \
		xlab='GHz' ylab='mK (T_A)' headline=obsnum=33551  yapp=I10565_rsr1a_spectrum.png/png
	-tabplot I10565_rsr_spectrum_bandspec.txt xcol=9 ycol=10 xmin=104 xmax=112 ymin=-10 ymax=50 line=1,1 ycoord=0 point=2,0.05 yscale=1000 \
		xlab='GHz' ylab='mK (T_A)' headline=obsnum=33551a yapp=I10565_rsr1b_spectrum.png/png
	@echo "Determine the RMS*sqrt(2) in mK"
	-grep -v nan I10565_rsr1_spectrum.txt | tabtrend - 2 | tabhist - 1  -4 4     scale=1000 robust=t yapp=I10565_rsr1_rms.png/png
	@echo "Example fit of the 12CO line"
	-tabnllsqfit I10565_rsr1_spectrum.txt fit=gauss1d xrange=110:111 | tee fit1.log
	@a=$$(grep a= fit1.log); b=$$(grep b= fit1.log); c=$$(grep c= fit1.log); d=$$(grep d= fit1.log); rms=$$(grep rms= fit1.log);\
	echo  "FIT shows      : $$a $$b $$c $$d $$rms"
	@echo "FIT should show: a= -4.68656e-05 0.000227127  b= 0.0504297 0.00101759  c= 110.514 0.000808871 d= 0.0351696 0.00084017 rms= 0.00108359"

rsr1a:
	$(TIME) python rsr_sum.py -b rsr1.obsnum $(BADLAGS)  > rsr1a.log 2>&1
	@echo "Determine the RMS*sqrt(2) in mK"
	-grep -v nan rsr1.obsnum.sum.txt | tabtrend - 2 | tabhist - 1  -4 4     scale=1000 robust=t yapp=I10565_rsr1a_rms.png/png
	@echo "Example fit of the 12CO line"
	-tabnllsqfit rsr1.obsnum.sum.txt fit=gauss1d xrange=110:111 | tee fit1a.log
	@a=$$(grep a= fit1a.log); b=$$(grep b= fit1a.log); c=$$(grep c= fit1a.log); d=$$(grep d= fit1a.log); rms=$$(grep rms= fit1a.log);\
	echo  "FIT shows      : $$a $$b $$c $$d $$rms"
	@echo "FIT should show: a= -0.00218228 0.000231047  b= 0.049534 0.0010418  c= 110.514 0.000834269 d= 0.0347996 0.000866358 rms= 0.00110362"

rsr1b:
	$(TIME) python rsr_sum.py -b rsr1.blanking $(BADLAGS) > rsr1b.log 2>&1
	tabplot rsr1.blanking.sum.txt 1 2 line=1,1 ycoord=0 yapp=1/xs
	-grep -v 0.000000 rsr1.blanking.sum.txt | tabtrend - 2 | tabhist - 1  -16 16   scale=1000 robust=t bins=32 yapp=2/xs

rsr1c:
	$(TIME) python badlags.py 33551

# typical timing for 300 obsnums (one still bad)
# all procs:    2206.00user 123.86system 15:19.56elapsed 253%CPU
# 1 proc:        872.98user  48.28system 15:29.06elapsed  99%CPU
#
# See also: https://ui.adsabs.harvard.edu/abs/2011ApJ...732L..15C/abstract
#
# CAVEAT: data with 32m and 50m are combined here, so don't trust the mK scale
# These are data between obsum 15161 (2014-01-30) and 92068 (2020-03-04)

rsr2:
	$(TIME)	python $(RSR_DRIVER) rsr2.obsnum -w rsr2.wf.pdf -p -b 3 --exclude 110.51 0.15 108.65 0.3 85.2 0.4 > rsr2.log 2>&1
	cp I10565_rsr_spectrum.txt I10565_rsr2_spectrum.txt 
	-tabplot I10565_rsr2_spectrum.txt  ymin=-10 ymax=50 line=1,1 ycoord=0 point=2,0.05 yscale=1000 \
		xlab='GHz' ylab='mK (T_A)' headline=obsnum=all yapp=I10565_rsr2_spectrum.png/png
	@echo "Determine the RMS*sqrt(2) in mK"
	-grep -v nan I10565_rsr2_spectrum.txt | tabtrend - 2 | tabhist - 1  -0.4 0.4     scale=1000 robust=t yapp=I10565_rsr2_rms.png/png
	@echo "Example fits of the 12CO line"
	-tabnllsqfit I10565_rsr2_spectrum.txt fit=gauss1d xrange=110:111 | tee fit2.log
	@a=$$(grep a= fit2.log); b=$$(grep b= fit2.log); c=$$(grep c= fit2.log); d=$$(grep d= fit2.log); rms=$$(grep rms= fit2.log);\
	echo  "FIT shows      : $$a $$b $$c $$d $$rms"
	@echo "FIT should show: a= 0.000113749 0.000115652  b= 0.0440424 0.000525824  c= 110.507 0.000467126 d= 0.0342954 0.00048396  rms= 0.000553378"

# Min Yun's example. This also needs "all" the RSR data (111 obsnums are used).  Takes about 3' on "cln"
# These are data between obsnum 28190 (2014-11-13) and 61979 (2016-04-17)
rsr3-old:
	$(TIME) python I10565.sum.py > rsr3-old.log 2>&1
	-tabplot I10565.sum.txt  ymin=-10 ymax=50 line=1,1 ycoord=0 point=2,0.05 yscale=1000 \
		xlab='GHz' ylab='mK (T_A)' headline=obsnum=all yapp=I10565.sum.png/png
	@echo "Determine the RMS*sqrt(2) in mK"
	-grep -v nan I10565.sum.txt | tabtrend - 2 | tabhist - 1  -0.4 0.4     scale=1000 robust=t yapp=I10565.sum.rms.png/png
	@echo "Should show:         Robust Mean Disp     : -0.00100919 0.124678"
	@echo "Example fits of the 12CO line"
	-tabnllsqfit I10565.sum.txt fit=gauss1d xrange=110:111 | tee fit3.log
	@a=$$(grep a= fit3.log); b=$$(grep b= fit3.log); c=$$(grep c= fit3.log); d=$$(grep d= fit3.log); rms=$$(grep rms= fit3.log);\
	echo  "FIT shows      : $$a $$b $$c $$d $$rms"
	@echo "FIT should show: a= 0.000179097 0.000118254  b= 0.0466679 0.000536265  c= 110.508 0.000451531 d= 0.0344496 0.000468057 rms= 0.000565537"

rsr3:
	$(TIME) python rsr_sum.py -b I10565.blanking > rsr3.log 2>&1
	-tabplot I10565.blanking.sum.txt  ymin=-10 ymax=50 line=1,1 ycoord=0 point=2,0.05 yscale=1000 \
		xlab='GHz' ylab='mK (T_A)' headline=obsnum=all yapp=I10565.blanking.sum.png/png
	@echo "Determine the RMS*sqrt(2) in mK"
	-grep -v nan I10565.blanking.sum.txt | tabtrend - 2 | tabhist - 1  -0.4 0.4     scale=1000 robust=t yapp=I10565.blanking.sum.rms.png/png
	@echo "Should show:         Robust Mean Disp     : -0.00100919 0.124678"
	@echo "Example fits of the 12CO line"
	-tabnllsqfit I10565.blanking.sum.txt fit=gauss1d xrange=110:111 | tee fit3.log
	@a=$$(grep a= fit3.log); b=$$(grep b= fit3.log); c=$$(grep c= fit3.log); d=$$(grep d= fit3.log); rms=$$(grep rms= fit3.log);\
	echo  "FIT shows      : $$a $$b $$c $$d $$rms"
	@echo "FIT should show: a= 0.000179097 0.000118254  b= 0.0466679 0.000536265  c= 110.508 0.000451531 d= 0.0344496 0.000468057 rms= 0.000565537"

#       this is a benchmark to ensure that combinations do not depend on the order of the obsnums
rsr4:
	SLpipeline.sh obsnum=33551 restart=1 admit=0
	SLpipeline.sh obsnum=71610 restart=1 admit=0
	SLpipeline.sh obsnum=92068 restart=1 admit=0
	SLpipeline.sh obsnums=33551,71610 restart=1 admit=0
	SLpipeline.sh obsnums=71610,33551 restart=1 admit=0
	SLpipeline.sh obsnums=71610,92068 restart=1 admit=0
	SLpipeline.sh obsnums=92068,71610 restart=1 admit=0

1mm:
	$(TIME) process_ps.py --obs_list 82480 --pix_list 2 --bank 0 -p $(DATA_LMT) --x_axis VSRC


# to get the test data mentioned in this Makefile, run the following commands on a machine where $DATA_LMT has these
# and untar them on the where you want them
data:
	lmtar irc_2018.tar 79447 79448
	lmtar m31_2019.tar 85775 85776 85777 85778 85823 85824
	lmtar m51_2020.tar 91111 91112 90910 90911
	lmtar 1mm_2018.tar 82479 82480
	lmtar rsr_2018.tar 33550 33551 71609 71610 92066 92068 
