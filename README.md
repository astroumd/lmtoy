# lmtoy

LMTOY is your toy box for installing and running codes related to LMT data reduction. LMT is a large
50m single dish radio telescope located in Mexico (18:59:09N 97:18:53W) operating at mm wavelenghts.


## data

LMT telescope data are (mostly) in netCDF format (extension: .nc), which stores
data hierarchically in a big binary blob, much like HDF5.
Actually, a typical LMT observation consists of a about 10 files
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
way to install (if you have all the preconditions) is:

      wget https://astroumd.github.io/lmtoy/install_lmtoy
      bash install_lmtoy

if this worked, activate it in your shell

      source lmtoy/lmtoy_start.sh

and to run an example, try something like (in any directory)

      $LMTOY/examples/lmtoy_reduce.sh path=/lmt_data  obsnum=79448

this particular example is also the OTF benchmark. If you want to run this to check
if the numbers agree:

      cd $LMTOY/examples
      ln -s /lmt_data IRC_data
      make bench

and it will print two lines starting with QAC_STATS that should agree!


## References

* [pycdf](http://pysclint.sourceforge.net/pycdf)
* [dash](https://dash.plotly.com/) or [plotly dash](https://plotly.com/dash/)
  *  https://alpha.iodide.io/      Doing datascience in your browser
* [sdfits](https://fits.gsfc.nasa.gov/registry/sdfits.html) and https://github.com/timj/aandc-gsdd
* VO links:
  * [2019 radio hackathon](https://www.asterics2020.eu/dokuwiki/doku.php?id=open:wp4:wp4techforum5:radiointhevo) - has several VO presentations and links to VO standards
  * IVOA meetings (spring 2020 onwards)
  * A precursor in [gbtoy}(https://github.com/teuben/gbtoy)

