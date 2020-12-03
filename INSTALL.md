# LMT software

1. SpectralLineReduction - for Sequoia
2. dreampy3 - for RSR
3. tolteca/citlali - for TolTEC

# 1. Installing SpectralLineReduction

Grab the source

     git glone https://github.com/lmt-heterodyne/SpectralLineReduction
or
     git glone https://github.com/teuben/SpectralLineReduction


##  Libraries:   cfitsio, netcdf4

These are needed for the gridder program (written in C) spec_driver_fits

* Ubuntu:  sudo apt install libnetcdf-dev netcdf-bin libnetcdf15
* Centos:  yum install ...

Installing from source ?   Can borrow NEMO's $NEO/src/scripts/mknemo.d scripts

     mkdir local
     ./cfitsio wget=wget NEMO=`pwd
     ./netcdf4 wget=wget NEMO=`pwd`

this will place sources in lmtoy/local, and installed with --prefix=lmtoy/opt

Then

      cd C
      make CFITSIO_PATH=../../lmtoy/opt NETCDF_PATH=../../lmtoy/opt

but the Makefile currently also needs

      export LD_LIBRARY_PATH=$(readlink -f ../../lmtoy/opt/lib)

Yuck.

## python modules


The suggested path is to use a virtual environment. From anaconda3 for example:

     python -m venv lmt1

     source lmt1/bin/activate
     pip install -r requirements.txt
     #   this will cause a few packages to be compiled, which can take a long time (e.g. scipy)

Alternatively, virtualenv can be used, but needs to be installed (though it's now recommended to use the venv module)

     pip install virtualenv 
     virtualenv lmt2 
     source lmt2/bin/activate
     pip install -r requirements.txt     

With the "any" version, stripping the module versions from requirements.txt, install is much faster
but there is this error

     ERROR: jedi 0.17.2 has requirement parso<0.8.0,>=0.7.0, but you'll have parso 0.8.0 which is incompatible.

