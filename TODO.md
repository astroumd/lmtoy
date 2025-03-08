# TODO's and ISSUES

## Planned for version 1.2 (September 26, 2024)

- urgent unfiled issues:
  - combos of e.g. MX-2 sometimes fail (hardware issue)  [#46]
  - combos of mosaic doesn't work?   they also take VERY long, where is the CPU going?
  - LineCheck sometimes fails for blanking, when driver is ok (eg. 113206)
  - Should oid= allow us to use ${obsnum}__${oid} - this would make it possible to make multiple (line) cubes
  - can we create a different cube for bank0 and bank1 ?  should be possible.
  - "restart=1 bank=0" fails, but is ok with meta=0
  - why is RMS/RMS0 not closer to 1 for SEQ (it.s often 1.5--2 or worse)

- active github issues:  https://github.com/astroumd/lmtoy/issues
  - 57: spectral vs. average Tsys
  - 51: SEQ/Ps html now broken for dual IF
  - 48: allow missing roach files  **Kamal**
  - 47: "wtn" has the wrong beam plotted
  - 46: SEQ low power can crash pipeline (MX-2 example mentioned before)
  - 45: RSR not commutative **+Min**
  - 38: final DataVerse items **marc**
  - 35: inttime not correct - we need the ON time only,not ON+OFF+CAL

- Due to SB bugs with birdies, some data were taken with bank=1 in bank=0, e.g.
  in 2024-S1-MX-20 wwe have SB0 and SB1 named sources.  How can old-style and
  new SB-style named data be combined ?

- python versions via install_anaconda3:
  we now use version=2023.03-1 # 3.10.14 

  Also note that numpy 2.0 is upcoming and could have some impact beyond 2026.

- SEQ BS mode with a linecheck on ULIRGS

- on malt we should also do a "last_obsnum" trick we do on unity. malt is becoming slow
  again and for certain obsnums we will miss one in the last100
  could also leave less data in DATA_LMT

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
  - should there be an SDFITS option?
  - RSR works, but SEQ/Bs/Ps still in ascii [no rich header]

- SDFITS conversion of .nc file [#53]
  - rudimentary gridder exists

- SEQ/Bs works with dual bank now (some fixes needed for single bank)
  examples:  2023S1SEQUOIACommissioning  VX-Sgr    108756 108762 108766
             2021-S1-UM-3/100558         UGCA281   99713 .. 100558

- SEQ/Ps almost working
  examples:  2024-S1-UM-3/121219                Core_187 ...
             2024S1SEQUOIACommissioning/110416  MonR2
             2023S1SEQUOIACommissioning/108764  VX-Sgr
	     2018-S1-MU-79/90692                GP_J1735 ...
             2018-S1-MU-25/84891                Enceladus  Titan   

- stage/unstage on unity in case we do the work in /work and rsync to /nese (or /scratch?)
  this has MAJOR impact on how to run pipeline

- add the repo counter into the fits header of final output [currently only in lmtoy_repo=]
- revive maskmoment (has an import issue) [done?]
- resolve tsys_aver in lmtslr/spec/spec.py as per **Heyer**
- RMS0:   should we define some <Tsys>?  Currently RMS0 is defined per 100K (as is for RSR)
- Autoscaling the rather wide HTML pages for SEQ summary
- split parameters in single obsnum and combo (where only gridding is allowed) - useful for webrun
- pointing offsets from ifproc in meta-data ?
- automated generation of the script generator?
- FITS export option for spectra [sp2sdfits.py now exists]  [#53]
- the never finished manual (flow diagrams w/ mermaid?)

## Longer term wishes (>March 2024)

- SpecFile (netCDF format) to be replaced with an SDFITS file (just only convert)
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


