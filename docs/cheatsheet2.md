# SLpipeline cheat sheet (April 2024)

We outline the steps to reduce data with LMTOY's SLpipeline on Unity.

We assume LMTOY is present and up to date.   This command

      lmtoy

will inform you of some important parameters for your LMTOY.

We are also assuming you are working on a particular project, which
we will set as an environment variable, for example

      PID=2024-S1-MX-2

1. Go to the *script generator* directory for this project:

         cd $WORK_LMT/lmtoy_run/lmtoy_$PID

   This should have been set up for you. If not, contact PeterT.


2. Inspect the **README.md**, **comments.txt** and **mk_runs.py** files for human and programmatic
   information, and keep them up to date.

   There should be more verbiage here what's in the *mk_runs.py** file....


3. When **mk_runs.py** has been edited, make *run* files for Unity's **sbatch** system
   using this command:

         make runs

   The most complex ones are two-IF SEQ, where it creates a run1a, run1b and run1c file.
   These refer to a fresh start for both banks (run1a), then a specific run for bank=0 (run1b)
   and finally a specific run for bank=1 (run1c).

         sbatch_lmtoy.sh $PID.run1a
	 squeue --me | nl -v 0
	 
	 <patiently wait until all your obsnums have exited from the queue>
      
         sbatch_lmtoy.sh $PID.run1b

         <patiently wait for all the runs to finish>
      
         sbatch_lmtoy.sh $PID.run1c

         <patiently wait for all the runs to finish>

   When only one bank is present, only run1a and run1b is needed. For RSR data only run1a is needed.

4. When all these single obsnums are finished, make a summary

         make summary

   The results can be viewed on

         http://taps.lmtgtm.org/lmtslr/$PID

5. Now run the combination using the run2 script(s). Typically you only need
         
         sbatch_lmtoy.sh $PID.run2a

   It will do both banks (if you have two IF's)

6. Again do a summary and view the results

         make summary
         http://taps.lmtgtm.org/lmtslr/$PID	 

## Advanced use:

1. Mosaiced fields

   Example:  2024-S1-MX-2

2. Combining data from different projects

Example: 2024-S1-UM-1 and 2023-S1-UM-8  (notably their pointing center is different!!!)


3. Removing all your jobs from the sbatch queue:

         scancel $(squeue --me | tail +2 | awk '{print $1}')

4. Find out if there are new obsnums for a specific project

         source_obsnum.sh $PID

    If this looks different from what you have in your **mk_runs.py** file,
    for example new sources and/or new obsnums, add them to the file
    and make new run files and sbatch them .

    You can also manually search the raw data, for example

         lmtinfo.py grep 2024-03-17 Science 
         lmtinfo.py grep 2024-03-17 LineCheck Bs


   pipeline parameters).  

5. The files in the script generator directory are normally saved on github. That's for
   another chapter.
