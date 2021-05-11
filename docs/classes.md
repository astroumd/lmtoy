#   Sample Classes

The obvious thing would be to store a spectrum in a Spectrum1D class (we used that in GBTOY, and it's 
also a class in astropy's specutils); This **Spectrum** class has a near 1:1 relationship with a row
in an SDFITS bintable:

	Spectrum   <-> SDFITS
		data[nchan]
		crpix1,crval1,cdelt1
		band	         'G'
		pol          'S/G'
		board        'S'    (?)
		time         'S/G'
		ra, dec      'G'    (npos)
		calon/caloff        GBT - not used here
		on/off              GBT - not used here

An observation is a collection of spectra, S.  For some types
of instruments these Spectra can be organized in a regular
multi-dimensional array

	SLR:   SC[npos]
	OMA:   SC[npos, npol]
	RSR:   SC[ntime, nband, nboard]

but putting multi-dimensionality on a class is somewhat painful,
though not impossible using dunders

It would be more straightforward to use numpy arrays, they should be
as such inside a new XXX_Spectra class, e.g.

Or alternatively, better matches to numpy, but then classes for each instrument

	SLR_Spectra
		data[npos,nchan]             npos folds pixels and time
		~data3[npixel,ntime,nchan]   - "waterfall cube"
		~data4[nroach,npixel,ntime,nchan]
		ra[npos]
		dec[npos]
		time[npos]         # keep these, so one can flag on them
		pixel[npos]        # keep these, so one can flag on them

	OMA_Spectra
		data[npos, npol,nchan]
		pol[npol]
		ra[npos]
		dec[npos]

	Rx1mm_Spectra  
		data[npos, npol, nchan]
    

	RSR_Spectra
		data[ntime, nband, nboard, nchan]
		time[ntime]
		band[nband]
		board[nboard]
		
		
or more generalized	(un-used dimensions will then be 1)

	Spectra
		data[ntime, npixel, nboard, nband, npol, nchan]
		pixel[npixel]   dra,ddec
		board[nboard]
		band[nband]     IF  (crval1)
		pol[npol]       POL (crval2)
		chan[nchan]     (crval1)



# LSR ingest ("process")

	S = process_slr(12345, stype=2)
	S.saves('12345_0.sdfits')            # saving is optional
	S.shows()
      # obsnum=23456
      # source='NGC123'
      # z=0.123
      # ntime:    16384
      # nboard:   1
      # nband:    1

# reload the sdfits

	S = loads('12345_0.sdfits')
	z = S.get('z')
	vlsr = S.get('vlsr')
	S.mask(sample(100,200))
	S.mask(pixel(5),time=(14:00,14:15))
	S.mask(pixel(1))
	S.grid(beam=15.0, roc=3.0, filter='jinc', grid=[-100,100,-100,100])
	S.savec('12345.fits','12345.wt.fits')

# RSR ingest

	S = process_rsr(23456, bc_threshold=3.0)
	S.saves('23456_0.sdfits')
	S.shows()
       # obsnum=23456
       # source='NGC123'
       # z=0.123
       # ntime:    10
       # nboard:    4
       # nband:     6
    z = S.get('z')
	S.baseline_mask(115.2712018, z, 250.0)
	S.baseline_mask(110.2013543, z, 250.0)
	S.baseline_fit(order=2)
	S.savec('23456.ecsv')     # could also use (1D) fits


# The issue of multi-dimensional spectra in SDFITS

Althiough GBT does not use this allowed convention, Parkes and FAST appear to use it,
and in different ways:  FAST stores the polarization dimension first,
Parkes stores it second. Similar to the huge confusion that CASA has creates
(see the stokeslast= keyword in exportfits)

	data/fast1.head:  TDIM21  = '(4,65536)'          / Dimensions (4,NCHAN) 
	data/parkes1.head:TDIM23  = '(2048,2,1,1)'       / size of the multidimensional array 
	
## Parkes

	CTYPE2  = 'STOKES  '           / DATA array axis 2: polarization code           
	CRPIX2  =                  1.0 / Polarization code reference pixel              
	CRVAL2  =                 -5.0 / Polarization code at reference pixel (XX)      
	CDELT2  =                 -1.0 / Polarization code axis increment               

3 and 4 are RA,DEC

## FAST

	CTYPE1  = 'FREQ    '           / DATA array axis 1: frequency in Hz             
	CTYPE2  = 'STOKES  '           / DATA array axis 2: polarization code           
	CRPIX2  =                   1. / Polarization code reference pixel              
	CRVAL2  =                  -5. / Polarization code at reference pixel (XX)      
	CDELT2  =                  -1. / Polarization code axis increment               

3 and 4 are RA,DEC

## GBT

GBT stores :   1=freq  2=ra  3=dec   4=pol

# Other codes that use SDFITS:

##  specutils

In GBTOY we have an SDFITS loader for specutils.

##  cygrid

##  HCGrid

Was derived from cygrid

##  gbtidl
