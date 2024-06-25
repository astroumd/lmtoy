Benchmark data for SLpipeline
=============================

The **SLpipeline.sh** command is instrument and mode agnostic. The following obsnums are frequently
used to test and verify the operation of the pipeline.

1. RSR Bs:  **obsnum=33551**

   For RSR there really is one Science mode, though through the ages the instrument has gone through boards
   misbehaving.  The 2014 data with obsnum=33551 is well behaved and has served us as the default to develop
   the RSR portion of the pipeline.
   
2. SEQ Map:  **obsnum=79448** ; single IF in Az-El

   For SEQ (OTF) mapping there are several benchmarks possible, because of the native mapping mode
   (AzEl, RaDec, LatLon) as well as single or double (since 2023) IF mode.

3. SEQ Ps: 

4. SEQ Bs:  **obsnum=83057**    ; usually between beams 8 (off) and 10 (on), but check ``Header.Bs.Beam``. 10 is near the center
   and should be the "on" position.
   Also available via BS_EXAMPLE.ipynb

5. 1MM Ps: **obsnum=82480** : HCN 3-2 line in Comet 46P/Wirtanen, obtained in December 2018 with the 1mm EHT receiver.
   Also available via PS_EXAMPLE.ipynb
