# The LMT Spectral Line toolkit ("LMTOY") TL;DR

## Names used here:

- PID: ProjectID                e.g. 2021-S1-US-3
- OBSNUM:  Observation Number   e.g.  123456
- BANK / band :                 SEQ:2   RSR:6    (merged to 1)
- BOARD :                       SEQ:4   RSR:4
- BEAM ("pixel"):               SEQ:16  RSR:2 
- CHANNEL:                      SEQ:2k.4k,8k  RSR:256*6, merged ~1300)

## The pipeline:  SLpipeline.sh

The goal is to have a simple top-level OBSNUM driven script
producing science ready data products (SRDP)

             SLpipeline.sh obsnum=123456

- command line *key=val* driven (*"PI parameters"*)
- unknown *key*s, including typos, are silently ignored!
- _convenience_ keywords (useful for *grep* and *webrun*):
    - _io=   instrument/obsgoal,  e.g.   SEQ/Map, 1MM/Ps
    - _s=    source name, e.g.  NGC1234
- data:
    - $DATA_LMT:   input data tree with raw data (mostly netCDF)
    - $WORK_LMT:   output data tree with pipeline products (mix)
        - $WORK_LMT/$PID/$OBSNUM:  all pipeline products
- script generator creates RUN files
    - RUN file is text file with SLpipeline.sh commands
    - can be used by **sbatch**, **bash** or **gnu parallel**
    - $WORK_LMT/lmtoy_run/lmtoy_$PID - collaborative in github
     
                  cdrun *21*US-3
		  
    - for LMTOY we implemented **sbatch_lmtoy.sh** and **sbatch_lmtoy2.sh**
    - also creates an index of all PID summary pages http://taps.lmtgtm.org/lmtslr/lmtoy_run


Although LMTOY is not meant to be run by a PI (for that see webrun
below), it does need to be run by the PO (Pipeline Operator). All the
information is present for a persistent PI to be a PO :-)

Note that the lmtoy github repo is a mono-repo, it contains ALL info to get
you started from scratch on a new machine (well, that's the goal).


## Stakeholders of SLpipeline.sh

- script generator
- data catcher on malt
- helpdesk (DA)
- archiving
- webrun (with the concept of sessions)


## Web pages

- LMTSLR dashboard: http://taps.lmtgtm.org/lmtslr/lmtoy_run/



## Pipeline Parameters & Instrument Parameters

### Generic Pipeline

obsnum=0
obsnums=0
restart=0
admit=0
archive=0
qagrade=0

### SEQ/Map

maskmoment=0
extent=0
dv=100
dw=250
birdies=0
birdies_shift=0
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
b_order=0
otf_cal=0
bank=-1    


### SEQ/Ps

### SEQ/Bs

### 1MM/Map

### 1MM/Ps

