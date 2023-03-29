# Running SLpipeline via a web interface

## Reminder of nomenclature in the LMTOY environment in this document

      $DATA_LMT   - root directory of the read-only raw data
      $WORK_LMT   - root directory of the session's working area
      $PIN        - PI account name 
      $PIS        - PI session name
      $PID        - LMT's *ProjectId*
      $SRC        - PI's source name (no spaces or UTF-8)

## Overview of steps

1. User authenticates and get a list of valid PIDs (at least one)

   Examples of PIDs: 2023-S1-MX-1 2022S1RSRCommissioning

2. User picks *one* PID to work on.

   CL equivalent: (there is no authentication)
   
           PID=2023-S1-MX-1

3. If multiple sessions were available for this project, pick one, or allow
   a new one to be created.

   CL equivalent:

	   mkdir -p $WORK_LMT
	   export WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt/$PID/$PIN/$PIS
	   cd $WORK_LMT
	   lmtoy_run $PID

   this will create (or re-use) the $WORK_LMT/$PID directory

3. Interface returns a list of sources that can be worked on, user picks *one or more*.

   CL equivalent for one SRC:

           lmtinfo.py grep $PID | tabcols - 6 | sort | uniq -c
	   cd $WORK_LMT/lmtoy_run/lmtoy_$PID
	   make runs
	   grep $SRC *.run1a > test1
	   grep $SRC *.run2a > test2

   (append more for more SRC)
           

4. Interface returns a list of obsnums, and their PI/PL how the script generator
   had last decided it was going to be run

   obsnum=123456 badcb=1/2,3/4 cthr=0.02
   obsnum=123457 trhr=0.015
   obsnums=123456,123457 
   
   These can be edited and submitted via slurm.    Single obsnum= runs - by definition -
   can be run in parallel.
   Combination obsnums= need to wait before the single ones are done, but for multiple
   sources, can be run in parallel as well.
   
   In the command line version these are the "run1" and "run2" files:

        sbatch_lmtoy.sh *.run1a
   and
        sbatch_lmtoy.sh *.run2a

5. After submission of jobs, relevant summary listings are updated, and can be viewed online

   In the command line version:

        make summary



## Questions

Q1: How many compute nodes do we give them. One for all PIs?

Q2: how many session configurations? work areas (called $PIS here)

Q3: In the current scheme, when the 'lmtslr' users runs the pipeline, results are in

             /nese/toltec/dataprod_lmtslr/work_lmt/$PID
    
    In that hierarchy the PI has read access.

    If we create a new session in
    
    WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt/$PID/$PIN/$PIS

    the PI (lets say teuben) can now view the summary in
    
    http://taps.lmtgtm.org/lmtslr/2023-S1-US-18/teuben/session-1/2023-S1-US-18/

    Name checking needed, image the PI using an crafted session name that allows
    them to write directly into /nese/toltec/dataprod_lmtslr/work_lmt/$PID itself
