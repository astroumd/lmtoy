#! /usr/bin/env python


#    non-interactive mode
import matplotlib
matplotlib.use('Agg')


import aplpy


#ff = 'IRC_79448.fits'
ff = 'IRC_79448.wt.fits'

f = aplpy.FITSFigure(ff,slices=[0])
f.set_title("IRC_79448")
f.show_grayscale()
f.show_colorscale(aspect='auto')
f.show_contour(ff, colors='white', levels=[24.0], smooth=3)

rpd = 57.2958
#f.show_circles(146.9892/rpd,13.27877/rpd,0.003993056/rpd)

f.show_circles([48],[48],2,coords_frame='pixel')
#f.add_beam()
f.add_colorbar()
f.set_nan_color('white')
f.save('IRC_79448.wt.png')
