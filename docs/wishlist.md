# Overview of changes to LMTSLR

* process spectra as float, saving half the memory. Potentially more
  memory could be saved if slices, not the full spectra, are retrieved
  in memory. This depends if the data is doppler tracked or not (I
  believe it is)

* more header information passing from RAW to FITS, e.g. for ADMIT to
  work. more to come (e.g. HISTORY)

* write a weight map, needs to be tested if indeed M31 works better
  now. In the code you can also write out a 0/1 map which cells had a
  pixel inside.

* add otf_select=3 option to use a triangle convolution filter. In the
  end, normalizing to the same RMS, there are no noticable
  differences.

* buffer overruns in C gridder program. One solved, more to go it seems.

* by default, now only cells will be given a value if there was at
  least one pixel in it. This only works well for convex areas. For
  small cell size there can be empty cells surrounded by filled
  cells. In these circumstances it would be useful to turn this option
  to the old default, based on weight from the convolution.

* a number of NEMO based tools were slapped together that might need a
  python (astropy) equivalent if deemed useful

* there is a toy script **lmtoy_reduce.sh** that doesn't need user
  input, other then the obsnum. See
  [lmtoy_reduce.md](../examples/lmtoy_reduce.md).  Still a few thing to
  wrap up (e.g. resolution, spatial extent).   Script can be re-run and
  learn from new parameters.

# A wishlist

* To encourage making apps, the keywords belonging to the app should be with the code with
  minimal repetition of the keyword names

* Here and there more sensible defaults are needed

* Options to smooth/bin in velocity?   Or leave this to 3rd party tools?

* Masking file with more flexible  filtering:
  - by pixel number
  - by rms (absolute, or fractional)
  - by time
  - by sequence
  Inspired by miriad, the format could look at follows:

      time(11:20,11:35)
      sample(100,200)
      pixel(3,4)
      rms(1.5),pixel(5)
      
  have to decide on if you filter down or up, and if we allow a - sign in front of a directive
      
  

# parameter file vs. command line options

- defaults in more than one place
- parameter file seems to preclude overriding it with a command line option


# workflow

Remove some old things from the workflow:   e.g. tsys is not used

## process_otf_map2.py

- use float, not double, for spectra when read as RAW [ok]
- can spectra use the slice?  this would save more memory
- --elimianteb isn't useful
- there is an stype=3 in the code
- write_line_data_header_variables() is not used,
- where does the cpu go?

## grid_map.py


# adding an occasional variable from RAW -> FITS

string handling in particular is just out of this world, even in python.
is that a netcdf oddity? It's nuts.


1. make sure it comes from RAW into specfile
   ifproc.py -> spec.py -> specfile.py
2. put it in SpecFile.h and grab it in SpecFile.c read_spec_file()
3. put it in Cube.h and write it in write_fits_cube()
4. pass it from S to C in the main() driver in spec_driver_fits.c



# adding another parameter to the gridding program


grid_map is probably the worst, it requires 7 times a modification to 4 files

Here are the different orderings, the first one being the one we adopt to adjust the others:


      1. lmtslr/utils/configuration.py      help file (--help) with 15 options
      2. bin/grid_data.py                   15 options passed to spec_driver_fits
      3. C/OTFParameters.h                  struct definitions
      4. C/OTFParameters.c                  struct elements get their default
      5. C/OTFParameters.c                  long_options[] is defined
      6. C/OTFParameters.c                  getopt_long() is called with short options
      7. C/OTFParameters.c                  switch(coption) to set the values

      i:o:l:c:u:z:s:x:y:f:r:n:0:1:2:m:p:q:

I added the weight (-w) flag.  Having so much work to do for a little does not encourage app hacking.
I wanted an option to enable/disable edge blanking.... it's now #if hardcoded.


# Gridding

There are a few parameters to the gridding program (**grid_data.py**) that are worth a few comments. The
following parameters are all related and pertain to the gridding/convolution function:

      --resolution
      --cell
      --otf_select
      --otf_a
      --otf_b
      --otf_c
      --sigma_noise
      --rmax

and a few filters what spectra to be added to the gridding

      --pix_list
      --rms_cut

##  resolution

This should be 1.15 * lambda/D, though depending on the filter, and it's parameters, there may be
a reason to take a larger value. At CO 115.27 GHz this is 12.3". Currently the user has to supply it,
ideally we set it from the skyfreq.

##  cell: pixel size

The cell size should be 1/2 of the resolution, if you want to follow Nyquist sampling, but anything a bit
smaller is ok as well. At CARMA we used a ratio of 3, at ALMA they decided on a ratio of 5!

##  otf_select:  the choice of filter

Up to three parameters are used to control the shape of the filter (otf_a, otf_b, otf_c)

* 0 = box:   this uses cell as parameter (i suggest we should use resolution)
* 1 = jinc : this uses otf_a, otf_b and otf_c as parameters. Discussed in Appendix C
* 2 = gauss: this uses otf_b as the factor by with resolution is multiplied.
* 3 = triangle: this uses resolution as parameter
* 4 = box:   bus using the resolution as parameter

## rmax: convolution size

This is the dimensionless factor how many resolutions the convolution filter should be sampled. There is a secondary
parameter how many samples are taken, which defaults to 256. These is little reasons to change this parameter,
in fact, there may be some program array overruns lurking here if set wrong.


