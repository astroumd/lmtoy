# lmtoy

LMTOY is a toy box for installing and running codes related to LMT data reduction. 
LMT is a large 50m single dish radio telescope located in Mexico 
[(18:59:09N 97:18:53W)](https://www.google.com/maps/place/Large+Millimeter+Telescope/@18.9841105,-97.3258267,6245m/data=!3m1!1e3!4m5!3m4!1s0x85c516fb67a4820f:0xf9b66dcc651fb6e9!8m2!3d18.9857333!4d-97.3148183)
operating at mm wavelengths.


## DATA

LMT raw telescope data are (mostly) in netCDF-3 format (extension: .nc), which stores
data hierarchically, name and type tagged.
A typical LSR observation consists of a number of netCDF files in a specific directory hierarchy, starting at
$DATA_LMT, and all identified via a 7 digit OBSNUM.  Different instruments
use a different number of datasets, for example, RSR uses up to 9, LSR uses 10.

Tools like **ncdump** display structure and contents (as CDL).

A simple example to get at the raw data is the following:

      import netCDF4
      nc = netCDF4.Dataset(filename)
      rawdata = nc.variables['Data.Integrate.Data'][:]
      nc.close()

where **rawdata** is now a 2D array, shaped (ntime,nchan) in the python sense (nchan runs fastest).
The LMT software will typically calibrate and convert (grid) these data to the more common FITS format.


# LMT software

LMT software is very instrument specific:


* LMT heterodyne: SEQUOIA, MSIP 1mm and OMAyA
  * [LMTSLR](https://github.com/lmt-heterodyne/SpectralLineReduction)   (SpectralLineReduction)  

* RSR (Redshift Search Receiver)
  * [dreampy3](https://github.com/lmt-heterodyne/dreampy3)
  * [RSR_driver](https://github.com/LMTdevs/RSR_driver)

* TolTEC (later in 2021) - [private](https://github.com/toltec-astro)
  * TolTecA
  * CitLali
  * Dash

* MUSCAT: 1mm camera (Mexico-UK)
  *  4' FOV with 5.5" resolution
  *  Will use TolTecA


## Installation

There are some expanded notes in [INSTALL.md](INSTALL.md), and also check out the
Makefile for specific targets that simplify the install and updates. Probably the most automated/simple
way to install (if you have all the preconditions, most importantly the **cfitsio** and **netcdf** library) is:

      wget https://astroumd.github.io/lmtoy/install_lmtoy
      bash install_lmtoy

if this worked, activate it in your shell:

      source lmtoy/lmtoy_start.sh

If this failed, follow the steps in the script and find our where/when it failed. At the end of the script it
will have tried to run an SLR and RSR benchmark. This could fail if you don't have the data in the
$DATA_LMT directory. For example:

      cd $DATA_LMT
      tar zxf /n/chara/teuben/LMT/IRC_data.tar.gz
      lmtinfo.py $DATA_LMT 79488

after which you can run a benchmark to verify if LMTSLR is working

      cd $LMTOY/examples
      make bench

and it will print two lines starting with QAC_STATS that should agree! Another useful
test is plotting:

      make bench2

This should produce three plots.


In your own directory you can use the more general **lmtoy_reduce.sh** script

      $LMTOY/examples/lmtoy_reduce.sh obsnum=79448

to analyse any dataset. It will produce
a file **lmtoy_79448.rc** which you can edit and re-run the script to finetune
its settings. After a large number of OBSNUM's have been reduce this way, they
can be combined (stacked) using **lmtoy_combine.sh**. A description of these
steps can be seen in 
[lmtoy_reduce.md](examples/lmtoy_reduce.md).

## References

* [pycdf](http://pysclint.sourceforge.net/pycdf)
* [dash](https://dash.plotly.com/) or [plotly dash](https://plotly.com/dash/)
  *  https://alpha.iodide.io/      Doing datascience in your browser
* [sdfits](https://fits.gsfc.nasa.gov/registry/sdfits.html) and https://github.com/timj/aandc-gsdd
* Various related:
  * [cygrid](https://github.com/bwinkel/cygrid) - Effelsberg group
  * [HCGrid](https://github.com/HWang-Summit/HCGrid) - FAST group
  * [gbtgridder](https://github.com/GreenBankObservatory/gbtgridder) - GBT
  * [SD gridder](https://github.com/tvwenger/sdgridder) - Trey Wenger
  * [destriper](https://github.com/low-sky/destriper)
  * [sdpy](https://github.com/keflavich/sdpy) - Ginsburg
  * [otfmap](https://github.com/low-sky/otfmap) - Rosolowsky
* VO links:
  * [2019 radio hackathon](https://www.asterics2020.eu/dokuwiki/doku.php?id=open:wp4:wp4techforum5:radiointhevo) - has several VO presentations and links to VO standards
  * IVOA meetings (spring 2020 onwards)
  * A precursor in [gbtoy}(https://github.com/teuben/gbtoy)

