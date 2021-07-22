# A Pipeline

When an observing script finishes, it presumably knows the instrument and
observing mode, including the **obsnum**. These can be passed on to a pipeline
executor, which can then decide what tasks to run to run a "quick-look" pipeline
and provide a summary of the results, including some telling figures.

Since there are a number of instruments and software components, let us first
look at a Sequoia OTF cube.

## SLpipeline.sh

For the 2021-S1 season we expect to use the **SLpipeline.sh** script. The intent
is that the script only needs an **obsnum**, and will figure out which instrument
is used, and run the reduction via the instrument specific reduction scripts.

### Sequoia

How to use this is best described through an example. We use a proposal where a
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

This is a painful parameter, because it is a series of 3 integers, giving the pixel number, first and last
calibrated scan in the SpecFile.
