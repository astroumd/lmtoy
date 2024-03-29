#! /usr/bin/env python
#
#    plot one or more RSR spectra, optionally a band or piece of the spectrum
#

_version = "7-mar-2024"

_help = """Usage: tab_plot.py [options] TABLE1 [TABLE2...]

Options:
  -y PLOTFILE             Save plotfile instead of default interactive. Optional.
  -t --title TITLE        Title of plot. Optional.
  --xscale XSCALE         Scale factor to apply to X axis [Default: 1.0]
  --yscale YSCALE         Scale factor to apply to Y axis [Default: 1.0]
  --xlab XLAB             X-axis label [Default: X]
  --ylab YLAB             Y-axis label [Default: Y]
  --xrange XMIN,XMAX      Min and Max of X-coordinate. Optional.
  --yrange YMIN,YMAX      Min and Max of Y-coordinate. Optional.
  --irange IMIN,IMAX      Min and Max of X-coordinates on top axis (twiny). Optional.
  --size SIZE             Plotsize in inches. [Default: 8.0]
  --dpi DPI               DPI of plot. [Default: 100]
  --ycoord YCOORD         Dashed line at YCOORD. Optional.
  --boxes LL,UR           4-Tuples of lower-left upper-right boxes. Optional
  -h --help               This help
  -d --debug              More debugging output
  -v --version            The script version

One or more ASCII tables are needed, with columns 1 and 2 designating the
X and Y coordinates.


"""

import sys
import numpy as np
from docopt import docopt


# base   = 'tab_plot' 
title  = 'tab_plot'         # --title


av = docopt(_help,options_first=True, version='tab_plot.py %s' % _version)

if av['--debug']:
    print(av)

xscale = float(av['--xscale'])
yscale = float(av['--yscale'])
size = float(av['--size']) 
dpi = float(av['--dpi'])
boxes = av['--boxes']
if boxes != None:
    b = [float(f) for f in boxes.split(',')]
    if len(b)%4 != 0:
        print("Warning: boxes=%s needs to have multiple of 4 numbers" % boxes)
    boxes = b


if av['--title'] != None:
    title = av['--title']

Qdebug = av['--debug']
if Qdebug:
    print(av)

plotfile = av['-y']

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

imin = imax = None
if av['--irange'] != None:
    cw = av['--irange'].split(',')
    imin = float(cw[0])
    imax = float(cw[1])

xlab = av['--xlab']
ylab = av['--ylab']


import matplotlib
if plotfile == None:
    matplotlib.use('qt5agg')
else:
    # if the next statement was not used on unity, occasionally it would fine Qt5Agg, and thus fail
    # this else clause is NOT used in rsr_tsys.py, which has the same patters as this routine, and
    # never failed making a Tsys plot, go figure unity!
    matplotlib.use('agg')
import matplotlib.pyplot as plt
print('mpl backend spectra',matplotlib.get_backend())
    

fig=plt.figure(99,figsize=(size,size), dpi=dpi)
fig.clf()
fig,ax1 = plt.subplots(num=99)
if imin != None:
    ax2 = ax1.twiny()
    ax2.set_xlim(imin,imax)
    ax2.set_xlabel('Channel Number')    
    nchan = 512
    chan_ticks = np.arange(0,imax+nchan,nchan)   # maybe make it depend on 800MHz, 400MHz, 200 MHz   512/800*BW
    print("CHAN_TICKS:",chan_ticks)
    ax2.set_xticks(chan_ticks)
if xmin != None:
    ax1.set_xlim(xmin,xmax)
if ymin != None:
    ax1.set_ylim(ymin,ymax)

spectra = [av['TABLE1']]
spectra = spectra + av['TABLE2']
nfiles = len(spectra)
data = list(range(nfiles))

for i in range(nfiles):
    f = spectra[i]
    data[i] = np.loadtxt(f).T
    ax1.step(data[i][0]*xscale, data[i][1]*yscale, label=f, where='mid')

if ycoord != None:
    print("ycoord",ycoord)
    ax1.plot([xmin,xmax],[ycoord,ycoord],'--')

if boxes != None:
    print(boxes)
    xb=np.zeros(5)
    yb=np.zeros(5)    
    for i in range(len(boxes)//4):
        i0=i*4
        xb[0] = boxes[i0+0]; yb[0] = boxes[i0+1]
        xb[1] = boxes[i0+2]; yb[1] = boxes[i0+1]
        xb[2] = boxes[i0+2]; yb[2] = boxes[i0+3]
        xb[3] = boxes[i0+0]; yb[3] = boxes[i0+3]
        xb[4] = boxes[i0+0]; yb[4] = boxes[i0+1]
        ax1.plot(xb,yb, color='black')
        print('BOX',i,xb,yb)
        


ax1.set_xlabel(xlab)
ax1.set_ylabel(ylab)
plt.title(title)
plt.legend()
if plotfile == None:
    plt.show()
else:
    plt.savefig(plotfile)
    print("%s writtten" % plotfile)


