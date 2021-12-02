#

RSR = https://www.astro.umd.edu/~teuben/LMT/live/rsr4data_lmt.tar

help:
	@echo No help here

#       make a new time reverse sorted data_lmt.log - takes about 9 mins on "cln"
new:
	lmtinfo.py $(DATA_LMT)                        > data_lmt.new
	echo "# LAST UPDATED: `date` on `hostname`"   > data_lmt.log
	sort -r data_lmt.new                         >> data_lmt.log
	rm data_lmt.new

#  in the real $DATA_LMT : for RSR data a small calibration directory 'rsr' is needed (about 35MB)
rsr:
	wget -O - $(RSR) | tar -xf -

clean:
	rm -rf rsr
