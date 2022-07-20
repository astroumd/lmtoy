# Using LMTOY on Unity

Here we summarize how LMTOY can be used on Unity from the unix shell

## Your Unity account

There is a single account for the helpdesk

    lmthelpdesk_umass_edu
	
which means different helpdesk users will need to ensure they are not working on the same *ProjectId*.
	
In your local ~/.ssh/config file you will need a shortcut to be able to ssh into the unity account

    Host unity
       User lmthelpdesk_umass_edu
       HostName unity.rc.umass.edu
       IdentityFile ~/.ssh/unity_id
	   
and assuming your ssh public and private key has been set up (unity_id), the command

    ssh unity

will then log you into unity!


##  LMTOY on unity

Your **~lmthelpdesk_umass_edu/.bashrc** has been modified to handle multiple users, each using their own
$WORK_LMT. But immediately after a login, this variable is unset.  In order to change
it, use something like

     work_lmt teuben
	 
which will also remind you what projects you are working on, e.g.

	 work_lmt teuben
	 WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/teuben
	 2014ARSRCommissioning  sbatch  bench1  bench2  tmp

The directories **sbatch** and **tmp** need to be present, and of course you might see some *ProjectId*'s.

## Running on unity

You cannot run the pipeline directly on Unity, as you can on the laptop. The *slurm* environment is used
to submit scripts and coordinate when and where the script can run.

## Benchmark

As an example, our quick standard RSR benchmark could be executed from any directory if you
had LMTOY running on a normal Unix environment, viz.

    SLpipeline.sh restart=1 obsnum=33551
	
after which the pipeline results would be in $WORK_LMT/2014ARSRCommissioning/33551	
	
but on Unity this command would be need to be prepended by our **sbatch_lmtoy.sh** script, viz.

    sbatch_lmtoy.sh  SLpipeline.sh restart=1 obsnum=33551
	
this will report a JOBID, and a logfile where you could either cancel this job, e.g.

    scancel 3051415
	
or watch the progress of the output	that would normally be see in the terminal

    tail -f /nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/teuben/sbatch/slurm-3051415-33551.out
	
(this filename is reported on screen, so it copy+paste can be used. All *slurm*
for LMTOY will be kept in $WORK_LMT/sbatch and may occasionally have to be cleaned up)

If you have many obsnums to process, the script generator would put them in a text file, and you
would run it as follows (here the example is just one case, we showed above):

    echo "SLpipeline.sh restart=1 obsnum=33551" > bench1
    sbatch_lmtoy.sh  bench1
	
## Interactive shell

Although Unity is not meant to be used in an interactive mode, there is a *blessed* way to start
an interactive shell, e.g.

    srun -n 1 -c 4 --mem=16G -p toltec-cpu --x11 --pty bash
	
in this shell you are using a real unity CPU, and should get much faster response and able to run
a pipeline instance interactively. You can also use sbatch from here, as discussed before.

## Viewing pipeline results

The pipeline output is again in your $WORK_LMT/2014ARSRCommissioning/33551	
and should be viewable online on 

http://taps.lmtgtm.org/lmtslr/2014ARSRCommissioning/33551/README.html

vs.

http://taps.lmtgtm.org/lmthelpdesk/peter/2014ARSRCommissioning/33551/README.html


(ok, this is not correct yet, need Kamal for this)

