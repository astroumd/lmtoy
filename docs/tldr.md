# The LMT Spectral Line toolkit ("LMTOY") TL;DR

## Names

Reminder on the names used for LMT 

- PID: ProjectID (e.g. 2021-S1-US-3)
- OBSNUM:  Observation Number (e.g.  123456)
- BANK / band : SEQ:2  RSR:5
- BOARD :  SEQ:4   RSR:4
- BEAM ("pixel"): SEQ:16   RSR:2
- CHANNEL:    (SEQ:2k.4k,8k  RSR:256)


## SLpipeline.sh

The goal is to have a simple top-level OBSNUM driven script
producing science ready data products (SRDP)

             SLpipeline.sh obsnum=123456

- command line *key=val* driven (*"PI parameters"*)
- unknown keys, including typos, are silently forgotten!
- script generator creates RUN files of pipeline commands
- _convenience keywords useful for *grep* and *webrun*
  - _io=   instrument/obsgoal,  e.g.   SEQ/Map, 1MM/Ps
  - _s=    source name, e.g.  NGC1234
- data:
  - $DATA_LMT:   input data tree with raw data (mostly netCDF)
  - $WORK_LMT:   output data tree with pipeline products (mix)
     - $WORK_LMT/$PID/$OBSNUM:  all pipeline products
- script generator creates RUN files
     - $WORK_LMT/lmtoy_run/lmtoy_$PID - collaborative in github
     
                  cdrun *21*US-3
		  
     - RUN file is text file with SLpipeline.sh commands
     - can be used by **sbatch**, **bash** or **gnu parallel**
     - for LMTOY we implemented **sbatch_lmtoy.sh** and **sbatch_lmtoy2.sh**
     - creates an index of all PID summary pages


Although LMTOY is non meant to be run by a PI (see webrun below), it
does need to be run by the PO (pipeline operator). All the information
is present for a persistent PI to be a PO :-)

Note that the lmtoy github repo is a mono-repo, it contains ALL info to get
you started from scratch on a new machine (well, that's the goal).


## Stakeholders of SLpipeline.sh

- script generator
- archiving 
- webrun (with the concept of sessions)
- helpdesk


## Web pages
