# LMTOY cheat sheet

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

2. Start the data catcher

       cd ~/SLpipeline.d
       SLpipeline_run.sh > SLpipeline.log 2>&1
       tail -f SLpipeline.log

   A file **SLpipeline.pid** contains the **process id** of **SLpipeine_run.sh**.  This
   needs to be killed before running another one (e.g. if software was updated)

       kill -9 $(cat SLpipeline.pid)
       rm SLpipeline.pid

2. This data catcher will allow some "permanent" extra parameters (e.g. pix_list=-13) to
   the pipeline, if added to the file **SLpipeline.in**:

       exit SLpipeline.in

3. Summary of what rsync has done is a nice way to remotely keep track of progress

       tail -f rsync.log

4. Re-execute a pipeline with extra parameters (only for urgency)

       SLpipeline_run1.sh 113271 2024-S1-MX-24 dv=10 dw=10

   this is a convenient way to fix really bad pipeline runs.

5. After this the most recent 100 TAP's produced are on this list:

       	xdg-open http://taps.lmtgtm.org/lmtslr/lmtoy_run/last100.html

6. There is also a way to make these TAPs available via a tunnel on a browser that runs
   on **malt** itself, but this is for emergency only and is usually not available as the TAP
   copies to Unity seem pretty reliable now.

## 2. Script Generator

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

2. Update the "lmtinfo" database if new data should be added.

       cd $DATA_LMT
       lmtinfo.py last
       # note the last obsnum, and replace it in the next line
       make new2 OBSNUM0=$(lmtinfo.py last)

   This process can take a few mins. After this, make sure that last.obsnum is updated.

3. Record the new value for **last.obsnum**

        tabcols data_lmt.log 2 | head -1  > last.obsnum

   (there will be a better way)
	

4. Update your script generators

        cd $WORK_LMT/lmtoy_run/
	make git git pull
	#
	make status

   Depending if you left unchecked portions, you may need to commit those.

4. Find out if there are new obsnums for a specific project

        source_obsnum.sh $PID

5. Add obsnums and/or sources to the script generator

        cd $WORK_LMT/lmtoy_run/lmtoy_$PID
        make pull
        edit mk_runs.py
        make runs

6. To re-run a whole project, find our which run files you need. Here's an example:

        sbatch_lmtoy.sh *run1a 
        sbatch_lmtoy.sh *run1b
        sbatch_lmtoy.sh *run1c 
        sbatch_lmtoy.sh *run2a 
        sbatch_lmtoy.sh *run2b 

6. But if you want to be more efficient, you made a note of the
   first obsnum (and higher) that you need to run for this project,
   lets say this is 123456, then

        sbatch_lmtoy.sh *run1a obsnum0=123456

   would only process the pipeline for 123456 and up.

7. Make summary and update the master index

        make summary index

   The following URL's will then give access to the master list, and this PID project in particular

        xdg-open http://taps.lmtgtm.org/lmtslr/lmtoy_run
        xdg-open http://taps.lmtgtm.org/lmtslr/$PID	

8. Ingest in the archive. Here we have to make sure that the final runs were done with "admit=1 sdfits=1 srdp=1"

        cd $WORK_LMT/lmtoy_run/lmtoy_$PID
        find_obsnum_and_ingest.sh ?args?

   Details on the arguments to be determined. In theory, the script generator knows what to ingest, but perhaps
   these need to be confirmed on the commandline. Once this button is pushed, there's no way back.

## 4. Helpdesk Pipeline: lmthelpdesk_umass_edu@@unity 

Many things overlap with how the final pipeline is run and submit, except the work in git. Generally the DA's work
in a git branch, so the work can be shared with the main pipeline work. More details to come here.


## 5. PI remote execution

Something needs to be written down how a remote PI webrun is impacted when new data arrives.
