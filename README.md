# lmtoy

LMTOY is a toolbox (a mono repository if you wish) for installing 
and running codes related to LMT spectral line data reduction.

LMT is a large 50m single dish radio telescope located in Mexico 
[(18:59:09N 97:18:53W)](https://www.google.com/maps/place/Large+Millimeter+Telescope/@18.9841105,-97.3258267,6245m/data=!3m1!1e3!4m5!3m4!1s0x85c516fb67a4820f:0xf9b66dcc651fb6e9!8m2!3d18.9857333!4d-97.3148183)
at an altitude of 4600m,
operating at mm wavelengths. See also http://lmtgtm.org/



# LMT software

LMT software is very instrument specific, but LMTOY only supports a few.


* LMT heterodyne: SEQUOIA, MSIP1MM and the future OMAyA
  * [LMTSLR](https://github.com/lmt-heterodyne/SpectralLineReduction)   (SpectralLineReduction)
  * dvpipe

* RSR (Redshift Search Receiver)
  * [dreampy3](https://github.com/lmt-heterodyne/dreampy3)
  * [RSR_driver](https://github.com/LMTdevs/RSR_driver)

* TolTEC - [private](https://github.com/toltec-astro) - no LMTOY support
  * TolTecA
  * CitLali
  * Dash
  
* B4R (2mm = ALMA band 4) - no LMTOY support
  * [B4R](https://github.com/b4r-dev)

* MUSCAT: 1mm camera (Mexico-UK) - no LMTOY support
  *  4' FOV with 5.5" resolution
  *  Will use TolTecA
  
* CHARM ( <1mm) RAL space (Mexico-UK ) - no LMTOY support
  * 345 GHz


## Installation

There are expanded notes in [INSTALL.md](INSTALL.md), and also check
out the Makefile for specific targets that simplify the install and
updates. Probably the most automated/simple way to install (if you
have all the preconditions, most importantly the **cfitsio**,
**netcdf** and **pgplot** library) is:

      wget https://astroumd.github.io/lmtoy/install_lmtoy
      bash install_lmtoy

if this [worked](install_results.md), activate it in your terminal/shell:

      source lmtoy/lmtoy_start.sh
	  
Assuming you have the raw data in your $DATA_LMT tree,
you can check an RSR benchmark with the following shell command

      lmtinfo.py 33551
	  
you can proceed running the SLpipeline, again from the terminal:

      SLpipeline.sh obsnum=33551
	  
and a Timely Analysis Products (TAP) can be viewed in the
2014ARSRCommissioning/33551 directory, or view a version we have
online in
https://www.astro.umd.edu/~teuben/LMT/live/2014ARSRCommissioning/33551/

The sequoia benchmark is **obsnum=79448**


## DATA

LMT raw telescope data are (mostly) in netCDF-3 format (extension: .nc), which stores
data hierarchically, name and type tagged.
A typical SLR observation consists of a number of netCDF files in a specific directory hierarchy, starting at
$DATA_LMT, and all identified via a 7 digit OBSNUM.  Different instruments
use a different number of datasets, for example, RSR uses up to 8, SLR uses 10.

Tools like **ncdump** display structure and contents (as CDL).

The LMTOY software will typically calibrate and convert (grid) these data to the more common FITS format.


## Manual

A manual is in preparation. Here is a link of which the contents changes faster than
the github source. At the bottom of the index page it lists the last built time.
https://www.astro.umd.edu/~teuben/LMT/lmtoy/html
       

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
  * pyInterpolate - an example generic kriging method
* VO links:
  * [2019 radio hackathon](https://www.asterics2020.eu/dokuwiki/doku.php?id=open:wp4:wp4techforum5:radiointhevo) - has several VO presentations and links to VO standards
  * IVOA meetings (spring 2020 onwards)
  * A precursor in [gbtoy}(https://github.com/teuben/gbtoy)

