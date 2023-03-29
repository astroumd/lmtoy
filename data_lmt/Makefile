#


URL1 = https://www.astro.umd.edu/~teuben/LMT/data_lmt/rsr_bench.tar.gz
URL2 = https://www.astro.umd.edu/~teuben/LMT/data_lmt/seq_bench.tar.gz
URL3 = https://www.astro.umd.edu/~teuben/LMT/live/rsr4data_lmt.tar

help:
	@echo "Your current DATA_LMT=$(DATA_LMT)"
	@echo "Here you could place your LMT RAW data"
	@echo "  help:    this help"
	@echo "  new:     make a new data_lmt.log here"
	@echo "  data:    download needed benchmark obsnums (33551 for RSR, 79448 for SEQ)"
	@echo "  rsr:     only download the RSR calibration tables"

#       make a new time reverse sorted data_lmt.log - takes about 9 mins on "cln"
new:
	lmtinfo.py $(DATA_LMT)                        > data_lmt.new
	echo "# LAST UPDATED: `date` on `hostname`"   > data_lmt.log
	sort -r data_lmt.new                         >> data_lmt.log
	rm data_lmt.new

OBSNUM0=0
new2:
	cp data_lmt.log data_lmt.new
	lmtinfo.py new $(OBSNUM0)  >> data_lmt.new
	sort -r data_lmt.new | uniq > data_lmt.log

data:   ifproc RedshiftChassis0

# 33551 RSR data + calibration files
RedshiftChassis0:
	wget -O - $(URL1) | tar -zxf -

# 79448 SEQ data
ifproc:
	wget -O - $(URL2) | tar -zxf -

#  in the real $DATA_LMT : for RSR data a small calibration directory 'rsr' is needed (about 35MB)
#  it is also included in the rsr_bench dataset
rsr:
	wget -O - $(URL3) | tar -xf -
