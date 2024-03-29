#! /usr/bin/env python
#
#  Convert an ascii spectrum to a  FITS HDU spectrum
#
#   tab2spfits.py J17293-CO10.tab
#

_version = "30-jan-2023"

_help = """Usage: sp2sdfits [options] TABLE_FILE

-r --restfreq RF    Give a (new) RESTFREQ in GHz.  Optional.
-h --help           Give this help.
-d --debug          Add more debugging info.
-v --version        Report version.

tab2spfits.py converts an ascii table to a simple 1D HDU spectrum fits file

A restfreq 115.2712018 is common for RSR, but RSR by default does not keep it.

""" 

import os
import sys

from astropy.io import fits
from astropy.table import Table
from astropy.wcs import WCS
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")
from docopt import docopt


def help(cmd):
    print("no help here")
    sys.exit(0)

def dms2deg(dms):
    """ convert a string d:m:s to degrees
    """
    sign = 1
    if dms[0] == '-':
        sign = -1
        dms = dms[1:]
    if dms[0] == '+':
        dms = dms[1:]
    w = dms.split(':')
    deg = float(w[0])
    if len(w) > 1:
        deg = deg + float(w[1])/60.0
        if len(w) > 2:
            deg = deg + float(w[2])/3600.0
    return sign*deg
            
        
        
if __name__ == "__main__":
    av = docopt(_help, options_first=True, version='sp2sdfits. %s' % _version)
    tab = av['TABLE_FILE']
    Qdebug = av['--debug']
    if av['--restfreq']:
        restfreq = float(av['--restfreq']) * 1e9       # assumed in GHz   e.g. 115.2712018
    else:
        restfreq = None

    if not os.path.exists(tab):
        print("Table %s does not exist" % tab)
        help(sys.argv[0])

    # first grab the 2 columns, and create the WCS for the 1st axis
    tabdata = np.loadtxt(tab).T
    freq = tabdata[0]
    data = tabdata[1]
    scale = 1e9          # assumed freq axis is in GHz
    naxis1 = len(freq)
    crpix1 = naxis1//2
    crval1 = freq[naxis1//2]*scale
    cdelt1 = (freq[1] - freq[0])*scale

    wcs = WCS(naxis=1)
    wcs.wcs.ctype = ['FREQ']
    wcs.wcs.crpix = [crpix1]
    wcs.wcs.crval = [crval1]
    wcs.wcs.cdelt = [cdelt1]
    print(wcs)

    # create a HDU for fits file
    spname = tab + '.fits'
    hdu = fits.PrimaryHDU()
    hdu.data = data
    hdu.scale('float32')
    hdu.header['TELESCOP'] = 'LMT'
    hdu.header['CRPIX1'] = crpix1
    hdu.header['CRVAL1'] = crval1
    hdu.header['CDELT1'] = cdelt1
    hdu.header['CUNIT1'] = 'Hz'    
    hdu.header['ORIGIN'] = 'LMTOY'
    if restfreq != None:
        hdu.header['RESTFREQ'] = restfreq
    else:
        hdu.header['RESTFREQ'] = crval1
    hdu.header['BUNIT'] = 'K'

    # reading header 
    #     *.driver.sum.txt has a header
    #     *.blanking.sum.txt has no header
    fp = open(tab)
    lines = fp.readlines()
    for line in lines:
        line.strip()
        if line[0] == '#':
            if Qdebug:
                print("header: %s" % line)
            w = line.split()
            if len(w) < 3:
                continue
            if w[1] == 'Source:':
                hdu.header['OBJECT'] = w[2]
                hdu.header['EQUINOX'] = 2000
                continue
            if w[2] == 'RA:':
                hdu.header['RA-DMS'] = w[3]                
                hdu.header['CRVAL2'] = dms2deg(w[3])*15.0
                hdu.header['CRPIX2'] = 0.0
                hdu.header['CTYPE2'] = 'RA---GLS'
                continue
            if w[2] == 'DEC:':
                hdu.header['DEC-DMS'] = w[3]
                hdu.header['CRVAL3'] = dms2deg(w[3])
                hdu.header['CRPIX3'] = 0.0                
                hdu.header['CTYPE3'] = 'DEC--GLS'                
                continue
            if w[1] == 'Date' and w[3] == 'Reduction':
                hdu.header['DATE-OBS'] = w[4]
                continue
            if w[1] == 'Average' and w[2] == 'Opacity':     # TAU-ATM
                hdu.header['OPACITY'] = float(w[4])
                continue
            if w[1] == 'Integration' and w[2] == 'Time:':   # OBSTIME ?   (class uses it )
                hdu.header['INTTIME'] = float(w[3])
                continue

    
    # finalize writing
    hdu.writeto(spname, overwrite=True)
    print("Wrote %s"  % spname)

