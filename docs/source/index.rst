
LMT
===

.. note:: A local version of this documentation can be found on
   https://www.astro.umd.edu/~teuben/LMT/lmtoy/html

LMTOY is a toolbox for installing and running codes related to
Large Millimeter Telescope (LMT)
data reduction. LMT is a large 50m single dish radio telescope located
in Mexico
`(18:59:09N 97:18:53W) <https://www.google.com/maps/place/Large+Millimeter+Telescope/@18.9857201,-97.315979,1233m/data=!3m1!1e3!4m5!3m4!1s0x85c516fb67a4820f:0xf9b66dcc651fb6e9!8m2!3d18.9857333!4d-97.3148183>`_
operating at mm wavelengths.
http://lmtgtm.org/

This document describes the current toolbox of LMT tools that you might
want to use to reduce LMT data.   It will cover most Spectral Line instruments
(Sequioa, RSR, 1MM, B4R), but currently does not discuss continuum instruments.

The source code is available via https://github.com/astroumd/lmtoy which describes
how to assemble the toolbox with the help of a number of existing
codes. We also use the
`github issue tracker <https://github.com/astroumd/lmtoy/issues>`_ for all things
related to the toolbox.


Installation
============

If you plan to try out the code, you may want to inspect or use the
``docs/install_lmtoy`` script from the **lmtoy** github repo. Here's
an example how to install using it:

.. code-block:: sh
  
   wget https://astroumd.github.io/lmtoy/install_lmtoy
   bash install_lmtoy 

This example script is not very long, is fairly self-documenting, and
should work on most Linux and Mac machines.  It has a few optional
command line parameters. 
Here is an example of installing it with an
already populated ``$DATA_LMT`` data directory:

.. code-block:: sh

    bash install_lmtoy data_lmt=/lma1/lmt/data_lmt 

After this was installed, the pipeline can be activated and executed as follows:

.. code-block:: sh

    source lmtoy_start.sh
    SLpipeline.sh obsnum=79448

After this the data products can be found in the directory
``2018S1SEQUOIACommissioning/79448``. Currently by default the script
runs the pipeline for obsnum=33551 (an RSR example) and obsnum=79448
(a Sequoia example), and the results are under ``$WORK_LMT``.
   


Spectral Line Reduction
=======================

Here is most of the manual

.. toctree::
   :maxdepth: 2
      
   workflow
   sdfits
   fits
   tools
   pipeline
   glossary
   FAQ


Sequoia pipeline
================

This old markdown will be converted to official rst.

.. toctree::
   :maxdepth: 2

   reduce

RSR pipeline
============

.. toctree::
   :maxdepth: 2

   rsr

Pointing
========

.. toctree::
   :maxdepth: 2

   pointing

Data and TAPs
=============

.. toctree::
   :maxdepth: 2

   TAP


Markdowns	      
=========

Some of the old documentation is still in markdown format, and
often contain just notes.  Here we attempt to include them
automagically

.. toctree::
   :maxdepth: 2

   masking
   wishlist
   unity
	      

Notebook: SLR_example
=====================

Here are some jupyter notebooks, automatically included by sphinx.

.. toctree::
   :maxdepth: 2

   SLR_example

API
=== 

This is where the API can eventually be found, but there is not much there yet.

.. toctree::
   :maxdepth: 2

   api
   lmtslr <lmtslr.api>
   dreampy3 <dreampy3.api>

History
=======

Instruments and LMT have undergone various transformations, and especially
when LMT was upgraded with a extra ring, making the dish from effectively
a 32m telescope to a 50m telescope. This occured somewhere in feb/mar 2018.

Indices
=======

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

Credits
=======
``lmtoy`` is developed by ...

This project is supported by NSF ...

.. if this last file is missing, that's ok

.. include:: lastmod.rst
