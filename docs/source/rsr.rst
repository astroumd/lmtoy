RSR via the SLpipeline
======================

Here we summarize the current (nov 2021) status of data reduction for the RSR. The invocation would be

.. code-block::

      SLpipeline obsnum=33551

The current **SLpipeline.sh** will currently run a few scripts for a single obsnum:

1. **seek_bad_channels.py**:  this will identify the bad lags, and store them in a **rsr.badlags** file. This file
   should be inspected (see the **sbc.png** plot). Options:

2. **rsr_driver.py**:

3. **rsr_sum.py**:

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

The final spectrum is a band merged spectrum covering from about  73 GHz to 110 GHz, in 6 bands. The average is over the 4 chassis and
a small number (5-10) of integrations. The typical integration time per sample is about 30 seconds. Here is a typical header
of a final spectrum:

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

Optional PI parameter can be set for each project, but currently this has to be set via the pipeline,
after the observations. There is no method yet to inherit this from the observing script.
For some projects multiple targets may be taken, in which case a parameter such as **vlsr** makes
no sense.  Currently if there is a **PI_pars.rc** file, it will be sourced. This procedure will likely
change in the future.

Combining ObsNum's
------------------

Although not officially supported yet, the **rsr_combine.sh** script will take all the
parameter file, and re-run the pipeline with these ranges of obsnums.



.. code-block::

      rsr_combine.sh obsnum=33551,71610,92068

the results are available in **2014ARSRCommissioning/33551_92068** and will otherwise look familiar to the
pipeline results of a single obsnum.


