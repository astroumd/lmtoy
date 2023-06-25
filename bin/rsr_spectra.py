#! /usr/bin/env python
#
#    plot one or more RSR spectra, optionally a band or piece of the spectrum
#

"""Usage: rsr_spectra.py [options] SPECTRUM1 [SPECTRUM2...]

Options:
  -s                      Don't show interactive plot, save plotfile instead.
  -g                      Use SVG instead of PNG for plotfile
  -o SPECTRUM             Optional output file indicated a weighted average
  -a                      No weighted average, use a simple average [not implemented yet]
  -z --zoom CEN,WID       Zoom spectrum on a CEN and +/- WID. Optional.
  -b --band BAND          Zoom on this band (0..5). Optional.
  -t --title TITLE        Title of plot. Optional.
  -d --dash LEVEL         Dashed line at 0+/-LEVEL. Optional.
  --kscale KSCALE         Scale factor to apply to spectrum  [Default: 1000]
  -h --help               This help
  --debug                 More debugging output
  --version               The script version

One or more ASCII spectra are needed, with columns 1 and 2 designating the
frequency (for RSR in GHz) and amplitude (for RSR in Kelvin).
By default the full spectrum is plotted, but using --zoom or --band (RSR only)
a section of the spectrum can be plotted instead.
Using "--kscale 1000" the assumed Kelvin scale factor can be used to plot in mK.

Use the "-o" option to merge the instead, and write (and plot) the merged
spectrum.   For rsr the presence of a 3rd column insidicates the dispersion in
the spectra, which will translate into a weight ~ 1/dispersion^2

The saved plotfile has a fixed name, rsr.spectra.png (or rsr.spectra.svg)

"""
_version = "24-jun-2023"

import sys
import numpy as np
from docopt import docopt

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



kscale = float(av['--kscale'])
if kscale == 1000.0:
    ytitle = 'Ta (mK)'
elif kscale != 1.0:
    ytitle = 'Ta (K/%g)' % kscale
#print("kscale=",kscale)    
    
if av['--title'] != None:
    title = av['--title']

Qdebug = av['--debug']
if Qdebug:
    print(av)

if av['-o']:
    Qmerge = True
    merge = av['-o']
else:
    Qmerge = False
    
if av['-s']:
    Qshow = False

import matplotlib
if Qshow:
    matplotlib.use('qt5agg')
else:
    matplotlib.use('agg')
import matplotlib.pyplot as plt
print('mpl backend',matplotlib.get_backend())
    

plt.figure()

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
nfiles = len(spectra)
data = list(range(nfiles))

for i in range(nfiles):
    f = spectra[i]
    data[i] = np.loadtxt(f).T
    if Qmerge:
        if i==0:
            ncol = data[i].shape[0]
        else:
            ncol = min(ncol,data[i].shape[0])
    else:
        plt.step(data[i][0], data[i][1]*kscale, label=f, where='mid')

if Qmerge:        
    print("Ncol=",ncol)
    nchan = len(data[0][0])
    sum =  0.0 * data[0][0]
    if ncol == 2:
        mode = "Average"
        for i in range(nfiles):
            sum = sum + data[i][1]
        sum = sum / nfiles
    else:
        mode = "Weighted Average"
        wsum =  sum
        for i in range(nfiles):
            sum = sum + data[i][1]/(data[i][2]**2)
            wsum = wsum + 1/(data[i][2]**2)
        sum = sum / wsum
    print(mode)
    header = '%s of %s' % ( mode, str(spectra))
    np.savetxt(merge, np.transpose([data[0][0], sum]), header=header)
        
    plt.step(data[0][0], sum*kscale, label=merge, where='mid')

plt.xlabel(xtitle)
plt.ylabel(ytitle)
#plt.ylim([0,1])
plt.title(title)
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)


