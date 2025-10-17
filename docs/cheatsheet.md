# LMTOY cheat sheet (October 2025)

A brief reminder on the commands various stakeholders use to operate the pipeline and archive ingestion.

## 1. Lightweight TAPs Pipeline: lmtslr@malt

**malt** is the computer at LMT that we use to run the pipeline while data have been
taken. The lightweight TAP's are sent to Unity, where they can be viewed.
The user **lmtslr** runs the commands here.


1. When new software in LMTOY is available, use

       lmtoy pull

   and pay attention if anything needs to be recompiled. Most is python, and doesn't need any
   further action. Only the gridder may need a recompilation, but this is rare:

       cd $LMTOY
       make update

   and sometimes a NEMO task, e.g.

       mknemo ccdfits fitsccd

2. Start the data catcher

       cd ~/SLpipeline.d
       SLpipeline_run.sh > SLpipeline.log 2>&1
       tail -f SLpipeline.log

   A file **SLpipeline.pid** contains the **process id** of **SLpipeine_run.sh**.  This
   needs to be killed before running another one (e.g. if software was updated)

       kill -9 $(cat SLpipeline.pid)
       rm SLpipeline.pid

   There is an outstanding issue on speed. If the datasize on $DATA_LMT gets too big,
   the loop recomputing the lmtinfo data is taking too long.

   Example: 1-oct-2024 it took nearly 7 minutes for 1384 GB /scratch/data_lmt/ using 8000 obsnum.
   With only 2300 RSR in 3.6 GB it took almost 1 minute.

3. This data catcher will allow some "permanent" extra parameters (e.g. pix_list=-13) to
   the pipeline, if added to the file **SLpipeline.in**:

       edit SLpipeline.in

4. Summary of what rsync has done is a nice way to remotely keep track of progress

       tail -f rsync.log

4. Re-execute a pipeline with extra parameters (only for urgency, since malt is slow)

       SLpipeline_run1.sh 113271 2024-S1-MX-24 dv=10 dw=10

   this is a convenient way to fix really bad pipeline runs if you want to see them in the "last100"

6. After this the most recent 100 TAP's produced are on this list:

       	xdg-open http://taps.lmtgtm.org/lmtslr/lmtoy_run/last100.html

7. There is also a way to make these TAPs available via a tunnel on a browser that runs
   on **malt** itself, but this is for emergency only and is usually not available as the TAP
   copies to Unity seem pretty reliable now.

## 2. Script Generator (anybody, via git)

This is the bootstrap proces when a new project has its first data arrive.
This work can be done anywhere, since it's git controlled. But the initial bootstrapping
depends on the user having
installed the **gh** (github CLI) command, otherwise it's annoying work in the browser.

0. Set the ProjectId in a convenient shell variable **$PID** we are working with in this cheat sheet

       PID=2024-S1-MX-24

1. Bootstrap a new script generator for this project (the **gh** command is needed here)

       cd $WORK_LMT/lmtoy_run
       ./mk_project.sh $PID
       make links

   The last step, the links, are convenient for going back and forth between where the pipeline
   data are and where the script generator is.

2. Edit **Makefile** to add lmtoy_2024-S1-MX-24 to the specific year

       edit Makefile

3. Edit **comments.txt** to add 2024-S1-MX-24

       edit comments.txt

4. Edit **README.md** to say a few interesting things, make sure $PID is correct

       edit README.md

4. Commit the changes

       git commit -m "new project"  Makefile comments.txt README.md
       git push

5. Typically at the end of observing season, a record of all the obsnums is saved as well in **lmtinfo.txt**:

       lmtinfo.py $PID > lmtinfo.txt
       git add lmtinfo.txt
       git commit -m "observing records" lmtinfo.txt
       git push

## 3. Main Pipeline: lmtslr_umass_edu@unity

1. Check if new raw data has come in

       data_lmt_last

   Pay attention to the "Last recorded obsnum" and the latest SEQ and RSR obsnums listed in the output.

   Notes:

       1. Also watch the daily email (around noon) from `lmtsciop` with the Nightly Observations Report.
          Links to a page on the wiki.lmtgtm.org. They also report what the last obsnum was.
       2. watch the last100.html - but this depends if malt is running ok.
       3. Even if these report the last data, the `data_lmt_last` has the final word.

2. Update the "lmtinfo" database if new data should be added (see previous point)

        cd $DATA_LMT
        lmtinfo.py last
        make new2 

   This process can take a few mins. After this, make sure that last.obsnum is updated correctly with the
   command

        lmtinfo.py last

3. Update your script generators and make sure they are consistent

        cd $WORK_LMT/lmtoy_run/
	make git pull
	#
	make status

   Depending if you left unchecked portions, you may need to commit those.

   Note that the DA may work in a branch, it is adviced the PO does not use branches (or at your own risk)

4. Find out if there are new obsnums for a specific project

        source_obsnum.sh $PID

   or as long as you are in the $PID, a simpler

        source_obsnum.sh

   suffices

5. Or do a more manual search (many options here)

        lmtinfo.py grep 2024-03-17 Science 
        lmtinfo.py grep 2024-03-17 LineCheck Bs

6. Add obsnums and/or sources to the script generator
        
	cdrun $PID    # same as: cd $WORK_LMT/lmtoy_run/lmtoy_$PID
        make pull
        edit mk_runs.py
        make runs

7. To re-run a whole project, find our which run files you need. Here's an example:

        sbatch_lmtoy.sh *run1a
	make summary
	make runs
        sbatch_lmtoy.sh *run1b
        sbatch_lmtoy.sh *run1c 
        sbatch_lmtoy.sh *run2

   Be careful if you have modified

   On your screen it will show progress how far all the obsnums in each run are progressing. When they are
   all done, it will automatically turn to the next run file from the commandline etc.   It will also
   make the summary at the end, as well as update the master index.

        sbatch_lmtoy.sh *run2

   of course you'll need to wait for each sbatch to finish before the new one can start


6. But if you want to be more efficient, you made a note of the
   first obsnum (and higher) that you need to run for this project,
   lets say this is 123456, then

        sbatch_lmtoy.sh *run1a obsnum0=123456

   would only process the pipeline for obsnums 123456 and up.

7. Make summary and update the master index

        make summary index

   The following URL's will then give access to the master list, and this PID project in particular

        xdg-open http://taps.lmtgtm.org/lmtslr/lmtoy_run
        xdg-open http://taps.lmtgtm.org/lmtslr/$PID

7. To submit a whole project,including the final summary, you can do

        sbatch_lmtoy2.sh *.run??

   which runs all the runfiles like a relay race (each waiting for the other to finish), and then
   makes the summary as well.  Note this command currently blocks the terminal, but each 10 seconds
   gives a brief textual update on the status of the obsnums.

8. An even more efficient way to combine the previous 3 items is something like this (and assuming
   we had 11 new obsnums)

        sort *run1a | tail -11 > test1a
        sort *run1b | tail -11 > test1b
        sort *run1c | tail -11 > test1c
	sbatch_lmtoy2.sh test1a test1b test1c *run2

   after which you can go for lunch or dinner. No need to wait for the individual runs to finish
   and monitor the queue.

8. Ingest in the archive.  When the pipeline runs is will store obsnums in $PID/dir4dv.

   Single obsnum results can be done with:

        ./$PID.run1.sh

   and once combinations are deemed safe again, (they are not yet)

        ./$PID.run2.sh

   Note the obsnum directories in $PID/dir4dv will disappear after archives. This is safe, since they
   are hard links into the actual zip files stored in $PID/dirzip

9. If need be, update the large lmtoy_run/comments.txt file so that the dashboard is updated.


## 4. Helpdesk Pipeline: lmthelpdesk_umass_edu@unity 

Many things overlap with how the final pipeline is run and submit, except the work in git. Generally the DA's work
in a git branch, so the work can be shared with the main pipeline work. More details to come here, but here are
some points where it will differ:

0. Logging into the helpdesk account will have no LMTOY loaded, because the account is shared with TOLTEC and those
   two accounts having conflicting python environments.   So, we manually load LMTOY with a command:

        lmtoy

1. After this you need to identify yourself as a specific helpdesk person, using an identifyer, usually your name

        work_lmt peter

   This will set up your LMTOY environment ($WORK_LMT, $DATA_LMT etc.), you can view those with the lmtoy command
   again:

        lmtoy
	->
        DATA_LMT:    /nese/toltec/dataprod_lmtslr/data_lmt
        WORK_LMT:    /nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/peter

2. Reminder on some sample URLs:

        http://taps.lmtgtm.org/lmthelpdesk/peter/lmtoy_run/

        http://taps.lmtgtm.org/lmthelpdesk/peter/2024-S1-US-5/


1. setting up a DA workflow (since they all share the same account)

   1. each DA gets their own $WORK_LMT, where the pipeline data will be stored. Typically this would be ....

   2. The lmtoy_run should be in $WORK_LMT/lmtoy_run

   3. Under the lmtoy_run directory will be all the script generators for the projects, e.g. lmtoy_2021-S1-US-3

2. branching in git

   If multiple people work on a project, it's adviced to work in a branch. After the branch is merged into main,
   this branch can be deleted. If you want to re-use that name, it needs to be merged from main again.
   An example:

   1. Make a branch for testing:  "git checkout -b test1"
   2. Editing and testing done in this branch. When done, the main branch can merge this in the next step.
   3. Merge from the main branch:    "git checkout main;  git merge origin/test1"
   4. Run the pipeline with this merged set. confirm it's ok.
   5. In theory the test1 branch can be deleted.
   6. If work in test1 continues, it needs a merge from main:  "git checkout test1; git merge origin/main"
   7. If that merging is confusing , just start a new branch, say test2.


3. setting up your own YEAR file in lmtoy_run so you only see the projects you want to see, not all stuff back to 2018....

4. the viewing URLs will be helpdesk specific

5. the handoff to the general pipeline manager

6. grading (adding a qagrade= parameter to the pars) - what to do about QAFAIL. Set qagrade=-1 ?

7. final public date, but this can be automated with a 'date +1yr' type script


## 5. PI remote execution

Something needs to be written down how a remote PI webrun is impacted when new data arrives.


## 6. Noteworthy Tricks

0. the command `lmtoy help` gives various brief reminders 

1. It's possible to combine data across projects. An example is 2024-S1-UM-1, which is a followup from 2023-S1-UM-8

2. Mosaic'd data of which the field names are different, need a trick in the mk_runs.py file. See 2024-S1-MX-2
   and  2024-S1-US-20. Essentially a list of all obsnums is used, and **skip=1** is used to make sure the
   pipeline doesn't run twice for the single obsnums.


3. Using the "dunder" (double underscore) appendix to an obsnum, one can keep multiple versions (e.g. with different
   pipeline parameters).  Eventually the **oid=** might solve this too. But manual labor mean you need to rename
   *all* affected obsnums as in this example:

         mv 123456 123456__otfcal

4. Update one or more NEMO programs

         mknemo -u txtpar tabcols tabrows

4. Removing all your jobs from the sbatch queue:

         scancel $(squeue --me | tail +2 | awk '{print $1}')

5. If unity is too slow at the login node, set up your more personalized bash session as follows.
   Example here is for 8GB and 4 hours, adjust as needed.
   
         srun -n 1 -c 4 --mem=8G -p toltec-cpu -t 4:00:00 --x11 --pty bash
	 
   Unity helpdesk also recommends this command

         unity-compute

6. To check if we've missed obsnum in a particular year:


         cd $WORK_LMT
	 do_year 2025

   now look in the obsnums listed in tmp_2025.fail and investigate.  Format is horrible,
   work to be done here.   Also to check if the new column VALID is 1, since 0s should not
   appear in this list.

