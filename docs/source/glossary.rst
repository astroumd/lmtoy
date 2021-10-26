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
      sky. Commisioned April 2018.

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
      The footprint of one receiver horn on the sky. Sequioa as a 
      4x4 multi-beam receiver. Not to be confused with the
      **FWHM**.  At 115 GHz the **FWHM** is about 16", at 86 GHz about
      21".  The beam separation is 27.8" for Sequoia.

    board
      for LSR these are the roach boards (4). For RSR they
      are called **chassis** (4). But in **RSR** board has also been
      used where **band** is meant.

    cell
      (most people would call this a pixel, but at LMT
      **pixel** is an overloaded word for the beams. In the gridder we
      use --cell=

    chassis
      for **RSR** there are 4 chassis boards, which are tuples of two beams and two polarizations
      (though the beams look at the same sky position here)

    dasha
      A python frontend to dash, currently used by TolTeca

    ECSV
      (Enhanced Character Separated Values) a self-describing ascii table format popularized by astropy

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

    horn
      Another term used for :term:`beam` or :term:`pixel`.

    LSR
      (Spectral Line Reduction):  the software reduction Sequoia (3mm) data, and presumably in the future, Omaya (1mm)

    ObsNum
      Observatation Number. This is not all, obsnum is part of the (**ObsNum** , **SubObsNum** , **ScanNum**) tuple.

    OMAyA
      (One Millimeter Array Receiver for Astronomy):  200-280 GHz. 8 "pixels" (beams) on sky, each dual
      polarization, with two sidebands. IF can be 4-12 GHz in each sideband.

    OMAR
      something with omaya? Or is this another term for OMAYA
   
    PHAMAS
      (Phased Array Receiver for Millimeter Astronomy): 64 element receiver - prototype.
   
    pixel
      synonym for **beam** as in multi-beam. The keyword --pix_list= is used to select pixels (0..15) for processing.

    ProjectId
      Each LMT observing proposal has a unique proposal ID assigned. An example is **2018-S1-MU-46**

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
      (30 MHz)
      The RSR has two beams on the sky, each beam has two polarizations to
      form 4 independent calibrated spectra; the polarization pairs for each 
      beam are collected through the same horn. These 4 are referred to as the
      4 **chassis**.   Salient detail:  RSR does not doppler track.
    
    ScanNum
      Scan Number - see **ObsNum**

    SDFITS
      Single Dish **FITS** format, normally used to store
      raw or even calibrated spectra in a FITS BINTABLE format.  Each
      row in a BINTABLE has an attached RA,DEC (and other meta-data),
      plus the whole spectrum. This standard was drafted in 1995 (Liszt),
      and has been implemented by many telescopes (Arecibo, FAST, GBT, Parkes, ....)

    SEQUOIA
      85-115.6 GHz, has a 4x4 multi-beam (pixel) receiver. Can do multiple backend
      spectrometers tuned indepedently in a 15GHz window.

    SFL
      Sanson-Flamsteed projection, used in LMT **FITS** files
      (the GLS - GLobal Sinusoidal is similar to SFL).

    SLR
      (Spectral Line Receiver) The common name for the (SEQUOIA/1MM/OMAYA) instruments,
      since they share WARES hardware. Name is also used in ``lmtslr``, the python module.

    Spectrum
      A coherent section in frequency space, with its own unique meta-data (such as polarization,
      ra, dec, time). Normally the smallest portion of data we can assign. A spectrum is
      defined by its own seting of *(crval, crpix, cdelt)* in a FITS WCS sense.
      See also :ref:`storage`.

    SubObsNum
      Sub-Observatation Number - see **ObsNum**

    TolTec
      Continuum mapping instrument

    TolTeca
      Python frontend for the TolTec instrument. Is dasha based.

    WARES
      (Wideband Arrayed ROACH Enabled Spectrometer). The spectrometer used
      for Sequoia. To be resolved: is there one, or four? Also used for the name
      of the computer that receives data from the 4 (future 8) roach boards.


.. _overloaded:

Overloaded Terms
~~~~~~~~~~~~~~~~

Terms used in the code may not exactly match terms used by the develpers of the instruments.
Here we clarify those overloaded terms in the form of a table

.. list-table:: **Table of some overloaded terms**
   :header-rows: 1
   :widths: 15,15,15,45      

   * - code term
     - RSR term
     - SLR term
     - comments
   * - beam
     - pixel?
     - pixel
     - multi-beam receiver
   * - cell
     - n/a
     - cell
     - size of a sky pixel in gridding, usually 2-3 times smaller than the resolution
   * - band
     - board
     - bank
     - spectrometer window
   * - n/a
     - chassis
     - n/a
     - tuple of (pol,beam)
   * - channel
     - channel
     - channel
     - with a simple FREQ WCS{crval,crpix,cdelt}

.. _storage:

Data Dimensions
~~~~~~~~~~~~~~~

This section is not meant to describe either the RAW (netCDF) or SDFITS
format, but the storage model we have in mind to be encapsulated in a
Python class.

A unified data storage of LMT spectra would (naturally) break up the
spectra, such that each spectrum has a different
time, beam, band, polarization, etc.  Each spectrum
can be described as a set of sequential channels, described with a single
*(crval,crpix,cdelt)*) WCS.
In Python row-major array notation where the most slowly varying dimension comes
first this could be written as an **NDarray**:

.. code-block::

      data[ntime, nbeam, npol, nband, nchan]

where we added the ``ntime`` and ``nchan`` as the slowest resp. fastest running dimension
in this row-major (python/C) notation.


.. note:: For those used to GBTIDL **plnum** = **npol**, **ifnum** = **nband**, and
   **fdnum** = **nband**.  Arguably different scans can act as as **ntime**, although
   each scan will often have several snapshots inside of them. ?? **intnum**

.. code-block::

      Overloaded words, including GBT lingo:

      plnum   pol
      fdnum   feed     beam    pixel
      ifnum   window   band

Taking out those an observation can be seen as a set of spectra:

.. code-block::

      spectrum[nbeam, npol, nband]

This exactly matches the concepts used in an SDFITS file, although in the general
definition of SDFITS there is no assumption of the data being able to be stored
in an **NDarray** type array, where the more general

.. code-block::

       sdfits_data[naxis2, ndata]

where in general ``ndata=nchan``, but dialect with ``ndata = npol * nchan`` are
seen in the wild (FAST, Parkes). The FITS name ``naxis2`` is the number of rows,
which is the product of ``time,beam,band,pol`` in our case.


Taking an inventory of current and known future LMT Spectral Line instruments:

* RSR:
  two beams, two pols, 6 bands, though the term *chassis* is used to point at any
  tuple of (beam,pol). So here we have nbeam=2, npol=2,nband=6, nchan=256 and ntime
  it typically 10-20. Each beam happens to look at the same sky position here.

.. note::  If an instrument like RSR would multiplex the (beam,pol) pairs, this would be a challenge
	   to the assumption of homogeneity, and the SDFITS model would be more appropriate.

* 1MMRx:
  one beam, two pols, two sidebands. So here we have nbeam=1, bpol=2, nband=2, nchan=2k

* SEQ:
  16 beams (though 4 beams per roach board, and each roach board has its own time) in one
  band (they also call it bank) and one polarization. Thus nbeam=16, npol=1, nband=1

.. note::  The timestamps for the different roach boards make it impossible to store
	   the data in a multi-dimensional array, unless (typicall one) integration
	   is removed. Keeping all data would require ``data[ntime4, 1, 1, 1, nchan]`` for SEQ.

* OMA
  8 beams, 2 bands (banks), 2 polarizations.

* B4R
  4 XFFTS boards, 2.5 GHz/board:  1 beam, 2 bands (USB and LSB), 2 polarizations (XX and YY)

Note that FAST is the only known case that stores data as  ``data[ntime, nchan, npol]``, where
``nchan`` is not the fastest running dimension, but ``npol``. Technically this appears to be the
case such that they can vary ``nchan`` per row.


We thus arrive at the following summary for the multi-dimensional data[] array:

.. code-block::

      data[ntime, nbeam, npol, nband, nchan]

in the table we leave out the ``ntime`` dimension    

.. list-table:: **Table of data dimensions of LMT SLR instruments**
   :header-rows: 1
   :widths: 15,10,10,10,10,30

   * - **data**
     - **nbeam**
     - **npol**
     - **nband**
     - **nchan**
     - comment
   * - RSR
     - 2
     - 2
     - 6
     - 256
     - (pol,beam) tuples are the 4 chassis. 6 overlapping bands make one final spectrum
   * - SEQ
     - 16
     - 1
     - 1 (2)
     - 2k, 4k, 8k
     - beams have time issue, perhaps ntime ~ ntime * nbeam, and nbeam=1. Future will have 2 bands
   * - OMA 
     - 8
     - 2
     - 2
     - 2k, 4k, 8k
     - Future instrument, with 4 more roach boards (USB+LSB)
   * - 1MMRx
     - 1
     - 2
     - 2
     - 2k, 4k, 8k
     - band: 2 IF's in USB/LSB
   * - B4R
     - 1
     - 2
     - 2
     - 32k
     - Japanese 2mm receiver

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
associated with the P.I. name. An example of such is **2018-S1-MU-46**

An observation is that divided in a set a **ObsNum** 's, which can be hierchically
divided up in **SubObsNum**'s and **ScanNum**'s. When
an observing script executes, each source will gets its own **ObsNum**, though
calibration data often gets another **ObsNum**.


