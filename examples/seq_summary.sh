#! /bin/bash
#

f=$1

# NEMO based, some cubes

tmp=tmp$$


# maps :
#    IRC+10216_079448.ccd
#    IRC+10216_079448.wt.ccd



echo "# Min/Max/Mean/RMS of 2 cubes"
grep 'Min and Max'  $f | awk -F: '{print $2}'   > $tmp.1
grep 'Mean Robust'  $f | awk -F: '{print $2}'   > $tmp.2
grep 'Sigma Robust' $f | awk -F: '{print $2}'   > $tmp.3
paste $tmp.1 $tmp.2 $tmp.3

grep QAC_STATS $f

# cleanup
rm -f $tmp.?
