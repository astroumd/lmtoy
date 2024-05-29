# TODO's and ISSUES

## Planned for version 1.1 (April 1, 2024)

- urgent unfiled issues:
  - combos of e.g. MX-2 sometimes fail (hardware issue)
  - combos of mosaic doesn't work?   they also take VERY long, where is the CPU going?
  - LineCheck sometimes fails for blanking, when driver is ok (eg. 113206)
  - Should oid= allow us to use ${obsnum}__${oid} - this would make it possible to make multiple (line) cubes
  - can we create a different cube for bank0 and bank1 ?  should be possible.

- active github issues:  https://github.com/astroumd/lmtoy/issues
  - 51: SEQ/Ps html now broken for dual IF
  - 48: allow missing roach files  **Kamal**
  - 47: "wtn" has the wrong beam plotted
  - 46: SEQ low power can crash pipeline (MX-2 example mentioned before)
  - 45: RSR not commutative **+Min**
  - 36: final DataVerse items **marc**
  - 35: inttime not correct - we need the ON time only,not ON+OFF+CAL

- python versions via install_anaconda3:
  version=2021.04    # 3.8.8     aplpy OK, some spyder complaints
  version=2022.10    # 3.9.13
  version=2023.03-1  # 3.10.9    aplpy fails
  version=2023.09-0  # 3.11.5

  Also note that numpy 2.0 is upcoming and could have some impact.

- SLpipeline_run.sh :   should spawn reduction, not run in place.

- final spectrum in SEQ (tab_plot.py) should honor location=; ccdspec needs the patch

- re-install with a new python:
  make pip install_lmtslr install_dreampy3 install_dvpipe install_maskmoment
  
- autorun mode (restart=2) [partially implemented]

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

## Longer term wishes (>March 2024)

- SpecFile (netCDF format) to be replaced with an SDFITS file.
- interoperability with dysh  (e.g. sp2sdfits)
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


