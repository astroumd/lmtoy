#! /usr/bin/env python
#
#

import os
import sys
import aplpy

#   dims for an [ra,dec,vel] cube
dims = [0,1]   # ra-dec
#dims = [1,2]   # dec-vel
#dims = [0,2]   # ra-vel

fitsfile = sys.argv[1]
if len(sys.argv) > 2:
    plane = int(sys.argv[2])
else:
    plane = -1

try:
    if plane < 0:
        f = aplpy.FITSFigure(fitsfile)
    else:
        f = aplpy.FITSFigure(fitsfile, slices=[plane], dimensions=dims)
except:
    print("Cannot find %s in %s" % (fitsfile,os.getcwd()))
    sys.exit(0)

    
    
f.show_grayscale()
f.show_colorscale(cmap='gist_heat')
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
    pfile = fitsfile[:idx] + ".png"
else:
    pfile = fitsfile[:idx] + ".%04d.png" % plane
f.save(pfile)
print("Writing ",pfile)
