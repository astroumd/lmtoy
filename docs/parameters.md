# SLpipeline.sh parameters

We differentiate between **generic** and **instrument specific** (RSR, SEQ, 1MM, OMA, ...)

## Generic

Every instrument will be controlled by the following parameter. We also list their default,
as only obsnum= *or* obsnums= is required


    obsnum=o1           single obsnum
	obsnums=o1,o2,....  combination series
	
    debug=0             1:
	restart=0           1: cleans up old obsnum pipeline results
	path=$DATA_LMT
	work=$WORK_LMT
	tap=0
	srdp=0
	raw=0
	admit=0
	sleep=2
	nproc=1
	rsync=""
	rc=""
	oid=""
	goal=science
	obsid=
	newrc=
	pdir=

## RSR



### zero

pipeline parameters

SLpipeline.sh
=============

  obsnum=12345

rsr_pipeline.sh
===============

  badcb=2/3,2/2          preset detectors that are bad
  xlines=110.51,0.15     sections of spectrum not to be used for baseline fit

badlags.py
----------
  -b THRESHOLD        0.01
  -p PLOT_MAX         0.3
  --badlags           rsr.badlags
  bc_threshold=3.0
  bc_low=0.01
  Qspike = True
  spike_threshold = 3.0         # or use when > 0
  min_chan = 32                 
  Qedge = True                  # try to find high end edge (lag#=255)

rsr_tsys.py  
-----------
  rms_min = 25.0      # this will add more badcb's

rsr_driver.py
-------------
  -t 0.01             # --threshold sigma value when coadding all observations
  -s ???              # --smooth
  -b 1                # baseline order
  -r ???              # --repeat_thr  Threshold sigma value when averaging single observations repeats
  -f ???              # --filter N    Savitzky-Golay filter (SGF) - should be odd and > 21
  -n ???              # --notch_sigma sigma cut for notch filter (needs -f also)
  --exclude f1,df1,   # exclude regions from baseline calcs

rsr_sum.py
----------
  -t THRESHOLD_SIGMA  # Threshold sigma in spectrum needed for averaging [0.01]
  -o1 ORDER1          # Baseline order fit for individual spectra [1]
  -o1 ORDER2          # Baseline order fit for final combined spectrum [-1]



@todo   unified format for rfile/blanking ?
@todo   parallel processing


### one
Running RSR pipeline "manually". In this example we use 123456 as the obsnum
Notation "C/B" means Chassis/Board and "C/B/ch" means Chassis/Board/channel(s)

1. Run the default pipeline

   SLpipeline.sh admit=0 obsnum=123456

2. Inspect the Tsys plots. You might find 

2. Inspect the bad lags.   The plot and the *.badlags file

   Note the #BADCB lines at the bottom that the badlag.py script 
   has decided to take out. These get transferred to the *.blanking and *.rfile  files by
   the rsr_badcb script

3. Optionally there is an alternative way to specify the badlags etc.
   completely manually. For this do this inside the OBSNUM directory:
   
   badlags2.py OBSNUM  C/B/ch1,ch2,ch3,....      C/B    > *.badlags
   rsr_badcb -r *.badlags > *.rfile 
   rsr_badcb -b *.badlags > *.blanking

   In here C/B/ch...   are specific bad lags, whereas C/B means that
   complete Chassis/Board combination needs to be taken out.

   then run the pipeline, making sure any old badcb's are not added in
   again:

   SLpipeline.sh admit=0 obsnum=123456 badcb=

4. Parameters to control spectrum-making - and their regression defaults

   badlags:     bc_threshold  [3.0]
                bc_low        [0.0]
                rms_min       [0.01]
                rms_max       [0.1]

   rsr_driver:  --threshold 
                --repeat_thr
                -b
                --badlags (-B)
                --rfile (-R)




### two

usage: rsr_driver.py [-h] [-p] [-t CTHRESH] [-o OUTPUT] [-f FILTER] [-s SMOOTH] [-r RTHR] [-n NOTCH] [--simulate SIMULATE [SIMULATE ...]] [-d DATA_LMT] [-b BASELINE_ORDER] [--exclude EXCLUDE [EXCLUDE ...]] [-j] [-c CHASSIS [CHASSIS ...]]
                     [-B BADLAGS] [-R RFILE] [-w WATERFALL] [--no-baseline-sub]
                     obslist

Simple wrapper to process RSR spectra

positional arguments:
  obslist               Text file with obsnums to process. Either one obsnum per row or a range of observation numbers separated by hyphens.

optional arguments:
  -h, --help            show this help message and exit
  -p                    Produce default plots
  -t CTHRESH, --threshold CTHRESH
                        Thershold sigma value when coadding all observations
  -o OUTPUT, --output OUTPUT
                        Output file name containing the spectrum
  -f FILTER, --filter FILTER
                        Apply Savitzky-Golay filter (SGF) to reduce large scale trends in the spectrum. Must be an odd integer. This value represent the number of channels used to aproximate the baseline. Recomended values are larger than 21.
                        Default is to not apply the SGF
  -s SMOOTH, --smooth SMOOTH
                        Number of channels of a boxcar lowpass filter applied to the coadded spectrum. Default is to no apply filter
  -r RTHR, --repeat_thr RTHR
                        Thershold sigma value when averaging single observations repeats
  -n NOTCH, --notch_sigma NOTCH
                        Sigma cut for notch filter to eliminate large frecuency oscillations in spectrum. Needs to be run with -f option.
  --simulate SIMULATE [SIMULATE ...]
                        Insert a simulated line into spectrum. The format is a list or a set of three elements Amplitude central_frequency line_velocity_width.
  -d DATA_LMT, --data_lmt_path DATA_LMT
                        Path where the LMT data is located (default is to look for the DATA_LMT environment variable or the /data_lmt folder
  -b BASELINE_ORDER     Baseline calculation order
  --exclude EXCLUDE [EXCLUDE ...]
                        A set of frequencies to exclude from baseline calculations. Format is central frequency width. Eg --exclude 76.0 0.2 96.0 0.3 excludes the 75.8-76.2 GHz and the 95.7-96.3 intervals from the baseline calculations.
  -j                    Perform jacknife simulation
  -c CHASSIS [CHASSIS ...]
                        List of chassis to use in reduction. Default is the four chassis
  -B BADLAGS, --badlags BADLAGS
                        A bad lags file with list of (chassis,board,channel) tuples as produced by badlags
  -R RFILE, --rfile RFILE
                        A file with information of board data to ignore from analysis. The file must include the obsnum, chassis and board number to exclude separated by commas. One board per row
  -w WATERFALL, --waterfall-file WATERFALL
                        Request the driver to produce waterfall plot for each input file
  --no-baseline-sub     Disable subtraction of polinomial baseline. NOT RECOMMENDED.



"""Usage: rsr_sum.py -b BLANKING_FILE [options]

-b BLANKING_FILE              Input ASCII blanking file. No default.
-t THRESHOLD_SIGMA            Threshold sigma in spectrum needed for averaging [Default: 0.01]
--badlags BADLAGS_FILE        Input rsr.lags.bad file. Optional.
--o1 ORDER1 -1 ORDER1         Baseline order fit for individual spectra [Default: 1]
--o2 ORDER2 -2 ORDER2         Baseline order fit for final combined spectrum [Default: -1]
                              Use -1 to skip another fit
-p PATH                       Data path to data_lmt for the raw RedshiftChassis files.
                              By default $DATA_LMT will be used else '/data_lmt'.

-h --help                     show this help
"""




## SEQ

We list the keywords specific to SEQ and their defaults. Some parameters cause a computation
of derived paramers, and in a re-run will not be recomputed!  These are noted


    makespec=1
    makecube=1
    makewf=1
    viewspec=1
    viewcube=0
    viewnemo=1
    admit=0
    clean=1
      #            - meta parameters that will compute other parameters for SLR scripts
    extent=0
    dv=100
    dw=250
      #            - birdies (list of channels, e.g.   10,200,1021)
    birdies=0
      #            - parameters that directly match the SLR scripts
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

      # unset a view things, since setting them will give a new meaning
    unset vlsr

## Heyer's list 

Discussion document on SEQ reduction parameters. In two sets, for making spec-file, and for make cube

### spec file making

	obsnum
	makespec
	pix_list
	x_axis
	slice
	b_order
	b_regions
	ztype           0=velocity; 1=frequency; 2=channel
	otf_cal
	bank
	styp
	Vlsr
	DeltaV
	Nbw

### cube making

	x_extent
	y_extent
	cell
	resolution
	l_regions
	pix_list
	otf_select
	rmax
	otf_a
	otf_a
	otf_a
	n_samples
	noise_sigma
	rms_cut
	otf_cal
	Sample
	Linefreq          new   [f1,f2,....]
	IncludeRamps      new:  True/False
	Projection        new   CAR,SIN,TAN,SFL


## duplicates

There are files with duplicate mentions of parameter names.

* utils/configuration.py  (using configobj)
  * path = string(max=500, default='/data_lmt')
  * obsnum = integer(1, 100000)
  * bank = integer(min=0, max=3, default=0)
  * pix_list = int_list(min=1, max=32, default=list(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15))
  * eliminate_list = int_list(min=1, default=list(4096,))
  * stype = integer(min=0, max=3, default=1)
  * use_cal = boolean(default=False)
  * tsys = float(min=10, default=200)
  * use_otf_cal = boolean(default=False)
  * x_axis = option('VLSR', 'VSKY', 'VBARY', 'VSRC', 'FLSR', 'FSKY', 'FBARY', 'FSRC', default='VLSR')
  * b_order = integer(min=0, max=4, default=0)
  * b_regions = string(default='[[-193, -93], [107,207]]')
  * l_regions = string(default='[[-93, 107]]')
  * slice = float_list(min=2, max=2, default=list(-200, 200))
  * obs_list = int_list()
  * show_all_pixels = boolean(default=True)
  * show_pixel = integer(default=None)
  * rms_cut = float(default=10000)
  * plot_range = int_list(min=2, max=2, default=list(-10, 10))
  * v_range = float_list(min=2, max=2, default=list(-300, 200))
  * v_scale = float(default=0.001)
  * location = float_list(min=2, max=2, default=list(0, 0))
  * scale = float(default=2.78e-4)
  * limits = float_list(min=4, max=4, default=list(-100, 100, -100, 100))
  * tmax_range = float_list(min=2, max=2, default=list(-1, 1))
  * tint_range = float_list(min=2, max=2, default=list(-1, 1))
  * plot_type = option('TINT', 'TMAX', default='TINT')
  * interp = option('none', 'nearest', 'bilinear', 'bicubic', default='bilinear')
  * program_path = string(max=500, default='/usr/local/env/specenv/bin/spec_driver_fits')
  * resolution = float(min=0, default=14)
  * cell = float(min=0, default=7)
  * rms_cut = float(default=10000)
  * noise_sigma = float(default=1.0)
  * x_extent = float(min=1, default=300)
  * y_extent = float(min=1, default=300)
  * otf_select = option(0, 1, 2, default=1)
  * rmax = float(default=3)
  * n_samples = integer(default=256)
  * otf_a = float(default=1.1)
  * otf_b = float(default=4.75)
  * otf_c = float(default=2.0)


* utils/argparser.py
