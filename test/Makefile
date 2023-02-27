#

TIME = /usr/bin/time


bench_rsr:
	$(TIME) ./sdfitsio.py junk.fits 1000,2,2,6,256

bench_seq2:
	$(TIME) ./sdfitsio.py junk.fits 100000,1,1,1,2048

bench_seq8:
	$(TIME) ./sdfitsio.py junk.fits 100000,1,1,1,8196

