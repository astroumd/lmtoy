#! /usr/bin/env python
#
#   Example of detailed flagging of RSR data (courtesy Min Yun)
#   See "make rsr3" how to run this example.
#
#   historic:       MSY     Original Version
#   25-feb-2021:    PJT     added (obslist,blanks,windows) file
#   25-feb-2021:    PJT     converted from I10565.sum.py to a commandline version
#

"""Usage: rsr_sum.py -b BLANKING_FILE [options]

-b BLANKING_FILE              Input ASCII blanking file. No default.
-t THRESHOLD_SIGMA            Threshold sigma in spectrum needed for averaging [Default: 0.01]
--o1 ORDER1 -1 ORDER1         Baseline order fit for individual spectra [Default: 1]
--o2 ORDER2 -2 ORDER2         Baseline order fit for final combined spectrum [Default: -1]
                              Use -1 to skip another fit
-p PATH                       Data path to data_lmt for the raw RedshiftChassis files.
                              By default $DATA_LMT will be used else '/data_lmt'.

-h --help                     show this help


rsr_sum.py allows you to pass a very detailed blanking file to summing the spectra to a single
final spectrum. The operation of this script is somewhat similar to rsr_driver.py.  The
blanking file specifies which obsnum's to use, which ones to blank, and optionally specifies
the baseline regions for baseline subtraction.

The format of this blanking file is currently as follows (subject to change):

       # optionally set up to 6 window banks (0..5) where to fit the baselines
       windows[2] = [(80.0,83.3),(83.8,84.6)]
       # list of obsnums for the sum; give one or more comma separated, or an inclusive range
       12345,12346,12347
       30001-30010
       65432
       # list of obsnums where blanking is needed.
       12345,12346  0
       30001-30100  2    {4: [(95.,111.)]}   {5: [(95.,111.)]} 


"""


import os
import sys
import numpy as np
import glob
from docopt import docopt

from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.utils.filterscans import FilterScans
from dreampy3.redshift.plots import RedshiftPlot
# import gain
from blanking import blanking


def main(argv):
    av = docopt(__doc__,options_first=True, version='0.1')
    print(av)

    # -b
    blanking_file = av['-b']
    
    # -p
    if av['-p'] == None:
        if 'DATA_LMT' in os.environ:
            data_lmt = os.environ['DATA_LMT']
        else:
            data_lmt = '/data_lmt'
    else:
        data_lmt =  av['-p']

    # -t
    threshold_sigma = float(av['-t'])

    # --o1, --o2
    order1 = int(av['--o1'])
    order2 = int(av['--o2'])

    sourceobs = blanking_file + '.sum'
    (obslist,blanks,windows)  = blanking(blanking_file)
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
                # find the chassis file         
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
            nc.hdu.process_scan()

            #el = nc.hdu.header.ElReq
            #nc.hdu.spectrum = nc.hdu.spectrum/gain.curve(el)

            # flag chassis/obsnum/band triples
            for b in blanks:
                if chassis == b[0] and ObsNum in b[1]:
                    nc.hdu.blank_frequencies (b[2]) 
            if len(windows[0]) > 0:
                nc.hdu.baseline(order=order1, windows=windows, subtract=True)
            else:
                nc.hdu.baseline(order=order1, subtract=True)
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
    if order2 < 0:
        hdu.baseline(order=0, subtract=False)    # @todo    can we just skip this call?
    else:
        hdu.baseline(order=order2,subtract=True)
    txtfl = '%s.txt' % sourceobs
    hdu.make_composite_scan()
    hdu.write_composite_scan_to_ascii(txtfl)


if __name__ == "__main__":
    main(sys.argv[1:]) 
