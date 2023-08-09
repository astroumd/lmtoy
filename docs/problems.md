# FOBs - Frequently Occuring Problems

Here are some FOBs, often happening when the installation was not quite complete....

*  RSR: missing waterfall:    probably ImagaeMagick issue. See log file.   SOlution: "cd etc; make policy"

*  SEQ: missing tool "ncdump"

*  Not running with -X (x-windows enabled) can cause pipeline (plot) to fail and be missing. LMTOY has a few
   technologies (NEMO uses PGPLOT, ADMIT uses CASA, matplotlib needs to write png files)

*  On unity, logout from the login node if your environment has changed. Submitting SLURM jobs inherit from
   the current account, not your current ~/.bashrc
