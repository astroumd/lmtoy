#! /usr/bin/env python
#
#    plot one or more RSR spectra, optionally a band or piece of the spectrum
#

"""Usage: tab_plot.py [options] TABLE1 [TABLE2...]

Options:
  -s                      Don't show interactive plot, save plotfile instead.
  -g                      Use SVG instead of PNG for plotfile
  -t --title TITLE        Title of plot. Optional.
  --ycoord YCOORD         Dashed line at YCOORD. Optional.
  --xscale XSCALE         Scale factor to apply to X axis [Default: 1.0]
  --yscale YSCALE         Scale factor to apply to Y axis [Default: 1.0]
  --xlab XLAB             X-axis label [Default: X]
  --ylab YLAB             Y-axis label [Default: Y]
  --xrange XMIN,XMAX      Min and Max of X-coordinate. Optional.
  --yrange YMIN,YMAX      Min and Max of Y-coordinate. Optional.
  --size SIZE             Plotsize in inches. [Default: 8.0]
  --dpi DPI               DPI of plot. [Default: 100]
  -z --ext EXT            Plotfile extension.  [Default: png]
  -h --help               This help
  --debug                 More debugging output
  --version               The script version

One or more ASCII tables are needed, with columns 1 and 2 designating the
X and Y coordinates.

The saved plotfile has a fixed name, tabplot.png (or tabplot.svg)

"""
_version = "17-jul-2023"

import sys
import numpy as np
from docopt import docopt

Qshow  = True               # -s
base   = 'tab_plot' 
title  = 'tab_plot'         # --title


av = docopt(__doc__,options_first=True, version='rsr_spectra.py %s' % _version)


xscale = float(av['--xscale'])
yscale = float(av['--yscale'])
size = float(av['--size']) 
dpi = float(av['--dpi'])
ext = av['--ext']

if av['--title'] != None:
    title = av['--title']

Qdebug = av['--debug']
if Qdebug:
    print(av)

if av['-s']:
    Qshow = False

if av['--ycoord']:
    ycoord = float(av['--ycoord'])
else:
    ycoord = None

xmin = xmax = None
if av['--xrange'] != None:
    cw = av['--xrange'].split(',')
    xmin = float(cw[0])
    xmax = float(cw[1])

ymin = ymax = None
if av['--yrange'] != None:
    cw = av['--yrange'].split(',')
    ymin = float(cw[0])
    ymax = float(cw[1])

xlab = av['--xlab']
ylab = av['--ylab']


import matplotlib
if Qshow:
    matplotlib.use('qt5agg')
else:
    # if the next statement was not used on unity, occasionally it would fine Qt5Agg, and thus fail
    # this else clause is NOT used in rsr_tsys.py, which has the same patters as this routine, and
    # never failed making a Tsys plot, go figure unity!
    matplotlib.use('agg')
import matplotlib.pyplot as plt
print('mpl backend spectra',matplotlib.get_backend())
    

plt.figure(figsize=(size,size), dpi=dpi)
if xmin != None:
    plt.xlim(xmin,xmax)
if ymin != None:
    plt.xlim(ymin,ymax)

if av['-g']:
    ext = 'svg'

spectra = [av['TABLE1']]
spectra = spectra + av['TABLE2']
nfiles = len(spectra)
data = list(range(nfiles))

for i in range(nfiles):
    f = spectra[i]
    data[i] = np.loadtxt(f).T
    plt.step(data[i][0]*xscale, data[i][1]*yscale, label=f, where='mid')

if ycoord != None:
    print("ycoord",ycoord)
    plt.plot([xmin,xmax],[ycoord,ycoord],'--')

plt.xlabel(xlab)
plt.ylabel(ylab)
plt.title(title)
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)


