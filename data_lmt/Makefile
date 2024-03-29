#


URL1 = https://www.astro.umd.edu/~teuben/LMT/data_lmt/rsr_bench.tar.gz
URL2 = https://www.astro.umd.edu/~teuben/LMT/data_lmt/seq_bench.tar.gz
URL3 = https://www.astro.umd.edu/~teuben/LMT/live/rsr4data_lmt.tar

SLEEP = 5

help:
	@echo "Your current DATA_LMT=$(DATA_LMT)"
	@echo "Here you could place your LMT RAW data"
	@echo "  help:    this help"
	@echo "  new:     make a new data_lmt.log here"
	@echo "  new2:    append to data_lmt.log based on OBSNUM0=   usually from last.obsnum"
	@echo "  data:    download needed benchmark obsnums (33551 for RSR, 79448 for SEQ)"
	@echo "  rsr:     only download the RSR calibration tables"

#       make a new time reverse sorted data_lmt.log - takes long time
new:
	@echo "Sleeping for a few seconds, then new making a new data_lmt.log [takes long time]"XS
	sleep $(SLEEP)
	lmtinfo.py $(DATA_LMT)                        > data_lmt.new
	echo "# LAST UPDATED: `date` on `hostname`"   > data_lmt.log
	sort -r data_lmt.new                         >> data_lmt.log
	rm data_lmt.new

OBSNUM0=`cat last.obsnum`
last:
	@echo $(OBSNUM0)
new2:
	@echo "Sleeping for a few seconds, then new2 OBSNUM0=$(OBSNUM0)"
	sleep $(SLEEP)
	cp data_lmt.log data_lmt.new
	lmtinfo.py new $(OBSNUM0)  >> data_lmt.new
	sort -r data_lmt.new | uniq > data_lmt.log
	@echo "Most recent obsnum: `tabcols data_lmt.log 2 | head -1`"

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
