Spectral Line Workflow
======================

The current (pre2021) style workflow requires you to have your RAW files locally present. For LMT data this 
means having them located in your local $DATA_LMT tree.  In the future we expect another workflow, described
later in this section. 

In this current workflow, all you need to know is a set of **ObsNum** 's , which can be obtained by quering
(some) database. We need some examples of this.

SLR data
--------

The scripts ``lmtoy_reduce.sh`` and ``lmtoy_combine.sh`` will reduce single and combined OBSNUM's. They
always work through an intermediate Specfile (equivalent to our future SDFITS file), which gets gridded

NOTE:  renaming these to **rsr_** (nov 2021)

RSR data
--------

The scripts ``rsr_driver.sh`` and ``rsr_sum.sh`` are two methods to reduce RSR raw data. There is
no SpecFile.

Many more details of the old workflow is in ``examples/lmtoy_reduce.md``

NOTE:  we now have **rsr_pipeline.sh** and **rsr_combine.sh**


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


Current (nov 2021) Workflow
---------------------------

Here is a working procedure to get LMT data and reduce them
in your own local workspace, and assuming the full LMTOY toolkit has been installed:

1.  Find out which **obsnum** covers your observation(s).  This must include calibration ObsNum's as well.
    There are some existing databases and logfiles where a simple **grep** command will probably be sufficient
    to get the obsnums. The **lmtinfo.py $DATA_LMT** command can also be useful. If you have **Scans.csv**,
    this might also be useful. If you see a log file inside of $DATA_LMT, this might be useful too.
    Sa they say, YMMV.
    
2.  Get the data from a full $DATA_LMT archive (e.g. at "cln",or at LMT) via the **rsync_lma** script. Obviously
    only somebody on that archive machine can do this. But here is an example that worked (this script
    has not been blessed by LMT experts like Kamal or Gopal) but is laborious:

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

An alternative would be a direct rsync conection between e.g. cln to lma:

   cln% cd $DATA_LMT
   cln% rsync -avR `lmtar.py 79447 79448` lma:/lma1/lmt/data_lmt

for which we have a script, which works from any directory:

   cln% rsync_lma 79448

note that this script only needs the main (Map) obsnum, the calibration (Cal) is automatically included.

3. To re-run:   edit settings in **2018S1SEQUOIACommissioning/79448/lmtoy_79448.rc** ,and re-run:

.. code-block::

   lma% SLpipeline.sh obsnum=79448
        Re-Processing SEQ in 2018S1SEQUOIACommissioning/79448 for IRC+10216


Parallel Processing
-------------------

Although the SLpipeline consists of single processor code, it is possible to run a whole data-reduction using
GNU parallel, since the pipeline are independent.  An example:

.. code-block::

      SLpipeline.sh obsnum=85776 
      SLpipeline.sh obsnum=85778 
      SLpipeline.sh obsnum=85824 
      SLpipeline.sh obsnums=85776,85778,85824

      SLpipeline.sh obsnum=85818
      SLpipeline.sh obsnum=85826
      SLpipeline.sh obsnum=85882
      SLpipeline.sh obsnums=85818,85826,85882

      SLpipeline.sh obsnum=85820
      SLpipeline.sh obsnum=85878
      SLpipeline.sh obsnums=85820,85878

took about 29 minutes to reduce, because each task runs serially. However all the single obsnum could be run in
parallel, followed by the three combinations in parallel, viz.

.. code-block::

      # contruct the single obsnum pipelines job
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

      # ensure you have enough true cores, not hyperthreading cores
      parallel --jobs 8 < job1
      parallel --jobs 3 < job2


Using this technique, the same process took 6 minutes on a 512GB machine with 32 true cores.



 
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
