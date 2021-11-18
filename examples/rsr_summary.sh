#! /bin/bash
#

f=$1

# NEMO based, 3 spectra

tmp=tmp$$

echo "# Mean/RMS/Min/Max of 3 spectra"
grep 'Mean and dispersion' $f | awk -F: '{print $3}' > $tmp.1
grep 'min and max'         $f | awk -F: '{print $3}' > $tmp.2
paste $tmp.1 $tmp.2
rm -f $tmp.1 $tmp.2

grep QAC_STATS $f


# cleanup
rm $tmp.?
