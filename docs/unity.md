# Using LMTOY on unity

## Your Unity account

    lmthelpdesk_umass_edu
	
In your ~/.ssh/config file you will need a shortcut:

    Host unity2
       User lmthelpdesk_umass_edu
       HostName unity.rc.umass.edu
       IdentityFile ~/.ssh/unity_id
	   
and assuming your ssh public and private key has been set up (unity_id), the command

    ssh unity2
	
will then log you into unity!


Your .bashrc will need to point to the already installed LMTOY :

lmtoysh=/work/lmtslr/lmtoy/lmtoy_start.sh
if [ -e $lmtoysh ]; then
    source $lmtoysh
    export WORK_LMT=/nese/toltec/dataprod_lmtslr/work_lmt_helpdesk
else
    echo $lmtoysh does not seem to exist
fi

The directory $WORK_LMT/sbatch (and tmp?) should exist.

## Running on unity

You cannot run the pipeline directly on Unity. The *slurm* environment is used
to submit scripts and coordinate when and where the script can run.

## Benchmark

As an example, the standard RSR benchmark could be executed from any directory if you
had LMTOY running on a normal Unix environment, viz.

    SLpipeline.sh admit=0 obsnum=33551
	
and the pipeline results would be in $WORK_LMT/2014ARSRCommissioning/33551	
	
but on Unity this would be

    sbatch_lmtoy.sh  SLpipeline.sh admit=0 obsnum=33551
	
	
this will report a JOBID, and a logfile where you could either cancel this job, e.g.

    scancel 3051415
	
or watch the progress of the output	that would normally be see in the terminal

    tail -f /nese/toltec/dataprod_lmtslr/work_lmt_helpdesk/sbatch/slurm-3051415-33551.out
	
(this filename is reported on screen, so it copy+paste can be used. All *slurm*
for LMTOY will be kept in $WORK_LMT/sbatch and may occasionally have to be cleaed up)

The pipeline output is in $WORK_LMT/2014ARSRCommissioning/33551	




