# LMTOY cheat sheet

A brief reminder on the commands we use to operate the pipeline and everything around it

## 1. Lightweight TAPs Pipeline: lmtslr@malt

**malt** is the computer at LMT that we use to run the pipeline while data have been
taken. The lightweight TAP's are sent to Unity, where they can be viewed.
The user **lmtslr** runs the commands here.


1. Start the data catcher

       cd ~/SLpipeline.d
       SLpipeline_run.sh > SLpipeline.log 2>&1
       tail -f SLpipeline.log

2. Summary of what rsync does

       tail -f rsync.log

3. Re-execute a pipeline with improved parameters (only for urgency)

       SLpipeline_run1.sh 113271 2024-S1-MX-24 dv=10 dw=10

## 2. Script Generator

This work can be done anywhere, since it's git controlled. But it depends on the user having
installed the **gh** command, otherwise it's annoying work in the browser

0. Set the project id in a convenient shell variable we are working with in this cheat sheet

       PID=2024-S1-MX-24

1. Bootstrap a new project script generator (the **gh** command is needed here)

       cd $WORK_LMT/lmtoy_run
       ./mk_project.sh $PID
       make links

   The last step, the links, are convenient for going back and forth between where the pipeline
   data are and where the script generator is.

2. Edit Makefile to add lmtoy_2024-S1-MX-24 to the specific year

       edit Makefile

3. Edit comments.txt to add 2024-S1-MX-24

       edit comments.txt

4. Edit REDAME.md to say a few interesting things, make sure $PID is correct

       edit README.md

4. Commit the changes

       git commit -m "new project"  Makefile comments.txt README.md
       git push

5. Typically at the end of observing season, a record of all the obsnums is saved as well:

       lmtinfo.py $PID > lmtinfo.txt
       git add lmtinfo.txt
       git commit -m "observing records" lmtinfo.txt
       git push

## 3. Main Pipeline: lmtslr_umass_edu@unity

1. Check if new raw data has come in

       data_lmt_last

   Pay attention to the "Last recorded obsnum" and the SEQ and RSR obsnums listed in the output.

2. Update the "lmtinfo" database if new data should be added.

       cd $DATA_LMT
       lmtinfo.py last
       # note the last obsnum, and replace it in the next line
       make new2 OBSNUM0=$(lmtinfo.py last)

   This process can take a few mins

3. Record the new value for last.obsnum

        tabcols data_lmt.log 2 | head -1  > last.obsnum

   (there has to be a better way)
	

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

8. Ingest in the archive. Here we have to make sure that the final runs were done with "admit=1 sdfits=1 srdp=1"

cd $WORK_LMT/lmtoy_run/lmtoy_$PID


## 4. Helpdesk Pipeline: lmthelpdesk_umass_edu@@unity 

Many things overlap with how the final pipeline is run and submit, except the work in git. Generally the DA's work
in a git branch, so the work can be shared with the main pipeline work. More details to come here.
