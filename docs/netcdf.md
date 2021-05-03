# SD data formats

There is the old SDFITS standard, there is a NETCDF format by LMT, and
a few others (see our old GBTOY discussion paper).

On the simplest level, the SD format is just a series of spectra with
meta-data. Although 99% of the data is in the spectra, it's takes 99%
of effort to understand and properly use the 1% of meta-data. Example:

     ra,dec,pol,pol,var1,var2,varN,data[nchan]

The SDFITS format codifies some standard (e.g. RA, DEC) and optional meta-data.


# netCDF

The LMT uses NETCDF as the raw format, and although this is not going to change, here I would like to
constrast some typical operations in NETCDF and a few others in both python and C, since those are the
two languages we use. So typically we want a "getter" and "setter" for a simple variable, like a float,
and a more complex one, a (null terminated?) string. In particular the latter seemed overly complex
to me in NETCDF, maybe they are viewing is as an array of characters, which make I/O for programmers
overly complex as it requires two steps.

NETCDF also comes with some nice properties, such as units, as can be viewed with the correct
ncdump program.

     dimensions:
        time = UNLIMITED ; // (529 currently)
        nspec = 364314 ;
        nchan = 590 ;
        nlabel = 20 ;
        nhist = 512 ;
     variables:
        char Header.Version(nlabel) ;
        char Header.History(nhist) ;
        int Header.Obs.ObsNum ;
	double Data.TelescopeBackend.TelTime(time) ;
	   Data.TelescopeBackend.TelTime:units = "sec" ;
           Data.TelescopeBackend.TelTime:long_name = "Tel time" ;
     data:
        Header.Version = "10-jan-2021" ;
        Header.Obs.ObsNum = 91112 ;
        Data.TelescopeBackend.TelTime = 1582178610.55127, 1582178610.55927,
	   ...
           1582178617.61027, 1582178617.61827, 1582178617.63027 ;
