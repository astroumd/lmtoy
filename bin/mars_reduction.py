#! /usr/bin/env python
#

_version = "4-sep-2024"

_help = """Usage: mars_reduction.py -O OBSNUM [options]

-O OBSNUM --obsnum OBSNUM         The obsnum, something like 123456. No default.
-T TEMP --temperature TEMP        Brightness temperature of the planet in K. [Default: 205]
-D DIAMETER --diameter DIAMETER   Diameter of the planet in arcsec. [Default: 6.5]
-N NUMBANKS --numbanks NUMBANKS   Number of banks to process [Default: 2]
-v --version                      Version
-h --help                         This help

Formerly called continuum_reduction, this script ...

The name mars_reduction does not imply only mars can be reduced. Any spherical object
with finite size and brightness temperature can be reduced by this script.

In the 80-115 GHz range the spectral slope is about +0.1K/GHz
Variations are 205 +/- 8K (peak2peak 184 to 227) with a period of about 700 days.

Here's an example of ephemeris diameters for mars:
   https://astropixels.com/ephemeris/planets/mars2018.html
   https://astropixels.com/ephemeris/planets/mars2024.html

2018-05-17   13.0  13.04 x 12.96
2018-05-20   13.4  13.45 x 13.37
2018-06-08   16.5  16.51 x 16.41
2018-06-11   17.0  17.05 x 16.95

2024-08-31    6.5   6.52 x  6.48

"""


import os
import numpy as np
from scipy.optimize import leastsq
import matplotlib.pyplot as pl
#pl.ion()
pl.ioff()
from scipy.interpolate import griddata
from lmtslr.ifproc.ifproc import IFProc, IFProcData, IFProcCal
from lmtslr.grid.grid import Grid
from lmtslr.utils.ifproc_file_utils import lookup_ifproc_file

# command line parsing
from docopt import docopt
# import lmtslr.utils.convert as acv


def TD_resolved(TD,R,H):
    r = np.linspace(0.,R,2001)
    g = np.exp(-4.*np.log(2.)*r*r/H/H)
    w = np.ones(len(r))
    w[0] = 0.5
    w[-1]= 0.5
    result = 2.*np.pi*np.sum(w*r*g)*(r[1]-r[0])/np.pi/R/R * TD
    return result

def flux_density(fGHz,R,TD):
    result = 2.0*1.38e-23/3e8/3e8*fGHz*fGHz*1e18 * np.pi*R/206265*R/206265 *TD *1e26
    return(result)

def compute_model(v,xdata,ydata):
    """computes gaussian 2d model from x,y; added 3/15/18 for least squares fit to beam
       v is array with gaussian beam paramters: [peak, azoff, az_hpbw, eloff, el_hpbw]
       xdata is array with x positions
       ydata is array with y positions
    """
    model = v[0]*np.exp(-4.*np.log(2.)*((xdata-v[1])**2/v[2]**2+(ydata-v[3])**2/v[4]**2))
    return(model)

def compute_the_residuals(v,xdata,ydata,data):
    """computes residuals to gaussian 2d model; added 3/15/18 for least squares fit to beam
       v is array with gaussian beam paramters: [peak, azoff, az_hpbw, eloff, el_hpbw]
       xdata is array with x positions
       ydata is array with y positions
       data is array with map values to be fit
    """
    n = len(data)
    model = compute_model(v,xdata,ydata)
    residuals = data-model
    return(residuals)

av = docopt(_help, options_first=True, version=_version)
print(av)   # debug

obsnum   = int(av['--obsnum'])             #  121356
TMars    = float(av['--temperature'])      #  205
DMars    = float(av['--diameter'])         #  RMars = 6.52/2 # August 31 2024
RMars    = DMars / 2.0
numbanks = int(av['--numbanks'])           #  2 (before 2023 use 1)

print("mars_reduction:  %d  %g  %g" % (obsnum, TMars, DMars))

data_lmt = os.environ['DATA_LMT']       # @todo  get the official method?

datafile = lookup_ifproc_file(obsnum,         path=os.path.join(data_lmt, 'ifproc'))
data = IFProcData(datafile)
calfile  = lookup_ifproc_file(data.calobsnum, path=os.path.join(data_lmt, 'ifproc'))
cal = IFProcCal(calfile)

cal.compute_calcons()
cal.compute_tsys()

data.calibrate_data(cal)
data.create_map_data()
theGrid = Grid(data.receiver)
gx,gy = theGrid.azel(data.elev/180.*np.pi, data.tracking_beam)
    


pix_list = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
pix0_list = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
bank_list = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

if numbanks == 2:
    nbeams = 32
else:
    nbeams = 16

for icount in range(nbeams):
    pixel = pix_list[icount]
    bank = bank_list[icount]
    pixel0 = pix0_list[icount]


    freq = data.line_rest_frequency[bank]
    H = 1.15*3e8/1e9/freq/50*206265

    TD = TD_resolved(TMars,RMars,H)
    S = flux_density(freq,RMars,TD)
    TMAX = np.max(data.map_data[pixel,:])
    
    dist = np.sqrt( ( data.map_x[pixel,:] - gx[pixel0] )**2 + ( data.map_y[pixel,:] - gy[pixel0] )**2 )
    
    good = np.where(dist>20)[0]
    index = np.arange(0,len(data.map_data[pixel,:]))
    
    bfit = np.polyfit(index[good],data.map_data[pixel,good],4)
    bmodel = np.polyval(bfit,index)
    data.map_data[pixel,:] = data.map_data[pixel,:]-bmodel
    
    v0 = np.array([10, 0, 15, 0, 15])
    lsq_fit, lsq_cov, lsq_inf, lsq_msg, lsq_success = leastsq(compute_the_residuals, v0, args=(data.map_x[pixel,:]-gx[pixel0],data.map_y[pixel,:]-gy[pixel0],data.map_data[pixel,:]),full_output=1)
    model = compute_model(lsq_fit,data.map_x[pixel,:]-gx[pixel0],data.map_y[pixel,:]-gy[pixel0])
    residuals = compute_the_residuals(lsq_fit, data.map_x[pixel,:]-gx[pixel0],data.map_y[pixel,:]-gy[pixel0],data.map_data[pixel,:])
    chisq = np.dot(residuals.transpose(),residuals)
    lsq_err = np.sqrt(np.diag(lsq_cov)*chisq/(len(data.map_data)-5))
    labels = ['AMP ','XOFF','XHPW','YOFF','YHPW']
#    for i in range(5):
#        print('%s %5.2f %5.2f'%(labels[i],lsq_fit[i],lsq_err[i]) )
        
    JyK = S/lsq_fit[0]
    eta = 2.0*1.38e-23*lsq_fit[0]/np.pi/25/25/S*1e26
    
    print('%2d %6.2f %5.1f %5.1f %5.2f %5.2f %5.2f %5.2f %5.3f %5.2f %5.2f  %4.1f %4.1f %4.1f %4.1f  %5.1f %5.1f %5.1f %5.1f'%(pixel, freq, TMars, TD, RMars, H, S, JyK, eta,lsq_fit[0],lsq_err[0],lsq_fit[1],lsq_err[1],lsq_fit[3],lsq_err[3],lsq_fit[2],lsq_err[2],lsq_fit[4],lsq_err[4]))

    
    pl.figure(figsize=(16,8))
    pl.subplot(1,2,1)
    pl.plot(data.map_data[pixel,:],label='Data')
    pl.plot(model,label='Model')
    pl.plot(residuals-2,label='Residuals-2')
    pl.xlabel('Sample')
    pl.ylabel('TA* (K)')
    pl.title('Pixel %d  T=%6.2f Jy/K=%5.2f eta=%5.3f'%(pixel,lsq_fit[0],JyK,eta))
    pl.legend()
    # do the map
    pl.subplot(1,2,2)

    map_region = np.array([-30,30,-30,30])
    show_points = True
    grid_spacing = 3.5

    xi,yi = np.mgrid[map_region[0]:map_region[1]:grid_spacing,
                     map_region[2]:map_region[3]:grid_spacing]
    
    # x,y swap in grid
    zi = griddata((data.map_x[pixel,:]-gx[pixel0], data.map_y[pixel]-gy[pixel0]), data.map_data[pixel,:],(yi, xi), method='linear')
    pl.imshow(zi, interpolation='bicubic', cmap=pl.cm.jet, origin='lower',
              extent=map_region)
    pl.xlabel('X (")')
    pl.ylabel('Y (")')
    pl.title('%5.2f  %4.1f %4.1f  %5.1f %5.1f'%(lsq_fit[0],lsq_fit[1],lsq_fit[3],lsq_fit[2],lsq_fit[4]))
    pl.axis('equal')
    if show_points:
        pl.plot(data.map_x[pixel,:]-gx[pixel0],data.map_y[pixel,:]-gy[pixel0],'k.')
        pl.axis(map_region)
        pl.colorbar()

    pl.savefig('mars_%d_%d.png'%(pixel,bank))
