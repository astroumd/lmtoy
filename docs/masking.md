# Masking

Masking (blanking, flagging) is the operation by which we can remove data
from any subsequent operations, leading to the final gridding or
stacking. We do this by setting a mask in python, so there is an option
to unset the mask and get the data back. This also includes keeping track
of the masking operations, so we can undo or apply a set of masking
operations to another observation.

*there could also be options to interpolate across masked data*.


There are two ways to achieve masking: a command line flag and a text
file with directives (ignoring interactive).  There is also the
confusion that some command line flags cause data to be included,
others to be excluded.  Combinations of both methods are used in RSR,
though SLR is using all command line options.

These are masking operations: they keep the data, but just mask it. There is also the
flltering operation, remove data alltogether, to lower the data space. See a later
section below.

## RSR-Sanchez

This is the simplest masking file format, passed to **RSR_driver.py** using the **--rfile**


        obsnum  chassis  band
  

## RSR-Yun

The original **rsr_sum.py** had a code-based masking method, which
was converted to using a masking file. This format is close to the Sanchez format,
but allows for a more detailed masking:

        windows[N] = [(f1,f2),(f3,f4)]             # for baselining
        obsnum                                     # inclusive
        obsnum chassis bank                        # masking a full bank
        obsnum chassis bank:[(f1,f2),(f3,f4)]      # masking, dictionary for the bank

in order to decide on their values, detailed inspection of the spectra was required.

Notice this format also sneaks in the baselining parameters.

## SLR

Current masking is only done via command line flags:

        --bank	    	        bank to use (0 or 1)       [band in our new terms]
        --pix_list              pixels to use (0..15)      [beam in our new terms]
        --eliminate_list        remove channels            [chan]
        --slice                 channel section to keep    [chan, but special]
        --sample                time samples to remove     [time]

As we discussed elsewhere, LMT spectral data can also be seen as dimensioned as follows:

        DATA[time,beam,pol,band,chan]

though not all dimensions need to be populated.

There are two types of masking:

* masking based on a slice in this (time,beam,pol,band,chan) space. On the simplest level
  this can be done using 0-based integers
  with inclusive (min,max) notation, e.g. **time(0,10)**,
  or using their acceptable WCS designations, e.g.

       -time(12:05:10,12:30:05)                         # on the same day
       -time(2021-10-31T23:30,2021-11-01T00:30)         # ISO notation if day boundary is crossed
       -beam(5,7)                                       # beams (pixels for some) 5,6,7
       -pol(XX)                                         # XX if they are labeled (they should)
       -band(USB)                                       # band, if labeled
       -chan(10km/s,20km/s)                             # RESTFREQ is needed here
       -chan(104.1GHz,104.14GHz)                        # by freq
       -obsnum(12345)                                   # by obsnum

  and combinations can be made to designate higher-dimensional slices, for example

       -beam(5,7),pol(XX)

  would mask the XX polarization for bands 5, 6 and 7 (for all times, beams and channels)

  Some exceptional names can be used if they have an overloaded meaning. For example, each beam
  will have an (RA,DEC) associated with it, thus

       -ra(12.34,12.50),dec(34.2,35.0)
       -glon(120.0,121.0),glat(20,21)
       -ha(h1,h2)
       -lst(lst1,lst2)
       -elevation(el1,el2)
       -dra(p1,p2)
       -ddec(p1,p2)
       
  are all acceptable ways to deal with selecting. The current SpecFile does not export some
  of these variables, but they are commonly seen in other observatory SDFITS file, so we
  should discuss which ones are possibly relevant to us. They are not part of the CORE
  SDFITS agreement.

  Note the preceding minus sign is an explicit way to see this needs to be masked. If they are
  left off, masking is assumed. But to include it back, an explicit + is needed.

* masking records based on other meta-data (SDFITS columns) being in some range (if numeric)
  or matching, if a string

       -select(TSYS, 250.0, 999)
       -select(RMS, 3.0, inf)
       -select(OBJECT, NGC1234)

  If a selected range variable is not a column, but a keyword constant, there will be
  a warning and the masking is applied (or not) to all data!

* If no + or - is given in front of the specification, a - is assumed, i.e. that slice is masked.

* blank lines, or anything after a '#' is taken as a comment

* A line starting with a '{' is special, it's a raw format for testing (see below)

###   ObsNum

A few words on the **ObsNum** at LMT.  RSR observations are small (few MB), and it is not uncommon to combine many
ObsNum's for the stacking operation. Thus it is not unreasonable, in fact encouraged, that the SDFITS file contains
all the ObsNum's that should be part of the observation. The ObsNum will thus become an OBSNUM column in the SDFITS
BINTABLE, so it can be selected on later (as is already common in the two blanking files we discussed before).

For SLR there is no reason why multiple ObsNum's could not be combined, except these files are large, and it will
challenge the memory you have on your processor. A more common and sensible solution is to process one ObsNUm per
SDFITS file, then grid each into a FITS cube, and do a weighted average to produce the final cube.

###   Questions

1) With this logic, how does one mask 2 slices?

     chan(10,20),chan(50,60)

   or should we allow an even number of values,

     chan(10,20,50,60)

2) how to pick beams (pixels)?

     beam(1),beam(4)

3) units. for those should we embed, or separate?

     chan(104.1GHz,104.14GHz)
     chan(104.1,104.14,GHz)
     chan(104.1,104.14)GHz

4) An example of the complex RSR-Yun blanking:

      obsnum chassis bank:[(f1,f2),(f3,f4)]

   could be

      beam(1),pol(0),band(3),chan(71,71.5,82,83,GHz)


5) For testing we will allow a low level masking file, in the 'raw' format

    {2: '1', 0: '35,37', 4: '512,514', 'id': 'RFI'}

   since that is what is used under the hood. It will be better to not use integers for the numbers,
   but the agreed upon mnemonic, viz.  (time,beam,pol,band,chan) so the mask would read

    { 'time': '35,37', 'pol': '1',  'chan': '512,514', 'id': 'RFI'}


6) Is Panda's better than NDarray?   In my GBTOY experiments I noted some terrible deficiency of porting
   SDFITS to Panda's. Might need a review.


## GBTIDL

Some examples from the gbtidl manual
   
     #ID, RECNUM, SCAN, INTNUM, PLNUM, IFNUM, FDNUM, BCHAN, ECHAN, IDSTRING
     0 * 35:37 1,3 * * * 512 514 RFI

where they label (the IDSTRING) each flag. For us this would look something like

      mask[0]    = '35,37'     # scan
      mask[4]    = '512,514'   # chan
      mask['id'] = 'RFI'

and later to retrieve:

      cmd='mask=%s' % str(mask)

In gbtidl there are whole procedures to flag and unflag. By keeping an ascii representation of the mask,
we can mask and unmask in a similar fashion.


# Filtering

Some options are to narrow down the data. In the SLR pipeline those are

      --bank                cf. band()
      --pix_list            cf. beam()
      --slice               cf. chan() 

which would cause actual data not to be copied to the SDFITS (or SpecFile) file.

The two RSR scripts really don't have any options to physically remove data, they are all masking operations.

Obviously for filtering there is no way back, the RAW data will need to be re-ingested into SDFITS.


