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
      A coherent section of channels in frequency space. For **RSR** there
      are 6 bands, sometimes the word **board** is used as well, although
      the ordering of bands and boards is different. bands are ordered
      in frequency (by our convention).
      See also **bank**

    bank
      A set of spectrometers that cover the same *IF* band at the same
      resolution (and number of channels).
      There is no side-band restriction.   For SEQUOIA
      we use two banks currently, though both need to be in the
      band below 100GHz or in the band above 100GHz.
      For the MSIP 1mm receiver there are
      two, although they have one in USB and one in LSB.

    beam
      The footprint of one receiver horn on the sky. Sequioa has a 
      4x4 multi-beam receiver, numbered 0 through 15.
      Not to be confused with the
      **FWHM**.  At 115 GHz the **FWHM** is about 16", at 86 GHz about
      21".  The beam separation is 27.8" for Sequoia.
      The word **pixel** has also been used for **beam**, but this is
      discouraged as this has an overloaded means in our final images.
      See also **cell**.
    
      Note that for some instruments beams are also interpreted while
      including other simulteanously taken data in another band/polarization

    Beam Switching
      This is a variation on position switching using a receiver
      with multiple pixels. The "Main" and "Reference" positions on the sky are
      calculated so that the receiver is always pointing at the source. This is most
      useful for point sources.

    beammap
      A special observing mode (always in Az-El?) where you map around
      a strong source, e.g. Ori-KL. Usually a small field.

    board
      for SLR these are the roach boards (4 or 8). For RSR they
      are called **chassis** (4). But in **RSR** board has also been
      used where **band** is meant, but there is a subtle difference
      where bands are ordered in frequency.

    bufpos
      WARES variable to denote what type of data is being received.
      bufpos: 0=on 1=off 2=sky 3=hot.
      A value of 100 can be added if a reference a grid posititon in
      a grid map needs to be made.

    cell
      (most people would call this a pixel, but at LMT
      **pixel** is an overloaded word also used for the
      beams in Sequoia. In the gridder we
      use --cell=. This will be the pixel size in the final FITS
      images.

    chassis
      for **RSR** there are 4 chassis boards, which are tuples of two beams and two polarizations
      (though the beams look at the same sky position here)

    dasha
      A python frontend to dash, currently used by TolTeca

    dreampy, dreampy3
      The set of python modules that you need to reduce RSR data

    ECSV
      (Enhanced Character Separated Values) a self-describing ascii table format popularized by astropy.
      See also https://github.com/astropy/astropy-APEs/blob/main/APE6.rst

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

    grid map
      A sequence of spectra taken on a regular grid of sky points. In this procedure,
      the telescope tracks a specifc position in the grid as the "Main" position in a
      position switched spectrum. The procedure allows the user to defne a single integration
      on the "Reference" position to be used for all points or allows the user to interleave additional
      "Reference" spectra into the observation. 

    horn
      Another term used for :term:`beam` or :term:`pixel`.
    
    LMTSLR
      The LMT Spectral Line Reduction modules you will need to reduce
      WARES based data.

    MC
      Monitor and Control system, the system that runs the online LMT system.
    
    ObsNum
      Observatation Number. This is not all, obsnum is part of the (**ObsNum** ,
    **SubObsNum** , **ScanNum**) tuple,
      but for most applications you only need to know the **ObsNum**

    OMAyA
      (One Millimeter Array Receiver for Astronomy):  200-280 GHz. 8 "pixels" (beams) on sky, each dual
      polarization, with two sidebands. IF can be 4-12 GHz in each sideband. This is a planned instrument.

    OMAR
      something with omaya? Or is this another term for OMAYA

    OTF Mapping
      In this procedure the telescope is scanned across the sky to sample the emission.
      The samples are then "gridded" into a map.
   
    PHAMAS
      (Phased Array Receiver for Millimeter Astronomy): 64 element receiver - prototype.
   
    pixel
      synonym for **beam** as in multi-beam. The keyword --pix_list= is used to select pixels (0..15)
      for processing.

    plotly
      dash uses plotly, which is a data analytics framework working within a browser environment.

    Position Switching
      This is a standard way to obtain spectra by switching
      between a "Main" and "Reference" position on the sky.

    ProjectId
      Each LMT observing proposal has a unique proposal ID assigned. An example is **2018-S1-MU-46**,
      which contains the proposal year, session, institution and proposal number.

    Quick Look data
      At the LMT there are "Quick Look" data that will be used to assess if data will be scientifically
      viable. Usually made available via the Shift Report website. See also Timely Analysis Products (TAP)
      for a view closer to the science data.

    ramp
      The ramp is the area where not all beams have
      been. Within the ramp there is thus a non-uniform coverage.  The
      ramp covers 3 beams (not FWHM, but pixel), so about 85".  For
      any maps smaller than about 200" there is no good area of
      uniform coverage. Should have a plot of that here, and maybe
      compare that to a large M51 area?

    resolution
      this term is used in the gridder, but it's not
      **FWHM**, it's lambda/D.  Keyword --resolution= is used If
      selected this way, FWHM is then set as 1.15 * resolution. But if
      resolution is chosen larger, what is the effective FWHM?  It
      would be better to have a dimensionless term for
      **resolution/pixel** and a different name for resolution
      alltogether.

    roach board
      The SLR had four (4) roach boards, now eight (8), each of which writes a separate
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

    runfile
      A simple text file of (LMTOY pipeline) commands, one per line. Although more
      limiting than full programmable bash scripts, these can be executed serially
      by bash, or in parallel by GNU parallel or SLURM. The lmtoy script generator
      will produce sets of runfile's. The webrun environment also deals with runfiles,
      as they are submitted to Unity via SLURM.
    
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
      spectrometers tuned indepedently in a 15GHz window. In the single IF mode
      (before April 2023) beams 0..15 are used, but in dual IF mode, beams can be
      counted 0..31 to select from bank0 or bank1.

    SFL
      Sanson-Flamsteed projection, used in LMT **FITS** files
      (the GLS - GLobal Sinusoidal is similar to SFL).

    Shift Report
      See Quick Look Data

    SLR
      (Spectral Line Receiver) The common name for the (SEQ/1MM/OMA) instruments,
      since they share WARES hardware. Name is also used in ``lmtslr``, the python module.

    SLURM
      A workload manager to submit jobs to a queue, in our case for **Unity**.

    SpecFile
      A netcdf file containing the calibrated spectra, ready for gridding.  This is equivalent
      to an SDFITS file. In a future version we may replace the SpecFile with an SDFITS file.

    Spectral Window
      In ALMA commonly abbreviated as **spw**, this is closest to what we call a **bank**, a
      set of linearly spaced channels.

    Spectrum
      A coherent section in frequency space, with its own unique meta-data (such as polarization,
      ra, dec, time). Normally the smallest portion of data we can assign. A spectrum is
      defined by its own seting of *(crval, crpix, cdelt)* in a FITS WCS sense.
      See also :ref:`storage`.

    SRDP
      Science Ready Data Products (SRDP) are the data produced by the pipeline that can be used
      to write a paper, in theory. In practice the PI will want to assess the quality, perhaps
      even tune some pipeline parameters, and re-run the pipeline.

    SubObsNum
      Sub-Observatation Number - see **ObsNum**

    Timely Analysis Products (TAP)
      The SLpipeline produces a set of Timely Analysis Products, mostly in the form of figures,
      for the PI to asses the quality of the data. Normally presented on a web server, though
      the TAP is also available as a tar file. The TAP does not contain  See also SRDP.
      TAP is also known as the Table Access Protocal in the IVOA world. Not to be confused.

    TolTec
      Continuum mapping instrument

    TolTeca
      Python frontend for the **TolTec** instrument. Is **dasha** based.

    Unity
      An HPC system consisting of many compute nodes. We run the SLpipeline here, though they
      need to be submitted via a workload manager, called **SLURM**

    WARES
      (Wideband Arrayed ROACH Enabled Spectrometer). The spectrometer used
      for Sequoia/1MM/Omaya. Also used for the name
      of the computer that receives data from the individual roach boards
      in the spectrometer hardware.

    webrun
      Placeholder name for the futuure webbased environemnt that allows one to run
      pipeline on a project for science data.


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

* 1MM:
  one beam, two pols, two sidebands. So here we have nbeam=1, bpol=2, nband=2, nchan=2k

* SEQ:
  16 beams (though 4 beams per roach board, and each roach board has its own time) in one
  band (they also call it bank) and one polarization. Thus nbeam=16, npol=1, nband=1.
  Once the 2nd IF will be installed, 32 beams will be recognized by the software,
  but organizationally it is easier to to think of 16 beams and 2 bands.

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


