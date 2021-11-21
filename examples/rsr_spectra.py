#! /usr/bin/env python
#  template script written by NEMO::pytable
#
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
# plt.style.use("grayscale")

plt.figure()

for f in sys.argv[1:]:
    data1 = np.loadtxt(f).T
    # @todo   is the freq at the start or middle of the channel?
    plt.step(data1[0],data1[1],label=f)

    
plt.xlabel('Freq  (GHz)')
plt.ylabel('Ta (K)')
#plt.xlim([100,110])
#plt.ylim([0,1])
plt.title('RSR spectra')
plt.legend()
plt.savefig('rsr.spectra.png')
plt.show()
