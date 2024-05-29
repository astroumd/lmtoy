# LMTOY check list (May 2024)

There is an annual upgrade of Unity, and in 2023 this caused some havoc, so here's a check list
of things that ought to work.   Here we assume LMTOY and friends are all installed and have
been working so far.   If these are up, we should be good to go.


## LMTOY

1. Do the benchmarks for the pipeline work?


      srun -n 1 -c 4 --mem=8G -p toltec-cpu -t 4:00:00 --x11 --pty bash
      cd $LMTOY
      make bench1
      make bench2

2. Can we ssh to toltec3 (for archive ingestion)

      ssh toltec3

3. Can we recompile tools

      mknemo tsf

4. Advanced pipeline examples can be found in [cheatlist.md](cheatlist.md)
   and [cheatlist2.md](cheatlist2.md)
      

## Web services

1.  Entry point for pipeline summaries

       http://taps.lmtgtm.org/lmtslr/lmtoy_run

2.  Other related links:

       http://taps.lmtgtm.org/lmtslr/lmtoy_run/last100.html
       
       http://taps.lmtgtm.org/dvsearch/

       https://dp.lmtgtm.org/dataverse/lmtdata/search

       https://dataverse.harvard.edu//dataverse/lmt


    Common problems
    - dataverse server needs a restart
    - "mount -a" on the containers (toltec1-3)
