# linecheck

The linecheck are normally done on the RSR to verify the system is working. For a small set of AGN's
(see $LMTOY/etc/linecheck.tab) known lines and their strenghts can be verified to be close enough to
the expected value.

Since the RSR is not a doppler tracked instruments, and since the channel width is ~100 km/s, the
annual earth rotation can vary up to +/-30km/s, so the peak value of a measurement may not be the
best value to check (but isn't bad to within say XX%), the integrated flux (K.km/s) may be a better
measurement to compare, but this isn't normally done during the QuickLook procedure.

Here we describe  post-processing the linechecks again. Since the various linecheck results are
written into the "rc" files for an obsnum, the "nemopar" program can be effectively used to
produce a table such as the included linecheck1.tab. 
