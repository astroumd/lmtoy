Spectral Line Workflow
======================

The current (2021) style workflow requires you to have your RAW files locally present. For LMT data this 
means having them located in your local $DATA_LMT tree.  In the future we expect another workflow, described
later in this section.

In this current workflow, all you need to know is a set of **ObsNum** 's 

RSR data
--------



SLR data
--------

This should
LMT SLR data reduction
======================

Here we describe the workflow in a unified SDFITS based system.  The first step is always the
low level (lmtsrc or dreampy3) based conversion (*ingestion*) to SDFITS. If you are in an
interactive python session, the data will be in memory in a special class, there should be
no formal reason to save the SDFITS file (formerly called the *SpecFile* in lmtslr), but one
is well adviced to do this.

Load and Go
-----------

The initial workflow is load-and-go based. A number of parameters are set, a series of plots can be
reviewed, including having access to the final Science Ready Data Product (SRDP). User can set new
parameters and try again.

An interface should exist (via dasha?) that summarizes the plots the user wants to see on screen.
Vertically are the various plots the pipeline produces, horizontally are the different attempts to
run the pipeline. For each pipeline run, user  can download the data.

The pipeline will look a little different depending if the observation was a grid (e.g. OTF) 
a single pointing (e.g. SEQ-Ps or RSR). The former produces a data cube, the latter a spectrum.

The user should not need to see that behind the scenes our ``data[ntime,nbeam,npol,nband,nchan]``
type of data, but occasionally this will show up in reminders how to average down the data where
this could result in a higher Signal/Noise.

Grid
~~~~

For a grid


Pointing
~~~~~~~~

For a single pointing










Future Workflow
---------------

UMass Server has the data, a web interface will run the new-style pipeline. Data can be inspected.
New parameters can be set, and re-imaged.

The TolTECA data reduction workflow has a high level config file (yaml?) which via a command line
interface steers the pipeline.
