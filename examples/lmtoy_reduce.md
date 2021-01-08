#  A short introduction in using lmtoy_reduce.sh

As the name implies **lmtoy_reduce.sh** is a bash shell script, inspired by the
scripts Mike Heyer shared. Its intent is to reduce any Sequoia OTF
data without any guidance from the user, as well as
prepare (or even run) ADMIT on the final cube. This is a
simple proof of concept, to learn how to generalize the reduction scripts.


## Running lmtoy_reduce.sh

This pipeline script takes a series of *keyword=value* commandline
argument pairs. The parser is a very simple one, and does not check if you spelled
them correctly.  On the first run the **path=** is required, but **obsnum=**
is required for each run

      $LMTOY/examples/lmtoy_reduce.sh \
	    obsnum=91112                # always required
	    path=/data/LMT/lmt_data     # required on the first run
	    rc=0                        # optional:  force a new rc file
	    dv=100                      # optional:  width around spectral line (vlsr)
	    dw=250                      # optional:  width of the wings for baseline
	    makespec=1                  # optional
	    makecube=1                  # optional
	    viewspec=0                  # optional
	    viewcube=0                  # optional
	    extent=400                  # square map from -extent:+extent (arcsec)


On the first run it creates an **lmtoy_OBSNUM.rc** parameter file,
which is nothing more than a collection of shell variables that the
reduction script uses. This parameter file can be edited and you can
re-run the script. Remember there are no spaces left and right of the '='
sign in an rc file.


This will create a FITS cube **SRC_OBSNUM.fits**, as well as a
FITS weight map **SRC_OBSNUM.wt.fits**.  The current version of the script
is not smart enough, for example the spatial extent is hardcoded,
and the baselining area is guessed based on a VLSR and WIDTH.  Future
versions should improve on this.
The script will produce a number of logfiles
and plots from which better values for the pipeline parameters can be
set, but currently everything is done in the current directory and
printed to stdout.

If NEMO was installed, it will create a few ancillary .ccd
files, but most interestingly, the noise flat **SRC_OBSNUM.nf.fits** cube,
and a smoothed version **SRC_OBSNUM.nfs.fits** cube,
on which ADMIT can be more reliably run to the otherwise noisy edge.  In a
future version this will have to be done via astropy.

If unhappy with the initial guesses, or if you want a different
y_extent, b_order, otf_select etc.etc., edit or add them to the
**lmtoy_OBSNUM.rc** parameter file. The names of the variables are the
same as the ones used in the SLR scripts, except we use
a *keyword=value* syntax with no further error checking.

To re-run the pipeline, only obsnum= is now required. Since gridding
(makecube=1) is much faster than making a spectrum (makespec=1), with
the makespec=0 parameter you can re-run a new gridding
experiment. Here are a few examples how to compare the RMS for
different gridding (see also Appendix C in the SLR manual).

##  List of files

Here a summary of the files that are created:

   
     lmtoy_OBSNUM.rc         parameter (bash style) file
     SRC_OBSNUM.nc           SpecFile  (netcdf format)
     SRC_OBSNUM.wf.fits      Waterfall version of SpecFile
     SRC_OBSNUM.wf10.fits    Waterfall version of SpecFile with 10 times binning in time
     SRC_OBSNUM.fits         (flux flat) fits cube
     SRC_OBSNUM.wt.fits      weights fits map
     SRC_OBSNUM.nf.fits      noise flat fits cube, ready for ADMIT
     SRC_OBSNUM.nfs.fits     noise flat XYZ smoothed fits cube, ready for ADMIT
     SRC_OBSNUM.cubestats    ascii table of some per plane statistics



## An experiment


     ./lmtoy_reduce.sh path=M31_data obsnum=85776 
      
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=0                  rms -> 0.156  max -> 1.737 at (28,53,310)
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=1                  rms -> 0.108  max -> 1.645
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=1          rms -> 0.061  max -> 1.257
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=0.5        rms -> 0.100  max -> 1.541
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=3                  rms -> 0.063  max -> 1.289
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=3 resolution=6.25  rms -> 0.103  max -> 1.581
     
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=4 rmax=1                  0.056         1.172
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=4 resolution=6.25 rmax=1  0.088         1.429
 
and comparing two ways to do the same 25" gaussian beam: (with rms -> 0.046029)

     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=2 rmax=4                
     ./lmtoy_reduce.sh makespec=0 obsnum=85776 otf_select=2 otf_b=1 rmax=2 resolution=25  

will give the same cube. For those familiar with CASA's tclean and the different methods to find a good
balance between resolution and signal to noise, you will find the parameters to control this equally
challenging. Again, Appendix C contains a good summary, and there are some comments on this in our
future [wishlist](../docs/wishlist.md).

## Future

There is a [wishlist](../docs/wishlist.md) being written that contains a summary what was changed to
LMTSLR in December 2020, and what needs we could come up with to let less experienced
people enjoy reducing their Sequoia data.


# Description of scripts

The following script are used by the **lmtoy_reduce.sh** pipeline.
All scripts should self-describe using the **-h** or **--help** flag.

* **lmtinfo.py**:   gathers some info what OBSNUM's you have, and for a specific OBSNUM, useful info for the pipeline
* **process_otf_map2.py**:   converts RAW to SpecFile
* **process_otf_map.py**:   *deprecated version*
* **view_spec_file.py**: make a series of plots summarizing one or a set of pixels
* **view_spec_point.py**: show average spectrum for each pixel in a radius around a selected point
* **make_spec_fits.py**: convert SpecFile to a FITS waterfall cube
* **grid_data.py**: grid a SpecFile into a FITS cube
* **view_cube.py**: make a series of plots summarizing a FITS cube

## lmtinfo

The **lmtinfo.py** script makes a summary listing of the OBSNUM you have, e.g.

      lmtinfo.py /data/lmt_data
      
      #     DATE  OBSNUM   SOURCE     RESTFRQ VLSR INTTIME
      2018-11-16  079447  IRC+10216   115.271  -20       8
      2018-11-16  079448  IRC+10216   115.271  -20     686

      2019-10-31  085775  Region_J-K  115.271 -296       7
      2019-10-31  085776  Region_J-K  115.271 -296    1471
      2019-10-31  085777  Region_J-K  115.271 -296       8
      2019-10-31  085778  Region_J-K  115.271 -296    1483
      2019-11-01  085823  Region_J-K  115.271 -296       7
      2019-11-01  085824  Region_J-K  115.271 -296    1488

      2020-02-18  090910  NGC5194     115.271  463       7
      2020-02-18  090911  NGC5194     115.271  463    3986
      2020-02-20  091111  NGC5194     115.271  463       7
      2020-02-20  091112  NGC5194     115.271  463    6940


Although VLSR -296 agrees with NED, the one used for M51 (463) does not agree with NED (611)


## Process

The conversion from RAW to SpecFile is the process script. They differ slightly depending on an OTF, MAP, PS or BS.
There is a different script for each. Here we describe the important
parameters for **process_otf_map2.py**


### b_regions

two sections, typically left and right of the line, are selected. Check code if we can use more, for example, what to do when two lines
are in the spectrum.

### b_order

The order of the polynomial. Depending on the amount of channels used, and the gap inbetween, the b_order cannot
be too high. Typically 0 should do.

### l_regions

Why do we even need this? Is says this is for line fitting.   Or is this the eqv. of my suggested VLSR and DV?

### slice

This is the min and max of the channels (usual in VLSR) that are to be written out.
This has to be used with care. If the slice does not contain the b_regions, those sections of the b_regions would not be used.

### stype

This controls how the OFFs are combined with the ONs to create a calibrated spectrum.

### pix_list

If you already know certain pixels are bad, no need to include them in the SpecFile. But certainly
on the first run, better leave them all in, and inspect via a Waterfall Cube or the plots
via view_spec_file

Note there is a pix_list in a number of scripts in the pipeline, which in principle means they could differ. Within
the pipeline they are all the same.



## Gridding

There are a few parameters to the gridding program (**grid_data.py**) that are worth a few comments. The parallels to
how CASA's **tclean** program controls the gridding are not too different. The
following parameters are all related and pertain to the gridding/convolution function:

      --resolution          # should be 1.15 * lambda/ D
      --cell                # should be 1/2 of resolution, smaller is ok, but larger is not.
      --otf_select          # SLR recommends 1
      --otf_a               # SLR recommends 1.1
      --otf_b               # SLR recommends 4.75, but this is also the gaussian beam factor, where it should be 1
      --otf_c               # SLR recommands 2.0
      --sigma_noise         # should be 1
      --rmax                # should be 3

and a few filters what spectra to be added to the gridding

      --pix_list            # which pixels are to be included
      --rms_cut             # which spectra are rejected (but see below)

###  resolution

This should be 1.15 * lambda/D, though depending on the filter, and
it's parameters, there may be a reason to take a larger value. At CO
115.27 GHz this is 12.3". Currently the user has to supply it, ideally
we set it from the skyfreq.

###  cell: pixel size

The cell size should be 1/2 of the resolution, if you want to follow
Nyquist sampling, but anything a bit smaller is ok as well. At CARMA
we used a ratio of 3, at ALMA they decided on a ratio of 5!

###  otf_select:  the choice of filter

Up to three parameters are used to control the shape of the filter (otf_a, otf_b, otf_c)

* 0 = box:   this uses cell as parameter (i suggest we should use resolution)
* 1 = jinc : this uses otf_a, otf_b and otf_c as parameters. Discussed in Appendix C
* 2 = gauss: this uses otf_b as the factor by with resolution is multiplied.
* 3 = triangle: this uses resolution as parameter
* 4 = box:   but using the resolution as parameter

### rmax: convolution size

This is the dimensionless factor how many resolutions the convolution
filter should be sampled. There is a secondary parameter how many
samples are taken, which defaults to 256. These is little reasons to
change this parameter, in fact, there may be some program array
overruns lurking here if set wrong.

Note for example for otf_select=2 (a gauss) with rmax=3 and otf_b some large number, the
filter is effectively a box.

### edge: expand the edge?

This is not a parameter yes, but could/should. It's currently hardcoded and
easy to switch. I didn't like the fake expanded edges, in particular a
gaussian (--otf_select=2) would cause these straight features
perpendicular to the real edge. I decide to set a mask on cells where
a pixel has never been seen.  I could add one cycle if N neighbors are
present. N=3 could be a good value, with N=2 this will fill in the odd
NaN bands with otf_select=1.

### pix_list:  list of pixels to keep

The same keyword as the process script, which within the pipeline is used
in all scripts that use it.

### rms_cut: cull spectra with high rms

In the original version spectra with RMS > rms_cut would be rejected, across
all pixels. A slightly better version is to find the "MAD" (Median Absolute Deviate)
of the distribution of RMS, and reject all spectram with RMS  > median + factor * MAD_STD.
When rms_cut < 0 we assig factor = -rms_cut, a dimensionless number. A value of -3 or -4
seems to be working well.

Data prior to 2020-02-18 suffered from occasionally corrupted spectra
due to a doppler tracking based mishap. These data in particular can be easily
culled when rms_cut=-4 was set.


### noise_sigma:   RMS weighting

The measured RMS in each spectrum (describe what that is: RMS from the fitted baseline
in the b_regions?) can also be used to weigh (1/RMS^2) each spectrum when these spectra
are combined in the gridding process.




# Advanced concepts:   Combining maps from different OBSNUM

A common situation is that maps from different OBSNUM are combined. There at several
approaches

1. Use the fits and wt.fits of all obsnum to create a weighted map. Assuming the maps are
all on the same WCS gridd, this is a simple mathematical (in fits terms) operation, which
can be easily done in astropy.  Montage could be used, NEMO as well, and we should write
an astropy based tool for this. Maybe another 3rd party tool has solved this already.

2. Use the fact that the gridder (spec_driver_fits) can actually take a list of SpecFile's
and grid.  This has now been built into the new version **grid_data.py**. The old
version only allowed a single SpecFile.
CAVEAT: make sure that all bad pixels were removed from the specfile, as the pix_list from
the first lmtoy_OBSNUM.rc is used. We need a better interface for this.
