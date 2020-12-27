#  A short introduction in using lmtoy_reduce.sh

As the name implies **lmtoy_reduce.sh** is a bash script, inspired by the
scripts Mike Heyer shared. Its intent is to reduce any Sequoia OTF
dataset, and prepare (or even run) ADMIT on the final cube. This is a
simple proof of concept, to learn how to generalize the reduction scripts.

It takes a single OBSNUM, and creates an lmtoy_OBSNUM.rc parameter file, which
is nothing more than a collection of shell variables that the reduction
script uses. The first time you run it, you will probably need to
pass the path= variable:

      ./lmt_reduce.sh path=/lmt_data  obsnum=91112

This will in the end create a FITS cube SRC_OBSNUM.fits, as well as FITS weight map SRC_OBSNUM.wt.fits.
The current version ofh te script is not smart enough, for example the extent, the default best resolution. The script
will produce a number of logfiles and plots from which better values for the pipeline parameters can be set.

If NEMO was installed, it will it will create a few ancillary .ccd files, but most interestingly, the
noise flat SRC_OBSNUM.nf.fits cube, on which ADMIT can be more reliably run. In a future version this will
have to be done via astropy.

If unhappy with the initial guesses, or if you want a different y_extent, b_order, otf_select etc.etc., edit or add them to the
lmtoy_OBSNUM.rc parameter file. The names of the variables are the same as the ones used in the SLR scripts.

To re-run the pipeline, only obsnum= is required. Since gridding is much faster than making a spectrum,
with the makespec=0 parameter you can re-run a new gridding experiment. Here are a few examples how
to compare the RMS for different gridding (see also Appendix C in SLR)


      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=0                  rms -> 0.156
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=1                  rms -> 0.108
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=1          rms -> 0.061
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=0.5        rms -> 0.100
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=3                  rms -> 0.063
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=3 resolution=6.25  rms -> 0.103

and comparing two ways to do the same 25" gaussian beam: (with rms -> 0.046029)

      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=2 rmax=4                
      ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=1 rmax=2 resolution=25  


##  List of files

Here a summary of the files that are created:

     SRC_OBSNUM.nc           SpecFile  (netcdf format)
     SRC_OBSNUM.fits         (flux flat) fits cube
     SRC_OBSNUM.wt.fits      weights fits map
     SRC_OBSNUM.nf.fits      noise flat fits cube, ready for ADMIT
     SRC_OBSNUM.cubestats    ascii table of some per plane statistics

and then some.
