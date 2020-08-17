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


* Redshift Search Receiver
  * [dreampy3](https://github.com/lmt-heterodyne/dreampy3)
- LMT heterodyne (SEQUOIA and OMAyA)
- TolTEC



## References

* [pycdf](http://pysclint.sourceforge.net/pycdf)

