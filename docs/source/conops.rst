ConOps
======

ConOps stands for "Concept of Operations", and here we outline
what lmtoy is and how it should operate, but without
giving implementation details (the "what", not the "how").

LMTOY is

* a toolkit to reduce LMT spectral line data

* agnostic of the instrument (SEQ, RSR, 1MM), the code will figure it out

* a (Unix) environment that can be operated as
  * a command line based tool, commonly called the SLpipeline
  * a web based excution environment

* data is organized in a set of obsnums, each in
  themselves part of a PI owned project id. Each set 
  of obsnums is defined through a common setup (e.g. for given source,
  spectral line, etc.) so they can be stacked

* the first stage in the data reduction will create a calibrated spectrum,
  or set of spectra with the purpose of gridding and/or stacking.
  This intermediate format will be in SDFITS format.

* a set of obsnums can be combined to create a stacked
  version with the intent to increase the signal to noise
  and/or reject outliers.

* the final product will be a calibrated spectrum, or a gridded data cube,
  in 1D or 3D FITS format respectively.


LMTOY installation is

* based on git, being hosted on github

* need a series of other packages (all via github) to be installed using "pip install"

* compile a few tools, written in C

* optionally use tools and python packages
