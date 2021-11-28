#! /usr/bin/env python
#  template script written by NEMO::pytable
#

import sys
import numpy as np

#import matplotlib
#matplotlib.use('svg')
import matplotlib.pyplot as plt

Qshow = True
ext   = 'png'
base  = 'rsr.spectra'
n     = 0

def my_help():
    """   usage reminder
    """
    print("Plot one or more overlayed spectra - X,Y in cols 1,2, comments allowed")
    print("Output basename %s" % base)
    print("-s      show interactive plot as well")
    print("-z      use SVG instead of PNG")
    print("-co     show 106..112 GHz (last band)")
    print("-h      this help")


if len(sys.argv) == 1:
    print("RSR spectra plotter")
    print("Usage:   %s [")
    sys.exit(0)


plt.figure()

for f in sys.argv[1:]:
    if f == '-h':
        my_help()
        continue
    if f == '-s':
        Qshow = False
        continue
    if f == "-co":
        plt.xlim([106,112])
        continue
    if f == '-z':
        ext = 'svg'
        continue
    n = n + 1
    data1 = np.loadtxt(f).T
    plt.step(data1[0],data1[1],label=f, where='mid')

if n==0:
    sys.exit(0)
plt.xlabel('Freq  (GHz)')
plt.ylabel('Ta (K)')
#plt.ylim([0,1])
plt.title('RSR spectra')
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)
