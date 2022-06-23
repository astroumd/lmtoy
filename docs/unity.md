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
