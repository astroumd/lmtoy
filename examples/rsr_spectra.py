#! /usr/bin/env python
#  template script written by NEMO::pytable
#
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
# plt.style.use("grayscale")

Qshow = False
pout  = 'rsr.spectra.png'
n     = 0

plt.figure()

for f in sys.argv[1:]:
    if f == '-h':
        print("Plot one or more overlayed spectra - X,Y in cols 1,2, comments allowed")
        print("Output in %s" % pout)
        print("-s      show interactive plot as well")
        print("-co     show 106..112 GHz (last band)")
        print("-h      this help")
        continue
    if f == '-s':
        Qshow = True
        continue
    if f == "-co":
        plt.xlim([106,112])
        continue
    n = n + 1
    data1 = np.loadtxt(f).T
    # @todo   is the freq at the start or middle of the channel?
    plt.step(data1[0],data1[1],label=f)

if n==0:
    sys.exit(0)
plt.xlabel('Freq  (GHz)')
plt.ylabel('Ta (K)')
#plt.ylim([0,1])
plt.title('RSR spectra')
plt.legend()
plt.savefig(pout)
if Qshow:
    plt.show()
