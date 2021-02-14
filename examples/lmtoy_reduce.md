#  A short introduction in using lmtoy_reduce.sh

**lmtoy_reduce.sh** is a bash shell script, inspired by the scripts
Mike Heyer shared. Its intent is to reduce Sequoia OTF data
without any guidance from the user, as well as prepare (or even run)
ADMIT on the final cube. This is a simple proof of concept to learn
how to generalize LMT reduction scripts, with the added bonus that we
get some science done in a waterfall fashion!

For an observation consisting of a set of OBSNUM's a typical reduction
strategy could be as follows:

* First use **lmtoy_reduce.sh** for each OBSNUM. Make sure you cull out the
spectra that are bad, by reviewing logs, figures and data, edit the parameter file and
re-running the script. 

* If applicable, use **lmtoy_combine.sh** for the series of previously
determined good OBSNUM's. 


## Running lmtoy_reduce.sh

This script reduces a single OBSNUM, and uses a series of *keyword=value* commandline
argument pairs to construct a parameter file.
The commandline parser is a very simple one, and does not check if you spelled
the parameters correctly.  On the first run **path=** is required, but **obsnum=**
is required for each run

      $LMTOY/examples/lmtoy_reduce.sh \
	    obsnum=91112                # always required
	    path=data_lmt               # optional via $DATA_LMT
	    obsid=                      # optional on first run [not yet implemented]
	    dv=100                      # optional:  width around spectral line (vlsr) 
	    dw=250                      # optional:  width of the wings for baseline
	    rc=0                        # optional:  force a new rc file (i.e. new run)
            makespec=1                  # optional:  make the specfile
	    makewf=1                    # optional:  make a fits waterfall cube from specfile
	    makecube=1                  # optional:  grid fits cube from specfile
	    viewspec=0                  # optional:  view specfile
	    viewcube=0                  # optional:  view fits cube
	    extent=400                  # square map from -extent:+extent (arcsec)


On the first run it creates the **lmtoy_OBSNUM.rc** parameter file,
which is nothing more than a collection of shell variables that the
script uses. This parameter file can be edited and you can
re-run the script. Remember there are no spaces left and right of the '='
sign in an rc file, this is bash, not python!

In the end the script creates a FITS cube **SRC_OBSNUM.fits**, as well
as a FITS weight map **SRC_OBSNUM.wt.fits**.  The current version the
script is not smart enough, for example the spatial **extent=** is
still hardcoded, and the baselining area is guessed based on a VLSR
(from data header) and WIDTH (**dv=**).  Future versions should
improve on this.  The script will produce a number of logfiles and
plots from which better values for the pipeline parameters can be set.

If NEMO was installed, it will create a few ancillary files, but most
interestingly, the noise flat **SRC_OBSNUM.nf.fits** cube, and a
smoothed version **SRC_OBSNUM.nfs.fits** cube, on which ADMIT can be
more reliably run to the otherwise noisier edge.

If unhappy with the initial settings, or if you want a different
y_extent, b_order, otf_select etc.etc., edit or add them to the
**lmtoy_OBSNUM.rc** parameter file. The names of the variables are the
same as the ones used in the SLR scripts, except we use a
*keyword=value* syntax with no further error checking.

To re-run the pipeline only **obsnum=** is required. Since gridding
(makecube=1) is much faster than making a spectrum (makespec=1), with
the makespec=0 parameter you can re-run a new gridding experiment. In
some examples below a few examples how to compare the RMS for
different gridding settings (see also Appendix C in the SLR manual).

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

If NEMO or ADMIT had been run, a number of other files and directories will be present.

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


# Short description of LMTSLR scripts

The following scripts are used by the **lmtoy_reduce.sh** pipeline.
All scripts should self-describe using the **-h** or **--help** flag.

* **lmtinfo.py**:            gathers info what OBSNUM's you have, or for a specific OBSNUM selected, useful info for the pipeline
* **process_otf_map2.py**:   converts RAW to SpecFile
* **process_otf_map.py**:   *deprecated version*
* **view_spec_file.py**:     make a series of plots summarizing one or a set of pixels
* **view_spec_point.py**:    show average spectrum for each pixel in a radius around a selected point
* **make_spec_fits.py**:     convert SpecFile to a FITS waterfall *"SAMPLE-VEL-PIXEL"* cube
* **grid_data.py**:          grid a SpecFile into a FITS *"RA-DEC-VEL"* cube
* **view_cube.py**:          make a series of plots summarizing a FITS *"RA-DEC-VEL"* cube

We now highlight some keywords for a few selected scripts:

## "lmtinfo"

The **lmtinfo.py** script makes a summary listing of the OBSNUM's you have, e.g.

      lmtinfo.py $DATA_LMT
      
      #     DATE           OBSNUM   SOURCE     RESTFRQ VLSR INTTIME
      
      2018-11-16T06:48:30  079447  IRC+10216   115.271  -20       8
      2018-11-16T06:48:52  079448  IRC+10216   115.271  -20     686

      2019-10-31T03:01:32  085775  Region_J-K  115.271 -296       7
      2019-10-31T03:01:57  085776  Region_J-K  115.271 -296    1471
      2019-10-31T03:31:05  085777  Region_J-K  115.271 -296       8
      2019-10-31T03:31:31  085778  Region_J-K  115.271 -296    1483
      2019-11-01T03:09:20  085823  Region_J-K  115.271 -296       7
      2019-11-01T03:09:48  085824  Region_J-K  115.271 -296    1488

      2020-02-18T01:08:23  090910  NGC5194     115.271  463       7
      2020-02-18T01:08:47  090911  NGC5194     115.271  463    3986
      2020-02-20T01:03:30  091111  NGC5194     115.271  463       7
      2020-02-20T01:03:56  091112  NGC5194     115.271  463    6940


NOTE: Although VLSR -296 agrees with NED, it is the systemic velocity of M31,
which could throw off current auto-baselining for fields away from the
minor axis ofr M31. The one used for M51 (463) does not agree with NED (611)


## "Process"

The conversion from RAW to SpecFile is the "*process*" script. They
differ slightly depending if you have an OTF, MAP, PS or BS type
observation. There is a different script for each. Here we describe
the important parameters for **process_otf_map2.py** script, the
currently recommended procedure for OTF data.  We also refer to this
script in the **makespec=1** setting.


### b_regions

A set of [channel0,channel1] ranges (in VLSR) can be
selected. Typically you would select a set on either side of the
spectral line. The **lmtoy_reduce.sh** will make an initial guess based on
**vlsr,dv and dw**, but you can edit the parameter file and work with
posterior values.

If multiple lines are in the spectrum, and **b_order>0** it will
likely be important to straddle all lines. For a line forest, all bets
are off.

### b_order

The order of the baseline polynomial. Depending on the amount of
channels used, and the gap inbetween, the **b_order** cannot be too
high. Typically 0 should do, which is also the default.

### l_regions

Why do we even need this? Is says this is for line fitting.  Or is
this the eqv. of my suggested VLSR and DV?

### slice

This is the channel range (usually in VLSR) that are to be written out
to the specfile. Useful to limit the amount of data.

One caution: this has to be used with some care. If the slice does not
contain the b_regions, those sections of the b_regions would not be
used for fitting!

If multiple spectral lines are present, they could be selected with
this keyword, but a new keyword --restfreq will be needed to correctly
set the velocity scale. This might become a future option.


### stype

This controls how the OFFs are combined with the ONs to create a
calibrated spectrum.  0 for median, 1 for a single reference, and 2
for bracketed reference spectra. The default is 2.

### pix_list

If you already know certain pixels are bad, no need to include them
for the SpecFile. But certainly on the first run, better leave them
all in, and inspect via a Waterfall Cube or the other plots from
view_spec_file which pixels should be discarded for the SpecFile.

Note there is a pix_list in a number of scripts in the pipeline, which
in principle means they could differ. Within the pipeline they are all
the same.

It is also important to be sure to cull as many pixels as are needed,
not just to make a smaller SpecFile, but to ensure the
**lmtoy_combine.sh** script to properly work.



## "Gridding"

There are a few parameters to the gridding program (**grid_data.py**) that are worth a few comments. The parallels to
how CASA's **tclean** program controls the gridding are not too different. The
following parameters are all related and pertain to the gridding/convolution function:

      --resolution          # should be lambda/D because the gridder assumes it, despite that the real one is 1.15 larger
      --cell                # should be 1/2 of resolution, smaller is ok, but larger is not.
      --otf_select          # SLR recommends 1
      --otf_a               # SLR recommends 1.1
      --otf_b               # SLR recommends 4.75 (should be 1 for a gauss otf_select=2)
      --otf_c               # SLR recommands 2.0
      --sigma_noise         # should be 1
      --rmax                # should be 3

and a few filters what spectra to be added to the gridding

      --pix_list            # which pixels are to be included
      --rms_cut             # which spectra are rejected (but see below)
      --sample              # remove samples per pixel

###  resolution

You might think this should be 1.15 * lambda/D, but it depends on the
filter (otf_select), and it's parameters. For otf_select=1 the beam
should be 1.15 * resolution.  For otf_select=2 the beam should be
otf_b * resolution.  The pipeline script will also round this value up
to the neareset arcsecond.

At CO 115.27 GHz this is 12.3". Currently the user has to supply it, ideally
we set it from the skyfreq.

###  cell: pixel size

The cell size should be resolution/2, if you want to follow
Nyquist sampling, but anything a bit smaller is ok as well. At CARMA
we used a ratio of 3, at ALMA they decided on a ratio of 5!

###  otf_select:  the choice of filter

Up to three parameters are used to control the shape of the filter (otf_a, otf_b, otf_c)

* 0 = box:   this uses cell as parameter (i suggest we should use resolution)
* 1 = jinc : this uses otf_a, otf_b and otf_c as parameters. Discussed in Appendix C
* 2 = gauss: this uses otf_b as the factor by with resolution is multiplied.
* 3 = triangle: this uses resolution as parameter
* 4 = box:   but using the resolution as parameter

### rmax: convolution size factor

This is the dimensionless factor how many resolutions the convolution
filter should be sampled. There is a secondary parameter how many
samples are taken out to rmax, which defaults to 256. These is little reasons to
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
in all scripts that use it. Here you can make an additional selection.
Useful if you want to make mape per pixel and perhaps change
the initial pix_list for the **process** portion of the pipeline. Pixels
are counted from 0 to 15.

### rms_cut: cull spectra with high rms

In the original version spectra with RMS > rms_cut would be rejected, across
all pixels. A slightly better version is to find the "MAD" (Median Absolute Deviate)
of the distribution of RMS, and reject all spectram with RMS  > median + factor * MAD_STD.
When rms_cut < 0 we assig factor = -rms_cut, a dimensionless number. A value of -3 or -4
seems to be working well.

Data prior to 2020-02-18 suffered from occasionally corrupted spectra
due to a doppler tracking based mishap. These data in particular can be easily
culled when rms_cut=-4 was set.

### sample:  remove samples per pixel

This one (for now) replaces the non-existent time flagging. Each pixel has a number
of samples, which can be seen in the RMS plots, or the waterfall plot or fits file.
The format is the pixel number, and starting and ending sample number, where 0 is the
first.


### noise_sigma:   RMS weighting

The measured RMS in each spectrum (describe what that is: RMS from the fitted baseline
in the b_regions?) can also be used to weigh (1/RMS^2) each spectrum when these spectra
are combined in the gridding process.


# Advanced concepts:   Combining maps from different OBSNUM

A common situation is that maps from different OBSNUM are
combined. There are several approaches:

1. Use the .fits and .wt.fits of all obsnum to create a weighted
map. Assuming the maps have the same WCS grid, this is a simple
mathematical operation, which can be easily done in
astropy.  Packages such as NEMO, Miriad, CASA and Montage can all do
this. We could write our own astropy based tool for this.

2. Use the fact that the gridder (spec_driver_fits) can actually take
a list of SpecFile's. This has now been built into the
latest version of **grid_data.py**.  The old version only allowed a
single SpecFile.  CAVEAT: make sure that all bad pixels were removed
from the specfile, as the full pix_list (0..15) will be used,
and will rely on the SpecFiles to contain the good spectra/pixels.

There are two different ways to make a weight (.wt.fits) map.

## lmtoy_combine.sh

Example for our M31 data (see also "make bench31" in examples)

      ./lmtoy_reduce.sh path=M31_data obsnum=85776 > lmtoy_85776.log 2>&1
      ./lmtoy_reduce.sh path=M31_data obsnum=85778 > lmtoy_85778.log 2>&1
      ./lmtoy_reduce.sh path=M31_data obsnum=85824 > lmtoy_85824.log 2>&1
      ./lmtoy_combine.sh obsnum=85776,85778,85824  > lmtoy_m31.log   2>&1

but again, for now this depends on each OBSNUM having the bad pixels removed
during the "makespec" stage. 

Dangerous assumptions:  gridding may not work if certain header variables
(e.g. RA,DEC center) are not the same. Also, the --sample flag cannot be
applied, as it would be applied to each OBSNUM

The "bench31" target in the Makefile compares the two methods 1) and 2) and
they agree to the 1e-7 level, but at the 1e-6 level one can see an imprint
of the CO lines.

## lmtrc.py

When a large number of obsnum's are processed, once a single good rc file
has been decided (with the correct extent, b_regions, l_regions etc.) they
can simply be copied, e.g.

      for o in 91113 91115 91117; do
          cp lmtoy_91111.rc lmtoy_${o}.rc
      done		    

After this, inspection of each OBSNUM will show which pixel etc. will need to
be culled for gridding, and the scripts can be rerun for a clean set of
SpecFiles for each OBSNUM.  After this lmtoy_combine.sh can be run for a clean
combination, or the cubes can be combined.

If for some reason all rc files need an edit, consider using the lmtrc.py script,
e.g.

      lmtrc.py lmtoy_9*.rc otf_select=2 otf_b=1.5

after which you can either re-run all single cubes, or just run for example

      lmtoy_combine.sh obsnum=91111,91113,91115,91117

