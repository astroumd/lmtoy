#! /usr/bin/env python
#
#    plot one or more RSR spectra, optionally a band or piece of the spectrum
#

"""Usage: rsr_spectra.py [options] SPECTRUM1 [SPECTRUM2...]

Options:
  -s                      Don't show interactive plot, save plotfile instead.
  -g                      Use SVG instead of PNG for plotfile
  -z --zoom CEN,WID       Zoom spectrum on a CEN and +/- WID. Optional.
  -b --band BAND          Zoom on this band (0..5). Optional.
  -t --title TITLE        Title of plot. Optional.
  -d --dash LEVEL         Dashed line at 0+/-LEVEL. Optional.
  --kscale KSCALE         Scale factor to apply to spectrum  [Default: 1000]
  -h --help               This help
  --version               The script version

One or more ASCII spectra are needed, with columns 1 and 2 designating the
frequency (for RSR in GHz) and amplitude (for RSR in Kelvin).
By default the full spectrum is plotted, but using --zoom or --band (RSR only)
a section of the spectrum can be plotted instead.
Using "--kscale 1000" the assumed Kelvin scale factor can be used to plot in mK.

The saved plotfile has a fixed name, rsr.spectra.png (or rsr.spectra.svg)

"""
_version = "3-feb-2023"

import sys
import numpy as np
from docopt import docopt
#import matplotlib
#matplotlib.use('svg')
import matplotlib.pyplot as plt

Qshow  = True               # -s
ext    = 'png'              # -z
base   = 'rsr.spectra' 
title  = 'RSR spectra'      # --title
xtitle = 'Freq (GHz)'       
ytitle = 'Ta (K)'
band   = -1                 # --band
band_edges = [ (71.72, 79.69), (78.02 , 85.99),  (85.41,  93.38),
               (90.62, 98.58), (96.92, 104.88), (104.31, 112.28)]


av = docopt(__doc__,options_first=True, version='rsr_spectra.py %s' % _version)
#print(av)

plt.figure()

kscale = float(av['--kscale'])
if kscale == 1000.0:
    ytitle = 'Ta (mK)'
elif kscale != 1.0:
    ytitle = 'Ta (K/%g)' % kscale
#print("kscale=",kscale)    
    
if av['--title'] != None:
    title = av['--title']

if av['-s']:
    Qshow = False

if av['--band'] != None:
    band = int(av['--band'])

if av['--zoom'] != None:
    band = -1
    cw = av['--zoom'].split(',')
    cen = float(cw[0])
    wid = float(cw[1])
    plt.xlim(cen-wid, cen+wid)
    xtitle = xtitle + '   [Zoom %g +/- %g]' % (cen,wid)

if band >= 0 and band <=5:
    be = band_edges[band]
    print("Using band edges ",be)
    plt.xlim(be)
    xtitle = xtitle + '   [RSR Band %d]' % band

if av['-g']:
    ext = 'svg'

spectra = [av['SPECTRUM1']]
spectra = spectra + av['SPECTRUM2']

for f in spectra:
    data1 = np.loadtxt(f).T
    data1[1] = kscale* data1[1] 
    plt.step(data1[0],data1[1],label=f, where='mid')


plt.xlabel(xtitle)
plt.ylabel('Ta (mK)')
#plt.ylim([0,1])
plt.title(title)
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)


