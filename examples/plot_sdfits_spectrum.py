#! /usr/bin/env python
#  Plot (first) spectrum from an SDFITS file - very basic astropy

import sys
from astropy.io import fits
import matplotlib.pyplot as plt

if len(sys.argv) == 1:
    print("Usage: %s sdfits_file [spectrum#]" % sys.argv[0])
    sys.exit(0)

sdfits = sys.argv[1]
if len(sys.argv) > 2:
    n = int(sys.argv[2])
else:
    n = 0

hdu = fits.open(sdfits)
d2 = hdu[1].data
nmax = len(d2['DATA'])
if n > nmax:
    print("Good luck, only %d here" % nmax)
    sys.exit(0)
data = d2['DATA'][n]


plt.figure()
plt.plot(data)
plt.xlabel("Channel")
plt.ylabel("Data")
plt.title("%s[%d]" % (sdfits,n))
plt.show()
