Spectral Line Workflow
======================

The current (pre2021) style workflow requires you to have your RAW files locally present. For LMT data this 
means having them located in your local $DATA_LMT tree.  In the future we expect another workflow, described
later in this section. 

In this current workflow, all you need to know is a set of **ObsNum** 's , which can be obtained by quering
(some) database. We need an example of this.

SLR data
--------

The scripts ``lmtoy_reduce.sh`` and ``lmtoy_combine.sh`` will reduce single and combined OBSNUM's. They
always work through an intermediate Specfile (equivalent to our future SDFITS file), which gets gridded

RSR data
--------

The scripts ``rsr_driver.sh`` and ``rsr_sum.sh`` are two methods to reduce RSR raw data. There is
no SpecFile.

Many more details of the old workflow is in ``examples/lmtoy_reduce.md``


LMT SLR data reduction
======================

Here we describe the workflow in the future unified SDFITS based
system.  The first step is always the RAW (lmtsrc or dreampy3) based
conversion (*ingestion*) to SDFITS. If you are in an interactive
python session, the data will be in memory in a special class, there
should be no formal reason to save the SDFITS file (formerly called
the *SpecFile* in lmtslr), but one is well adviced to do this. 

Load and Go
-----------

The initial workflow is *load-and-go* based. A number of parameters are set, a series of plots can be
reviewed, including having access to the final Science Ready Data Product (SRDP). User can set new
parameters and try again.

An interface should exist (via dasha?) that summarizes the plots the user wants to see on screen.
Vertically are the various plots the pipeline produces, horizontally are the different attempts to
run the pipeline. For each pipeline run, user can download the data.

The pipeline will look a little different depending if the observation was a grid (e.g. OTF) 
a single pointing (e.g. SEQ-Ps or RSR). The former produces a data cube, the latter a single
spectrum.

The user should not need to see that behind the scenes our ``data[ntime,nbeam,npol,nband,nchan]``
type of data, but occasionally this will show up in reminders how to average down the data where
this could result in a higher Signal/Noise.

Gridding
~~~~~~~~

For a typical OTF grid individual spectra cannot be inspected, especially with a 10Hz integration time there could
be over half a million spectra! A waterfall image will give a useful overview:   for each beam a
time-frequency plot will easily reveal patterns, bad spectra, birdies, etc. A masking file will need
to be used to mask out areas in the masking cube.

It will also be useful to inspect the RMS (RMS value of a baseline fit per beam) as function of
time along the OTF track, either plotted as an image (in XPOS,YPOS space),
or a stacked scatter plot with RMS and TIME as variables.


Stacking
~~~~~~~~

For a single pointing it will become important to inspect individual
spectra. For example, for RSR with each typical 30 second integration
time, there are 24 spectra (4 spectra if you would combine the 6 bands
in the full RSR spectral range).


Masking
~~~~~~~

A unified masking file format is being designed. Details are still being drafted
in docs/masking.md, but here is a flavor of what is being considered:

.. code-block::


   time(12:05:10,12:30:05),chan(100,103)
   beam(5,7),pol(XX)
   select(TSYS, 250.0)
   select(RMS, 3.0)
   select(XPOS, 40.0, 50.0), select(YPOS, -30.0, -20.0)
   beam(1),pol(0),band(3),chan(71,71.5,GHz)
   user(rsr1, 1.0, 0.01)



Future Workflow
---------------

UMass Server has the data, a web interface will run the new-style pipeline. Data can be inspected.
New parameters can be set, and re-imaged.

The TolTECA data reduction workflow has a high level config file (yaml?) which via a command line
interface steers the pipeline.
