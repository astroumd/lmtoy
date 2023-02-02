# RSR files

In this directory you can find the following files, with the following name convention

       PID      the project id (e.g. 2023-S1-US-3)
       SRC      source name, as provided by the PI.   (no spaces allowed)
       OBSNUM   observation number - either a single OBSNUM, or if OBSNUM1_OBSNUM2
                if a range was used in stacking. OBSNUM is a 5 or 6 digit number.

Version:  31-jan-2023

       lmtoy.rc                    LMTOY system info
       lmtoy_OBSNUM.rc             parameter setting for SLpipeline (cumulative)
       lmtoy_OBSNUM.log            logfile of (latest) pipeline run
       lmtoy_PID.tar.gz            Record of the script generator used by pipeline (if available)

       rsr.OBSNUM.badlags          See also rsr_badlags.log
       rsr.badlags                 -will be deprecated-
       rsr.OBSNUM.blanking         Used by "blanking/sum" script
       rsr.OBSNUM.rfile		   Used by "driver" script

       rsr.OBSNUM.driver.sum.txt   Bandmerged spectrum from driver (see also rsr_driver.log)
       rsr.OBSNUM.blanking.sum.txt Bandmerged spectrum from blanking (see also rsr_sum.log)

       rsr.wf.pdf                  Waterfall style plot of different integrations (png versions as well)
       rsr.wf0.pdf                 Waterfall style plot - original version

       rsr.tsys.png
       rsr.tsys0.png

       rsr.spectrum.png
       rsr.spectrum_zoom.png

       rsr.spectra.png

       rsr.driver.png
       rsr.driver0.png       

       fit.driverN.{log,png}       N-th peak from tabpeak for driver spectrum
       fit.blankingN.{log,png}     N-th peak from tabpeak for blanking spectrum

       spec1.tab                   driver spectrum, only used for LineCheck
       spec2.tab                   blanking spectrum, only used for LineCheck

       first.*                     Record of first time run of this file


## Log files

       fit.blankingN.log            Fit of N=1..4 strongest lines in "blanking" spectrum
       fit.driverN.log              Fit of N=1..4 strongest lines in "driver" spectrum
       linecheck.log                Fit of line for "LineCheck"
       lmtoy_103779.log             pipeline (SLpipeline.sh)
       rsr_badlags.log              badlags.py
       rsr_driver.log               rsr_driver.py
       rsr_driver0.log
       rsr_driver1.log
       rsr_peaks.log                rsr_peaks.sh - summary of tabpeak fits (See also fit.*.log)
       rsr_sum.log                  rsr_sum.py
       rsr_tsys.log                 rsr_tsys.py
       rsr_tsys0.log
       rsr_tsys2.log
       rsr_tsys_badcb.log           record of Tsys jitter before and after badlags applied (plus improvement ratio)


## Naming

We have two scripts producing two spectra. They have some common code executed via the dreampy3 module,
but have different ways to blank sections of data. Their naming convention is - sadly - confusing at
the moment, this will be cleaned up. Ideally the two scripts will be merged into one.

rsr_driver:    driver, rfile
rsr_sum:       sum, blanking



# Software Workflow

Here we remind ourselves how the pipeline works, and what important keywords there
are, and which files are produced by whom.

Since the raw data are lags, they need to be fourier transformed to spectra (one band at
a time). Some lags may be bad, which are estimated by the variation accross the time samples.
This badlags file is applied to 

## Examples on important SLpipeline parameters:

     badcb=0/0,3/5     (example of first and last C/B pair)           
     xlines=110.0,0.3  (multiple comma separated can be given here)
     linecheck=0       (set to 1 if you want to pre-set xlines= from the sourcename)

If badcb= used, it pre-sets those BADCB'S in the (2) blanking files for later use
     
## New order of reduction for single obsnum cases

1. run rsr_driver to get a "first" spectrum, with whatever badlags are in dreampyrc
2. get Tsys0, which also gives some badcb0= (which we ignore)
3. run badlags, this also gives some badcb1=
4. try rsr_driver, just to apply these badlags
5. get Tsys1, now done with the badlags. these also give a badcb2=, which we could use
6. final rsr_driver, using badlags and badcb1,badcb2
7. final rsr_sum,    using badlags and badcb1,badcb2



## Flow


1. first call of rsr_driver and rsr_tsys so we can later compare how much better things improved
   these are taken with no badlags - might be a whole mess

      rsr_driver:  -> rsr.wf0.pdf rsr_driver0.log
      rsr_tsys:    RMS of adjacent channels will trigger BADCB's  -> rsr.tsys0.png

   The badcb's listed in the Tsys plot are based on jitter in the Tsys per CB (hardcoded at: rms_min = 25K)

2. some

3. [3] Get the badlags

      badlags.py -> rsr_badlags.log 
      rsr_driver.py -> rsr_driver1.log       now using badlags

4. some

5. [5] tsys plot

6. 


Note the waterfall plots have completely blanked out bands, but also spectra that look "greyed out". These are
also not used in the accumulation. The blanked out one are most likely the badcb's, the partially
colored repeats are because their jitter(blabla0 is above the threshold set in the rsr_driver. Current default
is....
   
# Updates

Software is maintained in https://github.com/astroumd/lmtoy where this file will be in docs/README_rsr.md

