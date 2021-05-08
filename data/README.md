# Some examples of LMT (and related) data.

* for SDFITS files from other observatories this is just the fits header. 

* for CDF (some of) the output of ncdump


## OBSNUM

We also list a few sample OBSNUM's of specific instruments/receivers that
can be used for inspection. See also the examples directory were scripts
exist to process these sample OBSNUM data



	79448    SEQ  map IRC+10216           2018-11-16 during comissioning
	85775    SEQ  map Region_J-K (M31)    2019-10-31 good example of emission to the field edge
	91112    SEQ  map NGC5194 (M51)       2020-02-20 (after the doppler fix)
	
             SEQ  Ps
			 SEQ  Bs
			 SEQ  map 

             1MM
	

Some example of data.  For FITS this is just the fits header. For CDF (some of) the output of ncdump

## Some SDFITS notes:

1) FAST data use
     TTYPE13 = 'NCHAN   '
     TDIM21  = '(4,65536)'
   which gives them the flexibility to sore any NCHAN (up to 64k) per row, and it can vary.
   But in order to keep the valid to the first portion, and not stride, they had to make
   the 4 polarizations the first index in the DATA array (256k)

2) Parkes also stores polarization in the same row, by using TDIM23  = '(2048,2,1,1)'
   Also note they use a separate equally dimensioned FLAGGED array (4096B)

3) GBT is more simple, only singly dimensioned arrays.


## Some netcdf notes:

* SEQ_ifproc
* SEQ_roach0 (there are 4)

* RSR_RedshiftChassis0 (there are 4)

* 1MM_ifproc
* 1MM_roach0 (there is 1)
