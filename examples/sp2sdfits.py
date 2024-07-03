#! /usr/bin/env python
#
#  Convert a FITS HDU spectrum to an SDFITS file, mostly for dysh
#  SDFITS should match GBTIDL's "keep" format?
#
#  tested with J17293-CO10.fits (a CLASS spectrum; not to be confused with their MATRIX sdfits dialect)
#
#   sp2sdfits.py J17293-CO10.fits
#
#   from dysh.fits.sdfitsload import SDFITSLoad
#   a = SDFITSLoad('J17293-CO10.sdfits')
#   sp=a.getspec(0)
#   sp.plot()
#
#   r=a.rawspectrum(0,0)
#   import matplotlib.pyplot as plt
#   plt.plot(r)
#   plt.show()
#

_version = "2-jul-2024"

_help = """Usage: sp2sdfits [options] INPUT

--class             Assuming CLASS format. Tested.
--ascii             Try an ASCII format. Not implemented.
--rsr               RSR driver format (GHz, K). Not tested yet.
-h --help           Give this help
-d --debug          Add more debugging info
-v --version        Report version

sp2sdfits.py converts a selection of 1D spectrum format to an SDFITS file
for dysh

Tested examples are from:
    --class     Grenoble CLASS
    --rsr       RSR ascii spectrum (needs extension .txt)
""" 



import os
import sys

from astropy.io import fits
from astropy.table import Table
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")
from docopt import docopt

_debug = False

def help(cmd):
    print("no help here")
    sys.exit(0)

def cols_append(h, key, fmt, cols):
    if key in h:
        if _debug:
            print("Copying %s = %s" % (key,h[key]))
        cols.append(fits.Column(name=key, format=fmt, array=[h[key]]))
    else:
        print("Warning: skipping missing column %s for table" % key)

        
        
if __name__ == "__main__":
    av = docopt(_help, options_first=True, version='sp2sdfits. %s' % _version)
    ff = av['INPUT']      # fits or table
    _debug = av['--debug']

    if not os.path.exists(ff):
        print("File %s does not exist" % ff)
        help(sys.argv[0])

    if ff.find('.fits') > 0:
        print("fits",ff)
        dname = ff.replace('.fits','.sdfits')
        mode = 0   # fits

        hdu = fits.open(ff)
        h = hdu[0].header
        data   = hdu[0].data
        print('Input data shape:   ',data.shape)
        d = data
        nchan = len(data.squeeze())
        d = d.reshape(1,nchan)
        print('Number of channels: ',nchan)
        if _debug:
            print(d.shape)
        
    elif ff.find('.txt') > 0:
        print("txt",ff)        
        dname = ff.replace('.txt', '.sdfits')
        mode = 1   # rsr txt spectrum only for now.

        if True:
            print("WARNING: you need a template for now")
            # steal for now
            hdu = fits.open('J17293-CO10.fits')
            h = hdu[0].header
            print(h)

        # manually reading table, since we need the header elements
        data = np.loadtxt(ff).T
        if _debug:
            print(data.shape)        
        freqs = data[0]
        temps = data[1]
        nchan = len(freqs)
        print("Number of RSR channels: ", nchan)
        d = temps.reshape(1,nchan)
        if _debug:
            print(d.shape)
    else:
        print("unknown mode");
        help(sys.argv[0])

    ifnum = 1  # 0 ?
    plnum = 1  # 0 ?
    fdnum = 1  # 0 ?

    cols = []

    # hacks for CLASS  ?
    if mode == 0:
        rf = h['RESTFREQ']
        cols.append(fits.Column(name='RESTFREQ', format='D', array=[rf]))
        cols.append(fits.Column(name='VELDEF', format='8A' , array=['OPTI-HEL']))
        # unsure what these fools are doing here, but CRVAL1 = 0 and it/s called an offset.
        dfreq  = float(h['IMAGFREQ'])
        if _debug:
            print("Finding         crval1=%g" % h['CRVAL1'])        
        crval1 = float(h['CRVAL1'])
        h['CRVAL1'] = crval1 + dfreq
        if _debug:
            print("Trying to patch crval1=%g" % h['CRVAL1'])
        # patch missing elements
        h['VELOCITY'] = 0.0   # vlsr really
        h['RADECSYS'] = 'FK5'
        h['RADESYS'] = 'FK5'      # is that a dysh typo
        h['EQUINOX'] = 2000
        # WCS issue 
        h['CDELT2'] = 1.0        
        h['CDELT3'] = 1.0        
        
    
    cols.append(fits.Column(name='IFNUM',  format='I' , array=[ifnum]))
    cols.append(fits.Column(name='PLNUM',  format='I' , array=[plnum]))
    cols.append(fits.Column(name='FDNUM',  format='I' , array=[fdnum]))
    for i in [1,2,3,4]:
        for key in ['CTYPE']:    # ? 'CUNIT' ?
            cols_append(h, "%s%d" % (key,i), '8A', cols)
        for key in ['CRVAL', 'CDELT', 'CRPIX']:
            cols_append(h, "%s%d" % (key,i), 'D', cols)


    cols.append(fits.Column(name='DATA',   format='%dE' % nchan , array=d, dim='(%d)' % nchan, unit=h['BUNIT']))
    idata = len(cols)
    if _debug:
        print("DATA at column",idata)


    for key in ['ELEVATIO', 'AZIMUTH', 'EQUINOX', 'VELOCITY']:
        cols_append(h, "%s" % key, 'D', cols)

    for key in ['OBJECT', 'RADESYS', 'DATE-OBS']:
        klen = len(h[key])
        cols_append(h, "%s" % key, '%dA' % klen, cols)    # @todo   will this cut off long object names?

    coldefs = fits.ColDefs(cols)
    hdu2 = fits.BinTableHDU.from_columns(coldefs)
    hdu2.header['EXTNAME']  = 'SINGLE DISH'
    for key in ['TELESCOP', 'OBJECT', 'DATE', 'DATE-OBS', 'ORIGIN', 'BUNIT']:
        if key in h:
            hdu2.header[key] = h[key]
            if _debug:
                print("Setting %s = %s" % (key,h[key]))
        else:
            print("Warning: %s not present in input header, skipped" % key)

    print("Writing",dname)
    hdu2.writeto(dname, overwrite=True)
