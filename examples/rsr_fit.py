#! /usr/bin/env python
#
#    plot spectrum in frequency or km/s, allow some fitting as well
#

"""Usage: rsr_fit.py [options] SPECTRUM

Options:
   -i                       No interactive mode, just save the plot in rsr_fit.png. Optional
   -x --xrange XMIN,XMAX    Plotting range, defaults to the full range. Optional
   -r --ref REF             Reference frequency, in given units, to convert to km/s. Optional
   -o --order ORDER         Baseline order. [Default: 0]
   -b --base X0,X1,X2,X3    Sections of spectrum to use for baseline fitten. Optional
   -s --smooth SMOOTH       Smoothing kernel. [Default: 0]
   -d --debug               More debug output. 
   --scale SCALE            Scale factor for intensity. [Default: 1.0]
   --sub                    Show subtracted instead of original data
   --wave                   Assume input spectrum is in wavelength units. Not implemented.
   --fit                    Attempt a fit between X1 and X2
   --nemo                   Pass to NEMO's tabnllsqfit to fit a gauss between X1 and X2
   -h --help                This help
   --version                Version of script

Plot a spectrum, and assign one or more segments if a polynomial
baseline needs to be fitted and subtracted .  Usually two segments are
given on either side of a line.

If a reference value is given, the spectrum is assumed to be in frequency, and is converted
to km/s.  In that case the --xrange and -base need to be given in units of km/s, otherwise
in whatever units the spectrum is (MHz, GHz, etc.). No support for wavelength yet, the
placeholder --wave flag should do this in some future version.

Currently --nemo will activate a fit using NEMO's tabnllsqfit, but the baseline has not been
subtracted for this.
"""

_version = "10-feb-2023"

import os
import sys
import subprocess
import numpy as np
from docopt import docopt
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

c = 299792.458       # km/s - speed of light
save_plot = 'rsr_fit.png'


# -- fancy command line parsing

av = docopt(__doc__,options_first=True, version='rsr_fit.py %s' % _version)

Qdebug  = av['--debug']
if Qdebug:
    print(av)
tab = av['SPECTRUM']
Qsaveplot = av['-i']
Qnemo = av['--nemo']
Qsub = av['--sub']
do_smooth = int(av['--smooth'])
p_order = int(av['--order'])
yscale = float(av['--scale'])
ref = av['--ref']
if ref != None:
    ref = float(ref)
else:
    ref = -1.0

xrange = av['--xrange']
if xrange != None:
    xrange = [float(i) for i in xrange.split(',')]
else:
    xrange = []
bl=[]
base = av['--base']
if base != None:
    baselines = [float(i) for i in base.split(',')]
    nbl = len(baselines)
    if nbl%2 != 0:
        print("Need even number of baseline sections")
        sys.exit(0)
    nbl = nbl//2
    for i in range(nbl):
        vmin = baselines[2*i]
        vmax = baselines[2*i+1]
        if True:
            bl.append((vmin,vmax))
        else:
            vmin = (1-vmin/ref)*c
            vmax = (1-vmax/ref)*c
            bl.append((vmax,vmin))
    print("BASELINE sections: ",bl)
else:
    nbl = 0


# --- a few useful helper functions ---------------------------------------------------------------------------

keywords = {}    

def get_key(key, tab=None, verbose=False):
    """  get a keyword from the tabular spectrum.
         This needs to be initialized the first call by setting tab=
    """
    if len(keywords) == 0:
        if tab == None:
            print("Cannot setup keys without given the tab= name")
            sys.exit(0)
        lines = open(tab).readlines()
        for line in lines:
            if line[0] == '#':
                words = line[1:].split('=')
                if len(words)>1:
                    key = words[0].strip()
                    val = words[1].strip()
                    if key in keywords:
                        keywords[key].append(val)
                    else:
                        keywords[key] = [val]
        if verbose:
            print(keywords)
    if key in keywords:
        return keywords[key]
    return None

def fit_poly(x, y, p_order=1, bl = []):
    """ from array X between Xmin and Xmax fit a polynomial
        returns fitted_poly,xvals,residual
    """

    if len(bl) == 0:
        p = np.poly1d(np.polyfit(x,y,p_order))
        t = x
        r = y - p(x)
    else:
        first = True
        for b in bl:
            # print('B',b)
            if first:
                m = ((x>b[0]) & (x<b[1]))
                first = False
            else:
                m = m | ((x>b[0]) & (x<b[1]))
                
        p = np.poly1d(np.polyfit(x[m],y[m],p_order))
        t = x[m]
        r = y[m] - p(x[m])
    return (p,t,r)

def diff_rms(y):
    """ take the differences between neighboring channel
    and compute their rms. this should be sqrt(2)*sigma
    if there is no  trend in the input signal, and if
    the input signal is not correlated (e.g. hanning)
    """
    return (y[1:]-y[:-1]).std() / 1.414

def my_smooth(y, box_pts):
    box = np.ones(box_pts)/box_pts
    y_smooth = np.convolve(y, box, mode='same')
    return y_smooth

def add_spectrum(filename):
    (v,t) = np.loadtxt(filename).T
    plt.plot(v,t,label=filename)

# --- start of code --------------------------------------------------------------------

data = np.loadtxt(tab).T
v2 = data[0]
zz = data[1] * yscale

if ref > 0:
    v2 = (1-v2/ref)*c

#get_key("FILENAME",tab)
#print("DATE_OBS:  ",get_key("DATE_OBS"))
#print("OBSERVER:  ",get_key("OBSERVER"))
#print("TSYS:      ",get_key("TSYS"))

if do_smooth > 0:
    zz = my_smooth(zz,do_smooth)

if p_order >= 0:
    (p2,t2,r2) = fit_poly(v2,zz,p_order,bl)

if Qnemo:
    # note that this has not subtracted the baseline fit !!
    cmd = "tabnllsqfit %s fit=gauss1d xrange=%g:%g" % (tab,bl[0][1],bl[1][0])
    print("NEMO: ",cmd)
    os.system(cmd)

plt.figure()

plt.plot(v2,zz)
if p_order >= 0:
    rms2 = r2.std()
    rms3 = diff_rms(r2)
    # plt.plot(t2, p2(t2), '-', label='POLY %d' % p_order)
    dd = zz - p2(v2)
    if not Qsub:
        plt.plot(v2, p2(v2), '-', label='POLY %d SMTH %d' % (p_order,do_smooth))
    plt.plot(t2, r2, '-', label='RMS %.3g dRMS %.3g' % (rms2, rms3))
    plt.plot([v2[0],v2[-1]], [0.0, 0.0], c='black', linewidth=2, label='baseline')
    if Qsub:
        plt.plot(v2, dd, '-', label='Subtracted Spectrum')
if len(xrange) > 0:
    plt.xlim(xrange)
plt.ylabel('Y')
plt.xlabel('X')
plt.title(tab)
plt.legend()
if Qsaveplot:
    plt.savefig(save_plot)
    print("%s written" % save_plot)
else:
    plt.show()
