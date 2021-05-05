.. _lmtglossary:

An LMT glossary
---------------

There are some overloaded and confusing terms in here.
E.g. *pixel/cell/beam* and *board/band/bank/chassis* are notorious. 
*Resolution/FWHM* can be confusing too. See also the correspondence table
of some overloaded terms after the glossary. See :ref:`overloaded`.


.. glossary::


    1MMRx
      The 1mm MSIP receiver has one beam on the sky, measuring two polarizations
      in an USB and LSB, thus there are 4 spectra at the same position on the
      sky.

    band
      A coherent section in frequency space. For **RSR** there
      are 6 bands, sometimes the word **board** is used as well.  LSR
      also uses this keyword, but there is currently only board=0 for
      LSR. See also **bank**

    bank
      A set of spectrometers that cover the same IF band at the same
      resolution (and number of channels).
      There is no side-band restriction.   For SEQUOIA
      we only use one bank currently. For the MSIP 1mm receiver there are
      two, although they have one in USB and one in LSB.

    beam
      in the 4x4 multi-beam. Not to be confused with the
      **FWHM**.  At 115 GHz the **FWHM** is about 16", at 86 GHz about
      21".  The beam separation is 27.8"

    board
      for LSR these are the roach boards (4). For RSR they
      are called **chassis** (4). But in **RSR** board has also been
      used where **band** is meant.

    cell
      (most people would call this a pixel, but at LMT
      **pixel** is an overloaded word for the beams. In the gridder we
      use --cell=

    chassis
      for **RSR** there are 4 chassis boards, which are tuples of different beams and polarizations
      (though the beams look at the same sky position here)

    ECSV
      (Enhanced Character Separated Values) a popular self-describing ascii table format popularized by astropy

    FITS
      (Flexible Image Transport System): the export format
      for data-cube, although there is also a waterfall cube
      (time-freq-pixel) cube available.  Unclear what we will use for
      pure spectra.  **SDFITS** seems overly complex. CLASS needs to
      be supported. Currently **RSR** exports ASCII tables, not even
      **ECSV**

    FWHM
      (Full Width Half Max): the effective resolution of the
      beam if normally given in **FITS** keywords BMAJ,BMIN,BPA.  The
      term **resolution**

    LSR
      (Spectral Line Reduction):  the software reduction Sequoia (3mm) data, and presumably in the future, Omaya (1mm)

    ObsNum
      Observatation Number. This is not all, obsnum is part of the (**ObsNum** , **SubObsNum** , **ScanNum**) tuple.

    pixel
      synonym for **beam** as in multi-beam. The keyword --pix_list= is used to select pixels (0..15) for processing.

    Project ID
      Or whatever we are going to call it

    ramp
      The ramp is the area where not all beams have
      been. Within the ramp there is thus a uniform coverage.  The
      ramp covers 3 beams (not FWHM, but pixel), so about 85".  For
      any maps smaller than about 200" there is no good area of
      uniform coverage. Should have a plot of that here, and maybe
      compare that to a large M51 area?

    resolution
      this term is used in the gridder, but it's not
      **FWHM**, it's lambda/D.  Keyword --resolution= is used If
      selected this way, FWHM is set as 1.15 * resolution. But if
      resolution is chosen larger, what is the effective FWHM?  It
      would be better to have a dimensionless term for
      **resolution/pixel** and a different name for resolution
      alltogether.

    roach board
      The SLR has four (4) roach boards, each of which writes a separate
      file with its own internal clock that later needs to be sync'd. In
      a future expansion we get 8 boards (2 pols, 2 IFs) , capable of writing
      8 files.  ``Rumor``:  for the 1mmRx configuration can be done on one
      board, hence one file (new IF switching system).

    RSR
      (Redshift-Search-Receiver): operates between 70 and 110 GHz
      in 6 separate bands of 256 channels each.  Typical resolution: 100 km/s.
      The RSR has two beams on the sky, each beam has two polarizations to
      form 4 independent calibrated spectra; the polarization pairs for each 
      beam are collected through the same horn. These 4 are referred to as the
      4 **chassis**.   
    
    ScanNum
      Scan Number - see **ObsNum**

    SDF
      Single Dish FITS (convention)

    SDFITS
      Single Dish **FITS** format, normally used to store
      raw or even calibrated spectra in a FITS BINTABLE format.  Each
      row in a BINTABLE has an attached RA,DEC (and other meta-data),
      plus the whole spectrum. This standard was drafted in 1995 (Liszt),
      and has been implemented by many telescopes (Arecibo, FAST, GBT, Parkes, ....)

    SFL
      Sanson-Flamsteed projection, used in LMT **FITS** files
      (the GLS - GLobal Sinusoidal is similar to SFL).

    SLR
      The common name for the (SEQUOIA/1MM/OMAYA) instruments, since they share hardware.

    Spectrum
      A coherent section in frequency space, with its own unique meta-data (such as polarization,
      ra, dec, time). Normally the smallest portion of data we can assign. A spectrum is
      defined by its own uniq seting of *(crval, crpix, cdelt)* in the FITS WCS sense.
      See also :ref:`storage`.

    SubObsNum
      Sub-Observatation Number - see **ObsNum**

    Wares
      The **wares** spectrometer. Each has a roach board?


.. _overloaded:

Overloaded Terms
~~~~~~~~~~~~~~~~


.. list-table:: **Table of some overloaded terms**
   :header-rows: 1

   * - RSR term
     - SLR term
     - code term
     - comments
   * - ?pol?
     - pixel
     - pixel/beam
     - multi-beam receiver
   * - n/a
     - cell
     - cell?
     - size of a sky pixel in gridding
   * - board
     - n/a
     - ?
     - spectrometer window
   * - chassis (pol?)
     - n/a
     - ?
     - ?
   * - n/a
     - bank 
     - ?
     - spectrometer window
   * - channel
     - channel
     - channel
     - channel

.. _storage:

Data Storage
~~~~~~~~~~~~

A unified data storage of LMT spectra would (naturally) break up the
spectra for different beams, bands, polarizations, such that each spectrum
is a simple set of sequential channels (described with a single
*(crval,crpix,cdelt)*) with different meta-data
(ra,dec,time,beam,polarization, etc).
In python (row-major) array notation where the most slowly varying dimension comes
first this could be written as an **NDarray**:

.. code-block::

      data[ntime, nbeam, nband, npol, nchan]

where we added the ``ntime`` and ``nchan`` as the slowest resp. fastest running dimension
in this row-major (python/C) notation. Taking out those an observation can be seen as a
set of spectra:

.. code-block::

      spectrum[nbeam, nband, npol]


Taking an inventory of current and known future LMT Spectral Line instruments:

* RSR:
  two beams, two pols, 6 bands, though the term *chassis* is used to point at any
  tuple of (beam,pol). So here we have nbeam=2, nband=6, npol=2, nchan=256 and ntime
  it typically 10-20. Each beam happens to look at the same sky position here.

.. note::  If an instrument like RSR would multi-plex the (beam,pol) pairs, this would be a challenge
	   to the assumption of homogeneity, and the SDFITS model would be more appropriate.

* 1MMRx:
  one beam, two pols, two sidebands. So here we have nbeam=1, nband=2, npol=2, nchan=???

* SEQ:
  16 beams (though 4 beams per roach board, and each roach board has its own time) in one
  band (they also call it bank) and one polarization. Thus nbeam=16, nband=1, npol=1

.. note::  The timestamps for the different roach boards make it impossible to store
	   the data in a multi-dimensional array, unless (typicall one) integration
	   is removed. Keeping all data would require ``data[ntime4, nchan]`` for SEQ.
	   

* OMA (B3R):
  8 beams, 2 bands (banks), 2 polarizations.

Note that FAST is the only known case that stores data as  ``data[ntime, nchan, npol]``, where
``nchan`` is not the fastest running dimension.


We thus arrive at the following summary:

.. list-table:: **Table of LMT data dimensions**
   :header-rows: 1

   * - data
     - beam
     - pol
     - band
     - comment
   * - RSR
     - 2
     - 2
     - 6
     - (pol,beam) tuples are the 4 chassis. 6 overlapping bands make one final spectrum
   * - SEQ
     - 16
     - 1
     - 1
     - beams have time issue, perhaps ntime = ntime * nbeam, and nbeam=1
   * - 1MMRx
     - 1
     - 2
     - 2
     - band: USB and LSB
   * - OMA (B3R)
     - 8
     - 2
     - 2
     - Future instrument, with 4 more roach boards

Single Dish Math
~~~~~~~~~~~~~~~~

The meat of Single Dish math is getting the system temperature


.. math::

   T_{sys} = T_{amb} { { SKY } \over { HOT - SKY } }

and using this system temperature, calculating the signal by comparing an *ON* and *OFF* position,
assuming there is only sky in the *OFF*:

.. math::

   T_A = T_{sys}  {   { ON - OFF } \over {OFF} }

All of these have values for each channel. How exactly the :math:`T_{sys}` is computed (scalar, vector,
mean/median) is something we generally leave open.


Observing: ObsNum / SubObsNum / ScanNum
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An observation with a single dish such as LMT is done via proposals, which gets assigned a proposal ID,
associated with the P.I. name. An example of such is XXX.

An observation is that divided in a set a **ObsNum** 's, which can be devived in **SubObsNum** and **ScanNum**. When
an observing script executes, each source will gets its own **ObsNum**.


