# Frequencly Asked Questions

## What is a typical workflow for OTF data reduction

First find out which obsnums belong to a given observation, where a common
sky and spectral are. Perhaps the **lmtinfo.py** can be useful too:

      lmtinfo.py /data/lmt_data

Lets say you find there are only three: 85776 85778 85824.   You start with one:

      lmtoy_reduce path=/data/lmt_data obsnum=85776

this will attempt to make a cube of the line specified by the VLSR in the header, and
make some decisions on where to place the baseline fitting. Inspect the waterfall cube
(the .wt.fits file), or the plots from view_spec_file. Witht this edit the settings
in lmtoy_85776.rc. Simply edit and re-run:

      lmtoy_reduce obsnum=85776

Once satisfied with the fits cube, copy this for the other obsum, and reduce them

      for o in 85778 85824; do
          cp lmtoy_85776.rc lmtoy_${o}.rc
          lmtoy_reduce.sh obsnum=${o}
      done

Inspection is needed again, pixels may have to be removed etc. Once satisfied, combine them:

     lmtoy_combine.sh obsnum=85776,85778,85824


## How to make a beam as used by the gridder

There is no option in grid_data.py yet, but the -a flag in
spec_driver_fits will make a beam. Pick any SpecFile, select only 1
pixel (the -u flag), although this is not essential, and inspect the
-w beam.fits as the beam. The -o file can be discarded. Example:

      spec_driver_fits -i IRC_79448.nc -o beam.1.fits -w beam.fits \
         -u 0 -z 4 -s 1 -x 4 -y 4 -f 1 -r 1 -n 256 -0 1.1 -1 1 -2 2 -b -1 -a -l 2 -c 1


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
      SPECSYS = 'LSRK    '           / could be wrong (check ? Header.Source.VelSys)


In MIRIAD:

MIRIAD supports the VOBS concept (Velocity of the observatory w.r.t. restframe), but
although this value is in the RAW header, it is not passed on to the SpecFile


In the RAW headers we can find (e.g.)

      Header.Source.Velocity = 463 ;
      Header.Source.VelSys = 0 ;
      Header.Sky.ObsVel = -19.9564373466461 ;
      Header.Sky.BaryVel = -11.6443975487706 ;

shell examples

      rm -rf irc.mir
      fits in=IRC_79448.fits out=irc.mir op=xyin
      imhead in=irc.mir
      velsw in=irc.mir axis=freq
      fits in=irc.mir out=irc.mir.fits op=xyout

Importing this FREQ based file, makes it work in CASA.

      importfits('irc.mir.fits','irc.mir.fits.im',overwrite=True)
      imhead ('irc.mir.fits.im')
      exportfits('irc.mir.fits.im','irc.mir.fits.im.fits',velocity=True,overwrite=True)
      
but this doesn't work

      exportfits('irc.mir.fits.im','irc.mir.fits.im.fits',velocity=True,overwrite=True,optical=True)

Miriad also differtiates between CELLSCAL= 'CONSTANT' and CELLSCAL= '1/F'

in CASA:

Our LMT fits file is linear in frequency and velocity (VELO-LSR, not FELO-LSR)
yes, exportfits complains about non-linear axis unless we say optical=True.
issue?

      importfits('IRC_79448.fits','irc.im',overwrite=True)
      imhead('irc.im')
      exportfits('irc.im','irc.fits',velocity=True,optical=True,overwrite=True)

The reference pixel is 350.303, but in exportfits I see ALTRVAL = 349.894
It works fine of CTYPE3 is VRAD, and not the current VELO-LSR, but VELO_LSR
is not a recognized axis name, so it sticks to the (correct) m/s, but doesn't
know about FREQ.
