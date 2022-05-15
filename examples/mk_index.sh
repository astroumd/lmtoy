#! /bin/bash
#
#  create nice looking index.html for LMT/ADMIT products from pipeline for Sequoia
#  this needs to be executed from the $ProjectId/$obsnum directory 
#

# set -e
pwd=$(pwd)
update="$(date) on $(hostname)"

# there better be only one....
source $(ls ./lmtoy_*.rc)
if [ -z "$obsnum" ]; then
    # hack until it's in the rc file ?
    grep '# obsnum=' $(ls ./lmtoy_*.rc) | sed s'/# //' > obsnum.rc
    source ./obsnum.rc
fi
echo "Making index.html for obsnum=$obsnum"

base1="${src}_${obsnum}"
base2="${src}_${obsnum}_specviews"
base3="${src}_${obsnum}_specpoint"

#base1="${src}_${obsnum}_?"
#base2="${src}_${obsnum}_?_specviews"
#base3="${src}_${obsnum}_?_specpoint"


echo $base1
echo $base2
echo $base3

if [ -d $base1.nf.admit ]; then
    admit=""
else
    admit="(Looks like no ADMIT was produced)"
fi

dev=$(yapp_query png ps)

html=index.html
echo Writing $html # in $pwd
echo "<H1> $ProjectId/$obsnum for $src </H1>"                              > $html
echo "<H2>  <A HREF=index_pipeline.html>SL Pipeline summary</A> </H2>"    >> $html
echo "<H2>  <A HREF=index_admit.html>ADMIT summary</A> $admit   </H2>"    >> $html
echo "<H2>  <A HREF=index_pars.html>parameters</A>              </H2>"    >> $html
echo "<H2>  <A HREF=index_log.html>log files</A>                </H2>"    >> $html
echo "<H2>  Select FITS files:   </H2>"                                   >> $html
echo "<OL>"                                                               >> $html

c=("final reduced data cube"  "per pixel weights map"    "waterfall cube"     "full SRDP tar"         "TAP data")
f="${base1}.fits              ${base1}.wt.fits           ${base1}.wf.fits     ../${obsnum}_SRDP.tar   ../${obsnum}_TAP.tar"
i=0
for ff in $f ; do
    if [ -e $ff ]; then
	echo "<LI><A HREF=$ff>$ff</A> - ${c[$i]}."                        >> $html
    else
	echo "<LI>$ff (missing)"                                          >> $html
    fi
    ((i=i+1))
done
echo "<LI> These and other files are also available via the _SRDP.tar,"   >> $html
echo "     if available"                                                  >> $html
echo "</OL>"                                                              >> $html
echo "<br>Last updated $update"                                           >> $html



html=index_pipeline.html
echo Writing $html # in $pwd


# if "first" figures don't exist, copy them from existing
first="$base2.1.png $base2.6.png $base2.2.png $base2.3.png $base3.1.png $base3.2.png $base2.5.png $base1.wt.png $base1.mom0.png $base1.peak.png $base1.rms.png"
for f in $first; do
    if [ -e $f ]; then
	if [ ! -e first_$f ]; then
	    cp $f  first_$f
	fi
    fi
done

echo "<H1> SL Pipeline summary for $ProjectId/$obsnum for $src </H1>"      > $html
echo "The figures in the right column are those generated from the first" >> $html
echo "pass of the pipeline, those on the left are the latest iteration."  >> $html
echo "<br>"                                                               >> $html
echo "If no figure shown, the pipeline did not produce it,"               >> $html
echo "e.g. a combination obsnums will not have figures 1..7"              >> $html
echo "<OL>"                                                               >> $html

if [ -e $base2.1.png ]; then
    # assume single obsnum
    # 1.
    echo "  <LI> Sky coverage for all 16 beams"                               >> $html
    echo "       (sky coordinates in arcsec w.r.t. map center)"               >> $html
    echo "           <br><IMG SRC=$base2.1.png>"                              >> $html
    echo "         <IMG SRC=first_$base2.1.png>"                              >> $html
    
    # 2.
    echo "  <LI> Tsys for each beam in 4x4 panels"                            >> $html
    echo "       (VLSR vs. TA*)"                                              >> $html
    echo "           <br><IMG SRC=$base2.6.png>"                              >> $html
    echo "         <IMG SRC=first_$base2.6.png>"                              >> $html
    
    # 3.
    echo "  <LI> Waterfall plot for each beam in 4x4 panels"                  >> $html
    echo "       (VLSR vs. SAMPLE TIME)"                                      >> $html
    echo "           <br><IMG SRC=$base2.2.png>"                              >> $html
    echo "         <IMG SRC=first_$base2.2.png>"                              >> $html
    
    # 4.
    echo "  <LI> RMS $b_order order baseline fit (in K) for each beam"        >> $html
    echo "           <br><IMG SRC=$base2.3.png>"                              >> $html
    echo "         <IMG SRC=first_$base2.3.png>"                              >> $html
    
    # 5.
    echo "  <LI> Spectra for the whole map, overplotted for each beam"        >> $html
    echo "           <br><IMG SRC=$base3.1.png>"                              >> $html
    echo "         <IMG SRC=first_$base3.1.png>"                              >> $html
    
    # 6.
    echo "  <LI> Spectra for center beam, overplotted for each beam"          >> $html
    echo "           <br><IMG SRC=$base3.2.png>"                              >> $html
    echo "         <IMG SRC=first_$base3.2.png>"                              >> $html
    
    # 7.
    echo "  <LI> mean_spectra_plot for each beam"                             >> $html
    echo "           <br><IMG SRC=$base2.5.png>"                              >> $html
    echo "         <IMG SRC=first_$base2.5.png>"                              >> $html
else
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <LI> N/A"  >> $html
    echo "  <br>obsnums=${obsnums}<br><br>"                               >> $html
fi    

# 8.
echo "  <LI> Sky coverage as defined how often sky pixel was seen"        >> $html
echo "       (sky pixels are about half of LMT beam size)"                >> $html
echo "           <br><IMG SRC=$base1.wt.png>"                             >> $html
echo "         <IMG SRC=first_$base1.wt.png>"                             >> $html

# 9.
echo "  <LI> Moment-0 estimate [K.m/s] (<A HREF=index_admit>ADMIT</A>)"   >> $html
echo "           <br><IMG SRC=$base1.mom0.png>"                           >> $html
echo "         <IMG SRC=first_$base1.mom0.png>"                           >> $html

# 10.
echo "  <LI> Peak temperature [mK]"                                       >> $html
echo "           <br><IMG SRC=$base1.peak.png>"                           >> $html
echo "         <IMG SRC=first_$base1.peak.png>"                           >> $html
echo "</OL>"                                                              >> $html

# 11.
echo "  <LI> RMS estimate [mK]"                                           >> $html
echo "           <br><IMG SRC=$base1.rms.png>"                            >> $html
echo "         <IMG SRC=first_$base1.rms.png>"                            >> $html
echo "</OL>"                                                              >> $html

echo "<br>Last updated $update"                                           >> $html

html=index_admit.html
echo Writing $html # in $pwd
echo "<H1> ADMIT summary for $ProjectId/$obsnum for $src </H1>"            > $html
echo "Currently we produce results for two cubes: "                       >> $html
echo "<OL>"                                                               >> $html
echo "   <LI> Native ('nf') resolution, which could be noisy: "           >> $html
echo "        <A HREF=$base1.nf.admit>$base1.nf.admit</A>"                >> $html
echo "   <LI> Smoothed ('nfs') spatially and spectrally: "                >> $html
echo "        <A HREF=$base1.nfs.admit>$base1.nfs.admit</A>"              >> $html
echo "</OL>"                                                              >> $html
echo "<br>Last updated $update"                                           >> $html

html=index_pars.html
echo Writing $html # in $pwd
echo "<H1> Parameter summary for $ProjectId/$obsnum for $src </H1>"        > $html
echo "<pre>"                                                              >> $html
cat lmtoy_*.rc                                                            >> $html
echo "</pre>"                                                             >> $html
echo "<br>Last updated $update"                                           >> $html

html=index_log.html
echo Writing $html # in $pwd
echo "<H1> Logfiles for $ProjectId/$obsnum for $src </H1>"                 > $html
echo "<OL>"                                                               >> $html
for log in *.log *.ifproc; do
    echo "<LI> <A HREF=$log>$log</A>"                                     >> $html
done
echo "</OL>"                                                              >> $html
echo "<br>Last updated $update"                                           >> $html
