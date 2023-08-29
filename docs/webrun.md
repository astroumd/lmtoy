# Running SLpipeline via a web interface

At the moment this is a discussion document. The source code for the webrun environment
is currently in:    https://github.com/lmtmc/lmt_web

## Reminder of nomenclature in the LMTOY environment in this document

Some of these are environment variables, others so noted for convenience

      $DATA_LMT   - root directory of the read-only raw data
      $WORK_LMT   - root directory of the session's working area
      $PID        - LMT's *ProjectId*  (e.g.  2023-S1-UM-10)
      $PIS        - PI session name  (a new concept in *webrun*)
      $SRC        - Source Name

## Overview for the lmtslr user:

This is how the pipeline is normally run via a CLI from the main *lmtslr* account

We start from the directory where the project script generator lives, generate
run files for this project and submit them to SLURM. Note that each
(sbatch_lmtoy.sh) command here can only be run when the previous command has finished!

      cd $WORK_LMT/lmtoy_run/lmtoy_$PID
      git pull
      make runs
          [should find out which run files there are to run]
      sbatch_lmtoy.sh $PID.run1
      sbatch_lmtoy.sh $PID.run2
      make summary
      xdg-open https://taps.lmtgtm.org/lmtslr/$PID

This is the typical workflow for the pipeline operator, as well as the DA.

The work results for this PID will be in $WORK_LMT/$PID, but is available
to the PI at https://taps.lmtgtm.org/lmtslr/$PID
 
The PI webrun will essentially do the same thing, but in a new hierarchy
for just that PID, and underneath a new $WORK_LMT/$PID/session/ tree, as
summarized below:

## Directory hierarchy:

Following this convention we arrive at the following proposed directory hierarchy

     ..../work_lmt/                                       top level WORK_LMT used by pipeline
                   lmtoy_run/lmtoy_PID                    script generator used by pipeline
                   PID/                                   The PI has web-read-access to this tree via index.html
                       O1                                 obsnum's
                       O2
                       ..
                       session.dat                        this file contains session entries "1" and "2"
                       session-1/                         PIS=session-1 is the new WORK_LMT for this webrun session
                                 lmtoy_run/lmtoy_PID/     
                                 PID/O1                   only one PID in this session
                                     O2
                                     ..
                       session-2/lmtoy_run/lmtoy_PID      PIS=session-2 is the new WORK_LMT for this webrun session
                                 PID/O1
                                     O2
                                     ..


      
## Overview of steps

Command Line (CL) equivalent commands are given where this makes sense:

1. User logs in and authenticates for a given PID.

   Examples of PIDs:    "2023-S1-MX-1"
                        "2022S1RSRCommissioning"

   CL equivalent: (there is no authentication needed within the shell of the CL)
   
           PID=2023-S1-MX-1


2. If multiple sessions were available for this project, pick one, or allow
   a new one to be cloned.  There will always be one session, the one that
   was prepared for the DA's for the PI. It cannot be modified though, only
   cloned.

   CL equivalent (notice we only redefine the WORK_LMT):

           PIS=1
     	   export WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt/$PID/Session-$PIS
           mkdir -p $WORK_LMT
           cd $WORK_LMT
           lmtoy_run $PID

   this will create (or re-use) the $WORK_LMT/$PID directory and the pipeline is now
   set up with the script generator and a default run can be submitted.
   webrun has exclusive read/write in this new WORK_LMT tree

3. Interface returns a list of sources that can be worked on, user picks *one or more*.

   CL equivalent for one SRC:

           lmtinfo.py grep $PID | tabcols - 6 | sort | uniq -c
           cd $WORK_LMT/lmtoy_run/lmtoy_$PID
           make runs
           grep $SRC *.run1a > test1
           grep $SRC *.run2a > test2

   (append more for more SRC)
           

4. Interface returns a list of obsnums, and their PI/PL's how the script generator
   had last decided it was going to be run, e.g.

   obsnum=123456 badcb=1/2,3/4 cthr=0.02
   obsnum=123457 trhr=0.015
   obsnums=123456,123457 
   
   These can be edited and submitted via SLURM.    Single obsnum= runs - by definition -
   can be run in parallel.
   Combination obsnums= need to wait before the single ones are done, but for multiple
   sources, can be run in parallel as well.
   For SEQ multiple banks need to be run serially.
   
   In the command line version these are the "run1" and "run2" files:

        sbatch_lmtoy.sh *.run1
   and
        sbatch_lmtoy.sh *.run2

   **NOTE**:  this section needs a session managment where the status of the keywords belonging
   to an obsnum are recorded and picked up the next iteration. Valid keywords need to be provided
   since they are instrument specific.

5. After submission of jobs, relevant summary listings are updated, and can be viewed online

   CL equivalent:

        make summary

   the PI can then compare the pipeline results in

        https://taps.lmtgtm.org/lmtslr/2018-S1-MU-45/84744

   with their webrun in

        https://taps.lmtgtm.org/lmtslr/2018-S1-MU-45/Session-1/2018-S1-MU-45/84744

   One could argue the 2nd 2018-S1-MU-45 is superfluous, but the problem is that the pipeline
   expects a PID below a WORK_LMT


## Example scenarios

The current lmtoy/docs/ui slides suggest the following workflow, perhaps in a Previous/Next series?

This is the suggested workflow for SEQ/Map

1. sessions:  select a session
2. sources:   select one or more sessions
3. obsnums:   select one or more sources, also pick a bank (and what about freq setup)
4. beams (SEQ): select which beams to keep, and what time ranges to reject   [bank confusion]
5. baselines (SEQ): select spectral range where baselines are to be measured
6. calibrations (SEQ): how spectra are calibrated
7. gridding (SEQ): how map is gridded: mapsize, resolution, cell
8. output:  overall flow, output products etc.


## Open Questions

Q1: How many compute nodes do we give the PI. One for all PIs?

Q2: What if a PI has data from different PID's that need to be combined?

    the pipeline user can do this, but a webrun doesn't have a solution for this yet.
