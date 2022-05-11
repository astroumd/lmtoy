# realtime pipeline at malt and unity

Some notes on running the pipeline in real-time at malt (LMT) and unity (UMASS).

malt produces the TAP's, and immediately copies them to unity for public viewing.

## LMTOY development

I frequently run LMTOY on 4 different machines (malt, unity, lma, and my laptop) where
this gives me different levels of speed and debugging. Since everything goes via github,
it can become tedious to keep everything in sync. Here's my own recipe, once a machine
gets an update, the others are done "on demand" as follows:

      lmtoy pull
	  
and if there were changes to the gridder or NEMO, those need a compilation

	  cd $LMTOY
	  make update_lmtslr
	  make update_nemo
	  
or if only one NEMO routine needed an update, e.g.
  
      mknemo ccdstat
	  
can be done from any directory.	

## Setup at malt

Login as **lmtslr**

commands in window 1:

	  ssh malt
      cd $WORK_LMT/SLpipeline.d
	  # rebuild the database (probably good to do daily if observations are taken)
	  lmtinfo.py build
	  # inspect and see if there need to be changes
	  more SLpipeline.in
	  SLpipeline_run.sh
	  
this window will refresh automatically when new obsnum's are seen, and will run the SLpipeline.
Important information will be displayed in red. A typicaly SEQ map takes about 3-4 minutes
to compute on malt, well in time for the next map to appear (10-15 mins)


commands in window 2:

      ssh malt
	  tail -f $WORK_LMT/SLpipeline.d/data_lmt.lag 

which is useful to review progress overall. The refresh rate can be changed by changing the sleep=
parameter to  SLpipeline_run.sh. The default is set at 60 seconds.


commands in window 3:

      ssh malt
	  SLpipeline.sh admit=0 restart=1 obsnum=99438 extent=120 pix_list=$(pix_list.py -14,-15)

I often run manually a Pointing map (they are not automagially included in the Science run), but
these need a larger mapsize value, e.g. **extent=120**

## Setup at unity

Login as **lmtslr_umass_edu**, which brings you do the *login* node where no serious commands
can be given. We have the **sbatch_lmtoy.sh** script to make it a little easier to submit
SLURM based scripts.

commands in window 1:

      sbatch_lmtoy.sh lmtinfo.py build

will need to be on a daily basis. This is still slow, because it goes over all files 
(as we speak, 18752 ifproc and 46876 rsr)

      539.05user 171.59system 2:10:23elapsed 9%CPU

commands in window 2:

      srun -n 1 -c 4 --mem=16G -p toltec-cpu --x11 --pty bash
	  
this will allow you to run commands with some CPU usage where you need direct interaction. 
An example is the processing of the incoming TAP's.

	  cd $WORK_LMT
	  ls 2021*/*TAP.tar
	  # change to the directory where the TAP.tar files 
	  cd 2021-S1-.....
	  ../do_untap *TAP.tar
	  
so this is still manual labor, but needs to be fully automated.



