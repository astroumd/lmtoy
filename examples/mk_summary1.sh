#! /bin/bash
#
#  create nice looking README.html for a given ProjectId
#  run this script in the ProjectId directory where all the obsnums's are.
#
#  Typical usage:
#        mk_summary1.sh > README.html
#  After this, make a symlink from index.html to README.html if you enforce noindex.
#

#set -e
#set -x

csv=summary.csv


echo "<html>"
echo '<script src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>'

echo "<A HREF=$csv>Summary of all obsnum's:</A> (click on column name to sort by that column)"
echo '<table border=1 class="sortable">'
echo '  <tr class="item">'
echo "    <th>"
echo "      #"
echo "    </th>"
echo "    <th>"
echo "      ObservingDate"
echo "    </th>"
echo "    <th>"
echo "      ObsNum"
echo "    </th>"
echo "    <th>"
echo "      SourceName"
echo "    </th>"
echo "    <th>"
echo "      RestFreq"
echo "    </th>"
echo "    <th>"
echo "      inttime [s]"
echo "    </th>"
echo "    <th>"
echo "      tau"
echo "    </th>"
echo "    <th>"
echo "      RMS [mK]"
echo "    </th>"
echo "    <th>"
echo "      RMS/RMS0 ratio"
echo "    </th>"
echo "    <th>"
echo "      aPlot"
echo "    </th>"
echo "    <th>"
echo "      comments"
echo "    </th>"
echo "  </tr>"

echo "obsnum,date,source,inttime,tau,rms"   > $csv


n=0
for o in $(find . -maxdepth 1 -type d | sed s+./++ | sort -n); do
    if [ ! -e $o/lmtoy.rc ]; then
	continue
    fi
    rc=$o/lmtoy_*$o.rc
    log=$o/lmtoy_*$o.log
    source $rc
    date_obs=$(grep date_obs $rc | awk -F= '{print $2}')
    if [ $instrument == "RSR" ]; then
	# RSR - use average of driver and blanking RMS
	#rms=$(grep QAC_STATS $log | txtpar - '1000*0.5*(%1+%2)/sqrt(2)' p0=1,4 p1=2,4)  # trend spectrum
	rms=$(grep QAC_STATS $log | txtpar - '1000*0.5*(%1+%2)'          p0=3,4 p1=4,4)  # straight spectrum
	rms0=$(nemoinp "1.291*1000*100/sqrt(4*31250000*$inttime)")
	rms0="$(nemoinp $rms/$rms0) /100K"
    elif [ $instrument == "SEQ" ] && [ $obspgm == "Bs" ]; then
	rms=$(grep QAC_STATS $log | txtpar - "%1" p0=1,4)
	rms0=TBD
    else
	# SEQ and other mapping instruments
	rms=$(grep QAC_STATS $log | txtpar - "%1*1000" p0=-cent,1,4)
	rms0=$(grep QAC_STATS $log | txtpar - p0=radiometer,1,3)
    fi
    n=$(expr $n + 1)
    if [ -e comments.txt ]; then
	# nov2022:   we allow obsnum.args to go after the # symbol in comments.txt
	#comments=$(grep -w ^$obsnum comments.txt | cut -d' ' -f2-)
	comments=$(grep -w ^$obsnum comments.txt | cut -d' ' -f2- | awk -F\# '{print $1}')
    else
	comments=""
    fi
    echo "$obsnum,$date_obs,$src,$inttime,$tau,$rms" >> $csv
  
    echo '  <tr class="item">'
    echo "    <td>"
    echo "     ${n}."
    echo "    </td>"
    echo "    <td>"
    echo "      $date_obs"
    echo "    </td>"
    echo "    <td>"
    echo "      <A HREF=$obsnum/README.html> $obsnum</A>"
    echo "    </td>"
    echo "    <td>"
    echo "      $src"
    echo "    </td>"
    echo "    <td>"
    echo "      $restfreq"
    echo "    </td>"
    echo "    <td>"
    echo "      $inttime"
    echo "    </td>"
    echo "    <td>"
    echo "      $tau"
    echo "    </td>"
    echo "    <td>"
    echo "      $rms"
    echo "    </td>"
    echo "    <td>"
    echo "      $rms0"
    echo "    </td>"
    echo "    <td>"
    if [ -e ${o}/${src}_${o}.nf.admit/x.csm.png ]; then
	echo "      <A HREF=${o}/${src}_${o}.nf.admit/x.csm.png> <IMG SRC=${o}/${src}_${o}.nf.admit/x.csm.png height=100></A>"
	echo "      <A HREF=${o}/${src}_${o}.nfs.admit/x.csm.png> <IMG SRC=${o}/${src}_${o}.nfs.admit/x.csm.png height=100></A>"
    elif [ -e ${o}/${src}_${o}.mom0.png ]; then
	echo "      <A HREF=${o}/${src}_${o}.mom0.png> <IMG SRC=${o}/${src}_${o}.mom0.png height=100></A>"
    elif [ -e ${o}/rsr.spectra.png ]; then
	echo "      <A HREF=${o}/rsr.spectra.png> <IMG SRC=${o}/rsr.spectra.png height=100></A>"
	echo "      <A HREF=${o}/rsr.spectra_co.png> <IMG SRC=${o}/rsr.spectra_co.png height=100></A>"		
    elif [ -e ${o}/seq.spectra.png ]; then
	echo "      <A HREF=${o}/seq.spectra.png> <IMG SRC=${o}/seq.spectra.png height=100></A>"	
    else
	echo "      N/A"
    fi  

    echo "    </td>"
    echo "    <td>"
    echo "      $comments"
    echo "    </td>"
    echo "  </tr>"

done
echo "</table>"
if [ -e TAP ]; then
    echo "TAPs copied from LMT <A HREF=TAP>here</A><br>"
fi
echo "Last written on:  $(date)"
echo "<A HREF=$csv>$csv</A>"
echo "<hr>"  

