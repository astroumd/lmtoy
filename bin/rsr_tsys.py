#! /usr/bin/env python
#
#    inspect and plot the chassis and band (C/B) based Tsys (or with -t the Spectrum)

"""Usage: rsr_tsys.py [options] OBSNUM

Options:
  -y PLOTFILE             Save plotfile instead of interactive. Optional
  -b --badlags BADLAGS    Use this badlags file. Optional.
  -t                      Show spectrum instead of tsys
  -r --rms RMS            Use this RMS (in K) for Tsys jitter to determine a BADCB [Default: 25.0]
  -h --help               This help
  --version               The script version

The saved plotfile has a fixed name, rsr.spectra.png (or rsr.spectra.svg)

"""
_version = "1-aug-2023"



import sys
import numpy as np
from docopt import docopt


from dreampy3.redshift.utils.fileutils import make_generic_filename
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.redshift.plots import RedshiftPlot


#                    command line options
Qspec    = False

#                    trigger "badcb" on the RMS in the adjacent-channel differences ("jitter")



av = docopt(__doc__,options_first=True, version='rsr_spectra.py %s' % _version)
print(av)


if av['-t']:
    Qspec = True

plotfile = av['-y']
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

import matplotlib
if plotfile == None:
    matplotlib.use('qt5agg')
import matplotlib.pyplot as plt
print('mpl backend tsys',matplotlib.get_backend())


plt.figure()
colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
label = ""

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
                if len(label) > 0:
                    label = label + ",%d/%d" % (chassis,board)
                else:
                    label =    "badcb=%d/%d" % (chassis,board)
            else:
                print("#OKCB",obsnum,chassis,board,rms,'Tsys');                
        ch = nc.hdu.header.ChassisNumber
        if board == 0:
            plt.step(freqs,y,c=colors[chassis], where='mid', label="chassis %d" % chassis)
        else:
            plt.step(freqs,y,c=colors[chassis], where='mid')
    nc.close()

print("obsnum=%d %s" % (obsnum,label))

plt.xlim([72,112])
plt.title("obsnum=%d jitter %s" % (obsnum,label))
plt.xlabel("Frequency (GHz)")
if Qspec:
    plt.ylabel("Spectrum (mK)")
    plt.ylim([-10,100])
else:
    plt.ylabel("Tsys (K)")
    plt.ylim([40,310])
plt.legend()
if plotfile == None:
    plt.show()
else:
    plt.savefig(plotfile)
    print("%s writtten" % plotfile)
