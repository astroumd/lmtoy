#! /usr/bin/env python
#
#  Convert a FITS HDU spectrum to an SDFITS file, mostly for dysh
#  SDFITS should match GBTIDL's "keep" format?
#
#  Some refs:
#  Garwood (2000) - The definition of the sdfits format
#    https://ui.adsabs.harvard.edu/abs/2000ASPC..216..243G/abstract
#
#   See also:
#    https://fits.gsfc.nasa.gov/registry/sdfits.html
#    https://safe.nrao.edu/wiki/bin/view/Main/SdfitsDetails
#    https://casa.nrao.edu/aips2_docs/notes/236/node14.html



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

_version = "3-jul-2024"

_help = """Usage: sp2sdfits [options] INPUT

--class             Assuming CLASS format. Tested.
--ascii             Try an ASCII format. Not implemented.
--rsr               RSR driver format (GHz, K, RMS). 
-h --help           Give this help
-d --debug          Add more debugging info
-v --version        Report version

sp2sdfits.py converts a selection of 1D spectrum format to an
SDFITS file for dysh. The output file replaces the extension
of the input file with "sdfits". It will overwrite any existing
file with that name.

Tested examples are from:

    --class     Grenoble CLASS (assumed from .fits extension)
    --rsr       RSR ascii spectrum (assumed from .txt extension)

Example of use:

   $ sp2sdfits.py J17293-CO10.fits

   dysh> from dysh.fits.sdfitsload import SDFITSLoad
         a = SDFITSLoad('J17293-CO10.sdfits')
         sp=a.getspec(0)
         sp.plot() 
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
        dname = ff.replace('.txt', '.fits')
        mode = 1   # rsr txt spectrum only

        # reading data portion of the table, masking out the nan's
        data = np.loadtxt(ff).T
        if _debug:
            print(data.shape)
        sigma = data[2]
        freqs = data[0][~np.isnan(sigma)] * 1e9     # input was GHz, need Hz
        temps = data[1][~np.isnan(sigma)]
        nchan = len(freqs)
        print("Number of RSR channels with no nan values: ", nchan)
        d = temps.reshape(1,nchan)
        if _debug:
            print(d.shape)
        crpix1 = nchan//2
        crval1 = freqs[nchan//2]
        cdelt1 = freqs[1] - freqs[0]
        #
        h = {}
        h['TELESCOP'] = 'LMT'
        h['INSTRUME'] = 'RSR'
        h['CRPIX1'] = crpix1
        h['CRVAL1'] = crval1
        h['CDELT1'] = cdelt1
        h['CUNIT1'] = 'Hz'
        h['CTYPE1'] = 'FREQ'
        h['ORIGIN'] = 'LMTOY sp2sdfits.py %s' % _version
        h['BUNIT'] = 'K'

        # reading header portion of the table to fill more of the header
        lines = open(ff).readlines()
        for line in lines:
            line.strip()
            if line[0] != '#': continue
            w = line.split()
            if len(w) < 3: continue
            if w[1] == 'Source:':
                h['OBJECT'] = w[2]
                h['EQUINOX'] = 2000
                continue
            if w[2] == 'RA:':
                h['RA-DMS'] = w[3]                
                h['CRVAL2'] = dms2deg(w[3])*15.0
                h['CRPIX2'] = 0.0
                h['CTYPE2'] = 'RA---GLS'
                continue
            if w[2] == 'DEC:':
                h['DEC-DMS'] = w[3]
                h['CRVAL3'] = dms2deg(w[3])
                h['CRPIX3'] = 0.0                
                h['CTYPE3'] = 'DEC--GLS'                
                continue
            if w[1] == 'Date' and w[3] == 'Observation:':
                h['DATE-OBS'] = w[4]
                continue
            if w[1] == 'Date' and w[3] == 'Reduction:':
                h['DATE'] = w[4]
                continue
            if w[1] == 'Average' and w[2] == 'Opacity':     # TAU-ATM
                h['OPACITY'] = float(w[4])
                continue
            if w[1] == 'Integration' and w[2] == 'Time:':   # OBSTIME ?   (class uses it )
                h['INTTIME'] = float(w[3])
                continue
        # done reading all header elements
        
    else:
        print("unknown mode");
        help(sys.argv[0])

    ifnum = 0
    plnum = 0
    fdnum = 0

    cols = []

    if mode == 0:
        # hacks for CLASS  ?
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
    elif mode == 1:
        # hacks for RSR        
        rf = 115.2712018e9   # nominal CO(1-0) for restfreq
        cols.append(fits.Column(name='RESTFREQ', format='D', array=[rf]))
        cols.append(fits.Column(name='VELDEF', format='8A' , array=['OPTI-HEL']))    # @todo
        h['VELOCITY'] = 0.0       # vlsr really
        h['RADECSYS'] = 'FK5'
        h['RADESYS']  = 'FK5'     # GBT seems to use RADESYS and RADECSYS
        h['EQUINOX'] = 2000
        # WCS issue 
        h['CDELT2'] = 1.0        
        h['CDELT3'] = 1.0

    if _debug:
        print("HEADER:::",h)

    # extra variables to keep GBTFITSLoad() happy
    # OBSMODE
    h['OBSMODE'] = "None"
        
    
    cols.append(fits.Column(name='IFNUM',  format='I' , array=[ifnum]))
    cols.append(fits.Column(name='PLNUM',  format='I' , array=[plnum]))
    cols.append(fits.Column(name='FDNUM',  format='I' , array=[fdnum]))
    for i in [1,2,3,4]:
        for key in ['CTYPE']:    # ? 'CUNIT' ?
            cols_append(h, "%s%d" % (key,i), '8A', cols)
        for key in ['CRVAL', 'CDELT', 'CRPIX']:
            cols_append(h, "%s%d" % (key,i), 'D', cols)

    # @todo   unit= writes a TUNITxx=, but SDFiTSLoad isn't looking at it
    cols.append(fits.Column(name='DATA',   format='%dE' % nchan , array=d, dim='(%d)' % nchan, unit=h['BUNIT']))
    idata = len(cols)
    if _debug:
        print("DATA at column",idata)


    for key in ['ELEVATIO', 'AZIMUTH', 'EQUINOX', 'VELOCITY']:
        cols_append(h, "%s" % key, 'D', cols)

    for key in ['OBJECT', 'RADESYS', 'DATE-OBS']:    #  'OBSMODE']:
        klen = len(h[key])
        cols_append(h, "%s" % key, '%dA' % klen, cols)



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
