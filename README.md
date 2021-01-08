# lmtoy

LMTOY is your toy box for installing and running codes related to LMT data reduction. LMT is a large
50m single dish radio telescope located in Mexico (18:59:09N 97:18:53W) operating at mm wavelengths.


## DATA

LMT raw telescope data are (mostly) in netCDF format (extension: .nc), which stores
data hierarchically in a big binary blob, much like HDF5.
A typical LMT observation consists of a about 10 files
in a specific directory hierarchy, all identified via an OBSNUM. 

Tools like **ncdump** display structure and contents (as
CDL). Careful, hdf5 also contains **ncdump** but it differs in subtle
ways.

A simple way to get at the raw data is the following:

      import netCDF4
      nc = netCDF4.Dataset(filename)
      rawdata = nc.variables['Data.Integrate.Data'][:]
      nc.close()

where **rawdata** is now a 2D array, shaped (ntime,nchan) in the python sense (nchan runs fastest).
The LMT software will typically calibrate and convert these data to the more common FITS format.


# LMT software

LMT software is very instrument specific:


* LMT heterodyne: SEQUOIA, MSIP 1mm and OMAyA
  * [LMTSLR](https://github.com/lmt-heterodyne/SpectralLineReduction)   (SpectralLineReduction)  

* RSR (Redshift Search Receiver)
  * [dreampy3](https://github.com/lmt-heterodyne/dreampy3)

* TolTEC
  * TolTecA
  * CitLali
  * Dash

* MUSCAT: 1mm camera (Mexico-UK)
  *  4' FOV with 5.5" resolution

## Installation

There are some expanded notes in [INSTALL.md](INSTALL.md), and also check out the
Makefile for specific targets that simplify the install. Probably the most automated/simple
way to install (if you have all the preconditions, most importandly the **cfitsio** and **netcdf** library) is:

      wget https://astroumd.github.io/lmtoy/install_lmtoy
      bash install_lmtoy

if this worked, activate it in your shell

      source lmtoy/lmtoy_start.sh

Now you can place the benchmark data in for example ~/LMT/IRC_data, or in UMass you
can make a symlink to the big data disk

      cd $LMTOY/examples

pick the appropriate one for you:

      ln -s /data/LMT/lmt_data  IRC_data
      ln -s ~/LMT/IRC_data
      tar zxf /n/chara/teuben/LMT/IRC_data.tar.gz

after which you can run a benchmark to verify if LMTSLR is working

      make bench

and it will print two lines starting with QAC_STATS that should agree! Another useful
test is plotting:

      make bench2

This should produce three plots.

In your own directory you can use the more general **lmtoy_reduce.sh** script

      $LMTOY/examples/lmtoy_reduce.sh path=/data/LMT/lmt_data  obsnum=79448

(again with the appropriate **path=**) to analyse any dataset. It will produce
a file **lmtoy_79448.rc** which you can edit and re-run the script to finetune.


## References

* [pycdf](http://pysclint.sourceforge.net/pycdf)
* [dash](https://dash.plotly.com/) or [plotly dash](https://plotly.com/dash/)
  *  https://alpha.iodide.io/      Doing datascience in your browser
* [sdfits](https://fits.gsfc.nasa.gov/registry/sdfits.html) and https://github.com/timj/aandc-gsdd
* VO links:
  * [2019 radio hackathon](https://www.asterics2020.eu/dokuwiki/doku.php?id=open:wp4:wp4techforum5:radiointhevo) - has several VO presentations and links to VO standards
  * IVOA meetings (spring 2020 onwards)
  * A precursor in [gbtoy}(https://github.com/teuben/gbtoy)

