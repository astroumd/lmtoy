SDFITS
======

SDFITS is still a draft standard written up by Liszt (1995), with some more
documentation by Garwood (2000?). Many observatories have implemented it,
but this resulted in a few dialects, notably in the TDIM that is associated
with the DATA:

* LMT  : simple 1-dimensional spectra (our plan)
* GBT  : simple 1-dimensional spectra
* FAST : (4,64k):   pol goes before chan, and NCHAN is a column in the table, so it can vary!
* Parkes: (nchan,2,1,1):   chan goes first, then next pol (not sure if 4 is also available)

Why use SDFITS for LMT?
-----------------------

The idea for LMT is to take a RAW (netCDF) data from the different
Spectral Line instruments, and allow a first pass (TSYS and ON/OFF)
calibration, such that the SDFITS file is a collection of calibrated
spectra, where inspection, baseline subtraction, binning are all done,
and optionally gridding.

Using SDFITS also gives us different paths:

* Use tools in specutils

* Use GBTIDL and/or its python successor

* A variety of gridders (but: dialects)


CLASS
-----

The path from CLASS to SDFITS (and vice versa?) is not well described,
or at least I don't know it, and should be described here.

