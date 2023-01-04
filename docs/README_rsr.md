# RSR files

In this directory you can find the following files, with the following name convention

    PID      the project id
    SRC      source name, as provided by the PI.   (no spaces allowed)
    OBSNUM   observation number - either a single OBSNUM, or if OBSNUM1_OBSNUM2
             if a range was used in stacking. OBSNUM is a 5 or 6 digit number.

Version:  22-dec-2022

	lmtoy.rc                    ??  reduction history ??
	lmtoy_OBSNUM.rc             parameter setting for SLpipeline
	lmtoy_OBSNUM.ifproc         ASCII listing of the ifproc header variables
	lmtoy_PID.tar.gz            Record of the script generator used by pipeline	

# Quality

This RSR pipeline suggests the following procedure for quality
assesment and flagging parameters:

1. In the first run the pipeline will attempt to determine the bad lags (**badcbl=**) and 
   bad detectors (**badcb=**)
   
2. bla


   
# Updates

Software is maintained in https://github.com/astroumd/lmtoy 
