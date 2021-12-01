#

help:
	@echo No help here

#       make a new time reverse sorted data_lmt.log - takes about 9 mins on "cln"
new:
	lmtinfo.py $$DATA_LMT                         > data_lmt.new
	echo "# LAST UPDATED: `date` on `hostname`"   > data_lmt.log
	sort -r data_lmt.new                         >> data_lmt.log
