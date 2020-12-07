# lmtoy

Toy Codes for LMT , not to be confused with https://github.com/teuben/gbtoy

## Installation

This is not finalized yet, there are some notes in [INSTALL.md](INSTALL.md). This is still a toy monorepo.

## data

LMT data are (mostly) in netCDF format (extension:  .nc), which stores data hierarchically in a big binary blob. Much like how HDF5 stores data.

Tools like **ncdump** display structure and contents (as CDL). Careful, hdf5 also contains **ncdump** but it differs in subtle ways.

A simple way to get at the raw data is the following:

      import netCDF4
      nc = netCDF4.Dataset(filename)
      rawdata = nc.variables['Data.Integrate.Data'][:]
      nc.close()

where **rawdata** is now a 2D array, shaped (ntime,nchan) in the python sense (nchan runs fastest).


# LMT software

Is very instrument specific:


* RSR (Redshift Search Receiver)
  * [dreampy3](https://github.com/lmt-heterodyne/dreampy3)
- LMT heterodyne: SEQUOIA and OMAyA
  * [LMTSLR](https://github.com/lmt-heterodyne/SpectralLineReduction)   (SpectralLineReduction)  
- TolTEC
  * TolTecA
  * CitLali
  * Dasha


## References

* [pycdf](http://pysclint.sourceforge.net/pycdf)
* [dash](https://dash.plotly.com/) or [plotly dash](https://plotly.com/dash/)
  *  https://alpha.iodide.io/      Doing datascience in your browser
* [sdfits](https://fits.gsfc.nasa.gov/registry/sdfits.html) and https://github.com/timj/aandc-gsdd
* VO links:
  * [2019 radio hackathon](https://www.asterics2020.eu/dokuwiki/doku.php?id=open:wp4:wp4techforum5:radiointhevo) - has several VO presentations and links to VO standards
  * IVOA meetings (spring 2020 onwards)
