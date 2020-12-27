#  A short introduction in using lmtoy_reduce.sh

Currently **lmtoy_reduce.sh** is a bash script, inspired by the
scripts Mike Heyer shared. Its intent is to reduce any Sequoia OTF
dataset, and prepare (or even run) ADMIT on the final cube.

It runs on a single OBSNUM, and creates an lmtoy_OBSNUM.rc fle, which
is nothing more than a collection of shell variables that the reduce
script will use. The first time you run it, you will probably need to
pass the path= variable:

      ./lmt_reduce.sh path=/lmt_data  obsnum=91112

This will in the end create a FITS cube SOURCENAME_OBSNUM.fits, as well as FITS weight map SOURCENAME_OBSNUM.wt.fits.
The current version ofh te script is not smart enough, for example the extent, the default best resolution. The script
will produce a number of logfiles and plots from which better values for the pipeline parameters can be set.

If NEMO was installed, it will it will create a few ancillary .ccd files, but most interestingly, the
noise flat SOURCENAME_OBSNUM.nf.fits cube, on which ADMIT can be more reliably run. In a future version this will
have to be done via astropy.

If unhappy with the initial guesses, or if you want a different y_extent, b_order, otf_select etc.etc., edit or add them to the
lmtoy_OBSNUM.rc parameter file. The names of the variables are the same as the ones used in the SLR scripts.

##  List of files

Here a summary of the files that are created:

     SOURCENAME_OBSNUM.nc           SpecFile  (netcdf format)
     SOURCENAME_OBSNUM.fits         (flux flat) fits cube
     SOURCENAME_OBSNUM.wt.fits      weights map
     SOURCENAME_OBSNUM.nf.fits      noise flat fits cube, ready for ADMIT
     SOURCENAME_OBSNUM.cubestats    ascii table of some per plane statistics

and then some.
