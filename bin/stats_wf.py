#! /usr/bin/env python
#
#      some stats on a waterfall plot
#

from docopt import docopt

_version = "2-mar-2023"

_help    = """Usage: stats_wf.py [options] FITSFILE

Show some statistics of a waterfall cube.

Options:
  -s                   Save plot, no interactive plot.
  -t                   Plot along time instead of channel
  -d                   Add more debug
  -h --help            show this help
  --version            show version

Expect a Time x Channels x Beams  waterfall cube. 
axis statistics are listed and plotted


version: %s

""" % _version

av = docopt(_help,options_first=True, version=_version)
Qdebug = av['-d']
if Qdebug:
    print(av)



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



ff = av['FITSFILE']
hdu = fits.open(ff)
data=hdu[0].data
head=hdu[0].header

nz = data.shape[0]   # number of beams
ny = data.shape[1]   # number of channels
nx = data.shape[2]   # number of time samples

pix_list = pixels(head)

if av['-t']:
    axis = 0     # plot along time
else:
    axis = 1     # plot along channel

# showing interactive plot/
Qshow = not av['-s']

    
print("# beam RMS <rms_chan> <rms_time>")
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

plt.title(ff)
if axis==0:
    plt.xlabel('Time Sample')
else:
    plt.xlabel('Channel')
plt.ylabel('RMS')

# @todo   figure out a more universal best scaling 
#plt.ylim([0.40,1.65])

plt.legend()

if Qshow:
    plt.show()
else:
    filename = 'stats_wf%d.png' % axis
    plt.savefig(filename)
    print("Wrote %s" % filename)




