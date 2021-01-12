#! /bin/bash
#
#  Combining M31 maps using NEMO, everything hardcoded
#

obsnum=(85776 85778 85824)


src=Region_J-K_
o1=85776
o2=85776
o3=85776


#                  fits files base names
f1=${src}${o1}
f2=${src}${o2}
f3=${src}${o3}

#                  weight maps base names
w1=${src}${o1}.wt
w2=${src}${o2}.wt
w3=${src}${o3}.wt

#                  convert to NEMO
fitsccd $f1.fits $f1.ccd error=1
fitsccd $f2.fits $f2.ccd error=1
fitsccd $f3.fits $f3.ccd error=1
fitsccd $w1.fits $w1.ccd error=1
fitsccd $w2.fits $w2.ccd error=1
fitsccd $w3.fits $w3.ccd error=1

#                  combine
ccdmath $f1.ccd,$w1.ccd,$f2.ccd,$w2.ccd,$f3.ccd,$w3.ccd - '(%1*%2+%3*%4+%5*%6)/(%2+%4+%6)' replicate=t error=1 |\
    ccdfits - ${src}_nemo.fits fitshead=$f1.fits

