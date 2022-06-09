#! /usr/bin/env python
#
#    inspect the chassis and band based Tsys (or with -t the Spectrum)
#
#    Usage:
#    rsr_tsys.py [-s] [-z] [-t] obsnum
#
#    -s     don't show, just create the png
#    -z     use "svg" extension
#    -f     show spectrum instead of tsys

import sys
import numpy as np
import matplotlib.pyplot as plt


from dreampy3.redshift.utils.fileutils import make_generic_filename
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
from dreampy3.redshift.plots import RedshiftPlot

Qshow = True
Qspec = False
ext   = 'png'
n     = 0
rms_min = 25.0

for f in sys.argv[1:]:
    if f == '-s':
        Qshow = False
        continue
    if f == '-z':
        ext = 'svg'
        continue
    if f == '-t':
        Qspec = True
        continue
    n = n + 1
    obsnum = int(f)

if n==0:
    sys.exit(0)

if Qspec:
    base  = 'rsr.spectrum'
else:
    base  = 'rsr.tsys'
    
    
plt.figure()
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
label = "badcb="

for chassis in range(4):
    try:
        nc = RedshiftNetCDFFile(make_generic_filename(obsnum,chassis))
    except:
        continue
    if Qspec:
        nc.hdu.process_scan()
    else:
        nc.hdu.get_cal()
    for board in range(6):
        freqs = nc.hdu.frequencies[board, :]
        if Qspec:
            y = 1000*np.mean(nc.hdu.spectrum[:,board,:], axis=0)
        else:
            y = nc.hdu.cal.Tsys[board, :]
            dy = y[1:] - y[:-1]
            rms = dy.std()
            if rms > rms_min:
                print("#BADCB",obsnum,chassis,board,rms,'Tsys');
                label = label + "%d/%d," % (chassis,board)
        ch = nc.hdu.header.ChassisNumber
        if board == 0:
            plt.step(freqs,y,c=colors[chassis], where='mid', label="chassis %d" % chassis)
        else:
            plt.step(freqs,y,c=colors[chassis], where='mid')
    nc.close()

plt.xlim([72,112])
plt.title("obsnum=%d %s" % (obsnum,label))
plt.xlabel("Frequency (GHz)")
if Qspec:
    plt.ylabel("Spectrum (mK)")
    plt.ylim([-10,100])
else:
    plt.ylabel("Tsys (K)")
    plt.ylim([40,310])
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)
