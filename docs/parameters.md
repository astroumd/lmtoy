# SLpipeline.sh parameters

Here we describe the spectral line pipeline parameters, as they are being understood by
**SLpipeline.sh** and its instrument specific scripts.

We differentiate between **generic** and **instrument/obsmode specific** (RSR,
SEQ, 1MM, OMA, ...) parameters.

The pipeline and instrument specific scripts all have a **--help** and **-h** option
as a reminder to the keywords and their defaults. They should always
report the parameters. If not visible, this means the parameter may still be hardcoded
in the code.

Note that command line keywords that do not belong to the instrument (e.g. band= for RSR) are just ignored,
and this includes typos!

## Filename Conventions

A reminder on filename conventions:

For a given **obsnum** (or in a combination **obsnumFirst_obsnumLast**) we have the following basenames that
all exist within the directory **obsnum/**:

* lmtoy_OBSNUM.log - logfile from the pipeline
* lmtoy_OBSNUM.ifproc - brief ASCII version of the IFPROC header
* lmtoy_OBSNUM.rc  - pipeline (and derived) parameters
* SRC_OBSNUM_wf.fits  - SEQ waterfall in case there is only one band
* SRC_OBSNUM__0_wf.fits  - SEQ waterfall for band 0 - in case there are > 1 band (e.g. 1MM and OMA)
* SRC_OBSNUM__1_wf.fits  - SEQ waterfall for band 1
* SRC_OBSNUM__1.txt - SEQ spectrum for band 1 (Bs or Ps mode)
* rsr.99862.badlags - RSR bad lags used for spectra
* README_files.md - explanation of all files in this directory
* README.html - the entry point for the summary table (index.html needs to symlink to this)

there are many more, most of them instrument specific, but this is the basic structure. The **README_files.md**
is written by the pipeline to explain their contents, and should always contain all used filenames.


## Observing Modes

A summary what the **SLpipeline.sh**  handles:

      Instrument    ObsGoal    ObsPgm         Example           Comments

      RSR           Science    Bs
      RSR           LineCheck  Bs             33551 (bench1)

      SEQ           Science    Bs             108766            only band=0; Bs is a special case of Ps
      SEQ           Science    Ps             108764            not working yet
      SEQ           Science    Map            94050,94052       various mapmodes (Hor,Equ,Gal)
      SEQ           Science    Lissajous      94051             ? broken now ?
      SEQ           Pointing   Map            79448 (bench2)

      1MM           Pointing   Map            74744,108715              
      1MM           Pointing   CrossScan      74742
      1MM           SciencePs  Ps             88058

      <any>         Focus                                       not handled by SLpipeline
      <any>         Astigmatism                                 not handled by SLpipeline
      <any>         Gaincurve                                   not handled by SLpipeline
      <any>         Calibration                                 not handled by SLpipeline

Scripts:

1. rsr_pipeline.sh, rsr_combine.sh - spectra + stacking
2. seq_pipeline.sh, seq_combine.sh - maps + stacking
3. seqbs_pipeline.sh, seqbs_combine.sh - spectra + stacking (no stacking yet)
4. seqps_pipeline.sh, seqps_combine.sh - spectra + stacking (no yet available)
5. lmtoy_functions.sh - common functions, never called by a user

## 1. Generic

The pipeline flow is controlled by the following generic
parameters. Note that either **obsnum=** *or* **obsnums=** needs
to be supplied, not both!


    obsnum=o1           single obsnum run [0]
    obsnums=o1,o2,....  combination series run [0]
    oid=""              tag obsnum (results in files with "__$oid") - used for bank 0,1
        
    debug=0             1: verbosely print all commands and shell expansions
    error=1             1: exit on error
    restart=0           1: cleans up old obsnum pipeline results
    exist=0             1: will not run if the obsnum exists (see also sbatch_lmtoy.sh obsnum0=)
    path=$DATA_LMT      - should not be used (but will still work)
    work=$WORK_LMT      - should not be used (but will still work)
    tap=0               produce TAP tar file?  [0|1]
    srdp=0              produce SRDP tar file? [0|1]
    raw=0               produe RAW tar file?   [0|1]
    admit=0             run admit?             [0|1]
    sleep=2             sleep before running, in case you change your mind
    nproc=1             number of processors (should stay at 1)
    rsync=""            special rsync option, only for running at LMT (malt)

and experimental (i.e. don't use in production)

    rc=""               ?
    goal=science        ?pointing,focus,....
    newrc=              ?if you want to add rc parameters
    pdir=               ?if you want to switch manually for work

## 2. RSR

The **rsr_pipeline.sh** script uses two scripts to get the same spectrum in two different
ways (they really should be merged).

    badcb=2/3,2/2          preset Chassis/Board detectors that are bad C=[0..3]  B=[0..5]
    xlines=110.51,0.15     sections of spectrum not to be used for baseline fit (freq-dfreq..freq+dfreq)
                           normally because there is a (strong) line. Used by linecheck, but adviced for
			   strong line sources
    linecheck=0            if set to 1, use the source name to grab the correct xlines=
    shortlags=32,15.0      set a short_min and short_hi to avoid flagging strong continuum sources
    sgf=51                 If given, set Savitzky-Golay high pass filter ; odd number > 21
                           Can be useful for strong continuum sources
    spike=3                spikyness of localized peaks
    bandzoom=5             default band to supply a zoomed view of the final spectrum
    speczoom=85,3          if given, override the bandzoom with a window 85 +/- 3
    rthr=0.01              Threshold sigma value when averaging single observations repeats (-r)
    cthr=0.01              Threshold sigma value when coadding all observations (-t)
    blo=1                  order of polynomial baseline subtraction
    

Below we describe a few common scripts used in the pipeline. Some parameters are promoted to
a pipeline parameter, others are hardcoded.

### 2.1 badlags.py

Usage: badlags.py [options] OBSNUM

Options:

    -p --plotmax PLOTMAX          Plot max. If not given, the bc_hi THRESHOLD is used. Optional
    -B --badlags BADLAGS          Output badlags file, if desired. [Default: rsr.badlags]
    -d                            Add more debug output
    -e                            Don't use edge detection, by default it will.
    -s                            No interactive plot, it will save the plot.
    --bc_hi HIGH                  Above this value, lags are flagged bad [Default: 2.5]
    --bc_lo LOW                   Below this value, lags are flagged bad [Default: 0.01]
    --spike SPIKE                 Threshold above which spikes are flagged as bad channel [Default: 3.0]
    --short_hi SHIGH              Above this value, lags under SMIN are flagged [Default: 2.5]
    --short_min SMIN              Lags below SMIN get special treatment and are allowed different threshold [Default: 256]
    --min_chan MINCHAN            No blabla below this channel [Default: 32]
    --rms_min RMIN                Minimum RMS to accept a C/B [Default: 0.01]
    --rms_max RMAX                Maximum RMS to accept a C/B [Default: 0.2]

    -b THRESHOLD        0.01
    -p PLOT_MAX         0.3
    --badlags           rsr.badlags
    bc_threshold    =   3.0
    bc_low          =   0.01
    Qspike          =   True
    spike_threshold =   3.0         # or use when > 0
    min_chan        =   32                 
    Qedge           =   True        # try to find high end edge (lag#=255)

### 2.2 rsr_tsys.py  

    rms_min         = 25.0      # this will add more badcb's

### 2.3 rsr_driver.py


    -t 0.01             # --threshold sigma value when coadding all observations
    -s ???              # --smooth
    -b 1                # baseline order
    -r ???              # --repeat_thr  Threshold sigma value when averaging single observations repeats
    -f ???              # --filter N    Savitzky-Golay filter (SGF) - should be odd and > 21
    -n ???              # --notch_sigma sigma cut for notch filter (needs -f also)
    --exclude f1,df1,   # exclude regions from baseline calcs

### 2.4 rsr_sum.py


    -t THRESHOLD_SIGMA  # Threshold sigma in spectrum needed for averaging [0.01]
    -o1 ORDER1          # Baseline order fit for individual spectra [1]
    -o1 ORDER2          # Baseline order fit for final combined spectrum [-1]



@todo   unified format for rfile/blanking?

@todo   parallel processing?


### 2.1 How to reduce RSR data with this pipeline?

Running RSR pipeline "manually". In this example we use 123456 as the obsnum
Notation "C/B" means Chassis/Board and "C/B/c" means Chassis/Board/channel(s)

1. Run the default pipeline

         SLpipeline.sh obsnum=123456

2. Inspect the Tsys plots. You might find some bands (boards) very noisy. They
   might go away when applying bad lags.

2. Inspect the bad lags: look at badlags plot and the *.badlags file

   Note the #BADCB lines at the bottom that the badlag.py script 
   has decided to take out. These get transferred to the *.blanking and *.rfile  files by
   the rsr_badcb script

3. Optionally there is an alternative way to specify the badlags etc.
   completely manually. For this do this inside the OBSNUM directory:
   
         badlags2.py OBSNUM  C/B/c1,c2,c3,....      C/B    > *.badlags
         rsr_badcb -r *.badlags > *.rfile 
         rsr_badcb -b *.badlags > *.blanking

   In here C/B/c1,...   are specific bad lags, whereas C/B means that
   complete Chassis/Board combination needs to be taken out.

   then run the pipeline, making sure any old badcb's are not added in
   again:

        SLpipeline.sh obsnum=123456 badcb=

4. Parameters to control spectrum-making 

   badlags:
   
        bc_threshold  [3.0]
        bc_low        [0.0]
        rms_min       [0.01]
        rms_max       [0.1]

   rsr_driver:

        --threshold 
        --repeat_thr
        -b
        --badlags (-B)
        --rfile (-R)



### more verbose description

    usage: rsr_driver.py [options] obslist

Simple wrapper to process RSR spectra

* positional arguments:

        obslist               Text file with obsnums to process. Either one obsnum per row or a range of observation numbers separated by hyphens.

* optional arguments:

        -h, --help                                        show this help message and exit
        -p                                                Produce default plots
        -t CTHRESH, --threshold CTHRESH
                                                          Threshold sigma value when coadding all observations
        -o OUTPUT, --output OUTPUT
                                                          Output file name containing the spectrum
        -f FILTER, --filter FILTER
                                                          Apply Savitzky-Golay filter (SGF) to reduce large scale trends in the spectrum. 
                                                          Must be an odd integer. This value represent the number of channels used to aproximate the baseline. 
                                                          Recomended values are larger than 21.
                                                          Default is to not apply the SGF
        -s SMOOTH, --smooth SMOOTH
                                                          Number of channels of a boxcar lowpass filter applied to the coadded spectrum. 
                                                          Default is to no apply filter
        -r RTHR, --repeat_thr RTHR
                                                          Thershold sigma value when averaging single observations repeats
        -n NOTCH, --notch_sigma NOTCH
                                                          Sigma cut for notch filter to eliminate large frecuency oscillations in spectrum. 
                                                          Needs to be run with -f option.
        --simulate SIMULATE [SIMULATE ...]
                                                          Insert a simulated line into spectrum. The format is a list or a set of three elements 
                                                          Amplitude central_frequency line_velocity_width.
        -d DATA_LMT, --data_lmt_path DATA_LMT
                                                          Path where the LMT data is located (default is to look for the DATA_LMT environment 
                                                          variable or the /data_lmt folder
        -b BASELINE_ORDER                                 Baseline calculation order
        --exclude EXCLUDE [EXCLUDE ...]
                                                          A set of frequencies to exclude from baseline calculations. Format is central 
                                                          frequency width. Eg --exclude 76.0 0.2 96.0 0.3 excludes the 75.8-76.2 GHz and 
                                                          the 95.7-96.3 intervals from the baseline calculations.
        -j                                                Perform jacknife simulation
        -c CHASSIS [CHASSIS ...]
                                                          List of chassis to use in reduction. Default is the four chassis
        -B BADLAGS, --badlags BADLAGS
                                                          A bad lags file with list of (chassis,board,channel) tuples as produced by badlags
        -R RFILE, --rfile RFILE
                                                          A file with information of board data to ignore from analysis. The file must 
                                                          include the obsnum, chassis and board number to exclude separated by commas. One board per row
        -w WATERFALL, --waterfall-file WATERFALL
                                                          Request the driver to produce waterfall plot for each input file
        --no-baseline-sub                                 Disable subtraction of polinomial baseline. NOT RECOMMENDED.



* Usage: rsr_sum.py -b BLANKING_FILE [options]

        -b BLANKING_FILE              Input ASCII blanking file. No default.
        -T THRESHOLD_SIGMA            Threshold sigma in spectrum needed for averaging [Default: 0.01]
        --badlags BADLAGS_FILE        Input rsr.lags.bad file. Optional.
        --o1 ORDER1 -1 ORDER1         Baseline order fit for individual spectra [Default: 1]
        --o2 ORDER2 -2 ORDER2         Baseline order fit for final combined spectrum [Default: -1]
                                      Use -1 to skip another fit
        -p PATH                       Data path to data_lmt for the raw RedshiftChassis files.
                                      By default $DATA_LMT will be used else '/data_lmt'.

        -h --help                     show this help





## 3. SEQ

We list the keywords specific to Seqouia and their defaults. Some parameters cause a computation
of derived paramers, and in a re-run will not be recomputed!  These are noted as such


                   - parameters that determine if something gets done
    makespec=1
    makecube=1
    makewf=1
    viewspec=1       the location= is used here
    viewcube=0
    viewnemo=1
    admit=0
    maskmoment=1
    clean=1
      #            - parameters that will compute other parameters for SLR scripts

      #              1. BEAM/TIME filtering
    bank=-1           # -1 means all banks 0..numbands-1
    pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
    sample=-1         # not used until the gridding stage
	              # @todo deal with vlsr=, restfreq= and different lines

      #              3. BASELINE

    dv=100           line cube is +/- dv around VLSR
    dw=250           baseline is fitted +/-dw outside of the line cube, i.e. from dv to dv+dw on both sides
    b_order=0        baseline order
    b_regions        even number of areas where baseline is defined (dw= can do this symmetrically)
    l_regions
    slice            the cube to be cut (usually from the extreme b_regions)

      #              2. CALIBRATION
    birdies=0        birdie channels need to be in original (1based?) channel space
                     could also be a pulldown based on nchan from known cases
    rms_cut=-4       samples to reject if above an threshold [slider]
    stype=2          type of spectral line reduction (2=bracketed) [radio:0,1,2]
    otf_cal=0        use calibration within OTF scan? [radio: 0,1]


      #              4. GRIDDING
    extent=0          if used, use it as the field size (square -extent..extent) [arcsec]
    resolution=12.5   # will be computed from skyfreq (lambda/D, so not exactly beam)
    cell=6.25         # will be computed from resolution/2
    nppb=-1           # alternative number of points per beam setting
    rmax=3            # number of resolutions to convolve with
    otf_select=1      # otf filter code one of (0=box,1=jinc,2=gaussian,3=triangle) [default: 1]
    otf_a=1.1         # parameter for the filter
    otf_b=4.75        # parameter for the filter
    otf_c=2           # parameter for the filter
    noise_sigma=1     # weighting scheme (0 or 1)
    edge=0            # how to handle the edge (interpolate etc.)
    location=0,0      # viewing spectrum of this position w.r.t. center of map

      #              5. OUTPUT
    admit=0           # run admit?
    maskmoment=0      # run maskmoment?
    dataverse=0       # ingest in dataverse
    raw=0             # create RAW files for offline reduction
    srdp=0            # create SRDP for this obsnum
    tap=0             # create TAP (lightweight SRDP)
    clean=1           # cleanup tmp files after the run
    

      # unset a view things, since setting them will give a new meaning
    unset vlsr
    unset restfreq


### 3.1 process_otf_map2.py

Usage: process_otf_map2.py -p PATH -O OBSNUM -o OUTPUT [options]

     -p PATH --path PATH                Path where ifproc and spectrometer/roach* files are
     -o OUTPUT --output OUTPUT          Output SpecFile  [test.nc]
     -O OBSNUM --obsnum OBSNUM          The obsnum, something like 79448. 
     -b BANK --bank BANK                Spectral Bank for processing [default: 0]
     --pix_list PIX_LIST                Comma separated list of pixels [Default: 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
     --eliminate_list ELIMINATE_LIST    Comma separated list of channels to be blanked
     --use_cal                          Use Calibration scan
     --tsys TSYS                        If use_cal is False, value of Tsys to use [default: 250.0] ** not used **
     --use_otf_cal                      Use calibration within OTF scan (default: False)
     --save_tsys                        Should tsys (from CAL) be saved in specfile?
     --stype STYPE                      type of spectral line reduction;
                                        0 - median; 1 - single ref spectra; 2 - bracketed ref [Default: 2]
     -map_coord MAP_COORD              Override map_coord for output coordinate system. [Default: -1]
                                        -1 - default; 0 - Az/El;  1 - Ra/Dec; 2 - L/B
     --x_axis X_AXIS                    select spectral x axis.
                                        options one of VLSR, VSKY, VBARY, VSRC, FLSR, FSKY, FBARY, FSRC [default: VLSR]
     --b_order B_ORDER                  set polynomial baseline order [default: 0]
     --b_regions B_REGIONS              enter list of lists for baseline regions (default: [[],[]])
     --l_regions L_REGIONS              enter list of lists for line fit regions (default: [[],[]])
     --slice SLICE                      enter list to specify slice from spectrum for processing
     --sample PIXEL,S0,S1               Series of sample sections per pixel to be removed from SpecFile (not implemented yet)
     --restfreq RESTFREQ                Override the rest frequency (in GHz) for this bank. [Default: -1]

### 3.2  process_bs.py

usage: process_bs [-h] [-c CONFIG] [-p PATH] [-o OUTPUT] [--show] [--obs_list OBS_LIST] [-b BANK] [--block BLOCK] [--pix_list PIX_LIST] [--use_cal]
                  [--tsys TSYS] [--stype STYPE] [--x_axis X_AXIS] [--b_order B_ORDER] [--b_regions B_REGIONS] [--l_regions L_REGIONS] [--slice SLICE]

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        Name of configuration file to set parameters (default: None)
  -p PATH, --path PATH  data path (default: None)
  -o OUTPUT, --output OUTPUT
                        name of output SpecFile (default: None)
  --show                Show figures interactively (default: False)
  --obs_list OBS_LIST   Comma separated list of ObsNums (default: None)
  -b BANK, --bank BANK  Spectral Bank for processing (default: 0)
  --block BLOCK         Spectral block for stype=2 processing (default: -1)
  --pix_list PIX_LIST   Comma separated list of pixels (default: None)
  --use_cal             Use Calibration scan (default: False)
  --tsys TSYS           If use_cal is False, value of Tsys to use (default: 250.0)
  --stype STYPE         type of spectral line reduction; 0 - median; 1 - single ref spectra; 2 - bracketed ref (default: 1)
  --x_axis X_AXIS       select spectral x axis. options one of VLSR, VSKY, VBARY, VSRC, FLSR, FSKY, FBARY, FSRC (default: VLSR)
  --b_order B_ORDER     set polynomial baseline order (default: 0)
  --b_regions B_REGIONS
                        enter list of lists for baseline regions (default: None)
  --l_regions L_REGIONS
                        enter list of lists for line fit regions (default: None)
  --slice SLICE         enter list to specify slice from spectrum for processing (default: None)

### 3.3 grid_data

This calls spec_driver_fits!

Usage: grid_data.py  -i INPUT -o OUTPUT -w WEIGHT [options]

     -p PP --program_path PP       Executable [Default: spec_driver_fits]
     -i INPUT --input INPUT        Input SpecFile (no default)
     -o OUTPUT --output OUTPUT     Output map (no default)
     -w WEIGHT --weight WEIGHT     Output weight map (no default)
     --resolution RESOLUTION       Resolution in arcsec [Default: 14]
     --cell CELL                   Cell size in arcsec [Default: 7]
     --pix_list PIX_LIST           Comma separated list of pixels [Default: 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
     --rms_cut RMS_CUT             RMS threshold for data, negative allowed for robust MAD method  [Default: 10.0]
     --noise_sigma NOISE_SIGMA     noise weighting - apply if > 0 [default: 1]
     --x_extent X_EXTENT           x extent of cube (arcsec) note: cube will go to +/- x_extent [Default: 400]
     --y_extent Y_EXTENT           y extent of cube (arcsec) note: cube will go to +/- y_extent [Default: 400]
     --otf_select OTF_SELECT       otf filter code one of (0=box,1=jinc,2=gaussian,3=triangle) [default: 1]
     --rmax RMAX                   maximum radius of convolution (units lambda/D) [default: 3.0]
     --n_samples N_SAMPLES         number of samples in convolution filter [default: 256]
     --otf_a OTF_A                 OTF A parameter [default: 1.1]
     --otf_b OTF_B                 OTF B parameter [default: 4.75]
     --otf_c OTF_C                 OTF C parameter [default: 2.0]
     --sample P,S0,S1,P,...        Blank sample S0 to S1 for pixel P, etc. [Default: -1,0,0]
     --edge EDGE                   Fuzzy edge?  [default: 1]


### 3.4 spec_driver_fits

spec_driver_fits LMTSLR 4-dec-2022

     h help
     i input
     o output
     w weight
     a model
     l resolution_size
     c cell_size
     u pix_list
     z rms_cutoff
     s noise_sigma
     x x_extent
     y y_extent
     f filter
     r rmax
     n n_cell
     0 jinc_a
     1 jinc_b
     2 jinc_c
     b sample

## Heyer's list 

In **lmtoy_reduce_Parameters_v4.docx** the SEQ reduction parameters are described. A table with two subtables,
describing the parameters for making spec-file, and for making fits-cube.


### spec file making

        path
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
        stype
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
        otf_b
        otf_c
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

## 4. 1MM

This should follow most of the parameters in SEQ/Bs, though there are also map examples
