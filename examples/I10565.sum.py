#! /usr/bin/env python
#
#   Example of detailed flagging of RSR data (courtesy Min Yun)
#   feb-2021:    added (obslist,blanking) file 
#

import os
#import gain
import numpy as np
import glob

from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.utils.filterscans import FilterScans
from dreampy3.redshift.plots import RedshiftPlot

from blanking import blanking


sourceobs = 'I10565.sum'
(obslist,bands)  = blanking('I10565.blanking')
threshold_sigma = 0.01
hdulist=[]
obs = 1
windows = {}                     # freq sections in the 6 bands where baselines are to be computed, carefully ignoring a few obvious lines
windows[0] = [(73.5,79.3)]
windows[1] = [(87.0,91.5)]
windows[2] = [(80.0,83.3),(83.8,84.6)]
windows[3] = [(92.5,98.0)]
windows[4] = [(104.0,105.3),(105.8,108.0),(109.0,109.9)]
windows[5] = [(98.1,104.5)]
pl = RedshiftPlot()
while obs == 1:
    for ObsNum in obslist:        # for observations in obslist
        for chassis in (0,1,2,3): # for all chassis
            try:
                globs = '/data_lmt/RedshiftChassis%d/RedshiftChassis%d_*_0%d_00_0001.nc' % (chassis, chassis, ObsNum)
                fn = glob.glob(globs)
                if len(fn) == 1:
                    fname = fn[0]
                    print("Process filename %s" % fname)
                    nc = RedshiftNetCDFFile(fname)
                else:
                    print("Warning: [%d] failed finding files for %s" % (len(fn),globs))
                    continue
            except:
                continue
            print(nc.hdu.header.SourceName)
            #count += 1
            nc.hdu.process_scan()

            #el = nc.hdu.header.ElReq
            #nc.hdu.spectrum = nc.hdu.spectrum/gain.curve(el)
            
            # flag some chassis/obsnum/band triples, or skip out the whole chassis
            for b in bands:
                if chassis == b[0] and ObsNum in b[1]:
                    if len(b[2]) == 0:
                        continue
                    # nc.hdu.blank_frequencies (b[2]) 
                    for k in b[2].keys():
                        nc.hdu.blank_frequencies( { k : b[2][k] } )

            nc.hdu.baseline(order=1, windows=windows, subtract=True)
            nc.hdu.average_all_repeats(weight='sigma')
            # Comment out the following 3 lines if you don't
            #   want to see individual spectrum again
            #pl.plot_spectra(nc)
            zz = 1
            #zz = input('To reject observation, type ''r'':')
            if zz != 'r':
             hdulist.append(nc.hdu)
             nc.sync()
             nc.close()
             del nc

    hdu = hdulist[0]
    hdu.average_scans(hdulist[1:],threshold_sigma=threshold_sigma)
    pl.plot_spectra(hdu)
    # baselinesub = int(input('Order of baseline (use ''-1'' for none):'))
    baselinesub = -1    # -1, 0, 1, ...
    if baselinesub < 0:
        hdu.baseline(order=0, subtract=False)
    else:
        hdu.baseline(order=baselinesub,subtract=True)
    txtfl = '%s.txt' % sourceobs
    hdu.make_composite_scan()
    hdu.write_composite_scan_to_ascii(txtfl)
    # done !
    obs = 0
