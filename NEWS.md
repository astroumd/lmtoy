# NEWS


?             0.5   
2022-jan-26   0.4   band based fits files now implemented (but not working for 1MM)
2021-dec-13   0.3   SLpipeline.sh now a uniform approach for single and multiple obsnums
2021-may-11   0.2   lmtoy_reduce.sh now able to get some SEQ data through
2021-jan-22   0.1   ?

# New things

1. Ps mode for 1MM works, but only interactive for now.

#  Known bugs and nuisances

The detailed backgrounds should be in https://github.com/astroumd/lmtoy/issues but in this
list we try to keep it limited to the most urgent ones that we hope to fix soon:

1. If numbands > 2 (for the Msip1mm receiver) data is produced, but it's via the wrong mapping program.

2. bank= is bad for SEQ; should be using band= are 

3. Even for SEQ, if you use "bank=0" the links won't work

4. Tsys (and some other) plots for SEQ are not properly autoscaled if pix_list is not the full list [ISSUE # ...]


