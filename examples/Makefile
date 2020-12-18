#
#



DATA_DIRS = IRC_data M31_data M51_data

all:   $(DATA_DIRS)
	/usr/bin/time ./irc_reduce.sh              > irc_79488.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85776 > m31_85776.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85778 > m31_85778.log 2>&1
	/usr/bin/time ./m31_reduce.sh obsnum=85824 > m31_85824.log 2>&1
	/usr/bin/time ./m51_reduce.sh              > m51_91112.log 2>&1

bench: IRC_data
	@echo "Running benchmark"
	/usr/bin/time ./irc_reduce.sh > irc_bench.log 2>&1
	@echo "Result:"
	@grep QAC_STATS irc_bench.log
	@echo "Should see:"
	@echo "QAC_STATS: IRC_79448.fits.ccd -0.0295232 25.0818 -7545.73 5872.96  0 -0.0455642"
bench4:
	OMP_NUM_THREADS=1 /usr/bin/time ./irc_reduce.sh > irc1.log 2>&1
	OMP_NUM_THREADS=2 /usr/bin/time ./irc_reduce.sh > irc2.log 2>&1
	OMP_NUM_THREADS=4 /usr/bin/time ./irc_reduce.sh > irc4.log 2>&1
