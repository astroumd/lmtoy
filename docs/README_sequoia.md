# SEQUOIA files

In this directory you can find the following files:  (SRC=source name   OBSNUM is observation number(s))


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
	
	SRC_OBSNUM_wt.png           weight map
	SRC_OBSNUM_wt2.png
	SRC_OBSNUM_wt3.png
	SRC_OBSNUM_wtr.png
	SRC_OBSNUM_wtn.png          grey scale version of coverage map
	
	SRC_OBSNUM_mom0.png         simple MOM0 of the cube
	SRC_OBSNUM_mom1.png         simple MOM1 of the cube
	SRC_OBSNUM_mom2.png         simple MOM2 of the cube
	
	SRC_OBSNUM.nc               calibrated spectra (like an SDFITS file) before gridding
	
	SRC_OBSNUM.wf.fits          waterfall cube (each plane is a beam)
	SRC_OBSNUM.wf10.fits        waterfall cube - spatially rebinned x10
	
	SRC_OBSNUM.fits             gridded science cube ("flux flat cube")
	SRC_OBSNUM.wt.fits          weight map
	SRC_OBSNUM.wt2.fits         weight map v2
	SRC_OBSNUM.wt3.fits         weight map v3
	SRC_OBSNUM.nf.fits          noise flat cube (input for ADMIT)
	
	SRC_OBSNUM.nf.admit         ADMIT tree of the noise flat cube
	SRC_OBSNUM.nfs.admit        ADMIT tree of the noise flat smooth cube
