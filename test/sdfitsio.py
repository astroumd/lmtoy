#! /usr/bin/env python
#
#  some sample basic SDFITS I/O benchmarking as a baseline for future real work
#
#  %time a=sdf.gen_data((1000,16,1,1,2048))    user 1.88 s, sys: 496 ms, total: 2.38 s
#  %time sdf.my_write_sdfits('junk.fits',a)    user 314 ms, sys: 2.31 s, total: 2.62 s
#
#  (10000,16,1,1,2048)    user 20.1 s, sys: 7.09 s, total: 27.2 s      user 3.03 s, sys: 11.2 s, total: 14.2 s     1.3GB 
#
#  A typical large wide-band OTF:
#  dims=(20000, 16, 1, 1, 2048)    =  3 GB (about 1 hours observing at 0.1" integrations)
#
#  A large RSR contains a large number of OBSNUMS, which we simulate by taking a larger number of ntime's
#  dims=(1000, 2, 2, 6, 256)       = 25 MB (assumed 100 obsnums of 10 x 30" integrations)


import sys
import copy
import time

import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt

from astropy.io import fits
from astropy.nddata import NDData



def dimsize(dim=(2,3,4,5)):
    """ size of a multidimensional array via it's shape
        typically dim=data.shape
    
        data.size will also give it (faster) but we
        often need sized of hyperspaces, so the shape
        tuple works better
    """
    s = dim[0]
    for i in dim[1:]:
        s = s * i
    return s

# need to agree on what axis is what
axis_time  = 0   # ~scan
axis_beam  = 1   # beam ~ pixel
axis_pol   = 2
axis_band  = 3
axis_chan  = 4

class Spectra(object):
    def __init__(self,ndim=None):
        if ndim != None:
            print("gen_data for ",ndim)
            self.data = gen_data(ndim)
            self.wtpc = gen_data(ndim, noise=0, signal=1, width=1, mask=False)
            self.wtps = self.wtpc.mean(axis=axis_chan)
        # for each dim we need a lookup array (or WSC descriptor) of that axis
        # for a WCS the value = (i-crpix)*cdelt + crval
        # for a lookup the index into will be C=crval[i]

    def __len__(self):
        return self.data.size

    def pol_aver(self):
        d1 = (self.data*self.wtpc).mean(axis=axis_pol,  keepdims=True)
        d0 =             self.wtpc.mean(axis=axis_pol,  keepdims=True)
        self.data = d1/d0
        self.wtpc = d0        
    def time_aver(self):
        d1 = (self.data*self.wtpc).mean(axis=axis_time, keepdims=True)
        d0 =             self.wtpc.mean(axis=axis_time, keepdims=True)
        self.data = d1/d0
        self.wtpc = d0        
    def band_aver(self):
        d1 = (self.data*self.wtpc).mean(axis=axis_band, keepdims=True)
        d0 =             self.wtpc.mean(axis=axis_band, keepdims=True)
        self.data = d1/d0
        self.wtpc = d0
    def beam_aver(self):
        d1 = (self.data*self.wtpc).mean(axis=axis_beam, keepdims=True)
        d0 =             self.wtpc.mean(axis=axis_beam, keepdims=True)
        self.data = d1/d0
        self.wtpc = d0

    def aver(self):
        """ averages everything, one spectrum comes out
        """
        d1 = (self.data*self.wtpc).mean(axis=0).mean(axis=0).mean(axis=0).mean(axis=0)
        d0 =             self.wtpc.mean(axis=0).mean(axis=0).mean(axis=0).mean(axis=0)
        self.data = d1/d0
        self.wtpc = d0
        
    def band_merge(self, allow_gap=0):
        dims1 = self.data.shape
        dims2 = (dims1[0], dims1[1], dims1[2], 1, dims1[3]*dims1[4])
        self.data = self.data.reshape(dims2)
        self.wtpc = self.wtpc.reshape(dims2)

    def smooth(self, pars):
        """smooth channels
        """
        print("n/a")

    def rebin(self, pars):
        """ re-bin channels
        """
        print("n/a")

    def baseline(self, pars):
        """ set baseline fitting
        """
        print("n/a")

    def trim(self, pars):
        """ trim channels to save space
        """
        print("n/a")

    def mask(self, pars):
        """ general masking 
        """
        print("n/a")

    def gaussfit(self, pars):
        """ fit spectral line(s)
        """
        print("n/a")

    def stats(self, pars):
        """ stats 
        """
        print("n/a")

        
        
        
                  
def gen_data(dims=(256,1,1,1,256), noise=1,  signal=1, width=0.02, seed=None, mask=True):
    """
    generate fake data so we can fill an SDFITS file from scratch

    data[ntime, nbeam, npol, nband, nchan]
        (ntime,nbeam) are multiplexed for OTF - usually CRVAL3,CRVAL4 - but nbeam can be 1
                      even though beam can cycle over 16 in the case of SEQ
        npol usually in CRVAL2 - but npol can be 1
        (nband,nchan) are both under control of CRVAL1 - but band can be 1

    noise:    gaussian noise level if > 0
    signal:   peak of (gaussian) line in middle of channel ; 0 will add no line
    width:    FWHM width of (gaussian) line in fraction of band width
    seed:     set it to some integer if you want a fixed seed
    mask:     set to False if you don't need the mask (saves a bit of memory)
    
    """

    if len(dims) != 5:
        print("We currently only do 5D arrays: ",dims)
        return None
    
    ntime = dims[axis_time]
    nbeam = dims[axis_beam]
    npol  = dims[axis_pol]
    nband = dims[axis_band]
    nchan = dims[axis_chan]

    if noise > 0:
        if seed != None:
            np.random.seed(seed)
        data = np.random.normal(0,noise,dims)
    else:
        data = np.zeros(dims)

    if signal != 0:
        w2 = 11.1 * (nchan*width)**2
        c = nchan/2.0
        n2 = dimsize(dims[:-1])
        data2 = data.reshape(n2,nchan)
        # add the lines
        x2 = (np.arange(nchan)-c)**2 / w2
        g = np.exp(-x2)
        if True:
            # counterintuitive; this is a bit faster
            # print("looping data2 + g")            
            for i in range(n2):
                data2[i,:] = data2[i,:] + g
        else:
            # print("single data2 + g")
            #data2[:,:] = data2[:,:] + g
            data2 = data2 + g
                

    if mask:
        data = ma.masked_invalid(data,copy=False)    

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

    # for LMT only
    if 'DATADIMS' in header2:
        cmd = 'dims2=%s' % header2['DATADIMS']
        exec(cmd,globals())
        print('DIMS2:',dims2)

    spectra = data2['DATA']
    print(spectra.shape)
    spectra2 = spectra.reshape(dims2)
    print(spectra2.shape)

    print("Data.mean() = ", spectra.mean())
    
    hdu.close()
    spectra2 = ma.masked_invalid(spectra2,copy=False)        
    return spectra2
    
def my_write_sdfits(filename, data):
    # the CORE keywords/columns that need to be present
    core = ['DATE-OBS', 'TSYS', 'DATA', 'EXPOSURE', 'TELESCOP', 'BANDWID', 'OBJECT']
    keys = ['FEED']

    dims = data.shape
    dims1 = dims[:-1]    # all dims but nchan
    nchan = dims[-1]     # 
    n1 = dimsize(dims1)  # this is naxis2
    data1 = data.reshape(n1,nchan)

    print('SHAPE=',dims)
    print('NAXIS2=',n1)
    print('NCHAN=',nchan)
    
    # DATE-OBS
    a1 = np.arange(n1, dtype=np.float64)
    # TSYS
    a2 = np.ones(n1, dtype=float)
    # DATA:  make a copy, and apply the mask
    if data1.count() == dimsize(data1.shape):
        print("All data good, no masking operation needed")
        a3 = data1
    else:
        print("Some data masked, using a copy to write")
        a3 = ma.copy(data1)
        np.putmask(a3,a3.mask,np.nan)
    # FEED
    a4 = np.arange(n1, dtype=int)

    print(a1.shape)
    print(a3.shape)
    
    col1 = fits.Column(name='DATE-OBS', format='D',           array=a1)
    col2 = fits.Column(name='TSYS',     format='E',           array=a2)
    col3 = fits.Column(name='DATA',     format='%dE' % nchan, array=a3)
    col4 = fits.Column(name='FEED',     format='I',           array=a4)

    cols = fits.ColDefs([col1,col2,col3,col4])
    hdu = fits.BinTableHDU.from_columns(cols)
    # mark it as 'SINGLE DISH'
    hdu.header['EXTNAME']  = 'SINGLE DISH'
    hdu.header['EXTVER']   = 1
    
    # write the CORE keywords that do not vary
    hdu.header['EXPOSURE'] = 0.1        # sec
    hdu.header['TELESCOP'] = 'LMT/GTM'
    hdu.header['INSTRUME'] = 'lmtoy'
    hdu.header['OBJECT']   = 'NOISE'
    hdu.header['BANDWID']  = 800.0e6    # Hz
    
    # write some provenance
    hdu.header['ORIGIN'] = 'LMTOY test'
    hdu.header['DATADIMS'] = str(dims)
    
    # finish up and write the file
    hdu.writeto(filename, overwrite=True)
    print("Written %s" %  filename)


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

def data_mask(data, mask, value=True, show=False):
    """  Mask an NDarray by slices along one or more of its dimensions

         data[dims]   where dims=(d1,d2,d3,....dN)
         mask = { 0 : s0,  1:s1, .... }
         where s0, s0 is a string representing a slice, e.g. '1:4'
         value is normally True, but by setting it to False you can un-mask
    """
    print("DATA_MASK: ",mask)
    dims = data.shape
    ndims = len(dims)
    cmd = 'data.mask['
    for i in range(ndims):
        if i in mask.keys():
            s = mask[i]
        else:
            s = ':'
        cmd = cmd + s
        if i < ndims-1:
            cmd = cmd + ','
        else:
            cmd = cmd + '] = %s' % str(value)
    print("CMD:", cmd)
    exec(cmd)
    if show:
        # this is too expensive 
        fraction = data.count() / dimsize(dims)
        print("Fraction of data not masked: %g" % fraction)

def data_masked(data):
    """  Report how much data was masked
    """
    ntot  = dimsize(data.shape)
    nbad  = ntot - data.count()
    print("data_masked: %d / %d = %g%%" %  (nbad, ntot, 100.0*nbad/ntot))
    

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


