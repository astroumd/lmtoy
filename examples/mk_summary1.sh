#! /bin/bash
#
#  create nice looking README.html for ProjectId
#
#  2015-01-21T23:12:07 	33551 	 	I10565 	0.00162684 

#set -e

echo "<html>"
echo "Summary of all obsnum's:"
echo "<table border=1>"
echo "  <tr>"
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
echo "      projectID"
echo "    </th>"
echo "    <th>"
echo "      SourceName"
echo "    </th>"
echo "    <th>"
echo "      RestFreq"
echo "    </th>"
echo "    <th>"
echo "      RMS"
echo "    </th>"
echo "    <th>"
echo "      mom0"
echo "    </th>"
echo "  </tr>"

n=0
for o in ????? ?????_?????; do
#for o in ????? ; do
    rc=$o/lmtoy_*$o.rc
    log=$o/lmtoy_*$o.log
    source $rc
    date_obs=$(grep date_obs $rc | awk -F= '{print $2}')
    rms=$(grep QAC_STATS $log | tail -1 | awk '{print $4}')
    n=$(expr $n + 1)

  
    echo "  <tr>"
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
    echo "      $ProjectId"
    echo "    </td>"
    echo "    <td>"
    echo "      $src"
    echo "    </td>"
    echo "    <td>"
    echo "      $restfreq"
    echo "    </td>"
    echo "    <td>"
    echo "      $rms"
    echo "    </td>"
    echo "    <td>"
    if [ -e ${o}/${src}_${o}.nf.admit/x.csm.png ]; then
	echo "      <A HREF=${o}/${src}_${o}.nf.admit/x.csm.png> <IMG SRC=${o}/${src}_${o}.nf.admit/x.csm.png height=100></A>"
	echo "      <A HREF=${o}/${src}_${o}.nfs.admit/x.csm.png> <IMG SRC=${o}/${src}_${o}.nfs.admit/x.csm.png height=100></A>"
    elif [ -e ${o}/${src}_${o}.mom0.png ]; then
	echo "      <A HREF=${o}/${src}_${o}.mom0.png> <IMG SRC=${o}/${src}_${o}.mom0.png height=100></A>"
    else
	echo "      N/A"
    fi  

    echo "    </td>"
    echo "  </tr>"

done
echo "</table>"
if [ -e LMT ]; then
    echo "TAPs copied from LMT <A HREF=LMT>here<br>"
fi
echo "Last written on:  $(date)"
echo "<hr>"  

