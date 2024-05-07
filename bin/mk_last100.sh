#! /bin/bash
#

_version="5-may-2024"

log=$1
url1="http://taps.lmtgtm.org/lmtslr/%s/TAP/"
url2="http://taps.lmtgtm.org/lmtslr/%s/TAP/%s/README.html"
url3="http://taps.lmtgtm.org/lmtslr/%s/"
url4="http://taps.lmtgtm.org/lmtslr/%s/%s/README.html"


echo "<html>"
echo '<script src="https://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>'

echo "Last 100 observations SLpipeline'd on <B>malt</B> should be available as lightweight TAPS on Unity."
echo "Plus links to future final full processing on Unity (if available)."
echo "<br>"
echo "(click on column name to sort by that column) <br>Created: $(date)"

echo '<table border=1 class="sortable">'
echo '  <tr class="item">'
echo "    <th>"
echo "      LMT-Date"
echo "    </th>"
echo "    <th>"
echo "      ObsNum"
echo "    </th>"
echo "    <th>"
echo "      ProjectId"
echo "    </th>"
echo "  </tr>"

while read -r line; do
   comment=$(echo $line | cut -c1)
   if [ "$comment" = '#' ]; then
       continue
   fi
   date=$(echo $line | tabcols - 1)
   obsnum=$(echo $line | tabcols - 2)
   pid=$(echo $line | tabcols - 3)
   u1=$(printf $url1 $pid)
   u2=$(printf $url2 $pid $obsnum)
   u3=$(printf $url3 $pid)
   u4=$(printf $url4 $pid $obsnum)
   echo '  <tr class="item">'
   echo '    <td>'
   echo "      $date"
   echo '    </td>'
   echo '    <td>'
   echo "      <A HREF=$u2>$obsnum</A>"
   echo '    </td>'
   echo '    <td>'
   echo "      <A HREF=$u1>$pid</A>"
   echo '    </td>'
   echo '    <td>'
   echo "      <A HREF=$u4>[$obsnum]</A>"
   echo '    </td>'
   echo '    <td>'
   echo "      <A HREF=$u3>[$pid]</A>"
   echo '    </td>'
   echo '  </tr>'
done < $log

echo "</table>"

