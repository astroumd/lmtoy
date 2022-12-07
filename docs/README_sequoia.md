# SEQUOIA files

In this directory you can find the following files, with the following name convention
   SRC      source name, as provided by the PI.   (no spaces allowed)
   OBSNUM   observation number - either a single OBSNUM, or if OBSNUM1_OBSNUM2
            if a range was used in stacking. OBSNUM is a 5 or 6 digit number.
        
Version:  28-nov-2022


	SRC_OBSNUM.fits	            FITS cube 
	SRC_OBSNUM.wt.fits          FITS sensitivity map (a few versions may exist)
	SRC_OBSUM.wf.fits           FITS waterfall cube (time-channel-beam)
	lmtoy.rc                    LMTOY <version, git counter, reduction date>
	lmtoy_OBSNUM.rc             parameter setting for SLpipeline
	lmtoy_OBSNUM.ifproc         ASCII listing of the ifproc header variables

	SRC_OBSNUM.nc               calibrated spectra (like an SDFITS file) before gridding
	
	SRC_OBSNUM.wf.fits          waterfall cube (each plane is a beam)
	SRC_OBSNUM.wf10.fits        waterfall cube - spatially rebinned x10
	
	SRC_OBSNUM.fits             gridded science cube ("flux flat cube")
	SRC_OBSNUM.wt.fits          weight map    - time samples 
	SRC_OBSNUM.wt2.fits         weight map v2 - RMS of diffs
	SRC_OBSNUM.wt3.fits         weight map v3 - RMS in line free region

	SRC_OBSNUM.wtn.fits         ...coverage map (normalized) *BAD BEAM*
	SRC_OBSNUM.wtr.fits         ratio of wt3/wt3
	SRC_OBSNUM.wtr3.fits        ...
	SRC_OBSNUM.wtr4.fits        RMS expected from radiometer equation (weighted average of Tsys/sqrt(df.dt))
	
	SRC_OBSNUM.nf.fits          noise flat cube (input for ADMIT)

	SRC_OBSNUM.mom0.fits        simple MOM0 of the cube (signal, K.km/s)
	SRC_OBSNUM.mom1.fits        simple MOM1 of the cube (mean velocity, km/s)
	SRC_OBSNUM.peak.fits        peak in cube (mK)
	SRC_OBSNUM.rms.fits         rms in cube (mK)

        radiometer.rms.fits         Predicted RMS based on radiometer equation (K)
	
	SRC_OBSNUM_specpoint1.png   spectrum of central beam
	SRC_OBSNUM_specpoint2.png   spectrum of full cube

	SRC_OBSNUM_specviews1.png   sky coverage of all beams in RA/DEC
	SRC_OBSNUM_specviews2.png   waterfall plot for all good beams in a 4x4 panel
	SRC_OBSNUM_specviews3.png   RMS
	SRC_OBSNUM_specviews4.png   histogram of RSM
	SRC_OBSNUM_specviews5.png   spectrum 
	SRC_OBSNUM_specviews6.png   Tsys
	
	SRC_OBSNUM.wt.png           weight map (how many effective samples were in this pixel)
	SRC_OBSNUM.wt2.png          weight map v2 (now rms) - based on RMS of diffs in cube (/sqrt2)
	SRC_OBSNUM.wt3.png          weight map v3 (now rms) - based on RMS in line free section of cube
	SRC_OBSNUM.wtr.png          ratio of wt3/wt2
	SRC_OBSNUM.wtr3.png         ...
	SRC_OBSNUM.wtr4.png         ...
	SRC_OBSNUM.wtn.png          grey scale version of coverage map
	
	SRC_OBSNUM.mom0.png         simple MOM0 of the cube (signal, K.km/s)
	SRC_OBSNUM.mom1.png         simple MOM1 of the cube (mean velocity, km/s)
	SRC_OBSNUM.peak.png         peak map of the cube (mK)
	SRC_OBSNUM.rms.png          rms map of the cube (mK)

	first_*                     Various files created upon a first pass through pipeline
	README_files.md             This file

here are files that are only produced if ADMIT was run:

	SRC_OBSNUM.nf.admit/        ADMIT tree of the noise flat cube
	SRC_OBSNUM.nfs.admit/       ADMIT tree of the noise flat smooth cube

	SRC_OBSNUM.dilmsk.*         results from 'maskmoment' (dilated mask)
	SRC_OBSNUM.dilmskpad.*      results from 'maskmoment' (dilated mask padded)
	SRC_OBSNUM.dilsmomsk.*	    results from 'maskmoment' (dilated smooth mask)
	SRC_OBSNUM.msk2d.*	    results from 'maskmoment' (2d mask)
	SRC_OBSNUM.smomsk.*	    results from 'maskmoment' (smooth mask)
	SRC_OBSNUM.flux.png         comparing fluxes from different 'maskmoment' methods



# Quality

This OTF pipeline suggests the following procedure for quality
assesment and flagging parameters:

1. A **pix_list=** of good beams needs to be established. In the current 2021 cycle often
   beam 0 and 5 were bad. There was a brief period where beams 14 and 15 were
   broken as well. But individual inspections are still highly encouraged. These
   can be added to the **comments.txt** file
   
2. The default setting of **dv=** and **dw=** may need adjustment per project. It may also
   depend on any birdies. This is really a QA/PI process.

3. Maps need to be squared (for now), as given with the extent= keyword.

4. If there is a birdie, the waterfall plots will give clear horizontal lines. 
   However, the waterfall plot only covers from **vlsr-dv-dw** to **vlsr+dv+dw**
   and we need the actual absolute channel number, not relative in the selected
   (slice of the) spectral window.
   Recipe:    run SLpipeline with birdies=0, then scan the logfile for **ICHAN**, which is
   the starting channel for the output slice, and scan it for **birdie:**, e.g.
   
        ICHAN: 48
        birdie: 6 1139 98.69443800573403
		
   this implies a birdy at absolute channel 1139+48=1187, thus the SLpipeline 
   keyword will be
   
        birdies=1187
		
   Note that due to doppler tracking, the channel will shift over time, for example
   in 2021-S1-MX-14 it wandered from 1187 early on, to 1189 a months later.
   After the birdies have been removed, a close inspection of the waterfal plot
   is warrented.

   You may also find references to a **bumpie**, which are very small birdies and can
   probably be ignored. However, if they appear consistently in the same channels
   for all beams, and the PI is looking at a low S/N, it might be worth investigating
   the bumpies. Currently bumpies are defined when the RMS is < 10 times that of its
   neighboring channels, birdies where they exceed that factor 10.
   
   The procedure to find the birdie channel(s) will hopefully be more automated, but
   for now this manual recipe needs to be followed.
   
