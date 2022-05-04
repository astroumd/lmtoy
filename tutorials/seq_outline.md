# Introduction to Sequoia Spectral Line data reduction


Some references:



sequoia:         http://lmtgtm.org/telescope/instrumentation/instruments/sequoia/

observing:       http://lmtgtm.org/wp-content/uploads/2020/12/SEQUOIA_v1p1.pdf

OTF method:      https://www.aanda.org/articles/aa/pdf/2007/41/aa7811-07.pdf

M51 paper:       https://arxiv.org/abs/2204.09613

LMTOY manual:    https://www.astro.umd.edu/~teuben/LMT/lmtoy/html/

  glossary:      https://www.astro.umd.edu/~teuben/LMT/lmtoy/html/glossary.html

github code:     https://github.com/astroumd/lmtoy

sample data:     https://www.astro.umd.edu/~teuben/LMT/data_lmt/



##  M51

We have 3 fits file in  https://www.astro.umd.edu/~teuben/LMT/data_lmt/

1. **NGC5194_88874_91112.fits**           a data cube of the CO line (140MB)

2. **NGC5194_88874_91112.mom0.fits**      total CO gas

3. **NGC5194_88874_91112.wt.fits**        sensitivity map

these are related (but a demo version of) the data discussed
in the Heyer et al. (20211;  https://arxiv.org/abs/2204.09613) paper.
 

        ds9:     https://sites.google.com/cfa.harvard.edu/saoimageds9/download
      carta:     https://cartavis.org/#download
    glnemo2:     https://projets.lam.fr/projects/glnemo2/wiki/download


## LMT (SEQ) data

1. Raw Data: uncalibrated, seperate calibration and science data - in $DATA_LMT

2. SpecFile: calibrated spectra (an intermediate format) - in $WORK_LMT

3. FITS cube: gridded data, science ready - in $WORK_LMT

4. ADMIT data: science processed, interesting meta-data - in $WORK_LMT

5. Archives data:   stored in **DataVerse** - online https://dp.lmtgtm.org/


The command **lmtinfo.py** can be used to *find* data. Multiple search times can
be *and-ed* together. It only operates on the RAW data in $DATA_LMT


      lmtinfo.py grep 2022 Science Map NGC
	  
      # Y-M-D   T H:M:S     ObsNum ObsGoal       ObgPgm    SourceName                ProjectId
      2022-04-27T06:12:40    98779  Science      Map(Dec)  NGC6786                   2021-S1-MX-3
      2022-04-27T05:53:05    98778  Science      Map(Ra)   NGC6786                   2021-S1-MX-3
      2022-04-27T05:26:36    98774  Science      Map(Dec)  NGC6786                   2021-S1-MX-3
      ...


## SLpipeline overview

### 

**TAP** = Timely Analysis Products

**SRDP** = Scienc Ready Data Products

1. unity@umass:  TAP produced at LMT  http://taps.lmtgtm.org/lmtslr/2021-S1-US-3/TAP/

   These should be available 5-10 mins after an obsnum was finished, only lightweight TAP produced

2. unity@umass:  locally (re)reduced  http://taps.lmtgtm.org/lmtslr/2021-S1-US-3

   These should be available 1-5 days after an obsnum was copied to unity, and come with SRDP

3. lma@umd:  https://www.astro.umd.edu/~teuben/work_lmt/2018-S1-MU-8/demo/

   These are experiments on improving the pipeline



### SL Pipeline summary

The following figures are shown; in two columns representing the first flow (right column)
and after the latest improvement (left columns).

https://www.astro.umd.edu/~teuben/work_lmt/2021-S1-US-3/97520/README.html

1. sky coverage
2. Tsys (K)
3. Waterfall Plot (K)
4. RMS (K)
5. Spectra  (map, all beams overlapping)
6. Spectra  (center, all beams overlapping)
7. Spectra  (each beam)
8. sky coverage (heat map)
9. moment-0 summing all line emission (K.km/s)
10. RMS accross image (K)

### ADMIT

### parameters

### log files

### Select FITS files
	  
	  
## SLpipeline

Running a single obsnum:

     SLpipeline.sh obsnum=98779
	 
or a combination (it is assumed the corresponding single obsnums have been run before):

     SLpipeline.sh obsnums=98777,98778,98779
	 
The corresponding data can be found in:

     $WORK_LMT/2021-S1-MX-3/98779

for a single obsnum, and 

	 $WORK_LMT/2021-S1-MX-3/98774_98779
	 
for a combination of several obsnum's.	 


Depending on the instrument, extra keywords can be given to control the flow and parameter settings.
A few common ones that apply to all instruments are (their defaults are given):

     restart=0
	 admit=1
	 tap=0
	 srdp=0
	 raw=0
	 
and for sequoia:

     #                - flow control
	 make_spec=1
	 make_cube=1
	 make_wf=1
	 viewspec=1
	 viewcube=0
	 viewnemo=1
     admit=1
	 #                - options that are processed
	 extent=0
	 dv=100
	 dw=250
	 #                - exact options
     pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
     rms_cut=-4
     location=0,0
     resolution=12.5   # will be computed from skyfreq
     cell=6.25         # will be computed from resolution/2
     rmax=3
     otf_select=1
     otf_a=1.1
     otf_b=4.75
     otf_c=2
     noise_sigma=1
     b_order=0
     stype=2
     sample=-1
     otf_cal=0
     edge=0
     bank=-1           # -1 means all banks 0..numbands-1

	 

## Installing

Installing can be as simple as this:

      wget https://astroumd.github.io/lmtoy/install_lmtoy
      bash install_lmtoy
	  
which took 8.5 mins on my laptop.  You will get various LMT tools, a few
packages, like CASA, ADMIT, NEMO and LMT's python.

Users do this to set up your shell (e.g. in you ~/.bashrc file)

      source lmtoy/lmtoy_start.sh
	  
an example of using a SEQ dataset of M51

      lmtinfo.py $DATA_LMT 91112
      SLpipeline.sh obsnum=91112
