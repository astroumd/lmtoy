#!/usr/bin/env python

# converted from a notebook

# a long PS integration, source 46P (a comet)
# OBSNUMs  082230..082352
# Each CAL is followed by 5 PS    (71 Ps and 14 Cal)
# 2018-12-18T22:36:21 - 2018-12-19T03:51:52

import numpy as np
import matplotlib.pyplot as pl
from lmtslr.reduction.line_reduction import *


# In[ ]:


# Scan Numbers
line_rest_freq = 88.6318473e9
a_scan_list = [82231, 82232, 82233,82234,82235,82236,82240,82241,82242,82243,82244,82246,82247,82248,82249,82250,82252,82253,82254,82255,82256,82286,82287,82288,82289,82290,82336,82337,82338,82339,82340,82342,82343,82344,82345,82346,82348,82349,82350,82351,82352]
b_scan_list = [82292,82293,82294,82295,82296,82298,82299,82300,82301,82302,82304,82305,82306,82307,82308,82314,82315,82316,82317,82318,82320,82321,82322,82323,82324,82326,82327,82328,82329,82330]
bank = 0
nchan = 8192
bandwidth = 200.
chan_list = [10]
tsys = 150.0
path = 'lma_data'

print(len(a_scan_list),len(b_scan_list))

# testing
for o in a_scan_list:
    I,S = read_obsnum_ps(o,chan_list,bank=0,use_calibration=True,tsys=tsys,path=path)

# In[ ]:


ACCUM_A = Accum()
lines_A = []
obsnum_A = []
channum_A = []
for o in a_scan_list:
    I,S = read_obsnum(o,chan_list,True) 
    for i,c in enumerate(chan_list):
        line = LineData(I,bank,nchan,bandwidth,S.roach[i].ps_spectrum)
        line.x_vsrc()
        dvdc = line.dvdc 
        for elist in [1024,2048,3072]:
            #line.yarray[elist] = np.nan
            line.yarray[elist] = (line.yarray[elist+1]+line.yarray[elist-1])/2.
        line_gen = line.xgen(-100,100,dvdc)
        lines_A.append(line_gen)
        obsnum_A.append(o)
        channum_A.append(c)
        ACCUM_A.load(line_gen.yarray)

ACCUM_B = Accum()
lines_B = []
obsnum_B = []
channum_B = []
for o in b_scan_list:
    I,S = read_obsnum(o,chan_list,True) 
    for i,c in enumerate(chan_list):
        line = LineData(I,bank,nchan,bandwidth,S.roach[i].ps_spectrum)
        line.x_vsrc()
        dvdc = line.dvdc
        for elist in [1024,2048,3072]:
            #line.yarray[elist] = np.nan
            line.yarray[elist] = (line.yarray[elist+1]+line.yarray[elist-1])/2.
        line_gen = line.xgen(-100,100,dvdc)
        lines_B.append(line_gen)
        obsnum_B.append(o)
        channum_B.append(c)
        ACCUM_B.load(line_gen.yarray)        
    


# In[ ]:


ACCUM_A.ave()
ACCUM_B.ave()


# In[ ]:


pl.plot(lines_A[0].xarray,ACCUM_A.average)
pl.plot(lines_B[0].xarray,ACCUM_B.average)
pl.axis([-10,10,0,.2])


# In[ ]:


for i in range(len(lines_A)):
    pl.plot(lines_A[i].xarray,lines_A[i].yarray+i)
    pl.text(20,i,'%d %d %d'%(obsnum_A[i],channum_A[i],i),fontsize=6)
pl.axis([-20,20,-.5,len(lines_A)])


pl.figure()  
for i in range(len(lines_B)):
    pl.plot(lines_B[i].xarray,lines_B[i].yarray+i)
    pl.text(20,i,'%d %d %d'%(obsnum_B[i],channum_B[i],i),fontsize=6)
pl.axis([-20,20,-.5,len(lines_B)])


# In[ ]:


ACCUM = Accum()
good_A = np.arange(len(lines_A))
good_B = np.arange(len(lines_B))
for i in good_A:
    ACCUM.load(lines_A[i].yarray)
for i in good_B:
    ACCUM.load(lines_B[i].yarray)
ACCUM.ave()


# In[ ]:


pl.plot(lines_A[0].xarray,ACCUM.average)
pl.xlim([-5,5])


# In[ ]:


a = Line(lines_A[0].iarray,lines_A[0].xarray,ACCUM.average,'VCOMET (km/s)')
# note that hyperfine lines are located -7.1 and +4.8 km/s
pl.plot(a.xarray,a.yarray,'k')
bl,nbl = a.xlist([[-20.,-8.1],[-6.1,-1.],[1.,3.8],[5.8,20]])

a.baseline(bl,nbl,12)
pl.plot(a.xarray,a.baseline,'r')
pl.axis([-20,20,0,.2])
pl.figure()
pl.plot(a.xarray,a.yarray,'k')
pl.xlabel(a.xname)
pl.xlim([-20,20])
pl.ylim([-.04,.1])
pl.plot([-20,20],[0,0],'k')



# In[ ]:


llp,nllp = a.xlist([[-10,10]])
for c in llp:
    print(a.xarray[c],a.yarray[c])


# In[ ]:


# measure just the F=2-1 line
a = Line(lines_A[0].iarray,lines_A[0].xarray,ACCUM.average,'VCOMET (km/s)')

bl,nbl = a.xlist([[-4.,-2.],[2.,3.8]])
a.baseline(bl,nbl,0)
ll,nll = a.xlist([[-2.,2.]])
a.line_stats(ll,nll)
print('YINT = %f (%f)'%(a.yint,a.yerr))
print('XMEAN = %f'%(a.xmean))


pl.plot(a.xarray,a.yarray,'k')
pl.xlabel(a.xname)
pl.xlim([-4,4])

