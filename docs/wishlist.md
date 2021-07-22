## Overview of changes to LMTSLR

This list also contains the suggestions  Mark Heyer sent around earlier, but
not all the ones from the 8-jan-2021 list.

1. SpecFile now has spectra as float, the RAW data were double, thus
  saving 50% memory. In fact, the RAW data are actually integers (but
  16bit not enough) , some compression schemes could be used to shrink
  that if need be. Potentially more memory could be saved if the selected
  *slice*, not the full spectral band, are retrieved in memory. This
  depends if the data is doppler tracked or not (which it is).

1. buffer overruns in C gridder program have mostly (all?) been solved
  now.  There were issues with the convolution going over the edge,
  non-square maps and WCS errors. In the latest version (14-jan-2021)
  this turned up as a 1 cell offset that was fixed.  Segfaults show up
  as Error 11 in the gridder.  Non-square maps also suffer from
  another X-Y axis reversal, there is still an error left here.
  [https://github.com/astroumd/lmtoy/issues/9]

1. more header information passing from RAW to FITS, e.g. for ADMIT to
  work. Need to confirm if other things in CASA and MIRIAD also work
  correctly.
  [https://github.com/astroumd/lmtoy/issues/12]

1. the pipeline now outputs a lot more useful info (map extent in
  position and velocity, noise stats per pixel, etc.).  Some of the
  current info is not well labeled , and hard to understand for
  newcomers, so still need some serious labeling and cleanup.

1. gridder now writes a weight map, when used this makes for better
  results in ADMIT.  In the code you can also write out a 0/1 map
  which cells had a pixel inside, but this is not a flag. Can be
  emulated with otf_select=0 and a mask on that, which requires a
  re-run of the gridder.

1. add otf_select=3 option to use a triangle convolution filter. In the
  end, normalizing to the same RMS, there are no noticable visual
  differences. Need a more detailed analysis like in SLR Appendix C?

1. by default, now only cells will be given a value if there was at
  least one pixel in it. This only works well for convex areas. For
  small cell size there can be empty cells surrounded by filled
  cells. In these circumstances it would be useful to turn this option
  to the old default, based on weight from the convolution.

1. a number of NEMO tools were added that might need a python
  (astropy) equivalent if deemed useful.

1. The script **lmtoy_reduce.sh** is a simple pipeline, intended not to
  need user input, other then the obsnum. See
  [lmtoy_reduce.md](../examples/lmtoy_reduce.md).  Script can also be
  re-run and learn from new parameters.

1. There is a benchmark (IRC+10216, obsnum=79448) but it's not public
  data yet. Should we? who is the PI? This is commissioning data with
  some "wrong" headerinfo, so it's scientifically not correct. Keep it
  for developers only?

1. A new script **lmtinfo.py** that spits out some useful variables in
  "rc" (bash) format. Used by the **lmtoy_reduce.sh** script. This
  could be expanded to provide better guesses on baselining for
  example.

1. rms_cut is now allowed to be negative.  This will cause it to compute
  a robust mean and std, and use (now per pixel!) a cuttof of
  mean + |rms_cut|*std.  So a value of -3 or -4 should be sufficient
  to get rid of the doppler tuning problems of the data prior to Feb 19, 2020.
  Caveat  rms_cut<0 is only supported in the gridder, not the viewers.

1. New script **view_spec_point.py** to overplot spectra. Also uses the new
  docopt based user interface, where --help shows defaults and additional
  help like a unix man page. All new scripts use docopt.

1. New Plots() interface with  a --plots= command line interface allows
  users to easily switch between interactive and batch png (or pdf) files.
  The first example is in **view_spec_point.py**, though some issue with
  multi-panel plots   [code not committed yet]

1. New script **make_spec_fits.py** that makes a waterfall fits cube

1. The **lmtoy_combine.sh** is able to combine multiple SpecFile's and create
  an output cube

1. There is a new --sample flag in the gridder, to allow you to mask out
  samples from given pixels. The argument is a multiple of 3 integers:
  P,S0,S1, where P is the pixel number (0...15), and sequence from S0 through S1
  are then not included in the gridding. S0 can start at 0, S1 can max out
  to whatever number it has for that pixel, consult your output for this.
  There is no check on valid values, so you can set --sample 99,-100,-10

1. There is a new -a flag in **spec_driver_fits**, for which the output weight file
  (the -w flag) will contain the beam. This is achieved by rewriting the
  internal SpecFIle to contain one  pixel at (0,0) with 1 channel of
  intensity 1.0.  See also Appendix C in the SLR manual.  
  **NOTE: the option has been removed in favor of the --model, see below**

1. The **lmtoy_reduce** script also writes a "wt2" and "wt3" map, to aid in combining
   maps at the cube stage, without having to go through the specfiles. Eventually
   this will be cleaned up in favor of a single weight map.

1. $DATA_LMT is now more used (dreampy3 was already using it). 

1. Tsys spectra are now stored as Data.Tsys(ncal,npix,nchan) as of March 6, 2021.
   If there are embedded CAL's in a MAP, and those are used in the calibration,
   each CAL will be stored as a separate spectrum for each pixel. The **view_spect_file**
   script will display them.

1. Some plotting functions are now using the plots module, which allows scripts to
   use the --plots method to easily switch between on-screen plots and files (e.g. png
   or pdf).

1. A -a (or --model) flag to spec_driver_fits (the gridder) was re-implemented with a model
   filename (convolved with LMT beam) so the gridding can be checked. This is currently
   dumped in channel-0 with the then wrong WCS.  It is meant for debugging, and not for
   users. In theory we can make this a more formal feature via grid_data.py

1. The writing of the specfile suffers from writing dynamic arrays (that grow) into
   netcdf variables. Behind the scenes this may be just as bad as appending, but it's
   very slow. The relevant loop over all pixels in _create_nc_data() went from 100" to 37"
   on one particul benchmark.  The variable fast_nc = True should be used to use the new
   (slightly more memory consuming) faster version.

## A wishlist

In no particular order, there are some remaining things on the wish
list, the important ones are tracked in our [github
issues](https://github.com/astroumd/lmtoy/issues) list.  I've also
added a few that Mark Heyer listed in his reports.

1. A better auto-baselining. The current VLSR (from netcdf) and
  guessed DV and DW only does that much, but it's ok for a first
  start. The M31 data is already showing the VLSR is no good, as the
  VLSR of the galaxy is not appropriate for the small patches in the
  M31 survey the LMT undertook.

1. The Commandline Parser. I propose using docopt instead.
  A few subitems:

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
    file. Honestly, I believe the configuration is overrated and I
    would like to see it gone (would simplify this exploding parameter
    problem). This parameter file also seems to place different -
    possibly conflicting - defaults in different places.

1. There are still a few places in the C code that don't exit, where
  they should, for example if malloc() fails. Error messages need to
  be more descriptive in some places.

1. Options to smooth/bin in velocity?  Or leave this to 3rd party
  tools?  [NEMO writes an .nfs. cube, which is a NoiseFlatSMoothed
  version so ADMIT can run on it.]   CASA should be good test for this.
  The make_spec_fits waterfall script has a --binning= option.

1. RFI blanking - do we even need this? Is the --sample flag good enough?

1. Add a time column to the SpecFile (--sample can solve this too)

1. SpecFile vs. SDFITS.

1. Masking file with more flexible filtering:
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
  in front of a directive.

  This is quite involved, and not clear with the current capabilities if
  we still need it.
      
1. Additional parameters from the Hedwig proposal system should go in
  the workflow, so they can be used in the pipeline, and eventually go
  into FITS

       vlsr (e.g. M31 has issues) for small fields of a big object ?
       width - expected width of the line in the field - for baselining 
       extent (in X and Y different ?)
       observer (the PI name ?)
       instrument (for FITS)

  Additional experience with ADMIT and CASA could expose a few more
  things that are useful to have

1. An algorithm to fix the doppler update problem (data < Feb 18,
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

1. A number of fancy options (e.g. allow different projection systems, galactic included)
  can probably solved much easier by using the *Montage* package after our pipeline.
  Rotated frames?

1. visualizing the OFF positions?  The SpecFile has lost them.  There is no view_raw_file.
  Is a waterfall for raw data useful?

1. multiple spectral lines? Or if for any reason you want different
  SpecFiles, use the proposed obsid= keyword.  For any subsequent runs
  the obsnum=${obsnum}${obsid} would then be used. The default for
  ${obsid} would be a blank string

  For example, the initial run has a restfreq default for CO, but for some crazy line XY at
  115.38211 GHz a new narrower cube is made:
  
      ./lmtoy_reduce.sh obsnum=79448 obsid=_CO slice=[-100,100] 
      ./lmtoy_reduce.sh obsnum=79448 obsid=_ZZ slice=[-100,100] restfreq=115.38211 dv=50 dw=100dth
      

  And any repeat runs now with

      ./lmtoy_reduce.sh  obsnum=79448_CO
      ./lmtoy_reduce.sh  obsnum=79448_ZZ


### Keyword Sanitation:

Keyword names should make sense, have sensible defaults.

1. extent: is the half the map , or the full map. also, we imply we can
  only make maps from some -X to +X.

1. sigma_noise -> rms_weight, and should be a boolean

1. pix_list: we use the concept called pixels for what really are the
  beams. Once we grid, the parameter is --cell, so I refer to concepts
  such as if pixels were in cells etc. I started a glossary.

1. otf_select -> otf_filter ?

1. maxwt (and FCRAO keyword) - but the name minwt makes more sense, as
  this in the minimum weight in a cell preventing it from being masked
  via a NaN. I had a --min_neighbors idea.


## Procedure: Adding a variable from RAW -> SPECFILE ->  FITS

string handling in particular is just out of this world, even in python.
is that a netcdf oddity? It's nuts.


1. make sure it comes from RAW into specfile
   ifproc.py -> spec.py -> specfile.py
2. put it in SpecFile.h and grab it in SpecFile.c read_spec_file()
3. put it in Cube.h and write it in write_fits_cube()
4. pass it from S to C in the main() driver in spec_driver_fits.c



## Procedure: Adding another parameter to the gridding program


grid_map is probably the worst, it requires 8 times a similar
modification to 5 files to add a keyword

Here are the different orderings, the first one being the one we adopt
to adjust the others:


      1. bin/grid_data.py                   15 options passed to spec_driver_fits
      2. lmtslr/utils/configuration.py      help file (--help) with 15 options
      3. lmtslr/utils/argparser.py          self.parser.add_argument()
      4. C/OTFParameters.h                  struct definitions
      5. C/OTFParameters.c                  struct elements get their default
      6. C/OTFParameters.c                  long_options[] is defined
      7. C/OTFParameters.c                  getopt_long() is called with short options
      8. C/OTFParameters.c                  switch(coption) to set the values


I decided to jot this down as I added the weight (-w) flag.
Having so much work to do for a little does not encourage app hacking.
I wanted an option to enable/disable edge blanking.... it's now #if hardcoded. There
should be a better way to pass parameters and provide help.



## Masking / Blanking file

Any such ascii files should allow comments in the form that python/bash allow:
a line starting with '#' is preferred, but we should also allow a '# comment'
after any legal commands/directives.

### RSR

For RSR there are already two formats for a masking/blanking file. They are closely
related, and how a rather fine grained approach to masking:

1.  rsr_driver.py uses the --rfile file, which is an ascii file, with comma separated
    obsnum,chassis,band integers.  obsnum can also be a range by using a dash between
    the two integers,e.g.

       12345,2,3
       12350-12360,1,2

2.  rsr_sum.py uses a blanking file which contain three sections:  windows,obslist and
    blankings.
    1. windows define the sections where baseline fits are done, useful to ignore
       strong lines
    2. obslist is either a comma separated list of obsnums, or a range of obsnums
    3. blankings contain two or more items: obslist, chassis and band:freq

           #    
           windows[1]=  [(87.0,91.5)]
           #
           28190,28191
           58618-58620
           #
           7553          2   {1: [(74.,75.)]}

Question:   in RSR data typically there are a number of repetitions, each of order 30". But in either
flaggings a selection of chassis/band seems to be applied to all repetitions.
    
### SLR

There is no blanking file for SLR. A few keywords allow blanking by pixel/beam (--pix_list), by rms value (--rms_cut)
and some hard to determine list of sample ranges per pixel (--sample).

### Live Stream netCDF/RAW data

Given that the procedure to read live stream data is something like the following:

  
        nc = netCDF4.Dataset(filename)
	while True:
		nc.sync()
                datatime = nc.variables['Data.Integrate.time'][:]
                print("Found %d " % len(datatime))
                #check for change in BufPos to see when ON is done
                #slice accordingly and do the incremental work
                sleep(1)


any re-design of the SLR (RSR to a lesser extent?) is quite major, given the extra
constraint that the IFPROC and 4 ROACH file each have their own clock, but mostly
the 125Hz IFPROC needs to be re-sampled for the 10Hz ROACH files.more j
	    
