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

# take about 1'41"
bench: IRC_data
	@echo "Running benchmark"
	/usr/bin/time ./irc_reduce.sh > irc_bench.log 2>&1
	@echo "Result:"
	@grep QAC_STATS irc_bench.log
	@echo "Should see:"
	@echo "QAC_STATS: IRC_79448.fits.ccd -0.00431168 8.59776 -2360.77 2454.97  0 -0.0124982"

# takes about 14"
bench1: IRC_data
	@echo "Running quick test for 1 pixel"
	/usr/bin/time ./irc_reduce.sh pix_list=1 > irc_bench1.log 2>&1

bench4:
	OMP_NUM_THREADS=1 /usr/bin/time ./irc_reduce.sh > irc1.log 2>&1
	OMP_NUM_THREADS=2 /usr/bin/time ./irc_reduce.sh > irc2.log 2>&1
	OMP_NUM_THREADS=4 /usr/bin/time ./irc_reduce.sh > irc4.log 2>&1
