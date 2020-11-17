# lmtoy

Toy Codes for LMT , not to be confused with https://github.com/teuben/gbtoy


## data

LMT data are (mostly) in netCDF format (extension:  .nc), which stores data hierarchically in a big binary blob. Much like how HDF5 stores data.
There is a good python interface.  For anaconda3 you can simply use

      import netCDF4

and maybe something like this ?

      f = MFDataset("roach0/*nc")

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
