# TODO's and ISSUES

## Planned for version 1.1 (March 1, 2024)

- active github issues:  https://github.com/astroumd/lmtoy/issues ; Some important ones:
  - 48: allow missing roach files
  - 47: "wtn" has the wrong beam plotted
  - 46: SEQ low power can crash pipeline
  - 45: RSR not commutative **+Min**

- autorun mode (restart=2) [partially implemented]

- finalize all metadata for DV   [meta=0,1,2] **+Marc**
- fix metadata for combination runs (obsInfo) - can be delayed as we don't combine in the archive yet

- Webrun
  - verify.py ; obsmode (INSTR/MODE)
  - webrun.sh
  - etc/parameters.txt
  - lmt_web_lite

- FITS export option for spectra [mostly done, but not checked with dysh]

- SEQ/Bs only one bank works now [depending if observations planned]
- SEQ/Ps not implemented [depending if observations planned]

- check if combo's can be done (check sources etc.)

- stage/unstage on unity in case we do the work in /work and rsync to /nese (or /scratch?)

- add the repo counter into the fits header of final output [currently only in lmtoy_repo=]
- revive maskmoment (has an import issue) [done?]
- resolve tsys_aver in lmtslr/spec/spec.py as per **Heyer**
- RMS0:   should we define some <Tsys>?  Currently RMS0 is defined per 100K (as is for RSR)
- Autoscaling the rather wide HTML pages for SEQ summary
- split parameters in single obsnum and combo (where only gridding is allowed) - useful for webrun
- pointing offsets from ifproc in meta-data ?
- automated generation of the script generator?
- FITS export option for spectra [sp2sdfits.py now exists]
- the never finished manual (flow diagrams w/ mermaid?)

## Longer term wishes (March 2024)

- SpecFile (netCDF format) to be replaced with an SDFITS file.
- integrations with dysh  (e.g. sp2sdfits)
- advanced mapping programs (cf. dysh)
- SDHDF ?
- docker image for lmtoy

## Random

- SLpipeline
  - SEQ needs to log its commands
  - use "INSTR/MODE" in SLpipeline
  - safe frontends SLpipeline vs. SLpipeline.sh,  etc. - see verify
- script generator for SEQ numbands=2
- sbatch_lmtoy should learn how to use fewer cpu's [check w/ Grant]
- create flexible summaries of observations
  - obsnum,date,bad_beam
  - efficiency of observations


