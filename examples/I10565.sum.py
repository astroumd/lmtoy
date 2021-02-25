#! /usr/bin/env python
#
#   Example of detailed flagging of RSR data (courtesy Min Yun)
#

import os
#import gain
import numpy as np
import glob

from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.utils.filterscans import FilterScans
from dreampy3.redshift.plots import RedshiftPlot

def blanking(filename):
    """   blanking rules       obsnum,chassis,bank
    """
    blanks = []
    lines = open(filename)
    for line in lines:
        if line[0] == '#':
            continue
        line = line.strip()
        w = line.split()
        if len(w) < 2:
            # warning
            continue
        #print("B:",line)
        obsnum = w[0]
        chassis = int(w[1])
        #print("CHASSIS: ",chassis)
        dash = obsnum.find('-')
        if dash > 0:
            o1 = int(obsnum[:dash])
            o2 = int(obsnum[dash+1:])
            obsnums = 'range(%d,%d)' % (o1,o2)
        else:
            obsnums = '[%s]' % obsnum
        #print("OBSNUMS: " , obsnums)

        if len(w) == 2:
            bands = '{}'
        else:
            bands = ' '.join(w[2:]).replace(' ','').replace('}{',',')
        #print("BANDS: ", bands)

        d = {}
        exec('x=%d' % chassis, d)
        exec('y=%s' % obsnums, d)
        exec('z=%s' % bands,   d)
        print('PJT',d['x'], d['y'], d['z'])
        blanks.append([d['x'], d['y'], d['z']])

    print("Found %d blanking lines" % len(blanks))
    return blanks



sourceobs = 'I10565.sum'
bands     = blanking('I10565.blanking')
hdulist=[]
obs = 1
windows = {}                     # freq sections in the 6 bands in which baselines are to be computed
windows[0] = [(73.5,79.3)]
windows[1] = [(87.0,91.5)]
windows[2] = [(80.0,83.3),(83.8,84.6)]
windows[3] = [(92.5,98.0)]
windows[4] = [(104.0,105.3),(105.8,108.0),(109.0,109.9)]
windows[5] = [(98.1,104.5)]
pl = RedshiftPlot()
while obs == 1:
    obslist = [28190,28191,29674,29675,31349,31350,32018,32019,32876,32877,33392,33393,33551,33552,33848,33849,33905,33906,34431,34432,34788,34789,35691,35692,36445,36446,36949,36950,38494,38495,38624,38625,39593,39594,39686,39687,40134,40135,40286,40287,40605,40606,40608,40609,40797,40798,42166,42167,42303,42304,42313,42314,42318,42319,42864,42865,49515,49516,52195,52196,54693,54694,54802,54803,55770,55771,55784,55785,57632,57633,58392,58393,58448,58449,58618,58619,58620,58731,58732,58866,58867,58962,58963,59035,59036,59122,59123,59257,59258,59399,59400,59470,59471,59951,59952,60125,60126,60977,60978,61218,61219,61352,61353,61581,61582,61696,61697,61827,61828,61978,61979]# all data 
    #obslist = [28190,28191]# 11/13/14 Tsys=104K 
    #obslist = [29674,29675]# 11/27/14 Tsys=98K 
    #obslist = [31349,31350]# 12/17/14 Tsys=98K 
    #obslist = [31524,31525,31528,31529,31532,31533]# 12/19/14 Tsys=98K 
    #obslist = [32018,32019]# 1/4/15 Tsys=97K 
    #obslist = [32876,32877]# 1/17/15 Tsys=91K 
    #obslist = [32992,32993]# 1/18/15 Tsys=91K 
    #obslist = [33392,33393]# 1/21/15 Tsys=91K 
    #obslist = [33551,33552]# 1/22/15 Tsys=91K 
    #obslist = [33848,33849]# 1/25/15 Tsys=94K 
    #obslist = [33905,33906]# 1/26/15 Tsys=102K 
    #obslist = [34431,34432]# 1/31/15 Tsys=96K 
    #obslist = [34788,34789]# 2/4/15 Tsys=91K 
    #obslist = [35691,35692]# 2/12/15 Tsys=101K 
    #obslist = [36445,36446]# 2/17/15 Tsys=91K 
    #obslist = [36949,36950]# 2/21/15 Tsys=91K 
    #obslist = [38494,38495]# 3/18/15 Tsys=91K 
    #obslist = [38624,38625]# 3/19/15 Tsys=91K 
    #obslist = [39593,39594]# 4/3/15 Tsys=91K 
    #obslist = [39686,39687]# 4/4/15 Tsys=91K 
    #obslist = [40134,40135]# 4/7/15 Tsys=91K 
    #obslist = [40286,40287]# 4/8/15 Tsys=91K 
    #obslist = [40605,40606,40608,40609]# 4/21/15 Tsys=93K 
    #obslist = [40797,40798]# 4/24/15 Tsys=103K 
    #obslist = [41194,41195,41197,41198]# 5/2/15 Tsys=125K 
    #obslist = [42166,42167]# 5/18/15 Tsys=98K 
    #obslist = [42303,42304,42313,42314,42318,42319]# 5/19/15 Tsys=99K 
    #obslist = [42864,42865]# 5/25/15 Tsys=113K 
    #obslist = [49515,49516]# 11/23/15 Tsys=92K 
    #obslist = [52195,52196]# 12/13/15 Tsys=92K 
    #obslist = [54693,54694]# 1/29/16 Tsys=92K 
    #obslist = [54802,54803]# 1/30/16 Tsys=92K 
    #obslist = [55770,55771,55784,55785]# 2/7/16 Tsys=92K 
    #obslist = [57632,57633]# 2/24/16 Tsys=94K 
    #obslist = [58392,58393]# 3/8/16 Tsys=94K 
    #obslist = [58448,58449]# 3/15/16 Tsys=88K 
    #obslist = [58618,58619,58620]# 3/17/16 Tsys=94K 
    #obslist = [58731,58732]# 3/18/16 Tsys=96K 
    #obslist = [58866,58867]# 3/19/16 Tsys=94K 
    #obslist = [58962,58963]# 3/20/16 Tsys=102K 
    #obslist = [59035,59036]# 3/24/16 Tsys=101K 
    #obslist = [59112,59113]# 3/25/16 Tsys=104K 
    #obslist = [59122,59123]# 3/27/16 Tsys=104K 
    #obslist = [59257,59258]# 3/28/16 Tsys=107K 
    #obslist = [59359,59360,59399,59400]# 3/30/16 Tsys=107K 
    #obslist = [59470,59471]# 3/31/16 Tsys=96K 
    #obslist = [59951,59952]# 4/3/16 Tsys=92K 
    #obslist = [60125,60126]# 4/4/16 Tsys=92K 
    #obslist = [60977,60978]# 4/9/16 Tsys=94K 
    #obslist = [61218,61219]# 4/11/16 Tsys=93K 
    #obslist = [61352,61353]# 4/12/16 Tsys=98K 
    #obslist = [61581,61582]# 4/14/16 Tsys=99K 
    #obslist = [61696,61697]# 4/15/16 Tsys=102K 
    #obslist = [61827,61828]# 4/16/16 Tsys=95K 
    #obslist = [61978,61979]# 4/17/16 Tsys=96K 

    for ObsNum in obslist: #for observations in obslist
        for chassis in (0,1,2,3): #for all chassis
            try:
                #if ObsNum in (36231,36387,) and chassis in (2,3):
                #    continue
                globs = '/data_lmt/RedshiftChassis%d/RedshiftChassis%d_*_0%d_00_0001.nc' % (chassis, chassis, ObsNum)
                # print("Trying globs",globs)
                fn = glob.glob(globs)
                if len(fn) == 1:
                    fname = fn[0]
                    print("Process filename %s" % fname)
                    nc = RedshiftNetCDFFile(fname)
                else:
                    print("Warning: [%d] failed globbing on %s" % (len(fn),globs))
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
    hdu.average_scans(hdulist[1:],threshold_sigma=0.01)
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
    obs = 0
