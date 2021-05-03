#! /usr/bin/env python
#
#   run this with:    ipython --pylab

from dreampy3.redshift.utils.fileutils import make_generic_filename
from dreampy3.redshift.netcdf import RedshiftNetCDFFile
from dreampy3.redshift.plots import RedshiftPlot

nc = RedshiftNetCDFFile(make_generic_filename(33551, 1))
print(nc.hdu.header.SourceName, nc.hdu.header.ObsPgm)                  
# I10565 Bs

nc.hdu.process_scan()  # this automatically senses the ObsPgm and does the appropriate processing
pl = RedshiftPlot()
pl.plot_spectra(nc)

# you can also get at the Tsys vector for this scan directly from this Bs observation by doing the following:
nc.hdu.get_cal()
pl.plot_tsys(nc)

# or you can get at the CAL scan separately
print(nc.hdu.header.CalObsNum)                                         
# 33550

nc = RedshiftNetCDFFile(make_generic_filename(33550, 1))  # Cal scan for the Bs we just analyzed
nc.hdu.process_scan()
nc.hdu.get_cal()
pl.plot_tsys(nc)
