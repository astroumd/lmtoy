# Overview of changes to LMTSLR

This list also contains the ones Mark Heyer sent around earlier.

* process spectra as float, the RAW data are double, saving 50%
  memory. In fact, the RAW data are integers (but 16bit not enough) ,
  some compression schemes could be used to shrink that. Potentially
  more memory could be saved if the selected *slice*, not the full
  spectral band, are retrieved in memory. This depends if the data is
  doppler tracked or not (I believe it is)

* buffer overruns in C gridder program. One was the convolution running
  over the edge (big maps would prevent this).
  Also needed to fix Cube and Plane access for non-square maps
  (using square maps would solve that). 
  Segfaults show up as Error 11 in the gridder.

  Note added: I've still seen a segfault, but harder to reproduce.

* more header information passing from RAW to FITS, e.g. for ADMIT to
  work. more to come (e.g. HISTORY). Need to confirm if other things
  in CASA also work correctly.

* the pipeline now outputs a lot more useful info (map extent in
  position and velocity, noise stats per pixel, etc.), but more is
  needed. Some of the current info is not well labeled , and
  hard to understand for newcomers. 

* now writes a weight map, when used this makes for better results in
  ADMIT.  In the code you can also write out a 0/1 map which cells had
  a pixel inside, but this is not a flag. Can be emulated with
  otf_select=0 and a mask on that, which requires a re-run of the gridder.

* add otf_select=3 option to use a triangle convolution filter. In the
  end, normalizing to the same RMS, there are no noticable visual
  differences. Need a more detailed analysis like in SLR Appendix C?

* by default, now only cells will be given a value if there was at
  least one pixel in it. This only works well for convex areas. For
  small cell size there can be empty cells surrounded by filled
  cells. In these circumstances it would be useful to turn this option
  to the old default, based on weight from the convolution.

* a number of NEMO based tools were added that might need a python
  (astropy) equivalent if deemed useful. 

* The script **lmtoy_reduce.sh** is our simple pipeline, intended not
  to need user input, other then the obsnum. See
  [lmtoy_reduce.md](../examples/lmtoy_reduce.md).  Still a few things
  to wrap up (e.g. spatial extent).  Script can also be re-run and
  learn from new parameters.

* There is a benchmark (IRC+10216) but it's not public data yet. Should we? who
  is the PI? This is commissioning data with some bad header info, so
  it's scientifically not correct. 

* A new script "lmtinfo.py" that spits out some useful variables in "rc"
  format. Used by the lmtoy_reduce.sh script. This could be expanded to
  provide better guesses on baselining for example.

* rms_cut is now allowed to be negative.  This will cause it to compute
  a robust mean and std, and use (now per pixel!) a cuttof of
  mean + |rms_cut|*std.  So a value of -3 or -4 should be sufficient
  to get rid of the doppler tuning problems of the data prior to Feb 18, 2020.
  Note:  rms_cut<0 is not supported by all scripts yet!

* New script "view_spec_point.py" to overplot spectra. Also uses the new
  docopt based user interface, where --help shows defaults and additional
  help like a unix man page. All new scripts use docopt.

* A new Plots() interface with  a --plots= command line interface allows
  users to easily switch between interactive and batch png (or pdf) files.
  The first example is in "view_spec_point.py"

* New script "make_spec_fits.pu" that makes a waterfall fits cube 


# A wishlist

In no particular order, there are some remaining things on the wish
list, the important ones are tracked in our [github
issues](https://github.com/astroumd/lmtoy/issues) list.  I've also
added a few that Mark Heyer listed in his report.

* A much better auto-baselining. The current VLSR (from netcdf) and
  guessed DV and DW only does that much, but it's ok for a first
  start. The M31 data is already showing the VLSR is no good, as the
  VLSR of the galaxy is not appropriate for the small patches in the
  M31 survey the LMT undertook.

* To encourage making apps, the keywords belonging to the app should
  be with the code with minimal repetition of the keyword
  names. Should we look at e.g. click , docopt, clize.  The new
  view_spec_point.py script uses docopt to see how we like this.
  Thus this item has been tried out, and if deemed a good thing,
  conversion of other script can be done.

* Here and there more sensible defaults are needed for
  keywords. [docopt would solve this too]

* Using the -c flag and the other options are confusing.  Would be
  nice if the other options can override the configuration
  file. Honestly, I believe the configuration is overrated and I would
  like to see it gone (would simplify this exploding parameter
  problem). This parameter file also seems to place different -
  possibly conflicting - defaults in different places.

* There are still a few places in the C code that don't exit, where
  they should, for example of malloc() fails. Error messages need to
  be more descriptive in some places.

* Options to smooth/bin in velocity?  Or leave this to 3rd party
  tools?  [NEMO writes an .nfs. cube, which is a NoiseFlatSMoothed
  version so ADMIT can run on it.]   CASA should be good test for this.
  The make_spec_fits waterfall script has a --binning= option.

* RFI blanking

* Add a time column to the SpecFile

* Masking file with more flexible filtering:
  - by pixel number
  - by rms (absolute, or fractional [rms_cut < 0 can do that now])
  - by time
  - by sequence
  Inspired by miriad, the format could look at follows:

      time(11:20,11:35)
      sample(100,200)
      pixel(3,4)
      rms(1.5),pixel(5)
      rfi(10)
      
  have to decide on if you filter down or up, and if we allow a - sign
  in front of a directive
      
* Additional parameters from the Hedwig proposal system should go in
  the workflow, so they can be used in the pipeline, and eventually go
  into FITS

       vlsr (e.g. M31 has issues) for small fields of a big object ?
       width - expected width of the line in the field - for baselining 
       extent (in X and Y different ?)
       observer (the PI name ?)
       instrument (for FITS)

  Additional experience with ADMIT and CASA could expose a few more
  things that are useful to have

* An algorithm to fix the doppler update problem (data < Feb 18,
  2020), which causes the RMS values to have double or triple
  histograms. They are now also listed in the output of the
  **process_otf_map2.py**:

      Pix Nspec  Mean Std MAD_std  Min    Max      <RMS> RMS_max  Warnings

      0 5739    0.024 1.251 1.217  -6.629 16.754   1.201 1.785      *M 2.2
      1 5739    0.100 1.260 1.031  -8.395 19.176   1.075 3.185      *P 1.2 *M 9.1
      2 5739   -0.071 1.480 1.296 -11.787 41.735   1.314 3.442      *M 6.0
      3 5739   -0.008 1.003 0.956  -5.934 16.254   0.958 1.989      *M 4.2
      ...

   If either a **P** or **M** is warned about, the ratio of
   Std/Mad_Std is deemed to high and there are probably reason to not
   use this pixel or inspect it for perhaps more detailed
   flagging. Compare this to the M51 data where the doppler issue was
   fixed:
   
   [this is now implemented in the gridder, and the view_spec_point.py
   script is visualizing it's implications]

   Here's the stats for

         rms_cut=-4               rms_cut=-3

   IRC   84992/91816    0.926     84750  0.923
   M31a 223169/227660   0.980    222667  0.978
   M31b 210587/214998   0.979    210067  0.977
   M31c 225352/229960   0.980    224875  0.978
   M51  363812/364314   0.999    363075  0.997   [taken after 2020-02-18]


   So generally there are about 2-7% of the spectra that are doppler
   related outliers.  Looking at a wider waterfall plot, these bad
   scans and their fractions are fairly obvious.

*  A number of fancy options (e.g. allow different projection systems, galactic included)
   can probably solved much easier by using the *Montage* package after our pipeline.

* visualizing the OFF positions?  The SpecFile has lost them.  There is no view_raw_file.
  Is a waterfall for raw data useful?

## Keyword Sanitation:

* extent:   is the half the map , or the full map. also, we imply we can only make maps from
some -X to +X.

* sigma_noise -> rms_weight


# workflow

Remove some old things from the workflow:   e.g. tsys is not used

## process_otf_map2.py

- there is an stype=3 in the code
- where does the cpu go?

## grid_map.py

- there is some new otf_select=3,4 that I played with, but it doesn't seem to really
effect/improve maps. Setting the parameter to get a certain RMS gives pretty identical
looking maps. Not quantified. Probably plenty papers written on this.


# Adding a variable from RAW -> SPECFILE ->  FITS

string handling in particular is just out of this world, even in python.
is that a netcdf oddity? It's nuts.


1. make sure it comes from RAW into specfile
   ifproc.py -> spec.py -> specfile.py
2. put it in SpecFile.h and grab it in SpecFile.c read_spec_file()
3. put it in Cube.h and write it in write_fits_cube()
4. pass it from S to C in the main() driver in spec_driver_fits.c



# Adding another parameter to the gridding program


grid_map is probably the worst, it requires 7 times a modification to 4 files to add a keyword

Here are the different orderings, the first one being the one we adopt to adjust the others:


      1. lmtslr/utils/configuration.py      help file (--help) with 15 options
      2. bin/grid_data.py                   15 options passed to spec_driver_fits
      3. C/OTFParameters.h                  struct definitions
      4. C/OTFParameters.c                  struct elements get their default
      5. C/OTFParameters.c                  long_options[] is defined
      6. C/OTFParameters.c                  getopt_long() is called with short options
      7. C/OTFParameters.c                  switch(coption) to set the values

      i:o:l:c:u:z:s:x:y:f:r:n:0:1:2:m:p:q:
         ^
         b:

I decided to jot this down as I added the weight (-w) flag.
Having so much work to do for a little does not encourage app hacking.
I wanted an option to enable/disable edge blanking.... it's now #if hardcoded. There
should be a better way to pass parameters and provide help.

