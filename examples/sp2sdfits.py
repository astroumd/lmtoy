#! /usr/bin/env python
#
#  Convert a FITS HDU spectrum to an SDFITS file, mostly for dysh
#
#  tested with J17293-CO10.fits
#
#   ./sp2sdfits.py J17293-CO10.fits
#
#   from dysh.fits.sdfitsload import SDFITSLoad
#   a = SDFITSLoad('J17293-CO10.sdfits')
#   sp=a.getspec(0)
#   sp.plot()              <== not working yet, no freq axis
#   r=a.rawspectrum(0,0)
#   import matplotlib.pyplot as plt
#   plt.plot(r)
#   plt.show()
#

_version = "13-oct-2023"

_help = """Usage: sp2sdfits [options] FITS_FILE

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
    --rsr       
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


def help(cmd):
    print("no help here")
    sys.exit(0)

def cols_append(fits, h, key, fmt, cols, verbose=False):
    if key in h:
        if verbose:
            print("Copying %s = %s" % (key,h[key]))
        cols.append(fits.Column(name=key, format=fmt, array=[h[key]]))
    else:
        print("Warning: skipping missing column %s for table" % key)

        
        
if __name__ == "__main__":
    av = docopt(_help, options_first=True, version='sp2sdfits. %s' % _version)
    ff = av['FITS_FILE']

    if not os.path.exists(ff):
        print("File %s does not exist" % ff)
        help(sys.argv[0])        
    if ff.find('.fits') < 0:
        print("Can only handle .fits files:",ff)
        help(sys.argv[0])        

    dname = ff.replace('.fits','.sdfits')

    hdu = fits.open(ff)
    h = hdu[0].header
    data   = hdu[0].data
    print('Input data shape:   ',data.shape)
    d = data
    nchan = len(data.squeeze())
    d.reshape(1,nchan)
    print('Number of channels: ',nchan)

    

    ifnum = 1
    plnum = 1
    fdnum = 1
    
    cols = []
    cols.append(fits.Column(name='IFNUM',  format='I' , array=[ifnum]))
    cols.append(fits.Column(name='PLNUM',  format='I' , array=[plnum]))
    cols.append(fits.Column(name='FDNUM',  format='I' , array=[fdnum]))
    for i in [1,2,3,4]:
        for key in ['CTYPE']:    # ? 'CUNIT' ?
            cols_append(fits, h, "%s%d" % (key,i), '8A', cols, True)
        for key in ['CRVAL', 'CDELT', 'CRPIX']:
            cols_append(fits, h, "%s%d" % (key,i), 'D', cols)

    # hacks for CLASS  ?
    if True:
        rf = h['RESTFREQ']
        cols.append(fits.Column(name='RESTFREQ', format='D', array=[rf]))
        cols.append(fits.Column(name='VELDEF', format='A' , array=['OPTI-HEL']))
        
    cols.append(fits.Column(name='DATA',   format='%dE' % nchan , array=d, dim='(1,%d)' % nchan, unit=h['BUNIT']))
    idata = len(cols)
    print("DATA at column",idata)


    for key in ['ELEVATIO', 'AZIMUTH']:
        cols_append(fits, h, "%s" % key, 'D', cols)

    for key in ['OBJECT']:
        cols_append(fits, h, "%s" % key, 'A', cols)

    


# OBSMODE OnOff:        
    

    # which cols are required?
    # OBJECT, BANDWID, DATE-OBS, DURATION, EXPOSURE, TSYS
    #
    #UT      = ' 19:21:11.948'              /  Universal time at start
    #LST     = ' 14:00:19.050'              /  Sideral time at start
    # TUNIT from the DATA column in BUNIT from the FITS header....
    #TTYPE1  = 'OBJECT  '           /   TFORM1  = '32A     '           /
    #TTYPE2  = 'BANDWID '           /   TFORM2  = 'D       '           /
    #TTYPE3  = 'DATE-OBS'           /   TFORM3  = '22A     '           /
    #TTYPE4  = 'DURATION'           /   TFORM4  = 'D       '           /
    #TTYPE5  = 'EXPOSURE'           /   TFORM5  = 'D       '           /
    #TTYPE6  = 'TSYS    '           /   TFORM6  = 'D       '           /

    coldefs = fits.ColDefs(cols)
    hdu2 = fits.BinTableHDU.from_columns(coldefs)
    hdu2.header['EXTNAME']  = 'SINGLE DISH'
    for key in ['TELESCOP', 'OBJECT', 'DATE', 'DATE-OBS', 'ORIGIN', 'BUNIT']:
        if key in h:
            hdu2.header[key] = h[key]
        else:
            print("Warning: %s not present in input header, skipped" % key)

    print("Writing",dname)
    hdu2.writeto(dname, overwrite=True)
