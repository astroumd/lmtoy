Useful third party tools
========================

Here we list some potentially useful tools you might need to install
in your environment for advanced analysis of your LMT spectra. They are
not supported by LMTOY, but we have installation guidelines and
examples of usage for some of them.

Gridders
--------

Although we have our own gridder (in C), gridding and krigins are a cottage industry.
Where appropriate, we will describe which ones are of interest to us in this toolbox.

* cygrid (Effelsberg)

* HCGrid (FAST)

* gbtgridder

* SD gridder (Wenger)

* otfmap (Rosolowsky)


LineStacker
-----------


https://github.com/jbjolly/LineStacker          2020MNRAS.499.3992J 


SpecUtils
---------

`specutils <https://specutils.readthedocs.io/en/stable/>`_,
one of the astropy packages, had a number of tools that are likely useful
for post calibration analysis of LMT spectra. We have an SDFITS loader
in our previous GBTOY toolbox.

NEMO
----

Since NEMO is used for some of the infrastructure in LMTOY, there are a number
of tools that could be useful for specific projects. Apart from **tabplot** and
**tabhist**, the **nemopars** and **nemoplot** programs might be the most
useful tools.


NEMO 101
~~~~~~~~

Here's a very brief reminder on the quirky things of NEMO:

- NEMO has a large number of programs that are often combined through Unix pipes
- programs use a series of "keyword=value" command line arguments
- programs have a man page, e.g.  "man tabhist", for online help
- programs have -h, --help, help=h, help=M etc. for inline help
- program keywords don't need the "keyword=" part if given in the correct
  order, as shown with "-h"
- programs also have system keyword, like help=. They are not listed with help=,
  since each program has them. The important ones are:

  - help= has a few options (use help=? to see them)
  - yapp= designates what plotting (Yet Another Plotting Package) device is used.
  
    - pgplot interface uses things like yapp=1/xs, 2/xs, fig1.png/png etc.
    
  - debug= increases the debug level. 0 is the default, 1 has more, -1 would make it really silent etc.
  - error= allows you to bypass normally fatal error message, use at your own risk though!
  
- recompiling a program can often be done with **mknemo**, e.g. "mknemo tabhist", equally so
  for selected libraries, e.g. "mknemo cfitsio", would recompile.

nemopars
~~~~~~~~

Since the SLpipeline produces an **lmtoy_OBSNUM.rc** in each **OBSNUM** directory,
the **nemopars** program can effectively be used quite to extract values and table them up.
Here is an example to make a histogram of all **tau** values for a selected *ProjectId*:

.. code-block::

     cd $WORK_LMT/2021-S1-MX-3
     nemopars tau ?????/lmtoy_*.rc ?????/lmtoy_*.rc | tabhist -
     nemopars obsnum,tau ?????/lmtoy_*.rc ?????/lmtoy_*.rc | tabplot - point=2,0.1

nemoplot
~~~~~~~~

To easily reproduce certain plots from an existing table, the **nemoplot** program can do this
by executing the selected line starting with **#PLOT** in a table (or any file), e.g.

.. code-block::

      nemoplot $NEMO/scripts/csh/mkmh97.sh plot=1
      nemoplot $NEMO/scripts/csh/mkmh97.sh plot=2

This is a somewhat odd example from NEMO's stellar dynamics
universe where this plot is actually computed, but once we have an example
in LMTOY, we'll put that here instead!
