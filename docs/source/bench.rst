Benchmark data for SLpipeline
=============================

1. RSR:  33551

   For RSR there really is one mode, though through the ages the instrument has gone through boards
   misbehaving.  The 2014 data with obsnum=33551 is well behaved and has served us as the default
   
2. SEQ:  79448; single IF in Az-El

   For SEQ (OTF) mapping there are several benchmarks possible, because of the native mapping mode
   (AzEl, RaDec, LatLon) as well as single or double (since 2023) IF mode.

3. SEQ Ps

4. SEQ Bs; usually between beams 8 (off) and 10 (on), but check ``Header.Bs.Beam``. 10 is near the center
   and should be the "on" position.

5. 1MM Ps
