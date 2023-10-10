# TODO's and ISSUES

## Planned for version 1.1

- active github issues:  https://github.com/astroumd/lmtoy/issues
- add the repo counter into the fits header of final output [currently only in lmtoy_repo=]
* revive maskmoment (has an import issue) [done?]
- autorun mode (restart=2) [partially implemented]
- resolve tsys_aver in lmtslr/spec/spec.py as per Heyer
- fill in all metadata for DV
- RMS0:   should we define some <Tsys>?  Currently RMS0 is defined per 100K (as is for RSR)
- SEQ/Bs only one bank works now
- SEQ/Ps not implemented
- Autoscaling the rather wide HTML pages for SEQ summary
- split parameters in single obsnum and combo (where only gridding is allowed) - useful for webrun
- verify script that checks a runfile (or rc file) - for webrun
- pointing offsets from ifproc in meta-data ?
- fix manual creation, including flow diagrams via e.g. mermaid
- automated generation of the script generator?
- stage/unstage on unity in case we do the work in /work and rsync to /nese
- verify.py ; obsmode
- webrun.sh
- FITS export option for spectra


## Longer term wishes

- SpecFile (netCDF format) to be replaced with an SDFITS file.
- integrations with dysh
- advanced mapping programs (cf. dysh)

## Random

- SLpipeline
  - fully implement the restart=2 rerun option that is supposed to give us the automated pipeline
  - SEQ needs to log its commands
  - use "INSTR/MODE" in SLpipeline
  - safe frontends SLpipeline vs. SLpipeline.sh,  etc.
- script generator for SEQ numbands=2
- sbatch_lmtoy should learn how to
  #SBATCH --exclude=toltec-cpu00[3-7]
- create summaries of observations
  - obsnum,date,bad_beam
  - efficiency of observations
- use of scratch in normal pipeline operations?
- manual
