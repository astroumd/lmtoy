#! /usr/bin/env python
#
#    inspect and plot the chassis and band (C/B) based Tsys (or with -t the Spectrum)

"""Usage: rsr_tsys.py [options] OBSNUM

Options:
  -s                      Don't show interactive plot, save plotfile instead.
  -b --badlags BADLAGS    Use this badlags file. Optional.
  -t                      Show spectrum instead of tsys
  -r --rms RMS            Use this RMS (in K) for Tsys jitter to determine a BADCB [Default: 25.0]
  -h --help               This help
  --version               The script version

The saved plotfile has a fixed name, rsr.spectra.png (or rsr.spectra.svg)

"""
_version = "2-feb-2023"


import sys
import numpy as np
from docopt import docopt
import matplotlib.pyplot as plt

from dreampy3.redshift.utils.fileutils import make_generic_filename
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
from dreampy3.redshift.plots import RedshiftPlot


#                    command line options
Qshow    = True
Qspec    = False
ext      = 'png'
#                    trigger "badcb" on the RMS in the adjacent-channel differences ("jitter")



av = docopt(__doc__,options_first=True, version='rsr_spectra.py %s' % _version)
print(av)


if av['-s']:
    Qshow = False
if av['-t']:
    Qspec = True
badlags = av['--badlags']
rms_min  = float(av['--rms'])
obsnum = int(av['OBSNUM'])


if Qspec:
    base  = 'rsr.spectrum'
else:
    base  = 'rsr.tsys'


if badlags != None:
    import dreampy3
    dreampy3.badlags(badlags)
  
plt.figure()
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
label = "jitter badcb="

for chassis in range(4):    # loop over all chassis 0..3
    try:
        nc = RedshiftNetCDFFile(make_generic_filename(obsnum,chassis))
    except:
        continue
    if Qspec:
        nc.hdu.process_scan()     # spectrum
    else:
        nc.hdu.get_cal()          # tsys
    for board in range(6):  # loop over all boards 0..5
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
            else:
                print("#OKCB",obsnum,chassis,board,rms,'Tsys');                
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