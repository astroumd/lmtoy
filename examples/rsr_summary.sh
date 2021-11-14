#! /bin/bash
#

f=$1

# NEMO based, 3 spectra

tmp=tmp$$

echo "# Min/Max/Mean/RMS of 3 spectra"
grep 'min and max'         $f | awk -F: '{print $3}' > $tmp.1
grep 'Mean and dispersion' $f | awk -F: '{print $3}' > $tmp.2
paste $tmp.1 $tmp.2

grep QAC_STATS $f
