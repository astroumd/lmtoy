#! /bin/bash
#
#  Combining M31 maps using NEMO, everything hardcoded
#

obsnum=(85776 85778 85824)
pdir=""


#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done


if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


src=Region_J-K_
o1=85776
o2=85778
o3=85824


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
ccdmath $f1.ccd,$w1.ccd,$f2.ccd,$w2.ccd,$f3.ccd,$w3.ccd ${src}_nemo.ccd '(%1*%2+%3*%4+%5*%6)/(%2+%4+%6)' replicate=t error=1 
ccdsub  ${src}_nemo.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t


ccdfits ${src}_nemo.ccd  ${src}_nemo.fits fitshead=$f1.fits error=1

fitsccd Region_J-K_85776_85824.fits - | ccdmath -,${src}_nemo.ccd ${src}_diff.ccd %1-%2 error=1

ccdsub  ${src}_diff.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
