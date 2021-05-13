# Masking

Masking (or blanking) is the operation by which we can remove data
from any subsequent operations, leading to the final final gridding or
stacking. We do this by setting a mask in python, so there an option
to unset the mask and get the data back.
* there could also be options to interpolate across masked data*.


There are two ways to achieve masking: a command line flag and a text file with directives.
There is also the confusion that some flags cause data to be added, others to be removed
from the ensemble. Combinations of both methods are used in RSR, though SLR is all using
command line options.

## RSR-Sanchez

This is the simplest masking file format, passed to **RSR_driver.py** using the **--rfile**


      obsnum  chassis  band
  

## RSR-Yun

The original **rsr_sum.py** had a code-based masking method, which
was converted to using a masking file. This format is close to the Sanchez format,
but allowed for a more detailed masking:

      windows[N] = [(f1,f2),(f3,f4)]             # for baselining
      obsnum                                     # inclusive
      obsnum chassis bank                        # masking a full bank (or band)
      obsnum chassis bank:[(f1,f2),(f3,f4)]      # masking, dictionary for the bank

in order to decide on their values, detailed inspection of the spectra was required.

## SLR

Current masking is only done via command line flags:

	--bank	    	        bank to use (0 or 1)       [band in our new terms]
	--pix_list              pixels to use (0..15)      [beam in our new terms]
	--eliminate_list        remove channels            [chan]
	--slice                 channel section to keep    [chan]
	--sample                time samples to remove     [time]


As we discussed elsewhere, LMT spectral data can also be seen as dimensioned as follows:

           	data[time,beam,pol,band,chan]

though not all dimensions are populated.

There are two types of masking:

* masking based on a slice in this (time,beam,pol,band,chan) space. On the simplest level
  this can be done using 0-based integers
  with inclusive (min,max) notation, e.g. **time(0,10)**,
  or using their acceptable WCS designations, e.g.

       -time(12:05:10,12:30:05)
       -time(2021-10-31T23:30,2021-11-01T00:30)
       -beam(5,7)
       -pol(XX)
       -band(USB)
       -chan(10km/s,20km/s)
       -chan(104.1GHz,104.14GHz)

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
       
  are all acceptable ways to deal with selecting 

* masking records based on other meta-data (SDFITS columns) being in some range.

       -range(TSYS, 250.0, 999)
       -range(RMS, 3.0)

* By using a + sign in front of the selection, the slice is added back in.  For example

       +ra(12.4,12.45),dec(34.8,35.0)

  will add this area back in, and areas outside these are not modified.


* If no + or - is given in front of the specification, a - is assumed, i.e. that slice is masked.

* blank lines, or anything after a '#' is taken as a comment


   
