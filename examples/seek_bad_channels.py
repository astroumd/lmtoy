#! /usr/bin/env python
# seek_bad_channels.py
# This is the bad channel searcher
#
# F P Schloerb 
# March 4, 2014
#
# Revision 2014-03-04: Fixed problem with variable for number of channels.  Now always do 256 channels
#          2021-02-23: Converted for dreampy3/python3
#
#
# Possible CLI:
#
#    seek_bad_channels [-f obslist] [-p plot_max] [-b bc_threshold] [obsnum ....]

import os
import sys
import glob
import numpy
from matplotlib import pyplot as pl
from dreampy3.redshift.netcdf import RedshiftNetCDFFile


def rmsdiff(data):
    """   guess the RMS based on a robust neighbor differences
    """
    d = data[1:]-data[:-1]
    return d.std()/1.41421


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
nchan = 256
chassis_list = (0,1,2,3) # CHASSIS IDENTIFIERS
nboards = 6
board_list = (0,1,2,3,4,5) # BOARD (NOT FREQUENCY BAND) IDENTIFIERS 

# The program produces a plot showing the maximum value of the standard deviation
# for each channel.  You can set the maximum for the y axis in the plots (10 is good) 
plot_max = 10

# set the threshold for a bad channel (3 is not bad, but look at plot and experiment!)
bc_threshold = 3.0

# more debugging output ?
debug = True

# now ready to process.  First read in the data from the file or commandline

if True:
    # simply a list of obsnum via commandline, dates are not needed
    o_list = []
    for arg in sys.argv[1:]:
        o_list.append(int(arg))
    if len(o_list) == 0:
        print("ERROR: provide an obsnum list on the commandline, e.g. 33551")
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
findmax = numpy.zeros((nchassis,nboards,nchan))
# set up an array to hold obsnum for the maximum value
scanmax = numpy.zeros((nchassis,nboards,nchan))

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
        if nb != nboards:
            print("WARNING: nb",nb)
        if nch != nchan:
            print("WARNING: nch",nch)
        acf_diff = numpy.zeros((nons,nchan))
        for ib in range(nboards):
            board = board_list[ib]
            # we load in the data for each "On" ACF
            for on in range(nons):
                acf_diff[on,:] = nc.hdu.data.AccData[on,board,:]/nc.hdu.data.AccSamples[on,board]
            for chan in range(nchan):
                sigma = numpy.std(acf_diff[:,chan])
                # if the rms for this channel is bigger than previous maximum, save it
                if sigma>findmax[ic,ib,chan]:
                    scanmax[ic,ib,chan] = o_list[iobs]
                    findmax[ic,ib,chan] = sigma
            if debug:
                for chan in range(nchan):
                    if findmax[ic,ib,chan] > bc_threshold:
                        print("#    ",ic,ib,chan)
                        print('CHAN-',numpy.std(acf_diff[:,chan-1]), acf_diff[:,chan-1])
                        print('CHAN.',numpy.std(acf_diff[:,chan+0]), acf_diff[:,chan+0])
                        print('CHAN+',numpy.std(acf_diff[:,chan+1]), acf_diff[:,chan+1])
        # close the data file for this chassis
        nc.sync()
        nc.close()
        del nc

# make plot and report results
#pl.ion()
pl.figure(num=1,figsize=(12,8))
#pl.clf()

print(' ')
print('Bad Channel Threshold = %6.1f'%(bc_threshold))
print('-----------------------')
print(' c  b  ch   scan metric')
print('-----------------------')
ftab = open('rsr.lags.bad','w')


# fix the colors so they correspond to the colors as ordered by band in waterfall plot
# @todo alternatively, order the columns so they are in the correct order band order, not board order

colors = pl.rcParams['axes.prop_cycle'].by_key()['color']
b2b = [0, 2, 1, 3, 5, 4]
#colors = [c[b2b[0]], c[b2b[1]], c[b2b[2]], c[b2b[3]], c[b2b[4]], c[b2b[5]]]

peaks = []
for ic in range(nchassis):
    for ib1 in range(nboards):
        #ib = board2band[ib1]
        ib = ib1
        for chan in range(nchan):
            # check the value of the standard deviation against threshold and print if above threshold
            if findmax[ic,ib,chan] > bc_threshold:
                msg = '%2d %2d %3d %6d %6.1f'%(chassis_list[ic],board_list[ib],chan,scanmax[ic,ib,chan],findmax[ic,ib,chan])
                print(msg)
                ftab.write("%s\n" % msg)
                peaks.append((ic,ib,chan))

#  patch away the bad lags
if False:
    for p in peaks:
        ic = p[0]
        ib = p[1]
        chan = p[2]
        findmax[ic,ib,chan] =  (findmax[ic,ib,chan-1] +   findmax[ic,ib,chan-1])/2
plot_max = bc_threshold


if debug:
    for ic in range(nchassis):
        for ib in range(nboards):
            print('RMS_diff %2d %2d  %.3f' % (ic,ib,rmsdiff(findmax[ic,ib,:])))


# for each chassis and each board, we plot maximum standard deviations found for all channels
for ic in range(nchassis):
    for ib1 in range(nboards):
        #ib = board2band[ib1]
        ib = ib1
        plot_index = nboards*ic+ib+1
        ax = pl.subplot(nchassis,nboards,plot_index)
        #ax.tick_params(axis='both',which='major',labelsize=6)
        #ax.tick_params(axis='both',which='minor',labelsize=6)
        pl.plot(findmax[ic,ib,:], c=colors[ib])
        # pl.title('chassis=%d board=%d'%(chassis_list[ic],board_list[ib]),fontsize=6)
        pl.title('chassis=%d band=%d'%(chassis_list[ic],board_list[b2b[ib]]),fontsize=6)        
        pl.axis([-10,nchan+10,0,plot_max])
        if ic==nchassis-1 and ib==0:
            pl.xlabel("Channel")
            pl.ylabel("ACF_sigma (%d sampled)" % nons)

print('-----------------------')
ftab.close()


pl.savefig('sbc.png')
print("Wrote sbc.png")
# pl.show()

