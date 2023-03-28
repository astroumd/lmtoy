# Running SLpipeline via a web interface

## Overview of steps

1. User authenticates and get a list of valid PIDs (at least one)

   Examples of PIDs: 2023-S1-MX-1 2022S1RSRCommissioning

2. User picks one PID to work on.

   CL equivalent:
   
           PID=2023-S1-MX-1

3. Interface returns a list of sources that can be worked on, user picks one or more.

   CL equivalent:

           lmtinfo.py grep $PID | tabcols - 6 | sort | uniq -c
           

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



Of course 4 is the tricky part.  Each obsnum keeps track of its
default pipeline (as determined by the QA process) settings, to which
the PI can modify the PIPLs and re-run.

My current workflow is centered on a script generator, which is
project centered, and lives in git space (read: github).  I already
have an example python workflow which uses this and finds the pipeline
commands. But I suspect that based on which instrument it finds, it
needs to present the useful/valid parameter options.


