#! /usr/bin/env python
#
#

import os
import sys
import aplpy
import argparse


parser = argparse.ArgumentParser(description="Simple color plot of a FITS image",
                                 formatter_class=argparse.RawTextHelpFormatter)
                                 # formatter_class=argparse.ArgumentDefaultsHelpFormatter)

color_help =  ['Popular colors: viridis, gist_heat gist_ncar (default)',
               '                rainbow, jet, nipy_spectral', 
               'https://matplotlib.org/stable/tutorials/colors/colormaps.html']
               

parser.add_argument('fitsfile',    help="input FITS file",        default=None)
parser.add_argument('--plane',     help="plane (if cube) [-1]",   default=-1,            type=int)
parser.add_argument('--pvar',      help="plane var (x,y,[z])",    default='z')
parser.add_argument('--color',     help="\n".join(color_help),    default='gist_ncar')
parser.add_argument('--ext',       help="plot type ([png],pdf)",  default='png')

args  = parser.parse_args()


fitsfile = args.fitsfile
plane    = args.plane
color    = args.color
ext      = args.ext
pvar     = args.pvar

if pvar == 'z':
    dims = [0,1]   # ra-dec
elif pvar == 'y':
    dims = [0,2]   # ra-vel
elif pvar == 'x':
    dims = [1,2]   # dec-vel
else:
    dims = [0,1]

try:
    if plane < 0:
        f = aplpy.FITSFigure(fitsfile)
    else:
        f = aplpy.FITSFigure(fitsfile, slices=[plane], dimensions=dims)
except:
    print("Cannot find %s in %s" % (fitsfile,os.getcwd()))
    sys.exit(0)
    
f.show_grayscale()
f.show_colorscale(cmap=color)
f.add_colorbar()
# Cannot show beam when WCS is not celestial
# perhaps doesn't lke VRAD, but our fits files are not good enough
# f.add_beam()

try:
    f.add_beam()
except:
    pass

# f.show_contour(fitsfile, levels=10)
f.add_grid()

idx = fitsfile.rfind('.fits')
if plane < 0:
    pfile = fitsfile[:idx] + ".%s" % ext
else:
    pfile = fitsfile[:idx] + ".%04d.%s" % (plane,ext)
f.save(pfile)
print("Writing ",pfile)
