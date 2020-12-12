#! /usr/bin/env python
#
#     using chunking in DASK arrays?
#

import sys
import netCDF4
import dask.array as da

# get a roach dataset
filename = sys.argv[1]

# number of processors (chunks in nchan)
np = int(sys.argv[2])

print("filename=",filename)
print("np=",np)

nc = netCDF4.Dataset(filename)
rawdata = nc.variables['Data.Integrate.Data'][:]
nchan = nc.variables['Header.Mode.numchannels'][0]
print(rawdata.shape)
print(nchan)
(ntime,nchan) = rawdata.shape
print(ntime,nchan)
nc.close()

# measure only reading
if np<0:
    sys.exit(0)

# measure only classic numpy
if np==0:
    dmean = rawdata.mean(axis=0)
    dstd = rawdata.std(axis=0)
    print(dmean,dstd)
    sys.exit(0)

# now try the fancy DASK

x = da.from_array(rawdata,chunks=(ntime,nchan/np))
xmean = x.mean(axis=0).compute()
xstd = x.std(axis=0).compute()                        
print(xmean,xstd)

# M51_data/spectrometer/roach0/roach0_91112_0_1_NGC5194_2020-02-20_060348.nc
# this data is 3.3 GB
# -1  2.10user  2.42system 0:08.01elapsed  56%CPU   4.4G
#     2.03user  1.93system 0:03.19elapsed 124%CPU
#     1.97user  2.43system 0:07.81elapsed  56%CPU
#     1.79user  1.80system 0:02.85elapsed 125%CPU
# 0   3.19user  2.29system 0:04.73elapsed 115%CPU   7.7G ??
#     3.10user  2.06system 0:04.40elapsed 117%CPU
# 1  11.74user  8.70system 0:24.13elapsed  84%CPU  14+G !!
#    12.91user  8.62system 0:25.30elapsed  85%CPU
# 2  13.10user 11.47system 0:19.02elapsed 129%CPU
#    14.37user 11.54system 0:19.45elapsed 133%CPU
# 4  14.30user 15.20system 0:16.19elapsed 182%CPU 
#    14.50user 14.70system 0:10.91elapsed 267%CPU
#    15.99user 16.20system 0:16.63elapsed 193%CPU
# 8  24.10user 19.82system 0:10.58elapsed 415%CPU
