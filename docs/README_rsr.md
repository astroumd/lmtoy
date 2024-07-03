# RSR files

In this directory you can find the following files, with the following name convention

       PID      the project id (e.g. 2023-S1-US-3)
       SRC      source name, as provided by the PI.   (no spaces allowed)
       OBSNUM   observation number - either a single OBSNUM, or OBSNUM1_OBSNUM2
                if a range was used in stacking. OBSNUM is a 5 or 6 digit number.

Version:  11-jun-2024

       lmtoy.rc                    LMTOY system info
       lmtoy_OBSNUM.rc             parameter setting for SLpipeline (cumulative)
       lmtoy_OBSNUM.log            logfile of (latest) pipeline run
       lmtoy_PID.tar.gz            Record of the script generator used by pipeline (if available)

       rsr.OBSNUM.badlags          badlags
       rsr.OBSNUM.blanking         Used by "blanking/sum" script
       rsr.OBSNUM.rfile		   Used by "driver" script

       rsr.OBSNUM.driver.sum.txt   Bandmerged spectrum from driver (see also rsr_driver.log)
       rsr.OBSNUM.blanking.sum.txt Bandmerged spectrum from blanking (see also rsr_sum.log)

       rsr.wf.pdf                  Waterfall style plot of different integrations (png versions as well)
       rsr.wf0.pdf                 Waterfall style plot - original version

       rsr.tsys0.png               Tsys before badlags were applied
       rsr.tsys.png                Tsys after badlags were applied

       rsr.spectra.png             Comparing the driver and blanking spectrum (full)
       rsr.spectra_zoom.png        Comparing the driver and blanking spectrum (zoomed on a PI selected section)

       rsr.spectrum.png            Spectrum of 4 chassis, overplotted

       rsr.driver0.png             Driver spectrum, no badlags applied
       rsr.driver.png              Driver spectrum, with badlags and potentially xlines applies

       fit.driverN.{log,png}       N-th peak from tabpeak for driver spectrum
       fit.blankingN.{log,png}     N-th peak from tabpeak for blanking spectrum

       spec1.tab                   zoomed driver spectrum, only used for LineCheck (plus their .png version)
       spec2.tab                   zoomed blanking spectrum, only used for LineCheck (plus their  .png version)

       first.*                     (optional) Record of first time run of some of these files

       OBSNUM_lmtmetadata.yaml     YAML file of meta data used for archiving
       bash_vars.txt               list of all bash variable - useful for pipeline debugging


## Log files

Other log files not mentioned before:

       dreampy.log*                 Logfiles from the dreampy3 interface for RSR processing
       fit.blankingN.log            Fit of N=1..4 strongest lines in "blanking" spectrum
       fit.driverN.log              Fit of N=1..4 strongest lines in "driver" spectrum
       linecheck.log                Fit of line for "LineCheck"
       rsr_badlags.log              badlags.py
       rsr_driver.log               rsr_driver.py
       rsr_driver0.log
       rsr_driver1.log
       rsr_peaks.log                rsr_peaks.sh - summary of tabpeak fits (See also fit.*.log)
       rsr_sum.log                  rsr_sum.py
       rsr_tsys.log                 rsr_tsys.py
       rsr_tsys0.log                log from rsr_tsys w/o lags and containing the BADCB0's
       rsr_tsys2.log                log from rsr_tsys  w/ lags and containing the BADCB2's
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

6. badlags plot:   the badcb= list (if present) were C/B's with deemed bad behavior of those lags.
   Currently we have the following PI parameters:

     bc_threshold = 2.5
     bc_low = 0.01
     spike_threshold = 3.0
     rms_min = 0.01
     rms_max = 0.2
     min_chan = 32


Note the waterfall plots have completely blanked out bands, but also spectra that look "greyed out". These are
also not used in the accumulation. The blanked out one are most likely the badcb's, the partially
colored repeats are because their jitter(blabla0 is above the threshold set in the rsr_driver. Current default
is....
   
# Updates

Software is maintained in https://github.com/astroumd/lmtoy where this file will be in docs/README_rsr.md

