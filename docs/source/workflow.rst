Spectral Line Workflow
======================

The current style data reduction workflow requires you to have your RAW files locally present, in
the $DATA_LMT tree.   To reduce data you will need to know a set of **ObsNum** 's , which can be
obtained by querying a database. 

To run the pipeline, you would process each obsnum individually, inspect the pipeline products
in the $WORK_LMT tree and
decide if the data is good enough, or needs some extra flagging/masking. These are usually defined
in a small set of ascii files. After this the pipeline can be re-run.  In the case an observation
was split in a series of obsnums, you can combine them with the same script, viz.

.. code-block::

   SLpipeline.sh obsnum=12345
   SLpipeline.sh obsnum=23456
   SLpipeline.sh obsnums=12345,23456

The resulting data can then be found in $WORK_LMT/$ProjectId/$obsnum, or in the case of a combination,
$ProjectId/${on0}_${on1}. Inside there will be a README.html summarizing the
Timely Analysis Products (TAP).

Each instrument (e.g. RSR, SEQ) have their own pipeline script.

RSR pipeline
------------

For the RSR pipeline there are two scripts:
``rsr_pipeline.sh`` and ``rsr_combine.sh``.   These in turn use 
two different scripts, ``rsr_driver.sh`` and ``rsr_sum.sh``, reducing the raw data directly into an ASCII spectrum,
there is no SpecFile created as there is for WARES based data. These two scripts have slightly different
ways to mask bad data, but should otherwise produce a very similar final spectrum.

1. ``rsr_driver`` uses the RFILE (a simple obsnum,chassis,board tuple to remove from the data) and ``--exclude`` option
   to remove sections in frequency space to be removed from the baseline fitting.

2. ``rsr_sum`` uses the BLANKING (a more detailed format to exclode certain chassis and board sections from inclusion).
   a separate **windows[]** list is used to designate sections in frequency space for baselining.


The parameter files are:

1. ``lmtoy.${obsnum}.rc`` - general LMTOY parameter file
2. ``rsr.${obsnum}.badlags`` - triples of chassis,board,chan,obsnum,metric for badlag flagging
3. ``rsr.${obsnum}.blanking``  - triples of obsnum,chassic,board/freq ranges - for rsr_driver.py
4. ``rsr.${obsnum}.rfile`` - triples of obsnum,chassis,board - for rsr_sum.py


RSR Parameters
~~~~~~~~~~~~~~

Currently (to be) accepted by SLpipeline.sh when using it for RSR,
ignored when you happen to use them otherwise.

1. badboard=      a comma separated list, 0 being the first.  this is where board=4 is the highest freq board
2. badcb=         a comma separate list of *chassis/board* combinations, e.g. badcb=0/1,0/5,3/5 is a common one
3. vlsr=          not implemented yet
4. blo=           baseline order fit. hardcoded at 0 at the moment, so not implemented yet.

The **badboard** and **badcb** are normally not used, and during the **badlags** scanning, a set of badcb combinations are
identified if their RMS_diff is outside the 0.01-0.1 window. These are currently heuristically determined, and after inspection
the user can still edit them.

Common ones for SLpipeline:

1. obsnum=0 (or obsnums=0)
2. debug=0
3. pdir=""



WARES workflow
--------------

For WARES based instrument, such as Sequoia (SEQ)
the scripts ``seq_reduce.sh`` and ``seq_combine.sh`` will reduce single and combined OBSNUM's. They
always work through an intermediate Specfile (equivalent to our future SDFITS file), which gets then gridded
into a FITS cube.

The parameter files are:

1. ``lmtoy_${obsnum}.rc`` - general LMTOY parameter file


Many more details of the old workflow is in ``examples/lmtoy_reduce.md``



Getting at the RAW data
-----------------------

Here are some examples to get raw (netCDF) LMT data and reduce them
in your own local workspace. This assumes the LMTOY toolkit has been installed:

1.  Find out which **obsnum** covers your observation(s).  Depending on the observing procedure, you may
    also need to know the calibration ObsNum's as well, referred to as the **CalObsNum**, and usually you do.
    There are some existing databases and logfiles where a simple **grep** command will probably be sufficient
    to get the obsnums. The **lmtinfo.py $DATA_LMT** command can also be used. If you have the **Scans.csv**
    database, this might be faster. If you see a log file in the $DATA_LMT directory, this might be another
    place were a record of all ObsNum's exists.
    As they say, YMMV.

.. code-block::

      # assuming your administrator is maintaining a **data_lmt.log**
      % lmtinfo.py grep 2021-12-17
      % lmtinfo.py grep 2020 NGC5194

    would show all the data observed on that date, the second example shows all NGC5194 data in 2020.
    
2.  Get the data from a full $DATA_LMT archive (e.g. at "cln", or at LMT) via the **rsync_lma** script. Obviously
    only somebody on that archive machine can do this, but this is the easiest way. Here is an example of several
    methods:

.. code-block::

      # gather the LMT data on the archive machine
   cln% lmtar /tmp/irc.tar 79447 79448

      # pick one of these two to copy, and don't forget to remove your large /tmp files!
   cln% scp irc.tar lma:/tmp
   lma% scp cln:/tmp/irc.tar /tmp

      # reduce the data on your favorite workstation
   lma% tar -C $DATA_LMT -xf /tmp/irc.tar
   lma% SLpipeline.sh obsnum=79448
        Processing SEQ in 2018S1SEQUOIACommissioning/79448 for IRC+10216

      # view!   
   lma% xdg-open 2018S1SEQUOIACommissioning/79448/

This opens a directory using your favorite file browser, you can inspect figures,
and there will be two ADMIT directories, each with an **index.html** that can
be inspected the ADMIT way (or any other way).

An alternative would be a direct rsync conection between e.g. cln and lma:

.. code-block::

   cln% cd $DATA_LMT
   cln% rsync -avR `lmtar.py 79447 79448` lma:/lma1/lmt/data_lmt

for which we have a script, which also works from any directory:

.. code-block::

   cln% rsync_lma 79448

note that this script only needs the main (Map) obsnum, the calibration (Cal) is automatically included.

3. To re-run:   edit settings in ``2018S1SEQUOIACommissioning/79448/lmtoy_79448.rc`` ,and re-run:

.. code-block::

   lma% SLpipeline.sh obsnum=79448
        Re-Processing SEQ in 2018S1SEQUOIACommissioning/79448 for IRC+10216


Parallel Processing
-------------------

Although the SLpipeline consists of single processor code, this is
sufficient for a single ObsNum.  However, to stack a large number of
ObsNum's it can be useful to run run a whole data-reduction session
using GNU parallel, since the pipelines are independent. Here is an
example:  first the serial code for the M31 project, where 3 different
correlators settings cover three spectral lines:

.. code-block::

      # CO
      SLpipeline.sh obsnum=85776 
      SLpipeline.sh obsnum=85778 
      SLpipeline.sh obsnum=85824 
      SLpipeline.sh obsnums=85776,85778,85824

      # XXX
      SLpipeline.sh obsnum=85818
      SLpipeline.sh obsnum=85826
      SLpipeline.sh obsnum=85882
      SLpipeline.sh obsnums=85818,85826,85882

      # YYY
      SLpipeline.sh obsnum=85820
      SLpipeline.sh obsnum=85878
      SLpipeline.sh obsnums=85820,85878

This took about 29 minutes to reduce. Now we can split this up by
first running all eight single obsnum's in parallel, followed by the
three combinations in parallel, viz.

.. code-block::

      # construct the single obsnum pipelines job
      echo SLpipeline.sh obsnum=85776   > job1
      echo SLpipeline.sh obsnum=85778  >> job1
      echo SLpipeline.sh obsnum=85824  >> job1

      echo SLpipeline.sh obsnum=85818  >> job1
      echo SLpipeline.sh obsnum=85826  >> job1
      echo SLpipeline.sh obsnum=85882  >> job1

      echo SLpipeline.sh obsnum=85820  >> job1
      echo SLpipeline.sh obsnum=85878  >> job1

      # construct the combination pipelines job
      echo SLpipeline.sh obsnums=85776,85778,85824   > job2
      echo SLpipeline.sh obsnums=85818,85826,85882  >> job2
      echo SLpipeline.sh obsnums=85820,85878        >> job2

      # ensure you have enough true cores and memory these can be run in two steps:
      parallel --jobs 8 < job1
      parallel --jobs 3 < job2


Using this technique, the same process took 6 minutes on a 512GB machine with 32 true cores,
a speedup of almost a factor 5.

 
Web server
----------

The PI will need a password to acccess their ProjectId. It will be at something like

.. code-block::

      https://your_lmt_url/archive/2018-S1-MU-45

within which various **obsnum**'s will be visible, and possibly some combinations

.. code-block::
      
      85776/                     # individual obsnum pipeline reduced
      85778/
      85824/
      85776_85824/               # combining the 3 previous obsnums

      85776_TAP.tar              # TAP tar files for better (?) offline browsing
      85778_TAP.tar
      85824_TAP.tar
   
      85776_SRDP.tar             # full SRDP tar files for better (?) offline browsing
      85778_SRDP.tar
      85824_SRDP.tar
      85776_85824_SRDP.tar
   
      85776_RAW.tar              # full RAW telescope data for your local $DATA_LMT tree
      85778_RAW.tar              # only useful if you want to re-run the pipeline 
      85824_RAW.tar              # and only made available upon special request




Future LMT SLR data reduction
-----------------------------

Here we describe the workflow in the future unified SDFITS based
system.  The first step is always the RAW (lmtslr or dreampy3) based
conversion (*ingestion*) to SDFITS. If you are in an interactive
python session, the data will be in memory in a special class, there
should be no formal reason to save the SDFITS file (formerly called
the *SpecFile* in lmtslr), but one is well adviced to do this. 

Load and Go
~~~~~~~~~~~

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



Workflow
~~~~~~~~

UMass Server has the data, a web interface will run the new-style pipeline. Data can be inspected.
New parameters can be set, and re-imaged.

The TolTECA data reduction workflow has a high level config file (yaml?) which via a command line
interface steers the pipeline.
