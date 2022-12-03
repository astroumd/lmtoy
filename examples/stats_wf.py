#! /usr/bin/env python
#
#      some stats on a waterfall plot
#
import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from astropy.io import fits

def pixels(head):
    """ find and parse a comment line from a fits header like
           COMMENT pix_list: [1,2,3]
        into a python list and return that
    """
    for h in head:
        if h == 'COMMENT':
            for c in head[h]:
                if c.find('pix_list:') == 0:
                    cmd='pl = %s' % c[9:]
                    ldict = {}
                    exec(cmd, globals(), ldict)
                    return ldict['pl']

ff = sys.argv[1]
hdu = fits.open(ff)
data=hdu[0].data
head=hdu[0].header

nz = data.shape[0]   # number of beams
ny = data.shape[1]   # number of channels
nx = data.shape[2]   # number of time samples

pix_list = pixels(head)

if len(sys.argv) > 2:
    axis=int(sys.argv[2])
else:
    axis=1

    
print("# chan RMS <rms_chan> <rms_time>")
plt.figure()

for z in range(nz):
    p = pix_list[z]
    d = data[z,:,:]
    rms0 = d.std(axis=0)
    rms1 = d.std(axis=1)
    print(p,d.std(),rms0.mean(),rms1.mean(),rms0.std(),rms1.std())
    if axis==0:
        plt.plot(rms0, label=str(p))
    else:
        plt.plot(rms1, label=str(p))

plt.title(str(sys.argv[1:]))
if axis==0:
    plt.xlabel('Time Sample')
else:
    plt.xlabel('Channel')
plt.ylabel('RMS')

# @todo   figure out a more universal best scaling 
#plt.ylim([0.40,1.65])

plt.legend()
plt.savefig('stats_wf.png')
# plt.show()



