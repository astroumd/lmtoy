#! /usr/bin/env python
#
#  write sample SDFITS file
#  read SDFITS file and report some properties
#  
#

import sys
import numpy as np
import numpy.ma as ma

from astropy.io import fits
import copy
import time


def dimsize(dim=(2,3,4,5)):
    s = dim[0]
    for i in dim[1:]:
        s = s * i
    return s


class Spectra(object):
    def __init__(self,ndim):
        data = gen_data(ndim)
        wtps = get_data(ndim[:-1], 1.0)
        # for each dim we need a lookup array (or WSC descriptor) of that axis
        # for a WCS the value = (i-crpix)*cdelt + crval
        # for a lookup the index into will be C=crval[i]

    def pol_aver(self):
        #       data[ntime, nbeam, nband, npol, nchan]
        d1 = (self.data*self*wtps).sum(axis=axis_pol, keepdims=True)
        d0 = self.wtps.sum(axis=axis_pol, keepdims=True)
        self.data = d1/d0
    def time_aver(self):
        d1 = (self.data*self*wtps).sum(axis=axis_time, keepdims=True)
        d0 = self.wtps.sum(axis=axis_time, keepdims=True)
        self.data = d1/d0
    def band_merge(self, allow_gap=0):
        # check if the bands can be merged
        print("n/a")
        
        
                  
def gen_data(ndim=(256,1,1,1,256), value=None):
    """
    generate fake data so we can fill an SDFITS file from scratch

    data[ntime, nbeam, npol, nband, nchan]
        (ntime,nbeam) are multiplexed for OTF - usually CRVAL3,CRVAL4 - but nbeam can be 1
                      even though beam can cycle over 16 in the case of SEQ
        npol usually in CRVAL2 - but npol can be 1
        (nband,nchan) are both under control of CRVAL1 - but nband can be 1
    
    """
    # need to agree on what axis is what
    axis_time  = 0
    axis_board = 1   # board and pixel interchangeable ?
    axis_pol   = 2
    axis_band  = 3
    axis_chan  = 4

    # examples for di
    ndim_rsr = (10,4,1,6,256)
    ndim_slr = (256,1,1,1,256)
    ndim_oma = (128,1,2,1,256)
    ndim_1mm = (128,1,2,2,256)

                
    
    data_rsr = np.random.normal(-0.1,1,ndim_rsr)
    dims_rsr = data_rsr.shape
    r0 = ma.masked_where(data_rsr < 0, data_rsr)
    r1 = r0.mean(axis=axis_board, keepdims=True)
    r2 = r1.mean(axis=axis_time, keepdims=True)
    # patch the axis_band and axis_chan
    # first reshape them in one line
    r3 = r2.reshape( dims_rsr[axis_band] * dims_rsr[axis_chan])
    
    data_slr = np.random.normal(-0.1,1,ndim_slr)
    s0 = ma.masked_where(data_slr < 0, data_slr)
    # ready for gridding
    

    d0 = np.arange(3*4).reshape(3,4)

    # for return
    data = np.random.normal(-0.1,1,ndim)
    if True:
        data = ma.masked_invalid(data,copy=False)    
    if True:
        data = np.arange(data.size).reshape(ndim)

    print('data',data)
    return data

def my_read(filename):
    """
    example that can read SDFITS
    In LMT/GTM mode the data can be read as a multi-dimensional (ndarray) object
    """
    #
    print("File:      %s" % filename)
    
    hdu = fits.open(filename)
    header = hdu[0].header
    if len(hdu) == 1:
        print("Error: only one HDU found. Not SDFITS")
        return
    
    bintable = hdu[1]
    if len(hdu) > 2:
        print("Warning: skipping unkown HDUs, there are %d" % len(hdu))

    header2  = bintable.header
    data2    = bintable.data
    #
    extname = header2['EXTNAME']
    if extname != 'SINGLE DISH':
        print("Warning: extname=%s, winging it" % extname)
    #
    ncols = header2['NAXIS1']
    nrows = len(data2)
    nflds = header2['TFIELDS']

    print("Size:      %d cols x %d rows" % (nflds,nrows))


    telescope = header2['TELESCOP']
    print("Telescope: %s" % telescope)

    # spectra  = data2[:]['DATA']
    # the next command will finally load in the data, the rest were just pointers/references
    if 'OBJECT' in header2:
        srcs = [header2['OBJECT']]
        #srcs = np.tile(header2['OBJECT'], nrow)
    else:
        srcs = np.unique(data2[:]['OBJECT'])
    print("Object:    %s" % str(srcs))

    date_obs = data2[0]['DATE-OBS']
    print("DateObs:   %s" % str(date_obs))
        
    #scan = np.unique(data2[:]['SCAN'])
    
    hdu.close()
    

def my_write_slr(filename):
    # the CORE keywords/columns that need to be present
    core = ['DATE-OBS', 'TSYS', 'DATA', 'EXPOSURE', 'TELESCOP', 'BANDWID', 'OBJECT']
    keys = ['FEED']
    
    # DATE-OBS
    a1 = np.array([1542368910.35212, 1542368910.37891, 1542368910.40049])
    # TSYS
    a2 = np.array([190.0, 191.0, 192.0])
    # DATA
    a3 = gen_data((3,1,1,1,4))
    # FEED
    a4 = np.array([0, 1, 2])

    print(a1.shape)
    print(a3.shape)
    
    col1 = fits.Column(name='DATE-OBS', format='D',  array=a1)
    col2 = fits.Column(name='TSYS',     format='E',  array=a2)
    col3 = fits.Column(name='DATA',     format='4E', array=a3)
    col4 = fits.Column(name='FEED',     format='I',  array=a4)

    cols = fits.ColDefs([col1,col2,col3,col4])
    hdu = fits.BinTableHDU.from_columns(cols)
    # mark it as 'SINGLE DISH'
    hdu.header['EXTNAME']  = 'SINGLE DISH'
    hdu.header['EXTVER']   = 1
    
    # write the keywords that do not vary
    hdu.header['EXPOSURE'] = 0.1        # sec
    hdu.header['TELESCOP'] = 'LMT/GTM'
    hdu.header['INSTRUME'] = 'test'
    hdu.header['OBJECT']   = 'NGC1234'
    hdu.header['BANDWID']  = 800.0e6    # Hz

    # write some provenance
    hdu.header['ORIGIN'] = 'GBTOY test'
    
    # finish up and write the file
    hdu.writeto(filename, overwrite=True)
    print("Written %s" %  filename)

def my_write_rsr(filename):
    # the CORE keywords/columns that need to be present
    core = ['DATE-OBS', 'TSYS', 'DATA', 'EXPOSURE', 'TELESCOP', 'BANDWID', 'OBJECT']
    keys = []
    
    # DATE-OBS 
    a1 = [1542368910.35212, 1542368910.37891, 1542368910.40049]
    # TSYS
    a2 = [190.0, 191.0, 192.0]
    # DATA
    a3 = gen_data((3,2,1,3,4))     # time, board, pol, if, chan

    ntile = 2*1*3
    a1t = np.tile(a1,ntile)
    a2t = np.tile(a2,ntile)
    

    print(a1t.shape)
    print(a2t.shape)
    a3 = a3.ravel()
    print(a3.shape)

    # BNUM
    board_numbers = [0, 1]
    a4 = np.array([0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2])
    if_numbers    = [0, 1, 2]
    # IFNUM
    a5 = np.array([0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1])
    
    
    col1 = fits.Column(name='DATE-OBS', format='D',  array=a1t)
    col2 = fits.Column(name='TSYS',     format='E',  array=a2t)
    col3 = fits.Column(name='DATA',     format='4E', array=a3)    # 3,4 ->  3,24
    col4 = fits.Column(name='BNUM',     format='I',  array=a4)
    col5 = fits.Column(name='IFNUM',    format='I',  array=a5)        


    cols = fits.ColDefs([col1,col2,col4,col5,col3])
    hdu = fits.BinTableHDU.from_columns(cols)
    # mark it as 'SINGLE DISH'
    hdu.header['EXTNAME']  = 'SINGLE DISH'
    hdu.header['EXTVER']   = 1
    
    # write the keywords that do not vary
    hdu.header['EXPOSURE'] = 0.1        # sec
    hdu.header['TELESCOP'] = 'LMT/GTM'
    hdu.header['INSTRUME'] = 'test'    
    hdu.header['OBJECT']   = 'NGC1234'
    hdu.header['BANDWID']  = 800.0e6    # Hz
    hdu.writeto(filename, overwrite=True)
    print("Written %s" %  filename)

def oper1(data,axis):
    #       data[ntime, nbeam, nband, npol, nchan]
    data = dara.mean(axis=axis)
    
    return

if __name__ == '__main__':   


    if len(sys.argv) == 1:
        my_write_slr('slr.sdfits')
        my_write_rsr('rsr.sdfits')

        my_read('slr.sdfits')
        my_read('rsr.sdfits')
    else:
        my_read(sys.argv[1])


