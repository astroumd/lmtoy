# LMT software

1. SpectralLineReduction - for Sequoia, Omaya, 1MMRx (python module:  lmtslr)
2. dreampy3 - for RSR
3. tolteca/citlali - for TolTEC, Muscat and also old Aztec data (not covered here)

First we go through a guided install example. Please see the sections
below if you need more information on the pre-conditions or other
intermediate steps. The script in **docs/install_lmtoy** provides
some paths to the install described below, and it works in most cases
on most machines we've tested (Mac, Linux/Ubuntu and Linux/Redhat8). YMMV.

## Install Example

Instructions for installing **LMTOY**:

0) Pre-conditions: We are assuming you have a python3 
   (e.g. anaconda3) already in your path. We also assume you have a C
   compiler, and that cfitsio and netcdf libraries have been installed 
   (e.g. on a mac via brew).  Things can and will massively and confusingly fail
   if these are not in tip top shape :-)

   For python3 we also provide a manual install of anaconda3 before lmtoy is installed.
   
   Example ubuntu packages:  build-essential gfortran xorg-dev git tcsh cmake pgplot5 libcfitsio-dev autoconf libnetcdf-dev netcdf-bin
   Example centos packages:  gcc-gfortran tcsh gcc-c++ cmake libXext-devel libtirpc-devel netcdf-devel cfitsio-devel

1) Make a small shadow tree of the official $DATA_LMT on your laptop. If not on
   an official machine (cln, wares, lma), use the recommended ~/LMT/data_lmt
   since it is one of the options in configure:

        mkdir -p ~/LMT/data_lmt
        cd ~/LMT/data_lmt

        scp cln:/home/teuben/LMT/rsr_bench.tar.gz  .
        tar zxf rsr_bench.tar.gz
        rm rsr_bench.tar.gz

        scp cln:/home/teuben/LMT/seq_bench.tar.gz  .
        tar zxf seq_bench.tar.gz
        rm seq_bench.tar.gz

   At Umass the machine **cln** has to be used. 
   At UMD the machine **lma** has to be used.

   The SEQ bench is "big" (600MB), if you don't want to use the SLR
   software, skip it.  The RSR bench is small, 33 MB. Their OBSNUM's
   are 33550 and 33551 resp. plus the required **data_lmt/rsr**
   calibration data (also small).
   
   Note that the rsr_bench 2018 data are compressed from the old
   double precision raw data, the uncompressed size will be 1600
   MB. All data in 2020 and before are double precision, but we expect
   data in 2021 and beyond to be in single precision, where the
   compression factor won't be as large.

2) Install LMTOY (e.g. do this within the previously created ~/LMT)

        cd ~/LMT
        wget https://astroumd.github.io/lmtoy/install_lmtoy
        bash install_lmtoy 

   If you are using your own $DATA_LMT, make sure the environment variable
   is set before running the bash above or use, e.g.

        bash install_lmtoy venv=1 data_lmt=/your/data_lmt work_lmt=/your/work_lmt

   This would assume you have a proper python3 in your environment. If
   not, then use the default **venv=0**, and it will install anaconda3 for
   you. This will cost an extra 3.3 GB and a longer download.  For now we
   recommend using the default **nemo=1**, as it's useful to see benchmark
   results, and fully run the "old" pipeline. If you don't care, use **nemo=0**,
   but you'll be missing out.

   The native python3 might work for you, for which venv=1 could be used
   
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
        2018-11-16T06:48:30    79447  Cal   IRC+10216        115.2712   -20       7.8  146.989192  13.278767  115.0  77.1
        2018-11-16T06:48:52    79448  Map   IRC+10216        115.2712   -20     685.8  146.989192  13.278767  115.2  77.2


   You can now go back in the examples directory, and run the two benchmarks:

        cd $LMTOY/examples
        make bench
        make rsr1
		
   Or if you want to run the challenging M51 data (which needs 16GB memory):
   
        make bench51
		
4) To clone a select number of obsnums from a machine that has all raw data to a laptop for faster interaction, use the
   *lmtar* type script.  Obviously you will need an ssh session on one of those machines, and scp data back to your
   laptop.   Here's an example:
	
	
	    cln:  source /home/teuben/lmtoy/lmtoy_start.sh
	    cln:  lmtar.py 79447 79448 
		

   this will list the files that should go into your local $DATA_LMT tree. For each obsnum there should be one ifproc and 4 roach files
   for Sequoia data. For RSR there should be 4, for 1MMRx there should be 2.
   You can use your shell skills to rsync them to your $DATA_LMT, or use the **lmtar** script to make a tar file first:
	
	    cln:  lmtar IRC_bench.tar 79447 79448 
		
   If you gzip this file, it decreases in size from 1600 to 600 MB. 
 

# 1. Installing SpectralLineReduction (old notes)

See also the Makefile, as this has many targets that simplify this, and this is the
method that I've employed on a few machines (Ubuntu, Centos, and a Mac/brew).

Grab the official source

     git glone https://github.com/lmt-heterodyne/SpectralLineReduction
     
or for example another development version (in dec 2020 the better choice)

     git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction

##  Libraries:   cfitsio, netcdf4

These are needed for the gridder program (written in C) **spec_driver_fits**

* Ubuntu20:  sudo apt install libnetcdf-dev netcdf-bin libnetcdf15 libcfitsio-dev
* Ubuntu21:  sudo apt install libnetcdf-dev netcdf-bin libnetcdf18 libcfitsio-dev
* Centos:  sudo yum install netcdf-devel cfitsio
* MacBrew: brew install netcdf cfitsio

If in a bind, e.g. on a system where you don't have admin privilages, you
can always Install from source. E.g. borrow NEMO's $NEO/src/scripts/mknemo.d scripts

     mkdir local
     ./cfitsio wget=wget NEMO=`pwd`
     ./netcdf4 wget=wget NEMO=`pwd`

this will place sources in lmtoy/local, and installed with --prefix=lmtoy/opt

Then

      cd C
      make CFITSIO_PATH=../../lmtoy/opt NETCDF_PATH=../../lmtoy/opt

or if these were installed within NEMO:

      make CFITSIO_PATH=$NEMO/opt NETCDF_PATH=$NEMO/opt

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

NEMO, depending on what you see was updated, may need to have a new executable installed
(the mknemo command can be executed from any directory), e.g.

      mknemo ccdstat ccdfits fitsccd ccdhist ccdsub ccdmath ccdsmooth scanfits ccdmom tabplot tabhist

## Examples

Some examples how to use LMT software are in the examples directory.  The irc_reduce.sh serves as the benchmark,
m31_reduce.sh  and m51_reduce.sh  serve as other "hardcoded" example, but lmtoy_reduce.sh should be able
to reduce any OTF data. There are now also some RSR data reduction methods.   

## LMT machines

The following linux distributions are being used in the consortium (e.g. via the **lsb_release -a** command)

1. malt (LMT) - Ubuntu 18.04.5 LTS (to be upgraded)
2. cln (UMASS) - Ubuntu 16.04.7 LTS
3. unity (UMASS) - Ubuntu 20.04.1 LTS
4. lma (UMD) - CentOS 8.5.2111 - soon to be "Red Hat Enterprise 8.5"
5. T480 (Peter's laptop) - Ubuntu 20.04.3 LTS
6. xps13 (Peter's laptop) - Ubuntu 21.10
7. (Peter's rogue mac) - Mac 10.15.7 w/ brew

# Other packages

A few popular 3rd party tools for cube analysis

* MIRIAD
* karma (viz)
* ds9 (viz):     https://sites.google.com/cfa.harvard.edu/saoimageds9/download - Current version: 8.3
* carta (viz):   https://cartavis.org/
* casa - we still use CASA 5.8 for ADMIT
* RADIO astro tools
  * pip install spectral-cube pyds9 pvextractor
* bettermoments
  * pip install bettermoments
* maskmoment
  * Tony Wong's EDGE scripts https://github.com/tonywong94/maskmoment
* phangs pipeline
