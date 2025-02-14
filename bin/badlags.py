#! /usr/bin/env python
# 
# This is the bad lag searcher, formerly called seek_bad_channels.py
#
# It does two things:
#     - identify lags where the RMS in QAC is too high or too low
#     - @todo: lags that are obviously spiky
#     - identify Chassic/Board combos that should be flagged alltogether
#       (the same as badcb= keyword to the pipeline)
#
# F P Schloerb   March 4, 2014   (as seek_bad_channels.py)
# P Teuben       2021/2022 various changes for SLpipeline integration (as badlags.py)
#
# Revision 2014-03-04: Fixed problem with variable for number of channels.  Now always do 256 channels
#          2021-02-23: Converted for dreampy3/python3
#          2021-10-28: write badlags file. use docopt for CLI parsing
#          2021-11-30: better labeling, rms_diff masking ?
#          2021-12-01: renamed to badlags.py
#          2022-05-18: also flag when rms < bc_lo
#          2023-02-02: implemented proper flags using docopt
#          2023-02-22: --plotmax 
#          2024-11-04: fix plotting (and missing the badlags file in pipeline)
#
#

_version = "4-nov-2024"

_help = """Usage: badlags.py [options] OBSNUM

Options:
  -y PLOTFILE                   Plotfile to save, instead of default interactive plot. Optional
  -p --plotmax PLOTMAX          Plot max. If not given, the bc_hi THRESHOLD is used. Optional
  -B --badlags BADLAGS          Output badlags file, if desired. [Default: rsr.badlags]
  -e                            Don't use edge detection, by default it will.
  --bc_hi HIGH                  Above this value, lags are flagged bad [Default: 2.5]
  --bc_lo LOW                   Below this value, lags are flagged bad [Default: 0.01]
  --spike SPIKE                 Threshold above which spikes are flagged as bad channel [Default: 3.0]
  --short_hi SHIGH              Above this value, lags under SMIN are flagged [Default: 2.5]
  --short_min SMIN              Lags below SMIN get special treatment and are allowed different threshold [Default: 256]
  --min_chan MINCHAN            No blabla below this channel [Default: 32]
  --rms_min RMIN                Minimum RMS to accept a C/B [Default: 0.01]
  --rms_max RMAX                Maximum RMS to accept a C/B [Default: 0.2]

  -h --help                     show this help
  -d --debug                    add some debug
  -v --version                  show version

A badlags file can be optionally passed in. It will be a file where the first 3 columns
are tuples of Chassis,Board,Channel that is deemed a bad channel.

The odd combination (short_hi, short_min) is used for strong continuum, where the short lags will have a larger
variation than (bc_hi) but should still be allowed.


"""


import os
import sys
import glob
import numpy as np
from docopt import docopt
# from matplotlib import pyplot as pl
# dreampy3 is loaded below after commandline parser did its job

def rmsdiff(data, robust=True):
    """   guess the RMS based on a robust neighbor differences
    """
    if robust:
        factor = 2.0
        Q1 = np.percentile(data,25)
        Q3 = np.percentile(data,75)
        IQR = (Q3-Q1) * factor
        qs = (Q1 - IQR, Q3 + IQR)
        data0 = data[np.where((data >= qs[0]) & (data <= qs[1]))]
        d = data0[1:]-data0[:-1]
    else:
        d = data[1:]-data[:-1]
    return d.std()/1.41421

av = docopt(_help, options_first=True, version='badlags.py %s' % _version)
Qdebug = av['--debug']
if Qdebug:
    print(av)

data_lmt = os.environ['DATA_LMT']
    
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
nchassis     = 4
nboards      = 6
nchan        = 256
chassis_list = (0,1,2,3)     # CHASSIS IDENTIFIERS
board_list   = (0,1,2,3,4,5) # BOARD (NOT FREQUENCY BAND) IDENTIFIERS


# set the threshold for a bad channel (3 is not bad, but look at plot and experiment!)
#     -at short lags the RMS is often (naturally) higher. Cutting out those can result in bad spectra
#     -or use min_chan
bc_hi = float(av['--bc_hi'])
bc_lo = float(av['--bc_lo'])

# special short lag treatment?
short_hi = float(av['--short_hi'])
short_min = int(av['--short_min'])

# spike threshold (doesn't seem to work too well, often works bad on short lags)
spike_threshold = float(av['--spike'])
Qspike = spike_threshold > 0

# min RMS_diff needed for full acceptance of a C/B pair
rms_min = float(av['--rms_min'])
rms_max = float(av['--rms_max'])

# where to start checking for bad lags
min_chan = float(av['--min_chan'])



# showing interactive plot/
plotfile = av['-y']

# also trying to detect high end edge?
Qedge = not av['-e']

# plotting max
if av['--plotmax'] == None:
    plot_max = bc_hi
else:
    plot_max = float(av['--plotmax'])

# the obsnum (just one is accepted now, though we used to allow to process more)
o_list = [int(av['OBSNUM'])]

#  filenames   
badlags = av['--badlags']  
# lagsplot = 'badlags.png'

    
if False:
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

# since this code executes, load it later
from dreampy3.redshift.netcdf import RedshiftNetCDFFile

# set up an array to hold the maximum values of std dev for a channel
findmax = np.zeros((nchassis,nboards,nchan))
findmin = np.ones((nchassis,nboards,nchan)) * 999
# set up an array to hold obsnum for the maximum value
scanmax = np.zeros((nchassis,nboards,nchan))

# now we will go through all the scans and compute rms for each channel
for iobs in range(len(o_list)):
    #print('%2d %s %6d'%(iobs+1,date_list[iobs],o_list[iobs]))
    print('%2d %6d'%(iobs+1,o_list[iobs]))
    valid_chassis = []
    for ic in range(nchassis):
        chassis = chassis_list[ic]
        # open the data file for this chassis
        # glob for filenames like RedshiftChassis?/RedshiftChassis?_*_016975_00_0001.nc
        globs = data_lmt + '/RedshiftChassis%d/RedshiftChassis%d_*_%06d_00_0001.nc' % (chassis, chassis, o_list[iobs])
        fn = glob.glob(globs)
        if Qdebug:
            print("Found ",fn)
        if len(fn) != 1:
            print("Skipping missing chassis %d for obsnum %06d" % (chassis,o_list[iobs]))
            continue
            # sys.exit(0)
        valid_chassis.append(chassis)        
        nc = RedshiftNetCDFFile(fn[0])
        # nc = RedshiftNetCDFFile(data_lmt + '/RedshiftChassis%d/RedshiftChassis%d_*_%06d_00_0001.nc' % (chassis, chassis, date_list[iobs],o_list[iobs]))
        nons,nb,nch = np.shape(nc.hdu.data.AccData)
        if nb != nboards:
            print("WARNING: nb",nb)
        if nch != nchan:
            print("WARNING: nch",nch)
        acf_diff = np.zeros((nons,nchan))
        for ib in range(nboards):
            board = board_list[ib]
            # we load in the data for each "On" ACF
            for on in range(nons):
                acf_diff[on,:] = nc.hdu.data.AccData[on,board,:]/nc.hdu.data.AccSamples[on,board]
            for chan in range(nchan):
                sigma = np.std(acf_diff[:,chan])
                # if the rms for this channel is bigger than previous maximum, save it
                if sigma>findmax[ic,ib,chan]:
                    scanmax[ic,ib,chan] = o_list[iobs]
                    findmax[ic,ib,chan] = sigma
                if sigma<findmin[ic,ib,chan]:
                    findmin[ic,ib,chan] = sigma
            if Qdebug:
                for chan in range(1,nchan-1):
                    if findmax[ic,ib,chan] > bc_hi:
                        print("#    ",ic,ib,chan)
                        print('CHAN-',np.std(acf_diff[:,chan-1]), acf_diff[:,chan-1])
                        print('CHAN.',np.std(acf_diff[:,chan+0]), acf_diff[:,chan+0])
                        print('CHAN+',np.std(acf_diff[:,chan+1]), acf_diff[:,chan+1])
        # close the data file for this chassis
        nc.sync()
        nc.close()
        del nc

obsnum = o_list[0]        

# make plot and report results
#pl.ion()
#pl.figure(num=1,figsize=(12,8))
#pl.clf()

import matplotlib
if plotfile == None:
    matplotlib.use('qt5agg')
else:
    # if the next statement was not used on unity, occasionally it would fine Qt5Agg, and thus fail
    # this else clause is NOT used in rsr_tsys.py, which has the same patters as this routine, and
    # never failed making a Tsys plot, go figure unity!
    matplotlib.use('agg')
import matplotlib.pyplot as pl
print('mpl backend spectra',matplotlib.get_backend())

pl.figure(num=1,figsize=(12,8))


print(' ')
print('Bad Channel High Threshold = %6.1f'%(bc_hi))
print('-----------------------')
print(' c  b  ch   scan metric')
print('-----------------------')

ftab = open('rsr.badlags','w')
ftab.write('# File written by %s - version %s\n' % (sys.argv[0],_version))
ftab.write('# Bad Channel Thresholds:  RMS < %g or RMS > %g\n' % (bc_lo,bc_hi))
ftab.write("# Short Channel Threshold:  RMS > %g for lags < %d\n" % (short_hi, short_min))
ftab.write('# Spike trigger: %g\n' % spike_threshold)
ftab.write('# Min Channel: %d\n' % (min_chan))
ftab.write('# Edge: %s\n' % Qedge)
ftab.write('# Note these are chassis/board/channel numbers\n')
ftab.write('# -----------------------\n')
ftab.write('#  c  b  ch   scan metric\n')
ftab.write('# -----------------------\n')


# fix the colors so they correspond to the colors as ordered by band in waterfall plot
# @todo alternatively, order the columns so they are in the correct order band order, not board order

colors = pl.rcParams['axes.prop_cycle'].by_key()['color']
b2b = [0, 2, 1, 3, 5, 4]
#colors = [c[b2b[0]], c[b2b[1]], c[b2b[2]], c[b2b[3]], c[b2b[4]], c[b2b[5]]]

count_min = 0
count_max = 0
count_spike = 0

peaks = []
for ic in range(nchassis):
    for ib1 in range(nboards):
        #ib = board2band[ib1]
        ib = ib1
        for chan in range(nchan):
            # check the value of the standard deviation against threshold and print if above threshold
            if findmax[ic,ib,chan] > bc_hi:
                if chan < short_min and findmax[ic,ib,chan] < short_hi:
                    continue
                msg = '%2d %2d %3d %6d %6.1f    # max'%(chassis_list[ic],board_list[ib],chan,scanmax[ic,ib,chan],findmax[ic,ib,chan])
                print(msg)
                ftab.write("%s\n" % msg)
                peaks.append((ic,ib,chan))
                count_max = count_max + 1
                continue
            if findmin[ic,ib,chan] < bc_lo:
                msg = '%2d %2d %3d %6d %6.1f    # min'%(chassis_list[ic],board_list[ib],chan,scanmax[ic,ib,chan],findmin[ic,ib,chan])
                print(msg)
                ftab.write("%s\n" % msg)
                peaks.append((ic,ib,chan))
                count_min = count_min + 1
                continue
            if Qspike:   #  and chan > min_chan+1 and chan < nchan-2:
                if chan==0: continue
                if chan == nchan-1:
                    what = 'spike edge'
                    n1 = findmax[ic,ib,chan-1]
                else:
                    what = 'spike'                    
                    n1 = 0.5 * (findmax[ic,ib,chan-1]+findmax[ic,ib,chan+1])
                n2 = findmax[ic,ib,chan]
                if n2/n1 > spike_threshold:
                    if chan > min_chan+1 and chan < nchan-2:
                        comment=''
                        peaks.append((ic,ib,chan))
                        count_spike = count_spike + 1
                    else:
                        comment='# '
                    msg = '%s%2d %2d %3d %6d %6.1f %6.1f   # %s'%(comment,chassis_list[ic],board_list[ib],chan,scanmax[ic,ib,chan],findmin[ic,ib,chan],n2/n1,what)
                    print(msg)
                    ftab.write("%s\n" % msg)
                    

# report findins
print("Found %d min, %d max and %d spike badlags" % (count_min, count_max, count_spike))

if Qdebug:
    for ic in range(nchassis):
        for ib in range(nboards):
            rms0 = rmsdiff(findmax[ic,ib,:])
            if rms0 < rms_min or rms0 > rms_max:
                note = '*** bad c/b'
            else:
                note = ''
            print('RMS_diff %2d %2d  %.3f %s' % (ic,ib,rms0,note))
            

label="badcb="
# for each chassis and each board, we plot maximum standard deviations found for all channels
ftab.write("# rms_min/max = %g %g\n" % (rms_min,rms_max))
nbadcb = 0
for ic in range(nchassis):
    for ib1 in range(nboards):
        #ib = board2band[ib1]
        ib = ib1
        plot_index = nboards*ic+ib+1
        ax = pl.subplot(nchassis,nboards,plot_index)
        #
        #
        rms0 = rmsdiff(findmax[ic,ib,:])
        if rms0 < rms_min or rms0 > rms_max:
            nbadcb = nbadcb + 1
            pl.plot(findmax[ic,ib,:], c='black')
            pl.title('BAD chassis=%d band=%d'%(chassis_list[ic],board_list[b2b[ib]]),fontsize=6,color='red')
            ftab.write("#BADCB %d %d %d %g badlags\n" % (obsnum,ic,ib,rms0))
            label = label + "%d/%d," % (ic,ib)
            
        else:
            pl.plot(findmax[ic,ib,:], c=colors[ib])
            pl.title('chassis=%d band=%d'%(chassis_list[ic],board_list[b2b[ib]]),fontsize=6)                    
        # pl.title('chassis=%d board=%d'%(chassis_list[ic],board_list[ib]),fontsize=6)
        # pl.axis([-10,nchan+10,0,plot_max])
        for p in peaks:
            if ic == p[0] and ib == p[1]:
                pl.plot([p[2],p[2]], [0.0, 0.2], '-', color='black')
                    
        
        ax.set(xlim=(-10, nchan+10), ylim=(0,plot_max))
        ax.set(xticks=(0,64,128,192,256))
        if ib==0 and ic==nchassis-1:
            pl.xlabel("Lag Channel")
            pl.ylabel("$\sigma_{ACF}$")
            ax.tick_params(axis='both',which='major',labelsize=6)
            ax.tick_params(axis='both',which='minor',labelsize=6)
        elif ib==0 and ic < nchassis-1:
            ax.tick_params(axis='y',which='major',labelsize=6)
            ax.tick_params(axis='y',which='minor',labelsize=6)
            ax.tick_params(axis='x',which='major',labelsize=0)
            ax.tick_params(axis='x',which='minor',labelsize=0)
        elif ib>0 and ic==nchassis-1:
            ax.tick_params(axis='y',which='major',labelsize=0)
            ax.tick_params(axis='y',which='minor',labelsize=0)
            ax.tick_params(axis='x',which='major',labelsize=6)
            ax.tick_params(axis='x',which='minor',labelsize=6)
        else:
            ax.tick_params(axis='both',which='major',labelsize=0)
            ax.tick_params(axis='both',which='minor',labelsize=0)


if len(o_list) > 1:
    omore = "... %d" % o_list[len(o_list)-1]
else:
    omore = ""
#pl.suptitle("RMS in Auto Correlation Function as function of lag channels (%d samples) obsnum=%d %s" % (nons,obsnum,omore))
pl.suptitle("obsnum=%d %s" % (obsnum,label))
print("obsnum=%d %s" % (obsnum,label))
print('-----------------------')
ftab.write("# Found %d min, %d max, %d spike badlags and %d bad C/B's\n" % (count_min, count_max, count_spike, nbadcb))
ftab.close()
print("Wrote %s" % badlags)
print("Found %d bad Chassis/Board's" % nbadcb)

if plotfile == None:
    pl.show()
else:
    pl.savefig(plotfile)
    print("Wrote %s" % plotfile)

if len(o_list) > 1:
    print("Warning: this program is not meant to be used with multiple obsnums")

