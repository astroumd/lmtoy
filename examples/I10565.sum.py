#! /usr/bin/env python
#
#   Example of detailed flagging of RSR data (courtesy Min Yun)
#
#   25-feb-2021:    PJT     added (obslist,blanks,windows) file 
#

import os
import numpy as np
import glob
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.utils.filterscans import FilterScans
from dreampy3.redshift.plots import RedshiftPlot
# import gain
from blanking import blanking

if 'DATA_LMT' in os.environ:
    data_lmt = os.environ['DATA_LMT']
else:
    data_lmt = '/data_lmt'

sourceobs = 'I10565.sum'
(obslist,blanks,windows)  = blanking('I10565.blanking')
threshold_sigma = 0.01
hdulist=[]
pl = RedshiftPlot()

for ObsNum in obslist:        # for observations in obslist
    for chassis in (0,1,2,3): # for all chassis

        try:
            # first check to see if for this obsnum and chassis it can be skipped
            for b in blanks:
                if chassis == b[0] and ObsNum in b[1] and len(b[2]) == 0:
                    print("Skipping ",b)
                    raise
                    
            globs = '%s/RedshiftChassis%d/RedshiftChassis%d_*_0%d_00_0001.nc' % (data_lmt, chassis, chassis, ObsNum)
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

        # flag chassis/obsnum/band triples, or skip out the whole chassis
        for b in blanks:
            if chassis == b[0] and ObsNum in b[1]:
                if len(b[2]) == 0:
                    continue
                nc.hdu.blank_frequencies (b[2]) 

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

print("Accumulated %d hdu's" % len(hdulist))
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
