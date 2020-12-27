#
#

#  Directories (or symlinks to) the data
DATA_DIRS = IRC_data M31_data M51_data

#  takes 20'44" (with NEMO, 20'20" without)
all:   $(DATA_DIRS)
	/usr/bin/time ./irc_reduce.sh              > irc_79488.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85776 > m31_85776.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85778 > m31_85778.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85824 > m31_85824.log 2>&1
	/usr/bin/time ./m51_reduce.sh              > m51_91112.log 2>&1

new:   $(DATA_DIRS)
	/usr/bin/time ./lmtoy_reduce.sh path=IRC_data obsnum=79448 > lmtoy_79448.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh path=M31_data obsnum=85776 > lmtoy_85776.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh path=M31_data obsnum=85778 > lmtoy_85778.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh path=M31_data obsnum=85824 > lmtoy_85824.log 2>&1
	/usr/bin/time ./lmtoy_reduce.sh path=M51_data obsnum=91112 > lmtoy_91112.log 2>&1

# take about 1'41"
bench: IRC_data
	@echo "Running benchmark"
	/usr/bin/time ./irc_reduce.sh > irc_bench.log 2>&1
	@echo "Result:"
	@grep QAC_STATS irc_bench.log
	@echo "Should see:"
	@echo "With edge blanking"
	@echo "QAC_STATS: IRC_79448.fits.ccd 0.0138192 2.28207 -626.549 469.641  0 0.0580601"
	@echo "Without edge blanking (original)"
	@echo "QAC_STATS: IRC_79448.fits.ccd -0.00431168 8.59776 -2360.77 2454.97  0 -0.0124982"

# takes about 14"
bench1: IRC_data
	@echo "Running quick test for 1 pixel"
	/usr/bin/time ./irc_reduce.sh pix_list=1 > irc_bench1.log 2>&1

bench4:
	OMP_NUM_THREADS=1 /usr/bin/time ./irc_reduce.sh > irc1.log 2>&1
	OMP_NUM_THREADS=2 /usr/bin/time ./irc_reduce.sh > irc2.log 2>&1
	OMP_NUM_THREADS=4 /usr/bin/time ./irc_reduce.sh > irc4.log 2>&1


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
