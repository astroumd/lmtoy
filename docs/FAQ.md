# Frequencly Asked Questions

## Cubes in VLSR or FREQ

Both miriad and casa have conversion routines between them, but they will depend on
other keywords to be correct.  WCS can be a tricky thing, especially if you need
good accuracy.
Currently LMT cubes have the following keywords that influence the WCS:

      BUNIT   = 'K       '           /
      CTYPE1  = 'RA---SFL'           /
      CTYPE2  = 'DEC--SFL'           /
      CUNIT2  = 'deg     '           /
      CTYPE3  = 'VELO-LSR'           /
      CUNIT3  = 'm/s     '           /
      EQUINOX =                2000. /
      RADESYS = 'FK5     '           /
      RESTFRQ =        115271204000. / Header.LineData.LineRestFrequency
      SPECSYS = 'LSRK    '           / could be wrong


In MIRIAD:

      fits in= out= oper=xyin
      imhead in=
      velsw in=

in CASA:

      importfits('in.fits','out.im')
      imhead('out.im')
