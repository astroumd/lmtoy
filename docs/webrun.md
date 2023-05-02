# Running SLpipeline via a web interface

At the moment this is a discussion document.

## Reminder of nomenclature in the LMTOY environment in this document

Some of these are environment variables, others so noted for convenience

      $DATA_LMT   - root directory of the read-only raw data
      $WORK_LMT   - root directory of the session's working area
      $PID        - LMT's *ProjectId*
      $PIS        - PI session name  (new in webrun)
      $SRC        - Source Name

## Overview for the lmtslr user:

This is how the pipeline is normally run from the main *lmtslr* account,
from the directory where the script generator lives:

      cd $WORK_LMT/lmtoy_run/lmtoy_$PID
      git pull
      make runs
      sbatch_lmtoy.sh $PID.run1
      sbatch_lmtoy.sh $PID.run2
      make summary
      xdg-open https://taps.lmtgtm.org/lmtslr/$PID

The work results for this PID will be in $WORK_LMT/$PID
 
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

1. User authenticates and get a list of valid PIDs (at least one)

   Examples of PIDs:    2023-S1-MX-1   2022S1RSRCommissioning

2. User picks *one* PID to work on.

   CL equivalent: (there is no authentication needed within the shell of the CL)
   
           PID=2023-S1-MX-1

3. If multiple sessions were available for this project, pick one, or allow
   a new one to be created.

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


## Open Questions

Q1: How many compute nodes do we give the PI. One for all PIs?

Q2: What if a PI has data from different PID's that need to be combined?

    the pipeline user can do this, but a webrun doesn't have a solution for this yet.