#! /bin/bash
#
#  create nice looking README.html for a given ProjectId
#  run this script in the ProjectId directory where all the obsnums's are.
#
#  Typical usage:
#        mk_summary1.sh > README.html
#        mk_summary1.sh NGC5376  > README_NGC5376.html
#  After this, make a symlink from index.html to README.html if you enforce noindex.
#  On unity we do this, on malt and lma we don't, since developers like to see everything
#  For manual work, we also support making source based README_$src.html files, in case
#  there are multiple

#set -e
#set -x

_version="31-jul-2023"

if [ -z "$1" ]; then
    src0=""
    csv=summary.csv
else
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Typical usage:  $0 [source] > README.html"
	echo ""
	echo "Expects to be in a directory where obsnums have been reduced and creates a summary html listing"
	echo "Optionally can make a listing for a selected source"
	exit 0
    fi
    src0=$1
    csv=summary_${src0}.csv
fi
pid=$(pwd | awk -F/ '{print $NF}')

echo "<html>"
echo '<script src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>'

echo "<B>$pid</B>: <A HREF=$csv>Summary of all obsnum's and combinations:</A> (click on column name to sort by that column) Created: $(date)"
echo '<table border=1 class="sortable">'
echo '  <tr class="item">'
echo "    <th>"
echo "      #"
echo "    </th>"
echo "    <th>"
echo "      ObservingDate"
echo "    </th>"
echo "    <th>"
echo "      ReductionDate"
echo "    </th>"
echo "    <th>"
echo "      ObsNum"
echo "    </th>"
echo "    <th>"
echo "      Bank"
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

echo "obsnum,date,source,inttime,tau,rms,rms0"   > $csv


n=0
for o in $(find . -maxdepth 1 -type d | sed s+./++ | sort -n); do
    # ensure the directory is an LMTOY data directory
    if [ ! -e $o/lmtoy.rc ]; then
	continue
    fi
    # allow obsnum__ALIAS
    if [[ "$o" == *"__"* ]]; then
	on=$(echo $o | awk -F__ '{print $1}')
    else
	on=$o
    fi
    # bootstrap rc file
    rc=($o/lmtoy_*$on.rc)
    source $rc
    
    log=($o/lmtoy_*$on.log)
    if [ ! -z "$src0" ] && [ "$src" != "$src0" ]; then
	continue
    fi

    # numbands is only used by WARES systems, so for RSR etc. we fake there is 1
    # each bank (yeah, numbands) will get its own row in the summary file
    if [ -z "$numbands" ]; then
	numbands=1
    fi

    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)

	echo "HACK $on/$bank/$numbands"

	rc0=($o/lmtoy_*${on}__${bank}.rc)
	[ -e $rc0 ] && rc=$rc0 && source $rc
	
	date_obs=$(grep date_obs $rc | awk -F= '{print $2}')
	date=$(grep date= $rc | tail -1 | awk -F= '{print $2}' | awk '{print $1}')
	# @todo   the RMS0 and RMS/RMS0 should be computed by the pipeline and placed in the rc file
	
	if [ "$instrument" == "RSR" ]; then
	    # RSR - use average of driver and blanking RMS
	    #rms=$(grep QAC_STATS $log | txtpar - '1000*0.5*(%1+%2)/sqrt(2)' p0=1,4 p1=2,4)  # trend spectrum
	    #rms=$(grep QAC_STATS $log | txtpar - '1000*0.5*(%1+%2)'          p0=3,4 p1=4,4)  # straight spectrum
	    rms=$(grep QAC_STATS $log | txtpar - '1000*0.5*(%1+%2)' p0=driver.sum.txt,1,4 p1=blanking.sum.txt,1,4)
	
	    #rms0=$(nemoinp "1.291*1000*100/sqrt(4*31250000*$inttime)")
	    rms0=$(nemoinp "1000*100/sqrt(31250000*$inttime)")
	    rms0r="$(nemoinp $rms/$rms0) /100K"
	    ext=""
	elif [ "$instrument" == "SEQ" ] && [ $obspgm == "Bs" ]; then
	    rms=$(grep QAC_STATS $log | txtpar - "%1" p0=1,4)
	    rms0=TBD
	    rms0r=TBD
	    ext=""
	else
	    # SEQ and other mapping instruments
	    rms=$(grep QAC_STATS $log | txtpar - "%1*1000" p0=-cent,1,4)
	    rms0=$(grep QAC_STATS $log | txtpar - p0=radiometer,1,3)
	    rms0r=$rms0
	    ext="__$bank"
	fi
    
        n=$(expr $n + 1)
	if [ -e comments.txt ]; then
	    # nov2022:   we allow obsnum.args to go after the # symbol in comments.txt
	    #comments=$(grep -w ^$obsnum comments.txt | cut -d' ' -f2-)
	    comments=$(grep -w ^$obsnum comments.txt | cut -d' ' -f2- | awk -F\# '{print $1}')
	else
	    comments=""
	fi
	echo "$o,$date_obs,$src,$inttime,$tau,$rms,$rms0" >> $csv
  
	echo '  <tr class="item">'
	echo "    <td>"
	echo "     ${n}."
	echo "    </td>"
	echo "    <td>"
	echo "      $date_obs"
	echo "    </td>"
	echo "    <td>"
	echo "      $date"
	echo "    </td>"
	echo "    <td>"
	echo "      <A HREF=$o/README.html> ${o}</A>"
	echo "    </td>"
	echo "    <td>"
	echo "      $(echo $ext|sed s/__//)"
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
	echo "      $rms0r"
	echo "    </td>"
	echo "    <td>"
	if [ -e ${o}/${src}_${on}.nf.admit/x.csm.png ]; then
	    echo "      <A HREF=${o}/${src}_${on}.nf.admit/x.csm.png> <IMG SRC=${o}/${src}_${on}.nf.admit/x.csm.png height=100></A>"
	    echo "      <A HREF=${o}/${src}_${on}.nfs.admit/x.csm.png> <IMG SRC=${o}/${src}_${on}.nfs.admit/x.csm.png height=100></A>"
	elif [ -e ${o}/${src}_${on}__0.nf.admit/x.csm.png ]; then
	    # @todo for now only show bank0 ?
	    echo "      <A HREF=${o}/${src}_${on}__0.nf.admit/x.csm.png> <IMG SRC=${o}/${src}_${on}__0.nf.admit/x.csm.png height=100></A>"
	    echo "      <A HREF=${o}/${src}_${on}__0.nfs.admit/x.csm.png> <IMG SRC=${o}/${src}_${on}__0.nfs.admit/x.csm.png height=100></A>"
	elif [ -e ${o}/${src}_${on}.mom0.png ]; then
	    echo "      <A HREF=${o}/${src}_${on}.mom0.png> <IMG SRC=${o}/${src}_${on}.mom0.png height=100></A>"
	elif [ -e ${o}/${src}_${on}${ext}.mom0.png ]; then
	    # @todo  for now only show bank0 ?
	    echo "      <A HREF=${o}/${src}_${on}${ext}.mom0.png> <IMG SRC=${o}/${src}_${on}${ext}.mom0.png height=100></A>"	
	elif [ -e ${o}/rsr.spectra.png ]; then
	    echo "      <A HREF=${o}/rsr.spectra.png> <IMG SRC=${o}/rsr.spectra.png height=100></A>"
	    echo "      <A HREF=${o}/rsr.spectra_zoom.png> <IMG SRC=${o}/rsr.spectra_zoom.png height=100></A>"		
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

    done   # bank
    
done       # obsnum (o)

echo "</table>"
if [ -e TAP ]; then
    echo "TAPs copied from LMT <A HREF=TAP>here</A><br>"
fi
echo "Last written on:  $(date)"
echo "<A HREF=$csv>$csv</A>"
echo "<hr>"  

