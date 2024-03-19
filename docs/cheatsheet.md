# LMTOY cheat sheet

## lmtslr@malt: the lightweight TAPs pipeline

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

## script generator work can be done anywhere, since it's git controlled

0. Set the project id in a convenient shell variable we are working with in this cheat sheet

       PID=2024-S1-MX-24

1. Bootstrap

       cd $WORK_LMT/lmtoy_run
       ./mk_project.sh $PID

2. Edit Makefile to add lmtoy_2024-S1-MX-24 to the specific year

       edit Makefile

3. Edit comments.txt to add 2024-S1-MX-24

       edit comments.txt

4. Edit REDAME.md to say a few interesting things, make sure $PID is correct

       edit README.md

4. Commit the changes

       git commit -m "new project"  Makefile comments.txt README.md
       git push

## lmtslr_umass_edu@unity

1. Check if new raw data has come in

       data_lmt_last

   Pay attention to the "Last recorded obsnum" and the SEQ and RSR obsnums listed in the output.

2. Update the "lmtinfo" database if new data should be added. Note the value

       cd $DATA_LMT
       lmtinfo.py last
       # note the last obsnum, and replace it in the next line
       make new2 OBSNUM0=$(lmtinfo.py last)

   This process can take a few mins

3. Record the new value for last.obsnum

        tabcols data_lmt.log 2 | head -1  > last.obsnum
	


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


## lmthelpdesk_umass_edu@@unity 


