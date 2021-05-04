#! /usr/bin/env python
#
#  read and write an SDFITS file
#
#



import numpy as np
import numpy.ma as ma

from astropy.io import fits
import copy
import time

def gen_data(ndim=(256,1,1,1,256)):
    # need to agree on what axis is what
    axis_time  = 0
    axis_board = 1
    axis_pol   = 2
    axis_band  = 3
    axis_chan  = 4

    # examples for di
    ndim_rsr = (10,4,1,6,256)
    ndim_slr = (256,1,1,1,256)
    ndim_oma = (128,1,2,1,256)
    
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
    return data




def my_read(filename):
    #
    hdu = fits.open(filename)
    header = hdu[0].header   
    bintable = hdu[1]

    header2  = bintable.header
    data2    = bintable.data
    # spectra  = data2[:]['DATA']
    # the next command will finally load in the data, the rest were just pointers/references
    srcs = np.unique(data2[:]['OBJECT'])
    scan = np.unique(data2[:]['SCAN'])
    ncols = header2['NAXIS1']
    nrows = len(data2)
    nflds = header2['TFIELDS']

    
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
    
    col1 = fits.Column(name='DATA-OBS', format='D',  array=a1)
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
    print(a3.shape)

    # BNUM
    board_numbers = [0, 1]
    a4 = []
    if_numbers    = [0, 1, 2]
    # IFNUM
    a5 = []
    
    
    col1 = fits.Column(name='DATA-OBS', format='D',  array=a1t)
    col2 = fits.Column(name='TSYS',     format='E',  array=a2t)
    col3 = fits.Column(name='DATA',     format='4E', array=a3)


    cols = fits.ColDefs([col1,col2,col3])
    hdu = fits.BinTableHDU.from_columns(cols)
    # mark it as 'SINGLE DISH'
    hdu.header['EXTNAME']  = 'SINGLE DISH'
    hdu.header['EXTVER']   = 1
    
    # write the keywords that do not vary
    hdu.header['EXPOSURE'] = 0.1        # sec
    hdu.header['TELESCOP'] = 'LMT/GTM'
    hdu.header['OBJECT']   = 'NGC1234'
    hdu.header['BANDWID']  = 800.0e6    # Hz
    hdu.writeto(filename, overwrite=True)

my_write_slr('slr.sdfits')
my_write_rsr('rsr.sffits')
