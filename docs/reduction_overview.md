# Outline for Data Reduction flow for Spectra Line Receivers:

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


## List of Steps for Proposer from Grant's email of May 10.

Here's the list of steps I was talking about during the telecon.  This was just me thinking out loud, I could be convinced of other approaches.  I initially wrote this list to help identify what software we're missing on the TolTEC side.

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
