# LMT software

1. SpectralLineReduction - for Sequoia
2. dreampy3 - for RSR
3. tolteca/citlali - for TolTEC

# 1. Installing SpectralLineReduction

See also the Makefile, as this has many targets that simplify this, and this is the
method that I've employed on a few machines (Ubuntu, Centos, and a Mac/brew).

Grab the official source

     git glone https://github.com/lmt-heterodyne/SpectralLineReduction
     
or for example another development version (in dec 2020 the better choice)

     git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction

##  Libraries:   cfitsio, netcdf4

These are needed for the gridder program (written in C) **spec_driver_fits**

* Ubuntu:  sudo apt install libnetcdf-dev netcdf-bin libnetcdf15 libcfitsio-dev
* Centos:  sudo yum install netcdf-devel cfitsio
* MacBrew: brew install netcdf cfitsio

If in a bind, e.g. on a system where you don't have admin privilages, you
can always Install from source. E.g. borrow NEMO's $NEO/src/scripts/mknemo.d scripts

     mkdir local
     ./cfitsio wget=wget NEMO=`pwd
     ./netcdf4 wget=wget NEMO=`pwd`

this will place sources in lmtoy/local, and installed with --prefix=lmtoy/opt

Then

      cd C
      make CFITSIO_PATH=../../lmtoy/opt NETCDF_PATH=../../lmtoy/opt

but the Makefile currently also needs

      export LD_LIBRARY_PATH=$(readlink -f ../../lmtoy/opt/lib)

Yuck. Normally you should not need this path.

## python modules

The suggested path is to use a virtual environment. From anaconda3 for example:

     python3 -m venv lmt1

     source lmt1/bin/activate
     pip3 install -r requirements.txt
     #   this will cause a few packages to be compiled, which can take a long time (e.g. scipy)

Alternatively, the old (python2) style virtualenv can be used,
but normally needs to be installed (though it's now recommended to use the venv module)

     pip install virtualenv 
     virtualenv lmt2 
     source lmt2/bin/activate
     pip install -r requirements.txt

Currently requirements.txt are frozen (and by now old) versions, and installing them can take forever
(scipy is notorious).  With you following trick you can strip the version and just grab the latest:

     awk -F= '{print $1}'  requirements.txt > requirements_any.txt

but there is this error

     ERROR: jedi 0.17.2 has requirement parso<0.8.0,>=0.7.0, but you'll have parso 0.8.0 which is incompatible.

but it doesn't seem to hurt the LMT workflow.

Finally, when all this is installed, you can install LMTSLR, e.g.

      pip install -e .

There is no official runtime environment.   If you use lmtoy, via configure and the suggested method to
install LMTSLR we have constructed lmtoy_start.sh after you run the configure script. See the Makefile for
an example.

## Virtual Environment?

I had some strange experiences with a python venv.  For one, any bins that are not in setup.py (e.g. a new one)
could not be executed. Made no sense, since it's in my path, and /usr/bin/env python  even pointed to the venv.
I gave up.

### Updates

Since we run from a set of github repos, each with their own update procedures, here some reminders.

To update all repos:

      make pull

lmtoy needs no extra work, if you see updates.

lmtslr needs no extra work, since we installed using the -e flag in pip.

NEMO, depending on what you see, may need to have a new
executable installed, e.g.

      mknemo ccdstat ccdfits fitsccd ccdhist

For montage, I would use

      make install_montage

That should keep your environment up to date.
      
## Examples

Some examples how to use LMTSLR are in the examples directory.
