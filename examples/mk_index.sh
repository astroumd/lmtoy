#! /bin/bash
#
#  create nice looking index.html for LMT/ADMIT products from pipeline
#

set -e
pwd=$(pwd)

# there better be only one....
source $(ls ./lmtoy_*.rc)
# hack until it's in the rc file ?
grep '# obsnum=' $(ls ./lmtoy_*.rc) | sed s'/# //' > obsnum.rc
source ./obsnum.rc

base1="${src}_${obsnum}"
base2="${src}_${obsnum}_specviews"
base3="${src}_${obsnum}_specpoint"


html=index.html
echo Writing $html # in $pwd
echo "<H1> $ProjectId/$obsnum for $src </H1>"                              > $html
echo "<H2>  <A HREF=index_pipeline.html>SL Pipeline summary</A> </H2>"    >> $html
echo "<H2>  <A HREF=index_admit.html>ADMIT summary</A>          </H2>"    >> $html
echo "<H2>  <A HREF=index_pars.html>parameters</A>              </H2>"    >> $html
echo "<H2>  <A HREF=index_log.html>log files</A>                </H2>"    >> $html
echo "Last updated $(date)"                                               >> $html


html=index_pipeline.html
echo Writing $html # in $pwd
echo "<H1> SL Pipeline summary for $ProjectId/$obsnum for $src </H1>"      > $html
echo "<OL>"                                                               >> $html
echo "  <LI> sky coverage for all 16 beams"                               >> $html
echo "       (sky coordinates in arcsec w.r.t. map center)"               >> $html
echo "           <br><IMG SRC=$base2.1.png>"                              >> $html
echo "  <LI> Tsys for each beam in 4x4 panels"                            >> $html
echo "       (VLSR vs. TA*)"                                              >> $html
echo "           <br><IMG SRC=$base2.6.png>"                              >> $html
echo "  <LI> waterfall plot for each beam in 4x4 panels"                  >> $html
echo "       (VLSR vs. SAMPLE TIME)"                                      >> $html
echo "           <br><IMG SRC=$base2.2.png>"                              >> $html
echo "  <LI> RMS $b_order order baseline fit for each beam in 4x4 panels" >> $html
echo "           <br><IMG SRC=$base2.3.png>"                              >> $html
echo "  <LI> spectra for the whole map, overplotted for each beam"        >> $html
echo "           <br><IMG SRC=$base3.1.png>"                              >> $html
echo "  <LI> spectra for center beam, overplotted for each beam"          >> $html
echo "           <br><IMG SRC=$base3.2.png>"                              >> $html
#    unclear if we want to do this one
echo "  <LI> mean_spectra_plot for each beam"                             >> $html
echo "           <br><IMG SRC=$base2.5.png>"                              >> $html
echo "  <LI> coverage as defined how often sky pixel was seen"            >> $html
echo "       (sky pixels are half of LMT beam size)"                      >> $html
echo "           <br><IMG SRC=$base1.wt.png>"                             >> $html
echo "</OL>"                                                              >> $html

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

html=index_pars.html
echo Writing $html # in $pwd
echo "<H1> Parameter summary for $ProjectId/$obsnum for $src </H1>"        > $html
echo "<pre>"                                                              >> $html
cat lmtoy_*.rc                                                            >> $html
echo "</pre>"                                                             >> $html


html=index_log.html
echo Writing $html # in $pwd
echo "<H1> Logfiles for $ProjectId/$obsnum for $src </H1>"                 > $html
echo "<OL>"                                                               >> $html
for log in *.log; do
    echo "<LI> <A HREF=$log>$log</A>"                                     >> $html
done
echo "</OL>"                                                              >> $html
