RSR via SLpipeline
==================

Here we summarize the current (nov 2021) status of data reduction for the RSR. 
The invocation would be

.. code-block::

      SLpipeline.sh obsnum=33551

The current **SLpipeline.sh** will currently run a few scripts for a single obsnum:

1. **badlags.py**:  this will identify bad lags, based on the variation in time of the
   auto correllation function
   and store them in a **rsr.$obsnum.badlags** file. This file
   should be inspected (see the **badlags.png** plot). Options:

.. code-block::

      Usage: badlags.py [-f obslist] [-p plot_max] [-b bc_threshold] [obsnum ....]

      -b THRESHOLD                  Threshold sigma in spectrum needed for averaging [Default: 0.01]
      -p PLOT_MAX                   Plot max. If not given, the THRESHOLD is used
      -f OBSLIST                    List of OBSNUM's. Not used.
      -B --badlags BADLAGS_FILE     Output rsr.badlags file. If not provided, it will not be written
      -d                            Add more debug output
      -s                            no interactive show (default now is interactive)


2. **rsr_driver.py**: this will produce a final averaged and bandmerged spectrum

.. code-block::

      usage: rsr_driver.py [-h] [-p] [-t CTHRESH] [-o OUTPUT] [-f FILTER] [-s SMOOTH] [-r RTHR] [-n NOTCH]
             [--simulate SIMULATE [SIMULATE ...]] [-d DATA_LMT] [-b BASELINE_ORDER] [--exclude EXCLUDE [EXCLUDE ...]] [-j]
             [-c CHASSIS [CHASSIS ...]] [-B BADLAGS] [-R RFILE] [-w WATERFALL] [--no-baseline-sub]
             obslist

      Simple wrapper to process RSR spectra

      positional arguments:
            obslist               Text file with obsnums to process. Either one obsnum per row or a range of observation numbers separated by hyphens.

      optional arguments:
         -h, --help            show this help message and exit
         -p                    Produce default plots
         -t CTHRESH, --threshold CTHRESH
                               Threshold sigma value when coadding all observations
         -o OUTPUT, --output OUTPUT
                               Output file name containing the spectrum
         -f FILTER, --filter FILTER
                               Apply Savitzky-Golay filter (SGF) to reduce large scale trends in the spectrum. Must be an odd integer. This value represent the number of channels used to aproximate the baseline. Recomended values are larger than 21. Default is to not apply the SGF
                         
         -s SMOOTH, --smothing SMOOTH
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
                        A set of frequencies to exclude from baseline calculations. Format is central frequenciy width.
	                Eg --exclude 76.0 0.2 96.0 0.3 excludes the 75.8-76.2 GHz and the 95.7-96.3 intervals from the baseline calculations.
         -j                    Perform jacknife simulation
         -c CHASSIS [CHASSIS ...]
                        List of chassis to use in reduction. Default is the four chassis
         -B BADLAGS, --badlags BADLAGS
                        A bad lags file with list of (chassis,board,channel) tuples as produced by seek_bad_channels
         -R RFILE, --rfile RFILE
                        A file with information of band data to ignore from analysis.
	               The file must include the obsnum, chassis and band number to exclude separated by comas. One band per row
         -w WATERFALL, --waterfall-file WATERFALL
                        Request the driver to produce waterfall plot for each input file
         --no-baseline-sub     Disable subtraction of polinomial baseline. NOT RECOMMENDED.


3. **rsr_sum.py**: this will produce a final averaged and bandmerged spectrum

.. code-block::

       Usage: rsr_sum.py -b BLANKING_FILE [options]

       -b BLANKING_FILE              Input ASCII blanking file. No default.
       -t THRESHOLD_SIGMA            Threshold sigma in spectrum needed for averaging [Default: 0.01]
       --badlags BADLAGS_FILE        Input rsr.badlags file. Optional, but highly recommended.
       --o1 ORDER1 -1 ORDER1         Baseline order fit for individual spectra [Default: 1]
       --o2 ORDER2 -2 ORDER2         Baseline order fit for final combined spectrum [Default: -1]
                                     Use -1 to skip another fit
       -p PATH                       Data path to data_lmt for the raw RedshiftChassis files.
                                     By default $DATA_LMT will be used else '/data_lmt'.


The data are stored in a directory *ProjectId/ObsNum*, and the following files can be edited to re-run and improve
the pipeline:

1. **rsr.$obsnum.badlags** : make sure the  **-b** threshold and **-p** plotmax are set properly to inspect which lags can
   be reliably flagged.

2. **rsr.obsnum** : the obsnum used for this pipeline (in combination pipelines, multiple obsnums could be used here).

3. **rsr.$obsnum.blanking** : the obsnum used for this pipeline, as well as blanking information for this obsnum. 
   This file can be edited and the pipeline can be re-run.

4. **rsr.$obsnum.rfile**:  

Final averaged spectrum
-----------------------

The final spectrum is a band merged spectrum covering from about 73
GHz to 111 GHz, in 6 bands. The average is over the 4 chassis (beam
and polarization) and a small number (5-10) of integrations. The
typical integration time per sample is about 30 seconds. Here is a
typical header of a final spectrum:

.. code-block::

      # ------------Redshift Receiver Spectrum---------
      # Telescope: Large Millimeter Telescope
      # Source: I10565
      # Source RA: 10:59:18.1
      # Source DEC: 24:32:34
      # Pipeline version (DREAMPY): $Rev: 284 $: Last Commit: 23-Jul-2020
      # Driver script version: 0.6.0-pjt
      # Date of Reduction (YYYY-MM-DD): 2021-Nov-05
      # Frequency Units: GHz
      # Spectrum Units: K (T_A)
      # Band intervals (GHz):(73.001-79.595),(85.505-92.099),(79.301-85.895),(91.897-98.491),(104.401-110.995),(98.197-104.791)
      # Sigma per band: 0.001220,0.001292,0.001085,0.001509,0.001587,0.001560
      # Polynomial Baseline Order: 3 
      # Input Observations: 71610_0,71610_1,71610_2,71610_3, 
      # Integration Time: 291.94480924278946 s
      # Average Opacity (220GHz): 0.28 
      # RSR driver cmd: rsr.obsnum --badlags rsr.badlags --rfile rsr.rfile -w rsr.wf.pdf -p -b 3 
      # ------------------------------------------------


PI parameters
-------------

Optional PI parameter can be set for each project, but currently this
has to be set via the pipeline, after the observations. There is no
method yet to inherit this from the observing script.  For some
projects multiple targets may be taken, in which case a parameter such
as **vlsr** makes no sense.  Currently if there is a **PI_pars.rc**
file, it will be sourced. This procedure might change in the future.

Combining ObsNum's
------------------

The **rsr_combine.sh** script accepts a comma separated list of obsnums, 
and re-run the pipeline with the settings of each of the parameter files that
belong to that obsnum.


.. code-block::

      SLpipeline.sh obsnums=33551,71610,92068

the results are available in **2014ARSRCommissioning/33551_92068** and will otherwise look familiar to the
pipeline results of a single obsnum.


