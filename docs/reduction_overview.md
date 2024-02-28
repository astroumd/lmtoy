# 1. Outline for Data Reduction flow for Spectra Line Receivers:

1. Observations for an obsnum completed.
2. data files for just completed obsnum transferred to disk on data reduction
      computer. (Estimated to require 1 minute per 1 hour of SEQUIOA observations and
      would stop WARES data collection for that minute(s))
3. SLR pipeline run on data reduction computer at telescope or base camp. Automated
      with defaults and proposer input from script preparation process. NO user interaction
      with actual operation. The result is preliminary reduction with data cube and spectra,
      as appropriate. ADMIT run as the final stage of the pipeline to create ADMIT quick-look
      products.
4. ADMIT products made available to telescope operator and scientist
5. ADMIT "lite" products transferred to archive sites and put into project number directory. These
      are viewable on webpages -- static plots. Data volume is a few MB so that should be available
      "shortly" after the pipeline run is completed. The proposer would have access to these 
      to see if the observations were successful.
6. email proposer to tell them that quick-look overview of observations are available to viewing
7. Data cubes/spectra from preiminary reduction are e-transported back to archive(s). These too
      are loaded into the project number directory. These will generally be 1/10th to 1/100th the
      size of the raw data for SEQUOIA; they will be small for RSR. Proposer can download these
      cubes/spectra and view them locally as they please. They will be FITS files.
8. Raw data are transported down the mountain to INAOE and e-transported to archive(s). This could
      take 3-5 days.... Data will go into raw data structure in archive.
9. Pipeline will be run at archive(s) to create reduced data and intermediate products for proposer
      to interact with DASHA page for inspection of data in more detail. This stage would also combine
      obsnums if they are pieces of a common observation to create a cumulative data product.
10. Proposal can change selected parameters in pipeline reduction via web-page interface and create
      new version(s) of the reduced data. These versions would be kept in their project-number directory
      in which there can also be several obsnum's.
11. Proposer transfers home their final data cubes/spectra with great happiness.


## 1.1 List of Steps for Proposer from Grant's email of May 10.

Here's the list of steps I was talking about during the telecon.  This
was just me thinking out loud, I could be convinced of other
approaches.  I initially wrote this list to help identify what
software we're missing on the TolTEC side.

What steps does a user of the LMT need to take from the post-proposal acceptance period to the end of data reduction?

1. Plan out observations and generate the observing scripts (we now have a tool under development for TolTEC to do this)
2. Submit the final scripts for review by LMT staff and iterate if necessary 
3. Wait for the observations to be completed
4. Review the observation metadata and any quicklook/diagnostic results (we don't have a plan for this yet)
5. Plan out data reduction and generate the data reduction scripts 
6. Submit the final data reduction scripts for review and iterate if necessary 
7. Wait for the data reduction to be completed
8. Download and review the data reduction products (need a plan and new software for this, baseline is to use a Dataverse instance)
9. Characterize the reduction quality 
10. Iterate by going back to step 5 if needed.


# 2. Overview of the LMTOY pipeline steps

LMTOY has been installed at **malt** (@LMT) and **unity** (@UMass), plus development copies
exist at UMD and Peter's laptop.

A reminder on the directory locations:

       $LMTOY                 LMTOY software tree
       $DATA_LMT              raw data
       $WORK_LMT              reduced data are in a Project_Id/ObsNum hierarachy
       $WORK_LMT/lmtoy_run    script generators

and password protected URLs:

       http://taps.lmtgtm.org/lmtslr/lmtoy_run/        - LMTOY pipeline index list to all projects
       http://taps.lmtgtm.org/lmtslr/2021-S1-US-3/     - Example of a ProjectId
       http://taps.lmtgtm.org/lmtslr/2021-S1-US-3/TAP  - Example of the lightweight TAPs of a project
       https://www.astro.umd.edu/~teuben/work_lmt/     - peter's non-official experiments
       http://wiki.lmtgtm.org/lmtwiki

## 2.1 Steps

1. We skip the many steps prior to an observation. This list starts with RAW data showing up on malt
  (recall the data taking computer needs to rsync the RAW data to malt first, so there is a small
   delay)
      
* On **malt** we run the pipeline watcher from a special directory from the **lmtslr** user account
  where LMTOY is installed:

       cd SLpipeline.d
       SLpipeline_run.sh

  This will keep a running log what obsnums are being taken, and their instrument, obsgoal etc.

  The **lmtinfo.py** command will see new obsnums as they have been processed by the **lmtinfo.py build**
  process. This is usually fast on **malt** as we don't keep a lot of data here.

  As soon as new "science" data arrive, it will run the pipeline, summarize some results in red
  on the screen, and copy the lightweight TAP's to unity.
 
  NOTE we have no idea what projects and obsnums are being done. All we see on screen is

  ...

  TODO: check if a new project is now properly installed on **Unity** in their supposed location
  $WORK_LMT/$PID/TAP 


* On **unity** we need to ensure the TAP's are visible in the TAP URL of the ProjectID; this may
  need manual labor. (already done via malt?)

* The script generator needs to be be prepared.

  The steps are detailed in lmtoy_run/README.md, and the important directories are:
  
       $WORK_LMT/$PID                        where the data will go
       $WORK_LMT/lmtoy_run/lmtoy_$PID        where the script generator lives (also on github)

  It also depends on having symlinks between the $WORK_LMT/$PID and $WORK_LMT/lmtoy_run/

  It would be useful to have the phase-2 spreadsheet here, so some of the pipeline parameters
  can be extracted.  Are we allowed to keep a copy here ?

  - add obsnums of the source (there's a script than can make a template)

  - add comments to comments.txt

  - "make runs" : created the *run files

  - "sbatch_lmtoy.sh *.run1a

  - "make summary"    (this depends on the symlinks)

* A daily summary of all PID is in $WORK_LMT/lmtoy_run/README.html and visible to the pipeline admins,
  (but not the PI !!)

       cd $LMTOY/lmtoy_run
       make index

* DA team monitors what has been reduced

* Archivie ingestion. There are a  few unchecked items for the *yaml* file:
  - **qaGrade**  (see discussion below)
  - **obsComment**   - currently None
  - **publicDate**   - currently 2099-12-31


## Grading a project (email from Lee)

The DAs assign a grade -1 or 1-5 for each OBSNUM. They are approximate
estimations of the quality of the data, not the signal level, The considerations
that go into a grade:

1, absolute tau
2. stability of tau over time
3. rms compared to expected for frequency, time, and elevation of observation
4. stability of system temperature
5. number of good beams compared to expected
6. baseline stability/hardware issues/pointing/focus issues

Definitions are grades:

* -1: QAFAIL -- hardware/pointing/focus issues, system temperature >
  10x expectation rms > 10x expectation. The expectation is that these
  data are unusable for science.

* 1: bad but maybe usable-- tau/system temperature highly variable with
  time (>50%, after consideration of elevation effect), system
  temperature > 5x normal, missing > 50% of beams. highly variable
  baselines

* 2: poor -- rms > 4x expectation, tau/system temperature variable with
  time >20% level, hardware issue that affect the waterfall plot for
  many beams

* 3: typical, OK -- nothing wrong with the data. reasonable stability
  of tau and system temperature, nominal number of beams and no major
  structures in waterfall plot.

* 4: good -- tau better than typical, no apparent hardware
  problems. Waterfall plots look good for good beams. rms within
  factor of 2 of expectation

* 5: excellent -- very stable tau and system temperature, no apparent
  hardware problems. tau < 0.2 at frequency of observation

In this grading system, all data graded 3,4,5 should be usable for science.
Hopefully these three grades should include >80% of the data.

Grade of 2 means that the PI should look closely at the data and see if
it is appropriate to be used.

Gard of 1 means that the PI should carefully consider the problem with the
data before using it. The data may be usable in limited situations.

In counting the time accumulated for a project, the QA grade would be considered.
Grades 3,4,5 would definitely be considered successful. The observatory will
need to decide about grade2.
