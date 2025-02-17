# The LMT Spectral Line Pipeline

When an LMT observing script finishes, there is a unique **obsnum**,
which records the instrument, observing mode, and possibly
other obsnum's needed for calibration. The raw data is a set
of netCDF files identified by one or more obsnum's, its organization
differs on the instrument (currently RSR and WARES based are the two
modes).

The obsnum is the only identifier needed to run the pipeline. From the
obsnum the instrument can be discovered, and the pipeline has sensible
defaults for each instrument. Of course PI/PL parameters (PIPL's) can
be passed on the bypass these default settings. An example:

      $ SLpipeline.sh obsnum=79448 pix_list=-0,5 extent=240

would process Sequoia data, remove beams 0 and 5 from the default list (0..15),
and produce a square map of 240 arcsec. The last two keyword are optional. Use
--help to get more help:

      $ SLpipeline.sh --help
      $ seq_pipeline.sh --help
      $ rsr_pipeline.sh --help

to get generic help, and instrument specific help.

## Where is the work done

When observing concludes, raw data will show up in your $DATA_LMT. Depending on
where your $DATA_LMT is, this could be seconds, minutes or days.

How do you know if an obsnum is present? One possible way is the lmtinfo.py script:

      $ lmtinfo.py   12345

would show some basic info in "rc" format, which both python and bash can read. It does
not need a database, but you have to know the obsnum.

Another option is

       $ data_lmt_last

The pipeline will reduce the data in $WORK_LMT and create a directory tree
starting with **$ProjectId/$obsnum**.  If $WORK_LMT is not set, it will be interpreted
as the current directory, but this is not recommended in LMTOY. Normally a web browser
has been configured to look at the $WORK_LMT directory, with or without some authentication.
(check this, currently unset $WORK_LMT probably fails)

## SLpipeline.sh

Starting in 2021 we have been using the **SLpipeline.sh** script to
reduce all SLR data. As mentioned before, the
intent is that the script only needs an **obsnum**, and will figure out which instrument
is used, and run the reduction via the instrument specific reduction pipeline.

There will also be optional *PI pipeline Parameters* (PIPLs), which
are under discussion, but we will assume they are a series of
*keyword=value* pairs.  Word of caution: it does not check for spelling,
so **pix-list=-0,5** would not work, and will not return a warning.

### Sequoia  (SEQ)

How to use this is best described through an example. We use proposal **2018-S1-MU-46**
where a few small patches of M31 were observed each, several times (always in CO ?).
Each obsnum is run through the pipeline, 
inspected, maybe re-run if need be, and then combined in a final cube.

      SLpipeline.sh  obsnum=85776 
      SLpipeline.sh  obsnum=85778
      SLpipeline.sh  obsnum=85824
      SLpipeline.sh  obsnums=85776,85778,85824 

This will have created three obsnum directories inside the **2018-S1-MU-46** directory.
Various figures will need to be inspected, and you would find out that pixel 3
(counting pixels from 0 to 15) is bad for 85776. In each obsnum directory the
corresponding **lmtoy_OBSNUM.rc** file will contain parameters that control the pipeline.
Here are a few common ones

#### pix_list

This is the list of pixels to be used for this obsnum. In the gridder step pixels cannot
currently be selected.  The full list of pixels would be:

      pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

In some places (e.g. in comments.txt) one can shorten a list by removing bad beams, e.g.

      pix_list=-0,5

is equivalent to

      pix_list=1,2,3,4,6,7,8,9,10,11,12,13,14,15

## RSR

The RSR receiver....

## 1MM

The 1MM receiver....

## B4R

This 2MM received is not covered here, they have their own pipeline.

# User Processing (2023)

Here we sketch the user experience, as seen from both a POSIX shell
(now working) and a hypothetical web interface (translation in progress):

1. set up LMTOY (including $DATA_LMT, $WORK_LMT, as well as $WORK_LMT/lmtoy_run)

2. user logs in and this reports back one or more PID's (project-ID)
   that they are authenticated to work on

         # ... WORK_LMT has been set up. At the start it will be empty
         $ cd $WORK_LMT
         $ ls

3. User selects one PID and hits some "next" button [on the web interface
   one could perhaps debate allowing more PID's]

         # ...
         $ PID=2021-S1-MX-3
         $ cd $WORK_LMT/$PID

4. A list of sources is shown that are in this PID. User selects one
   or more of those to work on. 
   
         # ... current clumsy ascii database
         $ lmtinfo.py grepw $PID Science | awk '{print $6}' | sort | uniq -c
           12 Arp143
           10 Arp91
            4 NGC2540
           26 NGC5376
           32 NGC5473
           28 NGC5720
           22 NGC6173
           10 NGC6786

5. Based on the previous item, using the script generator can be done in two ways:
   whole project or source based. Either way, for the shell interface we need to be in
   the directory of the script generator   (this requires two symlinks from the $WORK_LMT/$PID directory:
   index.html needs to point to the README.html and comments.txt needs to point to its namesake here):

        $ cd $WORK_LMT/lmtoy_run/lmtoy_$PID
        $ make runs

   this will have generated some run1 and run2 scripts. The first one for single obsnums, the second one for
   combinations.   \*.run1a for the first/single stage,
   and \*.run1b for the second/combo stage (which can sometimes be skipped)

   1.   Whole project

        The run files can now be directly submitted, e.g.

                $ sbatch_lmtoy.sh *.run1a

        wait for the results to be done and submit the combinations

                $ sbatch_lmtoy.sh *.run2a

        after this the summary can be made

                $ make summary

        which can then be viewed, either via README.html or the symlinked index.html
		
   2.   Source based.
   
        Here we use grep to extract the source from the run files, and do the same as for the whole project

                $ grep $SRC *run1a > test1
                $ grep $SRC *run2a > test2
                $ sbatch_lmtoy.sh test1
                $ sbatch_lmtoy.sh test2
		
        but making the summary table just for a source is now tricky:
	 
                $ cd $WORK_LMT/$PID
                $ mk_summary1.sh $SRC > README_$SRC.html

   3. Any expression based.

      Using the **lmtinfo.py grep ** filter command you can extract a list of rows that can be fed into mk_summary2.sh for
      an arbitrary summary listing that crosses over projects, e.g.

                 #   !! Ensure this example actually works !!
                 $ cd $WORK_LMT/Example1
                 $ lmtinfo.py grep LineCheck Bs I10565  > I10565.log
		 $ mk_summary2.sh I10565.log > README.html
		 


   If you want to use a python based submission (e.g. via the web workflow), there's a better way, though
   as described before, it assumed the script generator(s) have been set up. This workflow hasn't been
   tested out yet, but looks something like:

        import os, sys
        work_lmt = os.environ['WORK_LMT']
        pid = '2023-S1-US-18'
        run = '%s/lmtoy_run/lmtoy_%s' % (work_lmt,pid)
        print(run)
        sys.path.append(run)
        import mk_runs as runs

   now runs.on is a dictionary, with sources as the key, and the obsnums as the obsnums, e.g.

        on["HZ1"] = [ 104675, 104676, 104677, 104679]
        on["HZ4"] = [ 104090, 104091, 104092, 104094, 104095]

   The SLpipeline.sh incantation are in the run files, but there should be an API returning a python
   list of them.




6. Valid PIPLs can also be found via the --help parameter to the corresponding instrument pipeline, e.g.

        $ rsr_pipeline.sh --help
        $ seq_pipeline.sh --help

   but it would be better if there is a better (yaml?) self-describing interface
