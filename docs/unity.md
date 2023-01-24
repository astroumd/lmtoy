# Using LMTOY on Unity

Here we summarize how LMTOY can be used on Unity from the unix shell using the *slurm*
environment. The reader is assumed to be familiar with the basic operation of LMTOY.

## Your Unity account

There is a single account for all helpdesk users

        lmthelpdesk_umass_edu
	
which means different helpdesk users will need to ensure they are not working on the same *ProjectId*.
	
In your local ~/.ssh/config file you will need a shortcut to be able to ssh into the unity account.
For example:

    Host unity
       User lmthelpdesk_umass_edu
       HostName unity.rc.umass.edu
       IdentityFile ~/.ssh/unity_id
	   
and assuming your ssh public and private key has been set up (unity_id), the command

    $ ssh unity

will then log you into unity without the need for a password.

##  LMTOY on unity

Your **~lmthelpdesk_umass_edu/.bashrc** has been modified to handle multiple users, each using their own
$WORK_LMT. But immediately after a login, this variable is unset.  You can see this by issuing the **lmtoy**
command, where you will see that WORK_LMT is still blank:

      $ lmtoy
      LMTOY:       /work/lmtslr/lmtoy  - 0.9
      DATA_LMT:    /nese/toltec/dataprod_lmtslr/data_lmt
      WORK_LMT:    
      python:      /work/lmtslr/lmtoy/anaconda3/bin/python  - Python 3.8.8
      NEMO:        /work/lmtslr/lmtoy/nemo  - 4.4.1
      OS_release:  Linux Description: Ubuntu 20.04.5 LTS

In order to set/change it, use something like

     work_lmt teuben
	 
which will also remind you what projects you are working on, e.g.

     $ work_lmt teuben
     WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/teuben
     2014ARSRCommissioning  sbatch  bench1  bench2  tmp

The directories **sbatch** and **tmp** need to be present, and will have been created for you
during your first setting. And of course you might see some *ProjectId*'s.
Now you are ready to submit scripts on unity!

## Running on unity

You cannot run the pipeline directly on Unity, as you would do on the laptop. The *slurm* environment is used
to submit scripts and coordinate when and where the script can run. However, to find data using
**lmtinfo.py** is probably ok, e.g.

     lmtinfo.py grep RSR 2014 I10565 LineCheck
	 
(note in this historic data the observing data was not properly encoded in the header and it will claim 1970)


## RSR Benchmark

As an example, our standard RSR benchmark could be executed from any directory if you
had LMTOY running on a normal Unix environment, viz.

     $ SLpipeline.sh restart=1 obsnum=33551 xlines=110.51,0.15
	
after which the pipeline results would be in $WORK_LMT/2014ARSRCommissioning/33551	
	
but on Unity you need to submit this via *slurm*. Within LMTOY we created the **sbatch_lmtoy.sh** script
to make this a bit easier, viz.

     $ sbatch_lmtoy.sh  SLpipeline.sh restart=1 obsnum=33551 xlines=110.51,0.15
	
this will report a JOBID, and a logfile.   The JOBID is needed if you need to cancel this job, e.g.

     $ scancel 3051415
	
and to watch the progress of the output of your command you would use something like

     $ tail -f /nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/teuben/sbatch/slurm-3051415-33551.out
	
(this long filename is reported on screen, so copy+paste can be used. All *slurm* scripts and logfiles
for LMTOY will be kept in $WORK_LMT/sbatch and will occasionally have to be cleaned up)

If you have many obsnums to process, the script generator would put them in a text file, and you
would run it as follows (here the example is just the one case we just showed above):

     echo "SLpipeline.sh restart=1 obsnum=33551 xlines=110.51,0.15" > bench1
     sbatch_lmtoy.sh  bench1

## SEQ benchmark

In the same vein, the Sequoia benchmark is the following:

     sbatch_lmtoy.sh  SLpipeline.sh restart=1 obsnum=79448
	
## Interactive shell

Although Unity is not meant to be used in interactive mode, there is a *blessed* way to start
an interactive shell, e.g.

     srun -n 1 -c 4 --mem=16G -p toltec-cpu --x11 --pty bash
	
in this shell you are using a real unity CPU (4 in fact), and should get much faster response and able to run
a pipeline instance interactively. You can also use sbatch from here, as discussed before.

## Viewing pipeline results

The pipeline output is again in your $WORK_LMT/2014ARSRCommissioning/33551	
and should be viewable online via the following URL

     http://taps.lmtgtm.org/lmthelpdesk/teuben/2014ARSRCommissioning/33551

where WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/teuben.

Note the official *lmtslr* results of this obsnum would be on

     http://taps.lmtgtm.org/lmtslr/2014ARSRCommissioning/33551/README.html


## Script Generator

There is an experimental script generator, one for each *ProjectId*, which
generates the SLpipeline.sh commands to process Spectral Line data and puts
them in a "run" file.. These "run"
files can be processed by **bash** (serial mode), gnu **parallel** and **sbatch_lmtoy.sh**,
depending on your computing environment.   Here is an example, where for convenience
we've placed the script generator below the data tree

      cd $WORK_LMT/2021-S1-MX-34
      git clone https://github.com/teuben/lmtoy_2021-S1-MX-34
      cd lmtoy_2021-S1-MX-34
      make runs
      sbatch_lmtoy.sh 2021-S1-MX-34.run1a 
	  
This has well over 300 obsnum entries. This particular script generator has
also historic 50m and 32m data included in the run file.  If for some reason
you only want to process historic 32m data, you would make a temporary run file,
e.g.

      grep h32 linecheck.run1a > test1a
      sbatch_lmtoy.sh test1a

which currently has only 199 entries, and only for source **I10565**. In serial
mode this would take about 60 mins on Unity, but in the new parallel mode,
it takes about 3-4 minutes, if enough cores are available!

The script generator maintains a lot more project related into. This was just
an introduction. See https://github.com/teuben/lmtoy_run/blob/main/README.md for
the current workflow suggestions.


