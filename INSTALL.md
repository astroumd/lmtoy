# LMT software

1. SpectralLineReduction - for Sequoia, Omaya, 1MMRx
2. dreampy3 - for RSR
3. tolteca/citlali - for TolTEC, Muscat and also old Aztec data
   (not covered here)

First we go through a guided install example. Please see the sections
below if you need more information on the pre-conditions or other
intermediate steps. The script in **docs/install_lmtoy** provides
paths to the install described below, and it works in most cases
on most machines we've tested (Mac, Linux).

## Install Example

Instructions for installing **LMTOY**:

0) Pre-conditions: We are assuming you have a python3 development like
   anaconda3 already in your path. We also assume you have a C
   compiler, and that cfitsio and netcdf libraries have been installed 
   (e.g. on a mac via brew).  Things can and will massively and confusingly fail
   if these are not in tip top shape :-)

   We have silently assumed the command python is a python3. Another failure mode.


1) Make a small shadow tree of the official $DATA_LMT on your laptop. If not on
   an official machine (cln, wares, lma), use the recommended ~/LMT/data_lmt:

        mkdir -p ~/LMT/data_lmt
        cd ~/LMT/data_lmt

        scp cln:/home/teuben/LMT/RSR_bench.tar.gz  .
        tar zxf RSR_bench.tar.gz
        rm RSR_bench.tar.gz

        scp cln:/home/teuben/LMT/IRC_bench.tar.gz  .
        tar zxf IRC_bench.tar.gz
        rm IRC_bench.tar.gz

   At Umass the machine **cln** has to be used. 
   At UMD the machine **lma** has to be used.

   The IRC bench is "big" (600MB), if you don't want to use the SLR
   software, skip it.  The RSR bench is small, 33 MB. Their OBSNUM's
   are 79448 and 33551 resp. plus the required **data_lmt/rsr**
   calibration data (also small).
   
   Note that the 2018 IRC_bench data are compressed from the old
   double precision raw data, the uncompressed size will be 1600
   MB. All data in 2020 and before are double precision, but we expect
   data in 2021 and beyond to be in single precision, where the
   compression factor won't be as large.

2) Install LMTOY (e.g. do this within the previously created ~/LMT)

        wget https://astroumd.github.io/lmtoy/install_lmtoy
        bash install_lmtoy venv=1 nemo=1

   This would assume you have a proper python3 in your environment. If
   not, then use the default **venv=0**, and it will install anaconda3 for
   you. This will cost an extra 3.3 GB and a longer download.  For now we
   recommend using the default **nemo=1**, as it's useful to see benchmark
   results, and fully run the "old" pipeline. If you don't care, use **nemo=0**.

   The native python3 might work for you, for which venv=1 should be used
   
   Known native python3 packages for common systems:

   Ubuntu:    python3 python-is-python3 python3-pip python3-numpy python3-matplotlib python3-venv
   Centos:
   Mac/Brew:

3) After the install, your shell needs the following command to activate LMTOY:

        source lmtoy/lmtoy_start.sh

   and to see what data you have in $DATA_LMT, try this (but not at a place where $DATA_LMT is huge):
   
        lmtinfo.py $DATA_LMT

        # Y-M-D   T H:M:S     ObsNum ObsPgm SourceName       RestFreq  VLSR    TSKY     RA        DEC          AZ    EL
        2015-01-21T23:12:07    33550  Cal   I10565               RSR      0      39.5  164.825417  24.542778   74.3  51.6
        2015-01-21T23:12:07    33551  Bs    I10565               RSR      0     319.5  164.825417  24.542778   74.3  51.9
        2018-11-16T06:48:30   079447  Cal   IRC+10216        115.2712   -20       7.8  146.989192  13.278767  115.0  77.1
        2018-11-16T06:48:52   079448  Map   IRC+10216        115.2712   -20     685.8  146.989192  13.278767  115.2  77.2


   You can now go back in the examples directory, and run the two benchmarks:

        cd $LMTOY/examples
        make bench
        make rsr1
		
   Or if you want to run the challenging M51 data (which needs 16GB memory):
   
        make bench51


# 1. Installing SpectralLineReduction (old notes)

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

Warning up front: this can be confusing. There are several ways
how to install it in "your" python, but we also have a built-in way
to do this It requires some deeper knowledge how python works, but the
current default is a completely self-contained python via anaconda3.

The suggested path is to use a virtual environment. This allows you to
piggy back on top of your system version of python. From anaconda3 for example:

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
I gave up, I bypass venv and install directly. This is a bit easier in a locally grown anaconda3. YMMV.

### Updates

Since we run from a set of github repos, each with their own update procedures, here some reminders.

To update all repos, you will need to run "git pull" in each of them. For convenience we have a shortcut,
all executed from $LMTOY:

      cd $LMTOY
      make pull

lmtoy needs no extra work, if you see updates, since at moment everything is "in place". This may change.

lmtslr needs no extra work, since we installed using the -e flag in pip. But if the C program was
updated, it's safe to do this:

      make install_lmtslr

NEMO, depending on what you see, may need to have a new
executable installed, e.g.

      mknemo ccdstat ccdfits fitsccd ccdhist ccdsub ccdmath ccdsmooth ccdmom scanfits tabplot tabhist

For montage, I would use

      make install_montage

That should keep your environment up to date. Note we currently don't use Montage yet, so you can skip this.

      
## Examples

Some examples how to use LMT software are in the examples directory.  The irc_reduce.sh serves as the benchmark,
m31_reduce.sh  and m51_reduce.sh  serve as other "hardcoded" example, but lmtoy_reduce.sh should be able
to reduce any OTF data. There are now also some RSR data reduction methods.   

# Other packages

A few popular 3rd party tools for cube analysis

* MIRIAD
* karma
* casa
* radio astro tools
  * pip install spectral-cube pyds9 pvextractor
* bettermoments
  * pip install bettermoments
* maskmoment
  * Tony's EDGE scripts https://github.com/tonywong94/maskmoment
