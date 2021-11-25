#! /bin/bash
#
#  summarize some property of a series of obsnums
#

for d in $*; do
    cd $d
    for o in ????? ?????_?????; do
	rc=$o/lmtoy_*$o.rc
	log=$o/lmtoy_*$o.log
	source $rc
	date_obs=$(grep date-obs $rc | awk -F= '{print $2}')
	rms=$(grep QAC_STATS $log | tail -1 | awk '{print $4}')
	echo $date_obs $obsnum $rms
    done
    cd ..
done

