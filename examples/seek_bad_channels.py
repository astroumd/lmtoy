#! /usr/bin/env python
# seek_bad_channels.py
# This is the bad channel searcher
#
# F P Schloerb 
# March 4, 2014
#
# Revision 2014-03-04: Fixed problem with variable for number of channels.  Now always do 256 channels
#          2021-02-23: Converted for dreampy3/python3

import os
import sys
import glob
import numpy
from matplotlib import pyplot as pl
from dreampy3.redshift.netcdf import RedshiftNetCDFFile

if 'DATA_LMT' in os.environ:
    data_lmt = os.environ['DATA_LMT']
else:
    data_lmt = '/data_lmt'
    
# The bad channel searcher reviews a set of scans to find channels
# with unusually large variations in the ACF for the set of "On"
# spectra associated with a typical BS observation.
# For each scan we look at all the ON spectra and compute the 
# standard deviation of every channel in the spectrometer.
# Bad channels have unusually large standard deviations and may be identified.

# The scans to be reviewed are given in a simple text file containing
# the date and the observation number for each one. 


# Here is the list of chassis and boards to review
# You can specify any number with chassis and board id's in a list
nchassis = 4
chassis_list = (0,1,2,3) # CHASSIS IDENTIFIERS
nboards = 6
board_list = (0,1,2,3,4,5) # BOARD (NOT FREQUENCY BAND) IDENTIFIERS 

# The program produces a plot showing the maximum value of the standard deviation
# for each channel.  You can set the maximum for the y axis in the plots (10 is good) 
plot_max = 10

# set the threshold for a bad channel (3 is not bad, but look at plot and experiment!)
bc_threshold = 3.0


# now ready to process.  First read in the data from the file or commandline

if True:
    # simply a list of obsnum via commandline
    o_list = []
    for arg in sys.argv[1:]:
        o_list.append(int(arg))
    if len(o_list) == 0:
        print("Provide obsnum list on the commandline")
        sys.exit(0)
    print('read obsnum %d observations\n'%(len(o_list)))
    
else:
    # This is the name of file with date and obsnum for scans we wish to review
    the_filename = 'testfile.lis'
    # the data format has two columns: date and obsnum, one observation per line 
    lfile = open(the_filename,'r')
    lc = 0
    date_list = []
    o_list = []
    for line in lfile:
        if line[0]=='#':
            continue
        lc = lc+1
        ss = line.split()
        date_list.append(ss[0])
        o_list.append(int(ss[1]))
    lfile.close()
    print('read file: %s  %d observations\n'%(the_filename,len(o_list)))

# set up an array to hold the maximum values of std dev for a channel
findmax = numpy.zeros((nchassis,nboards,256))
# set up an array to hold obsnum for the maximum value
scanmax = numpy.zeros((nchassis,nboards,256))

# now we will go through all the scans and compute rms for each channel
for iobs in range(len(o_list)):
    #print('%2d %s %6d'%(iobs+1,date_list[iobs],o_list[iobs]))
    print('%2d %6d'%(iobs+1,o_list[iobs]))
    for ic in range(nchassis):
        chassis = chassis_list[ic]
        # open the data file for this chassis
        # glob for filenames like RedshiftChassis?/RedshiftChassis?_*_016975_00_0001.nc
        globs = data_lmt + '/RedshiftChassis%d/RedshiftChassis%d_*_%06d_00_0001.nc' % (chassis, chassis, o_list[iobs])
        fn = glob.glob(globs)
        print("Found ",fn)
        if len(fn) != 1:
            print("Unexpected obsnum %06d " % o_list[iobs])
            sys.exit(0)
        nc = RedshiftNetCDFFile(fn[0])
        # nc = RedshiftNetCDFFile(data_lmt + '/RedshiftChassis%d/RedshiftChassis%d_*_%06d_00_0001.nc' % (chassis, chassis, date_list[iobs],o_list[iobs]))
        nons,nb,nch = numpy.shape(nc.hdu.data.AccData)
        acf_diff = numpy.zeros((nons,256))
        for ib in range(nboards):
            board = board_list[ib]
            # we load in the data for each "On" ACF
            for on in range(nons):
                acf_diff[on,:] = nc.hdu.data.AccData[on,board,:]/nc.hdu.data.AccSamples[on,board]
            for chan in range(256):
                sigma = numpy.std(acf_diff[:,chan])
                # if the rms for this channel is bigger than previous maximum, save it
                if sigma>findmax[ic,ib,chan]:
                    scanmax[ic,ib,chan] = o_list[iobs]
                    findmax[ic,ib,chan] = sigma
        # close the data file for this chassis
        nc.sync()
        nc.close()
        del nc

# make plot and report results
pl.ion()
pl.figure(num=1,figsize=(12,8))
pl.clf()

print(' ')
print('Bad Channel Threshold = %6.1f'%(bc_threshold))
print('-----------------------')
print(' c  b  ch   scan metric')
print('-----------------------')

# for each chassis and each board, we plot maximum standard deviations found for all channels
for ic in range(nchassis):
    for ib in range(nboards):
        plot_index = nboards*ic+ib+1
        ax = pl.subplot(nchassis,nboards,plot_index)
        #ax.tick_params(axis='both',which='major',labelsize=6)
        #ax.tick_params(axis='both',which='minor',labelsize=6)
        pl.plot(findmax[ic,ib,:])
        pl.title('chassis=%d board=%d'%(chassis_list[ic],board_list[ib]),fontsize=6)
        pl.axis([-10,265,0,plot_max])
        for chan in range(256):
            # check the value of the standard deviation against threshold and print if above threshold
            if findmax[ic,ib,chan] > bc_threshold:
                print('%2d %2d %3d %6d %6.1f'%(chassis_list[ic],board_list[ib],chan,scanmax[ic,ib,chan],findmax[ic,ib,chan]))

print('-----------------------')

pl.savefig('sbc.png')
#pl.show()
