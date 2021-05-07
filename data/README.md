Some example of data.  For FITS this is just the fits header. For CDF (some of) the output of ncdump

Some notes:

1) FAST data use
     TTYPE13 = 'NCHAN   '
     TDIM21  = '(4,65536)'
   which gives them the flexibility to sore any NCHAN (up to 64k) per row, and it can vary.
   But in order to keep the valid to the first portion, and not stride, they had to make
   the 4 polarizations the first index in the DATA array (256k)

2) Parkes also stores polarization in the same row, by using TDIM23  = '(2048,2,1,1)'
   Also note they use a separate equally dimensioned FLAGGED array (4096B)

3) GBT is more simple, only singly dimensioned arrays.
