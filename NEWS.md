# NEWS

2023-aug-09   1.0   SEQ and RSR deemed robustB
2022-mar-04   0.5   now using the master branch of SpectralLineReduction again - merged from "teuben1"
2022-jan-26   0.4   band based fits files now implemented (but not working for 1MM)
2021-dec-13   0.3   SLpipeline.sh now a uniform approach for single and multiple obsnums
2021-may-11   0.2   lmtoy_reduce.sh now able to get some SEQ data through
2021-jan-22   0.1   ?

# Plan

For version 1.0 all instruments are supported, but using the netcdf SpecFile format,
but SDFITS tools will be available.
Export can be in FITS for both cubes and spectra, but spectra in txt also supported.

For version 2.x we expect to fully use SDFITS.

# New things

1. Ps mode for 1MM works, but only interactive for now.
2. RedshiftPointing and LinePointing added, and being tested for the 2022 commisioning


