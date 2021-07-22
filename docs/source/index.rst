
LMT
===

.. note:: A local version of this documentation can be found on
   https://www.astro.umd.edu/~teuben/LMT/lmtoy/html

LMTOY is a toy box for installing and running codes related to LMT
data reduction. LMT is a large 50m single dish radio telescope located
in Mexico (18:59:09N 97:18:53W) operating at mm wavelengths.
http://lmtgtm.org/

This document described the current toy box of LMT tools that you might
want to use to reduce LMT data.   It will cover most Spectral Line instruments
(Sequioa, RSR, 1MM, B4R), but does not discuss continuum instruments.

The source code is available via https://github.com/astroumd/lmtoy which describes
how to assemble the toolbox with the help of a number of codes. We also use the
`github issue tracker <https://github.com/astroumd/lmtoy/issues>`_ for all things
related to the toolbox.


For Developers
==============

If you plan to try out the code, you may want to inspect the ``docs/install_lmtoy``
file from the **lmtoy** github repo. Here's an example how to install using it:

.. code-block:: sh
  
   wget https://astroumd.github.io/lmtoy/install_lmtoy
   bash install_lmtoy 

This example script is not very long, is fairly self-documenting, should work on most Linux and Mac machines.
It has a few optional command line parameters.  Here is an example of installing it on a laptop with a local
version of ``$DATA_LMT``:

.. code-block:: sh

    bash install_lmtoy data_lmt=~/LMT/data_lmt bench=/n/chara/teuben/LMT/irc_2018.tar.gz

with an example of where we keep the IRC benchmark data at UMD.  After this was installed, the pipeline can be
run as follows:

.. code-block:: sh

    source lmtoy_start.sh
    SLpipeline.sh obsnum=79448

after which all the artifacts can be found in the directory ``2018S1SEQUOIACommissioning/79448``.
   

API
=== 

This is where the API can be found

.. toctree::
   :maxdepth: 2

   api
   lmtslr <lmtslr.api>
   dreampy3 <dreampy3.api>
   workflow

Various
=======
.. toctree::
   :maxdepth: 2
      
   sdfits
   tools
   glossary
   FAQ

Markdowns	      
=========

Some of the documentation is still in markdown format

.. toctree::
   :maxdepth: 2

   masking
   wishlist

LMTOY_REDUCE
============

.. toctree::
   :maxdepth: 3

   reduce

Indices
=======

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

Credits
=======
``lmtoy`` is developed by ...

This project is supported by NSF ...

.. include:: lastmod.rst
