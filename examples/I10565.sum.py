#! /usr/bin/env python
#
#   Example of detailed flagging of RSR data (courtesy Min Yun)
#

import os
#import gain
import numpy as np

from dreampy3.redshift.netcdf import RedshiftNetCDFFile
# from dreampy3.utils.filterscans import FilterScans
from dreampy3.redshift.plots import RedshiftPlot

sourceobs = 'i10565.sum' 
hdulist=[]
obs = 1
windows = {}
windows[0] = [(73.5,79.3)]
windows[1] = [(87.,91.5)]
windows[2] = [(80.,83.3),(83,8,84.6)]
windows[3] = [(92.5,98.)]
windows[4] = [(104.,105.3),(105.8,108.),(109.,109.9)]
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
        for chassis in (0,1,2,3): #fol all chassis
            try:
                if ObsNum in (36231,36387,) and chassis in (2,3):
                    continue
                if ObsNum > 28000:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2014-11-13_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 29500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2014-11-27_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 31200:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2014-12-17_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 31500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2014-12-19_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 32000:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-04_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 32800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-17_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 32900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-18_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 33300:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-21_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 33500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-22_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 33800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-25_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 33900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-26_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 34400:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-01-31_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 34600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-02-04_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 35600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-02-12_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 36400:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-02-17_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 36900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-02-21_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 38400:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-03-18_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 38600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-03-19_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 39500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-03_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 39600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-04_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 40100:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-07_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 40200:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-08_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 40600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-21_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 40700:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-04-24_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 41100:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-05-02_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 42100:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-05-18_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 42300:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-05-19_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 42800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-05-25_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 49500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-11-23_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 52050:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2015-12-13_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 54600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-01-29_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 54800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-01-30_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 55700:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-02-07_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 57600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-02-24_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58300:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-08_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58400:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-15_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-17_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58700:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-18_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-19_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 58900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-20_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59000:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-24_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59100:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-25_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59120:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-27_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59200:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-28_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59300:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-30_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59400:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-03-31_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 59900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-03_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 60100:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-04_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 60900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-09_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61200:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-11_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61300:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-12_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61500:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-14_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61600:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-15_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61800:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-16_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if ObsNum > 61900:
                    fname = '/data_lmt/RedshiftChassis%s/RedshiftChassis%s_2016-04-17_0%s_00_0001.nc' % (chassis, chassis, ObsNum)          
                if fname:
                    print("Process filename %s" % fname)
                    nc = RedshiftNetCDFFile(fname)
                else:
                    continue
            except:
                continue
            print(nc.hdu.header.SourceName)
            #count += 1
            nc.hdu.process_scan()
            #el = nc.hdu.header.ElReq
            #nc.hdu.spectrum = nc.hdu.spectrum/gain.curve(el)
            ###
            # flag some chassis
         #   if ObsNum in (obslist) and chassis in(2,3): 
         #        nc.hdu.blank_frequencies( {3: [(95.,100.),]} )
            ### Flag Chassis 0
            #flaglist00=[1000]    
            if chassis == 0 and ObsNum in range(51800, 62000):
                nc.hdu.blank_frequencies( {0: [(70.,100.),]} )
                nc.hdu.blank_frequencies( {1: [(70.,100.),]} )
            flaglist00=[40608,40609]    
            if chassis == 0 and ObsNum in (flaglist00):
                nc.hdu.blank_frequencies( {0: [(65.,100.)]} )
            flaglist01=[2000]    
            if chassis == 0 and ObsNum in (flaglist01):
                nc.hdu.blank_frequencies( {1: [(65.,100.)]} )
            flaglist02=[1000]    
            if chassis == 0 and ObsNum in (flaglist02):
                nc.hdu.blank_frequencies( {2: [(75.,100.)]} )
            flaglist03=[1000]    
            if chassis == 0 and ObsNum in (flaglist03):
                nc.hdu.blank_frequencies( {3: [(95.,100.)]} )
            flaglist04=[28709,29313,32019,54803,59399]    
            if chassis == 0 and ObsNum in (flaglist04):
                nc.hdu.blank_frequencies( {4: [(95.,120.)]} )
            flaglist05=[31349,38494,40286,49516,58449,59112,59257,61219]  
            if chassis == 0 and ObsNum in (flaglist05):
                nc.hdu.blank_frequencies( {5: [(95.,111.),]} )
            ### Flag Chassis 1
            #if chassis == 1 and ObsNum in range(15600, 59500):
            #    nc.hdu.blank_frequencies( {0: [(67.5,100.),]} )
            if chassis == 1 and ObsNum in range(54400, 62000):
                nc.hdu.blank_frequencies( {0: [(70.,100.),]} )
                nc.hdu.blank_frequencies( {2: [(70.,100.),]} )
            if chassis == 1 and ObsNum in range(49900, 51000):
                nc.hdu.blank_frequencies( {2: [(70.,100.),]} )
            if chassis == 1 and ObsNum in range(15600, 34500):
                nc.hdu.blank_frequencies( {3: [(98.,100.),]} )
            if chassis == 1 and ObsNum in range(14400, 39500):
                nc.hdu.blank_frequencies( {0: [(70.,100.),]} )
            flaglist10=[49515]    
            if chassis == 1 and ObsNum in (flaglist10):
                nc.hdu.blank_frequencies( {0: [(70.,100.),]} )
            flaglist11=[37575,40609,42318,42319]    
            if chassis == 1 and ObsNum in (flaglist11):
                nc.hdu.blank_frequencies( {1: [(75.,120.),]} )
            flaglist12=[1000]    
            if chassis == 1 and ObsNum in (flaglist12):
                nc.hdu.blank_frequencies( {2: [(75.,120.),]} )
            flaglist13=[34488,34489,58866,58867,58962,58963,59035,59122,59123]    
            if chassis == 1 and ObsNum in (flaglist13):
                nc.hdu.blank_frequencies( {3: [(97.,100.),]} )
            flaglist14=[39594,42318]    
            if chassis == 1 and ObsNum in (flaglist14):
                nc.hdu.blank_frequencies( {4: [(90.,120.),]} )
            flaglist15=[37500,42318,58732]    
            if chassis == 1 and ObsNum in (flaglist15):
                nc.hdu.blank_frequencies( {5: [(90.,120.),]} )
            ### Flag Chassis 2
            if chassis == 2 and ObsNum in range(49500, 51000):
                nc.hdu.blank_frequencies( {1: [(70.,100.),]} )
            flaglist2=[32019,42313,42314,42318,42319]    
            if chassis == 2 and ObsNum in (flaglist2):
                nc.hdu.blank_frequencies( {4: [(95.,111.),]} )
                nc.hdu.blank_frequencies( {5: [(95.,111.),]} )
            flaglist20=[1000]    
            if chassis == 2 and ObsNum in (flaglist20):
                nc.hdu.blank_frequencies( {0: [(64.,95.)]} )
            flaglist21=[37553]    
            if chassis == 2 and ObsNum in (flaglist21):
                nc.hdu.blank_frequencies( {1: [(74.,95.)]} )
            flaglist22=[33906,40798]    
            if chassis == 2 and ObsNum in (flaglist22):
                nc.hdu.blank_frequencies( {2: [(74.,95.)]} )
            flaglist23 = [28190,28191,35692,36446,36949,36950,42865,49515,49516,52195,54693,54694,55770,58393,58866,58867,59035,59036,59122,59470] 
            if chassis == 2 and ObsNum in (flaglist23):
                nc.hdu.blank_frequencies( {3: [(95.,100.),]} )
            flaglist230 = [35691,38494,38495,38624,38625,39593,39594,39686,39687,40134,40135,40286,40287,40606,40608,40609,40797,40798,42166,42167,42303,42304,42313,42314,42318,42319,54802,57632,57633,58448,58731,58732,59471,60125,60126,60978,61218,61219,61352,61353,61581,61582,61696,61697,61827,61828,61978,61979] 
            if chassis == 2 and ObsNum in (flaglist230):
                nc.hdu.blank_frequencies( {3: [(90.,100.),]} )
            if chassis == 2 and ObsNum in range(29312, 35000):
                nc.hdu.blank_frequencies( {3: [(90.,100.),]} )
            flaglist24=[1000,58618,59036]    
            if chassis == 2 and ObsNum in (flaglist24):
                nc.hdu.blank_frequencies( {4: [(95.,111.),]} )
            flaglist25=[28191,32018,33392,33905,33906,35691,36950,40287,55770,57633,59257,61353,61827]    
            if chassis == 2 and ObsNum in (flaglist25):
                nc.hdu.blank_frequencies( {5: [(95.,111.),]} )
            ### Flag Chassis 3 
            flaglist3=[35691,40134,40609,42314,42318,42319,60977]
            if chassis == 3 and ObsNum in (flaglist3):
                nc.hdu.blank_frequencies( {4: [(95.,111.),]} )
                nc.hdu.blank_frequencies( {5: [(95.,111.),]} )
            flaglist30=[42865,52195,57633,58392]    
            if chassis == 3 and ObsNum in (flaglist30):
                nc.hdu.blank_frequencies( {0: [(70.,88.)]} )
            flaglist31=[1000]    
            if chassis == 3 and ObsNum in (flaglist31):
                nc.hdu.blank_frequencies( {1: [(84.,88.)]} )
            flaglist32=[29446,31236,38244]    
            if chassis == 3 and ObsNum in (flaglist32):
                nc.hdu.blank_frequencies( {2: [(74.,90.)]} )
            flaglist33 = [28190,28191,29674,32018,32019,32876,33392,33906,35691,35692,40608,40609,42303,42313,42314,42318,42319,49516,52195,52196,54694,54803,57632,57633,58393,58732,58962,59036,59258,61352,61353] 
            if chassis == 3 and ObsNum in (flaglist33):
                nc.hdu.blank_frequencies( {3: [(95.,100.),]} )
            if chassis == 3 and ObsNum in range(36198, 39900):
                nc.hdu.blank_frequencies( {3: [(95.,100.),]} )
            flaglist330 = [40134,42864,42865] 
            if chassis == 3 and ObsNum in (flaglist330):
                nc.hdu.blank_frequencies( {3: [(90.,100.),]} )
            flaglist34=[29163,32876,40797,42304,59112]
            if chassis == 3 and ObsNum in (flaglist34):
                nc.hdu.blank_frequencies( {4: [(95.,111.),]} )
            flaglist35=[29674,29675,31349,31350,32018,32019,32876,32877,33905,33906,38495,38624,38625,39594,39686,39687,40286,49516,52196,55770,55785,57633,58393,58448,58449,58618,58619,58620,58731,58732,59257,59258,59399,59400,59470,59471,59951,59952,60978,61219,61352,61353,61582]
            if chassis == 3 and ObsNum in (flaglist35):
                nc.hdu.blank_frequencies( {5: [(95.,111.),]} )
            #
            nc.hdu.baseline(order=1, windows=windows, subtract=True)
            nc.hdu.average_all_repeats(weight='sigma')
            # Comment out the following 3 lines if you don't
            #   want to see individual spectrum again
            #pl.plot_spectra(nc)
            zz = 1
            #zz = raw_input('To reject observation, type ''r'':')
            if zz != 'r':
             hdulist.append(nc.hdu)
             nc.sync()
             nc.close()
             del nc

    hdu = hdulist[0]
    hdu.average_scans(hdulist[1:],threshold_sigma=0.01)
    pl.plot_spectra(hdu)
    # baselinesub = raw_input('Order of baseline (type ''n'' for none):')
    baselinesub = -1    # -1, 0, 1, ...
    if baselinesub < 0:
        hdu.baseline(order=0, subtract=False)
    else:
        hdu.baseline(order=baselinesub,subtract=True)
    txtfl = '%s.txt' % sourceobs
    hdu.make_composite_scan()
    hdu.write_composite_scan_to_ascii(txtfl)
    obs = 0
