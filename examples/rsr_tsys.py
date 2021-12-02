#! /usr/bin/env python


import sys
import matplotlib.pyplot as plt


from dreampy3.redshift.utils.fileutils import make_generic_filename
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
from dreampy3.redshift.plots import RedshiftPlot

Qshow = True
ext   = 'png'
base  = 'rsr.tsys'
n     = 0

for f in sys.argv[1:]:
    if f == '-s':
        Qshow = False
        continue
    if f == '-z':
        ext = 'svg'
        continue
    n = n + 1
    obsnum = int(f)

if n==0:
    sys.exit(0)
    
plt.figure()
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']

for chassis in range(4):
    nc = RedshiftNetCDFFile(make_generic_filename(obsnum,chassis))
    # nc.hdu.process_scan() 
    nc.hdu.get_cal()
    for board in range(6):
        freqs = nc.hdu.frequencies[board, :]
        tsys = nc.hdu.cal.Tsys[board, :]
        ch = nc.hdu.header.ChassisNumber
        if board == 0:
            plt.step(freqs,tsys,c=colors[chassis], where='mid', label="chassis %d" % chassis)
        else:
            plt.step(freqs,tsys,c=colors[chassis], where='mid')
    nc.close()

plt.xlim([72,112])
plt.ylim([40,310])
plt.title("obsnum=%d" % obsnum)
plt.xlabel("Frequency (GHz)")
plt.ylabel("Tsys (K)")
plt.legend()
if Qshow:
    plt.show()
else:
    pout = "%s.%s" % (base,ext)
    plt.savefig(pout)
    print("%s writtten" % pout)
