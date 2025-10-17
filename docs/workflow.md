# LMTOY pipeline workflow (July 2025)



##   A brief high level description of who/how/what/where the pipeline does

Stakeholders

* PO = Pipeline Operator, currently mostly Peter
* DA = Data Analyst (helpdesk), currently Alaina and Leyna
* PI = Proposer (PI) of the Project. PI can share links with co-PI's?

Here are the distinct steps, each with their own timeline

1. Pipeline on malt (PO; during observing, runs automatically, but needs manual start after a reboot).
   See http://taps.lmtgtm.org/lmtslr/lmtoy_run/last100.html.  In the **lmtslr** account.

2. Pipeline on unity (PO; incrementally run usually the day after observing).
   See http://taps.lmtgtm.org/lmtslr/lmtoy_run/.  In the **lmtslr_umass_edu** account.

3. Pipeline on unity (DA; incrementally run, can take few days or weeks).
   In the **lmthelpdesk_umass_edu** account.

4. Pipeline on unity (PO, after merging in the DA suggestions, usually within a week after merging)

5. Data can now be archived (PO; soon)

6. Pipeline can be re-run via a web interface (PI; soon)

##  Detailed descriptions



###   1. Pipeline on malt

* Although it runs forever, when malt is rebooted, needs restarted with `SLrun`, and should be a crontab.
* Sends summary TAPs to unity.

To review what's been done:

1. Run the `data_lmt_last` on malt
2. Look at `rsync.log`
3. Look at `SLpipeline_run.log` (very detailed)

###  2. Pipeline on unity (level=1)

This is where the pipeline runs, with some human (PO) guidance, since the script generator
needs to be updated with new obsnums

There are several ways to track what observations were done the night before

1. Daily email, usually around 10am. Can have typos.
2. last100.html on lmtoy_run dashboard (assuming it ran fine)
3. Run the `data_lmt_last` on unity to see when data are all on unity. Usually around noon, sometimes a bit later.

When all data have arrived, the `lmtinfo` database should be updated (`make new2` in `$DATA_LMT`)

0. For new projects there is a special procedure in `lmtoy_run`. It uses the `gh` command to make it a
   scriptable process.

1. For the projects in question "make check" produces a raw check.py, and new sources/obsnums should
   be merged into mk_runs.py and "make runs" should now produce the same counts

2. For incremental changes (usually the default in level=1) figure out how many new obsnums, and sort/grep/tail
   those from the runfiles and sbatch_lmtoy2.sh those can update a whole project in one command

3. commit the changes in the main branch, and inform DA they can do their QA

###  3. Pipeline on unity (QA)

1. bla

###  4. Pipeline on unity (level=2)

1. Merge back in the changes, and prepare all new runfiles.    Sanity check if all obsnums are included.
2. Run the whole project, prepare for archive

###  5. Archiving

1. Archive the project

###  6. Webrun
