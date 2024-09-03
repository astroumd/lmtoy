# Plotting in LMTOY

Although many things in LMTOY can also be run interactively, the main purpose of the pipeline is
running on a slurm controlled HPC system and produce plots for web based summaries. There are
however some tricks needed to make these plotfiles, such as the **xvfb**.


## Plotting Methods


1. NEMO programs (e.g. tabplot) use CLI like yapp=1/xs, yapp=junk.png/png

2. Converted python programs have a CLI to do screen only or plotfile only, e.g.

   1. fitsplot.py --screen junk.fits
   2. tab_plot.py -y junk.png junk.tab
   3. some use --plots if a plotfile is needed. Used for programs that produce multiple plots (e.g. view_spec_file.py)

3. Non-converted programs are subject to the whims of unity

   1. various RSR (but not all)


## Shells

We can use different (interactive) shells:

1. standard remote X-based terminal. With the right "xhost +" and/or settings in the users ~/.ssh/config file
   plotting should be working both on screen and in a plotfile. This includes the unity login node,
   and malt, where we run the TAP (pre-unity) pipeline.

2. **srun**

      srun -n 1 -c 4 --mem=8G -p toltec-cpu -t 4:00:00 --x11 --pty bash

    Does have $DISPLAY=localhost:14.0, pgplot works, but matplotlib complains DISPLAY is invalid.

3. **compute_unity**

      /usr/bin/srun --pty -c 2 --mem=4G -p cpu-preempt /bin/bash

    Does have $DISPLAY=localhost:14.0, but pgplot doesn't work.

4. **sbatch**

    This is how the pipeline is run, but via **xvfb**, to give it a valid $DISPLAY. This was now failing
    in August 2024.


## History

On Aug 30, 2024, seemingly out of the blue, the pipeline on unity would not plot most matplotlib figures,
but pgplot figures would still work. We use xvfb to set a fake X display, so this has normally worked.
Even inside of an interactive "srun --x11" I can still use pgplot routines, but matplotlib now complains
that DISPLAY is not valid (it's the typical localhost:40 or so). The login node still works fine with
interactive matplotlib.

Earlier in 2023?, Unity had also changed and our plotting code needed a patch, but this time it seems
to be fatal.


This is the technique now used in some of the python scripts, where **plotfile** designates either a
plot screen, or an actual plotfile with that name.  Also have to ensure matplotlib is not include before
the import in the "main"!

     import matplotlib 
     if plotfile == None:
        matplotlib.use('qt5agg')
     else:
        # if the next statement was not used on unity, occasionally it would find Qt5Agg, and thus fail
        # this else clause is NOT used in rsr_tsys.py, which has the same patters as this routine, and
        # never failed making a Tsys plot, go figure unity!
        # 30 aug 2024: DISPLAY was not valid before this explicit args.screen was used.
        matplotlib.use('agg')
     import matplotlib.pyplot as plt
     print('mpl backend spectra',matplotlib.get_backend())

     plt.figure()
     <do usual plotting>     

     if plotfile == None:
        plt.show()
     else:
        fig.savefig(plotfile)
        print("Writing ",plotfile)    

srun:   slurm-wlm 23.11.8
