# SEQUOIA files

In this directory you can find the following files:  (SRC=source name   OBSNUM is the observation number(s))
as of 14-may-2022


	SRC_OBSNUM.fits	            FITS cube
	SRC_OBSNUM.wt.fits          FITS sensitivity map (a few versions may exist)
	SRC_OBSUM.wf.fits           FITS waterfall cube (time-channel-beam)
	lmtoy.rc                    ??  reduction history ??
	lmtoy_OBSNUM.rc             parameter setting for SLpipeline
	lmtoy_OBSNUM.ifproc         ASCII listing of the ifproc header variables
	
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
	SRC_OBSNUM.wtn.png          grey scale version of coverage map
	
	SRC_OBSNUM.mom0.png         simple MOM0 of the cube (signal, K.km/s)
	SRC_OBSNUM.mom1.png         simple MOM1 of the cube (mean velocity, km/s)
	SRC_OBSNUM.peak.png         peak map of the cube (mK)
	SRC_OBSNUM.rms.png          rms map of the cube (mK)
	
	SRC_OBSNUM.nc               calibrated spectra (like an SDFITS file) before gridding
	
	SRC_OBSNUM.wf.fits          waterfall cube (each plane is a beam)
	SRC_OBSNUM.wf10.fits        waterfall cube - spatially rebinned x10
	
	SRC_OBSNUM.fits             gridded science cube ("flux flat cube")
	SRC_OBSNUM.wt.fits          weight map
	SRC_OBSNUM.wt2.fits         weight map v2
	SRC_OBSNUM.wt3.fits         weight map v3
	
	SRC_OBSNUM.nf.fits          noise flat cube (input for ADMIT)

    radiometer.rms.fits         Predicted RMS based on radiometer equation (K)

	SRC_OBSNUM.nf.admit         ADMIT tree of the noise flat cube
	SRC_OBSNUM.nfs.admit        ADMIT tree of the noise flat smooth cube

# Quality

This OTF pipeline suggests the following procedure for quality
assesment and flagging parameters:

1. A **pix_list=** of good beams needs to be established. In the current 2021 cycle often
   beam 0 and sometimes 5 were bad. There was a brief period where beams 14 and 15 were
   broken.
   
2. The default setting of **dv=** and **dw=** may need adjustment per project. It may also
   depend on any birdies. This is really a PI process.

3. If there is a birdie, the waterfall plots will give clear horizontal lines. 
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
   
   The procedure to find the birdie channel(s) will hopefully be more automated, but
   for now this manual recipe needs to be followed.
   
