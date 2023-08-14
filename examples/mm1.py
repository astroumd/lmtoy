#! /usr/bin/env python
#
#  Create a few moment (0,1,2) maps based on the maskmoment module
#
#  based on the notebook example/N4047_examples.ipyn (Tony Wong)
#  adapted for LMT pipeline results
#  Also writes a README.html for web summary pages

_version = "14-aug-2023"

_help = """Usage: mm1.py [options] FITS_FILE

-v --vlsr VLSR      The expected VLSR of the signal
-b --beam BEAM      Smooth beam to be used
-h --help           Give this help
--version           Report version

mm1.py uses the maskmoment package to find signal, and construct
moments 0,1 and 2 maps. It also computes a global spectrum for
the whole field.
"""



import os
import sys
import maskmoment

from astropy.io import fits
from astropy.table import Table
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore")
from docopt import docopt

def quadplot(basename, extmask=None):
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(12,12))
    mom0 = fits.getdata(basename+'.mom0.fits.gz')
    ax1.imshow(mom0,origin='lower',cmap='CMRmap')
    ax1.set_title(basename+' - Moment 0',fontsize='x-large')
    mom1 = fits.getdata(basename+'.mom1.fits.gz')
    ax2.imshow(mom1,origin='lower',cmap='jet')
    ax2.set_title(basename+' - Moment 1',fontsize='x-large')
    mom2 = fits.getdata(basename+'.mom2.fits.gz')
    ax3.imshow(mom2,origin='lower',cmap='CMRmap')
    ax3.set_title(basename+' - Moment 2',fontsize='x-large')
    if extmask is None:
        mask = np.sum(fits.getdata(basename+'.mask.fits.gz'),axis=0)
    else:
        mask = np.sum(fits.getdata(extmask),axis=0)
    ax4.imshow(mask,origin='lower',cmap='CMRmap_r')
    ax4.set_title('Projected Mask',fontsize='x-large')
    plt.subplots_adjust(hspace=0.15,wspace=0.15)
    plt.savefig(basename + ".png")
    #plt.show()
    return

def help(cmd):
        print("Usage: %s cube.fits [vlsr]" % cmd)
        print("Will create a new subdirectory")
        sys.exit(0)

if __name__ == "__main__":
    av = docopt(_help, options_first=True, version='mm1.py %s' % _version)
    vlsr =  av['--vlsr']
    if vlsr != None:
        vlsr = float(vlsr)
    beam2 = av['--beam']
    if beam2 == None:
        beam2 = 15.0       # for LMT
    else:
        beam2 = float(beam2)        
    ff = av['FITS_FILE']

    if not os.path.exists(ff):
        print("File %s does not exist" % ff)
        help(sys.argv[0])        
    if ff.find('.fits') < 0:
        print("Can only handle .fits files:",ff)
        help(sys.argv[0])        

    dname = ff.replace('.fits','.mm')
    os.makedirs(dname, exist_ok=True)
    os.chdir(dname)
    if not os.path.exists(ff):
        os.symlink("../" + ff, ff)

    gal  = ff
    cube = ff
    mout = ff
    print("cube:  ",cube)
    print("vlsr:  ",vlsr)
    print("beam2: ",beam2)

    # example 0:
    maskmoment.maskmoment(img_fits=cube,
                          snr_hi=4, snr_lo=2, minbeam=2, snr_lo_minch=2,
                          outname="%s.dilmsk" % mout)
    fn1 = "%s.dilmsk" % mout
    quadplot(fn1)

    # example 1:
    maskmoment.maskmoment(img_fits=cube,
                          snr_hi=5, snr_lo=2, minbeam=2, nguard=[2,0],
                          outname='%s.dilmskpad' % mout)
    fn2 = "%s.dilmskpad" % mout
    quadplot(fn2)

    # example 2:
    maskmoment.maskmoment(img_fits=cube,
                          snr_hi=3, snr_lo=3, fwhm=beam2, vsm=None, minbeam=2,
                          outname='%s.smomsk' % mout)
    fn3 = "%s.smomsk" % mout
    quadplot(fn3)

    # example 3
    maskmoment.maskmoment(img_fits=cube,
                          snr_hi=4, snr_lo=2, fwhm=beam2, vsm=None, minbeam=2,
                          output_2d_mask=True,                   
                          outname='%s.dilsmomsk' % mout) 
    fn4 = "%s.dilsmomsk" % mout
    quadplot(fn4)

    # example 4
    maskmoment.maskmoment(img_fits=cube,
                          rms_fits='%s.dilmsk.ecube.fits.gz' % gal,
                          mask_fits='%s.dilsmomsk.mask2d.fits.gz' % gal,
                          outname='%s.msk2d' % mout)
    # error: No such file or directory: 'NGC0001.msk2d.mask.fits.gz'
    # quadplot("%s.msk2d" % mout)        
    # flux comparisons
    ex0 = Table.read('%s.dilmsk.flux.csv'    % mout, format='ascii.ecsv')
    ex1 = Table.read('%s.dilmskpad.flux.csv' % mout, format='ascii.ecsv')
    ex2 = Table.read('%s.smomsk.flux.csv'    % mout, format='ascii.ecsv')
    ex3 = Table.read('%s.dilsmomsk.flux.csv' % mout, format='ascii.ecsv')
    ex4 = Table.read('%s.msk2d.flux.csv'     % mout, format='ascii.ecsv')
    fig = plt.figure(figsize=[8,5.5])
    plt.step(ex0['Velocity'],ex0['Flux'],color='r',label='dilmsk')
    plt.step(ex1['Velocity'],ex1['Flux'],color='b',label='dilmskpad')
    plt.step(ex2['Velocity'],ex2['Flux'],color='g',label='smomsk')
    plt.step(ex3['Velocity'],ex3['Flux'],color='k',label='dilsmomsk')
    #plt.step(ex4['Velocity'],ex4['Flux'],color='orange',label='msk2d')
    plt.legend(fontsize='large')
    plt.xlabel(ex0['Velocity'].description+' ['+str(ex0['Velocity'].unit)+']',fontsize='x-large')
    plt.ylabel(ex0['Flux'].description+' ['+str(ex0['Flux'].unit)+']',fontsize='x-large')
    if vlsr != None:
        ax = plt.gca()
        fmax = ax.get_ylim()[1]
        print("VLSR=",vlsr," Fmax=",fmax)
        plt.arrow(vlsr,fmax,0.0,-0.5*fmax,
                  head_width=20, head_length=0.1*fmax,
                  length_includes_head=True, facecolor='red')
        plt.annotate('VLSR', xy=(vlsr, fmax), multialignment='center')
    fn5 = "%s.flux.png" % mout
    plt.savefig(fn5)
    #plt.show()

    # write a entry for the summary web pages

    fp = open('README.html','w')
    fp.write("<H1> %s: maskmoment with vlsr=%s </H1>\n" % (cube, str(vlsr)))
    fp.write("See also <A HREF=https://github.com/tonywong94/maskmoment>https://github.com/tonywong94/maskmoment</A> ")
    fp.write("for more information on <B>maskmoment</B>")
    fp.write("<OL>\n");
    fp.write("<LI> Flux summary                          <br> <IMG SRC=%s>\n" % (fn5))
    fp.write("<LI> Flux in central pixel (pipeline)      <br> <IMG SRC=../spectrum_0_zoom.png>\n")
    fp.write("<LI> <B>dilmsk:</B>    Dilated Mask        <br> <IMG SRC=%s.png>\n" % (fn1))
    fp.write("<LI> <B>dilmskpad:</B> Dilated Mask Padded <br> <IMG SRC=%s.png>\n" % (fn2))
    fp.write("<LI> <B>smomsk:</B>    Smoothed Mask       <br> <IMG SRC=%s.png>\n" % (fn3))
    fp.write("<LI> <B>dilsmomsk:</B> Dilated Smooth Mask <br> <IMG SRC=%s.png>\n" % (fn4))
    fp.write("</OL>\n");
    fp.close()
