# A Spectral Line Pipeline

When an observing script finishes, there is a unique **obsnum**,
which records the instrument, observing mode, and possibly
other obsnum's for calibration.

These can be passed on to a pipeline
executor, which can then decide what tasks to run to run a "quick-look" pipeline
and provide a summary of the results, including some standard QA figures and log files.


## Where is the work done

When observing concludes, raw data will show up in $DATA_LMT, and some signal
will be given to some database that a given obsnum is available. There is a lot more
behind this statement, as this depends on whether one  at LMT, or at basecamp, or
at UMass, or even ones' laptop (where only manual mode is supported). For now, imagine
a new obsnum is available.

The pipeline will reduce thne data in $WORK_LMT and create a directory tree
starting with **$ProjectId/$obsnum**.  If $WORK_LMT is not set, it will be interpreted
as the current directory.


## SLpipeline.sh

For the 2021-S1 season we expect to use the **SLpipeline.sh** script. The intent
is that the script only needs an **obsnum**, and will figure out which instrument
is used, and run the reduction via the instrument specific reduction scripts.

There will also be optional *PI Parameters*, which are under discussion, but we will 
assume they are a series of *keyword=value* pairs.

### Sequoia

How to use this is best described through an example. We use proposal **2018-S1-MU-46**
where a
small patch of M31 was observed several times. Each obsnum is run through the pipeline, 
inspected, maybe re-run if need be, and then combined in a final set of cubes.

      SLpipeline.sh  obsnum=85776 
      SLpipeline.sh  obsnum=85778
      SLpipeline.sh  obsnum=85824 
      lmtoy_combine.sh obsnum=85776,85778,85824 pdir=2018-S1-MU-46 output=M31a

This will have created three obsnum directories inside the **2018-S1-MU-46** directory.
Various figures will need to be inspected, and you would find out that pixel 3
(counting pixels from 0 to 15) is bad for the first. in each obsnum directory the
corresponding **lmtoy_OBSNUM.rc** file will contain parameters that control the pipeline.
The ones most likely useful for masking are:

### pix_list

This is the list of pixels to be used for this obsnum. In the gridder step pixels cannot
currently be selected.  The full list of pixels would be:

      pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

### sample

This can be a painfully long parameter,
because it is a series of 3 integers, giving the pixel number, first and last
calibrated scan in the SpecFile.

### masking

A masking file is the most powerful and flexible way to pass masking information
to the pipeline. It does not exist yet (jul 2021)

## RSR

The RSR receiver....

## 1MM

The 1MM receiver....

## B4R

This 2MM received is not covered here.
