# RSR files

In this directory you can find the following files, with the following name convention

       PID      the project id
       SRC      source name, as provided by the PI.   (no spaces allowed)
       OBSNUM   observation number - either a single OBSNUM, or if OBSNUM1_OBSNUM2
                if a range was used in stacking. OBSNUM is a 5 or 6 digit number.

Version:  24-jan-2023

       lmtoy.rc                    LMTOY system info
       lmtoy_OBSNUM.rc             parameter setting for SLpipeline (cumulative)
       lmtoy_OBSNUM.log            logfile of pipeline run
       lmtoy_PID.tar.gz            Record of the script generator used by pipeline

       rsr.OBSNUM.badlags          See also rsr_badlags.log
       rsr.OBSNUM.blanking         See also ..
       rsr.OBSNUM.rfile		   See also ..

       rsr.OBSNUM.driver.sum.txt   Bandmerged spectrum from driver (see also rsr_driver.log)
       rsr.OBSNUM.blanking.sum.txt Bandmerged spectrum from blanking (see also rsr_sum.log)

       rsr.wf.pdf                  Waterfall style plot of different integrations

       fit.driverN.{log,png}       N-th peak from tabpeak for driver spectrum
       fit.blankingN.{log,png}     N-th peak from tabpeak for blanking spectrum

       spec1.tab                   driver spectrum, only used for LineCheck
       spec2.tab                   blanking spectrum, only used for LineCheck

## Log files

       first.lmtoy_103779.log
       fit.blankingN.log            Fit of 4 strongest lines in "blanking" spectrum
       fit.driverN.log              Fit of 4 strongest lines in "driver" spectrum
       linecheck.log                Fit of line for "LineCheck"
       lmtoy_103779.log             pipeline (SLpipeline.sh)
       rsr_badlags.log              badlags.py
       rsr_driver.log		    rsr_driver.py
       rsr_driver0.log
       rsr_driver1.log
       rsr_peaks.log                rsr_peaks.sh - summary of tabpeak fits (See also fit.*.log)
       rsr_sum.log                  rsr_sum.py
       rsr_tsys.log                 rsr_tsys.py
       rsr_tsys0.log
       rsr_tsys2.log
       rsr_tsys_badcb.log

## Naming

We have two scripts producing two spectra. They have some common code executed via the dreampy3 module,
but have different ways to blank sections of data. Their naming convention is - sadly - confusing at
the moment, this will be cleaned up. Ideally the two scripts will be merged into one.

rsr_driver:    driver, rfile
rsr_sum:       sum, blanking, 

# Quality

This RSR pipeline suggests the following procedure for quality
assesment and flagging parameters:

1. In the first run the pipeline will attempt to determine the bad lags (**badcbl=**) and 
   bad detectors (**badcb=**)
   
2. bla


   
# Updates

Software is maintained in https://github.com/astroumd/lmtoy 
