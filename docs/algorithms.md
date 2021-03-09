# Algorithms

## TA 

The typical way a single dish signal (normally represented in Kelvin) is computed is with an ON/OFF comparison:

      (eq. 1)    TA = Tsys * (ON-OFF)/OFF

where Tsys is a calibrated system temperature.

## CAL

The Tsys in turn is computed by comparing a "HOT" and "SKY" load, where the ambient temperature (Tamb) is known
from a sensor, or in case of SLR, hardcoded at 280K:

      (eq. 2)    Tsys = Tamb * SKY / (HOT-SKY)

In theory Tsys is a spectrum, but there is an option in the code to make it a scalar (not the default).
Also the way how a single HOT and SKY are computed from several samples (e.g. 20-ish in case of Sequoia)
could be tuned, currently a median is used.

RSR has a 1 KHz sampler, but data are accumulated to ~ 30sec before written and processed. Also recall the RAW data
for RSR are LAGS, not a SPECTRUM as for SEQ/SLR.

## DATA

In a typical LMT data set the channel based data can be thought of dimensioned, of which some of it we can find
back in the various data structures. We are using python notation, where the last dimension runs fastest:

     SLR:      DATA[npixel, ntime, nchan]                   e.g. [16, inttime/0.1, 2k - 8k]   ~ 2-20GB

     RSR:      AccData[nchassis,ntime,nboard,nchan]         e.g. [4, inttime/32, 6, 256]      ~ 10 MB
               RefData[nchassis,ntime,nboard,nchan]

For both instruments the data is actually in different files:   4 for SLR (4 pixels per 4 roach boards), and 4 for RSR
(there are 4 chassis). The various data structures are of course not exactly the simplistic sketch of the
multi-dimensonal array mentioned here. However, sometimes to processing large amounts of data (e.g. for SLR) it is
useful to review this in terms of any potential parallel (e.g. OpenMP) processing.

For Sequioa the ifproc and roach data are sampled at 125 Hz and 10 Hz resp., have different timestamps and thus
need to be aligned to build the **data[]** for further calibration and analysis. This interpolation process is
somewhat expensive. Effective processing speed is about 20-40 MB/sec for this *process* step.

## OPS

Various operations are needed on spectra.

1. flagging

1. smoothing

1. binning

1. trimming

1. baselining

1. fitting

1. gridding to a spatial domain

1. exporting to FITS/CLASS/ECSV

## STATS


## Correspondence Table


      TA (eq.1)   lmtslr.spec.RoachSpec.reduce_spectra()

      CAL (eq.2)  lmtslr.spec.RoachSpec.compute_tsys_spectra()  - for CAL_in_MAP
                  lmtslr.spec.RoachSpec.compute_tsys_spectrum() - for CAL_before_MAP
		  dreampy3.redshift.netcdf.calibration_scan.process_astronomical_calibration()

		  

      STATS       lmtslr.spec.LineStatistics
      
      OPS:
                  lmtslr.spec.RoachSpec.baseline()
                  lmtslr.reduction.line_reduction.Line.baseline()
                  lmtslr.reduction.line_reduction.Line.line_stats()
                  lmtslr.reduction.line_reduction.Line.smo()
                  lmtslr.reduction.line_reduction.LineData.cslice()
                  lmtslr.reduction.line_reduction.Accum.load()
                  lmtslr.reduction.line_reduction.Accum.ave()
                  dreampy3.utils.smoothing.rebin()
                  dreampy3.utils.curve_fitting.Gauss1DFit()
                  dreampy3.utils.two_gaussian_fit.two_gaussian_fit()
                  dreampy3.redshift.utils.spectrum_utils.makespectrum()
                  dreampy3.redshift.utils.spectrum_utils.
		  		  		  
		  
		  
