# linecheck

The observation with a LineCheck goal are normally done on the RSR to
verify the system is working. For a small set of AGN's (see
$LMTOY/etc/linecheck.tab) known lines and their fluxes can be
verified to be close enough to the expected value. Unlike quasars
these are not expected to vary over the lifetime of the LMT.

The RSR is not a doppler tracked instrument, and since the channel width is fairly large at  ~100 km/s, the
annual earth rotation varying up to +/-30km/s, the "exact" peak value of a line may not be the
best value to check (but isn't bad to within say XX%), the integrated flux (K.km/s) may be a better
measurement to compare, but this isn't normally done during the QuickLook procedure.

Here we describe  post-processing the linechecks again. Since the various linecheck results are
written into the "rc" files for an obsnum, the "nemopar" program can be effectively used to
produce a table such as the included linecheck1.tab.

Here's the entry for our "bench1" pipeline obsnum=33551

     # date_obs          Projecd_Id           obsnum src    tau  rms[K]      base     peak    freq    fwhm
     2015-01-22T06:40:59 2014ARSRCommissioning 33551 I10565 0.18 0.000915921 0.135392 50.3725 110.514 224.508  


here is how after the pipeline has been run, the data are gathered in a table

     nemopars date_obs,ProjectId,obsnum,src,tau,rms,linecheck1 20*RSRCommissioning/*/lmtoy_*.rc > linecheck1.tab
     grep -v nan linecheck1.tab |grep -v _ > linecheck1a.tab
     ->   983 entries
     tabcols linecheck1a.tab  4 | sort | uniq -c | sort -nr
         323 I10565  110
	 305 I12112   40
	 229 I05189   55
	 119 I17208  110
	   6 VIIZw31 110
	   1 I08311


Recall that

      Flux = 1.064 * Peak * Width
