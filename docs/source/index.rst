
LMT
===

LMTOY is a toy box for installing and running codes related to LMT
data reduction. LMT is a large 50m single dish radio telescope located
in Mexico (18:59:09N 97:18:53W) operating at mm wavelengths.
http://lmtgtm.org/

This document described the current toy box of LMT tools that you might
want to use to reduce LMT data.   It will cover most Spectral Line instruments.

The source code is available via https://github.com/astroumd/lmtoy which describes
how to assemble the toolbox with the help of a number of codes.

LMTSLR
======

LMTSLR (SpectralLine Receiver)

This is for Sequoia, the msip 1MMRx and future Omaya

RSR
===

RSR (Redshift Search Receiver)


Tolteca
=======

Tolteca (and the low level Citlali C++ library) provide users with an interface
into TolTec data reduction.


For Developers
==============

If you plan to tinker with the code, you may want to inspect the *docs/install_lmtoy**
file in the **lmtoy**

.. code-block:: sh
  
   wget https://astroumd.github.io/lmtoy/install_lmtoy
   bash install_lmtoy 

this example script is not very long, is fairly self-documenting, should work on most Linux and Mac machines.
It has a few optional command line parameters.


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

Indices
=======

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

Credits
=======
``lmtoy`` is developed by ...

This project is supported by NSF ...

