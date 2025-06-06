# SEQUOIA files

In this directory you can find the following files, with the following naming conventions:

    PID      the project id (e.g. 2023-S1-US-3)
    SRC      source name, as provided by the PI.   (no spaces allowed)
    OBSNUM   observation number - either a single OBSNUM, or if OBSNUM1_OBSNUM2
             a range was used in stacking a series of OBSNUMS.
	     OBSNUM is a 5 or 6 digit number, e.g. 123456
	     If the OBSNUM contains a dunder (double underscore) this file
	     applies to a specific bank.
             For example  __0 for data from bank 0, and __1 for data from bank 1.
	     Pipeline version 1.0 (<2024) did not use the dunder notation!

A single bank observation currently has 95 files, a dual bank 166 files.
        
Version:  3-jun-2025

	lmtoy.rc                    LMTOY <version, git counter, reduction date, operating system>
	lmtoy_OBSNUM.rc             parameter setting for SLpipeline (for both banks)
	lmtoy_OBSNUM__0.rc          parameter setting for SLpipeline specific for bank 0
	lmtoy_OBSNUM__1.rc          parameter setting for SLpipeline specific for bank 1
	lmtoy_OBSNUM.ifproc         ASCII listing of the ifproc header variables
	lmtoy_PID.tar.gz            Record of the script generator used by pipeline

	SRC_OBSNUM__0.nc            calibrated spectra (like an SDFITS file) before gridding; for bank 0
	SRC_OBSNUM__1.nc            calibrated spectra (like an SDFITS file) before gridding; for bank 1
	SRC_OBSNUM__0.sdfits        calibrated spectra in SDFITS format for bank 0 (future)
	SRC_OBSNUM__1.sdfits        calibrated spectra in SDFITS format for bank 1 (future)

	SRC_OBSNUM.wf.fits          waterfall cube (each plane is a beam)
	SRC_OBSNUM.wf10.fits        waterfall cube - rebinned x10 in time for easier viewing
	
	SRC_OBSNUM.fits             gridded science cube ("flux flat cube")
	SRC_OBSNUM.wt.fits          weight map    - time samples
	SRC_OBSNUM.wt2.fits         weight map v2 - RMS of diffs
	SRC_OBSNUM.wt3.fits         weight map v3 - RMS in line free region

	SRC_OBSNUM.wtn.fits         ...coverage map (normalized) *HAS A BAD BEAM*
	SRC_OBSNUM.wtr.fits         ratio of wt3/wt2
	SRC_OBSNUM.wtr3.fits        ...
	SRC_OBSNUM.wtr4.fits        RMS expected from radiometer equation (weighted average of Tsys/sqrt(df.dt))
	
	SRC_OBSNUM.nf.fits          noise flat cube (input for ADMIT)
	SRC_OBSNUM.nfs.fits         noise flat smoothed cube (input for ADMIT)
	SRC_OBSNUM.ns.fits          noise flat smoothed cube (deprecated)

	SRC_OBSNUM.mom0.fits        simple MOM0 of the cube (signal, K.km/s)
	SRC_OBSNUM.mom1.fits        simple MOM1 of the cube (mean velocity, km/s)
	SRC_OBSNUM.peak.fits        peak in cube (mK)
	SRC_OBSNUM.rms.fits         rms in cube (mK)

        SRC_OBSNUM.radiometer.fits  Predicted RMS based on radiometer equation (K)
	
	spectrum_B.png              Spectrum through reference pixel, all channels
	spectrum_B_zoom.png         Spectrum through reference pixel, only selected channels

	
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
	SRC_OBSNUM.hist.png         histogram of fits cube


	SRC_OBSNUM__B.wf0.png       Waterfall RMS as function of channel (shown in summary)
	SRC_OBSNUM__B.wf1.png       Waterfall RMS as function of sample 

	first_*                     Various files created upon a first pass through pipeline
	README_files.md             This file

        stats__B_wf0.tab            RMS vs. SAMPLE - stats of watefall along channels
        stats__B_wf1.tab            RMS vs. CHAN  - stats of waterfall along sample
	stats__B.wf.tab             RMS vs. CHAN  - whole cube stats

	SRC_OBSNUM.bstats__B.tab    birdie stats (coluns: freq, rms) for bank B
        SRC_OBSNUM.birdies__B.tab   channels where birdies were found

Some more advanced files produces if MaskMoment was run (maskmoment=1):

	SRC_OBSNUM.dilmsk.*         results from 'maskmoment' (dilated mask)
	SRC_OBSNUM.dilmskpad.*      results from 'maskmoment' (dilated mask padded)
	SRC_OBSNUM.dilsmomsk.*	    results from 'maskmoment' (dilated smooth mask)
	SRC_OBSNUM.msk2d.*	    results from 'maskmoment' (2d mask)
	SRC_OBSNUM.smomsk.*	    results from 'maskmoment' (smooth mask)
	SRC_OBSNUM.flux.png         comparing fluxes from different 'maskmoment' methods


Directories only produced if ADMIT was run (admit=1):

	SRC_OBSNUM.nf.admit/        ADMIT tree of the noise flat cube
	SRC_OBSNUM.nfs.admit/       ADMIT tree of the noise flat smooth cube


Note that both MaskMoment and ADMIT need to run on a noise-flat cube.


# Quality

This OTF pipeline suggests the following procedure for quality assesment and flagging parameters:

1. A **pix_list=** of good beams needs to be established. In the current 2021 cycle often
   beam 0 and 5 were bad. There was a brief period where beams 14 and 15 were
   broken as well. But individual inspections are still highly encouraged. These
   can be added to the **comments.txt** file
   Bad beams either have an overall bad Tsys (plot 2),or have large RMS variations
   (plot 3 and 4)
   
2. The default setting of **dv=** and **dw=** may need adjustment per project. It may also
   depend on any birdies. This is really a QA/PI process, though the pipeline logs attempt
   to suggest changes.

3. Maps need to be square (for now), as given with the extent= keyword.
   This is a bug awaiting a fix.

4. If there is a birdie, the waterfall plots will give clear horizontal lines. 
   However, the waterfall plot only covers from **vlsr-dv-dw** to **vlsr+dv+dw**
   and we need the actual absolute channel number, not relative in the selected
   (slice of the) spectral window.
   Recipe:    run SLpipeline with birdies=0, then scan the logfile for **ICHAN**, which is
   the starting channel for the output slice, and scan it for **birdie:**, e.g.
   
        ICHAN: 48
        birdie: 6 1139 98.69443800573403
		
   this implies a birdy at absolute channel 1139+48=1187, thus the SLpipeline 
   keyword will be. Best is to add this to the **comments.txt** file
   
        birdies=1187
		
   Note that due to doppler tracking, the channel will shift over time, for example
   in 2021-S1-MX-14 it wandered from 1187 early on, to 1189 a months later.
   After the birdies have been removed, a close inspection of the waterfal plot
   is warrented.

   You may also find references to a **bumpie** in the logfile, which are very small birdies
   and can probably be ignored. However, if they appear consistently in the same channels
   for all beams, and the PI is looking at a low S/N, it might be worth investigating
   these bumpies. Currently bumpies are defined when the RMS is < 10 times that of its
   neighboring channels, birdies where they exceed that factor 10.
   
   The procedure to find the birdie channel(s) will hopefully be more automated, but
   for now this manual recipe needs to be followed.
   
# Updates

Software is maintained in https://github.com/astroumd/lmtoy where this file will be in docs/README_sequoia.md
a direct link is:  https://github.com/astroumd/lmtoy/blob/master/docs/README_sequoia.md
