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
echo "  </tr>"

n=0
for o in ????? ?????_?????; do
    rc=$o/lmtoy_*$o.rc
    log=$o/lmtoy_*$o.log
    source $rc
    date_obs=$(grep date-obs $rc | awk -F= '{print $2}')
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
    echo "      <A HREF=$obsnum/> $obsnum</A>"
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
    echo "  </tr>"

done
echo "</table>"
echo "Last written on:  $(date)"
echo "<hr>"  

