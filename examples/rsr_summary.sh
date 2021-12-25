#! /bin/bash
#

f=$1

# NEMO based, 2 spectra

tmp=tmp$$

grep 'Mean and dispersion' $f | awk -F: '{print $3}' > $tmp.1
grep 'min and max'         $f | awk -F: '{print $3}' > $tmp.2
paste $tmp.1 $tmp.2

echo "QAC_STATS Mean/RMS/Min/Max of spectra"
grep QAC_STATS $f

# cleanup
rm $tmp.?
