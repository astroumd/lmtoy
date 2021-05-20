#! /usr/bin/env python
#
#   example of using maskmoment for LMT data
#

import sys
import maskmoment as mm


cube = 'NGC5194_91112.nf.fits'
rms  = 'mm2.ecube.fits.gz'
rms  = 'NGC5194_91112.rms.fits'

fwhm = 20

# the default
#mm.maskmoment(cube,outname='mm1')


# dilmsk
mm.maskmoment(cube,outname='mm2', rms_fits=rms,
              snr_hi=4, snr_lo=2, minbeam=2, snr_lo_minch=2)

# dilmskpad
mm.maskmoment(cube,outname='mm3', rms_fits=rms,
              snr_hi=5, snr_lo=2, minbeam=2, nguard=[2,0])

# smomsk
mm.maskmoment(cube,outname='mm4', rms_fits=rms,
              snr_hi=3, snr_lo=3, fwhm=fwhm, vsm=None, minbeam=2)


# dilsmomsk
mm.maskmoment(cube,outname='mm5', rms_fits=rms,
              snr_hi=4, snr_lo=2, fwhm=fwhm, vsm=None, minbeam=2,
              output_2d_mask=True)
              

# msk2d
mm.maskmoment(cube,outname='mm6', rms_fits='mm2.ecube.fits.gz', mask_fits='mm5.mask2d.fits.gz')
