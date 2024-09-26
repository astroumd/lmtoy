#! /bin/bash
#
#  create summary spanning selected pid/obsnums based on a table
#  run this script in the ProjectId directory where all the obsnums's are.
#
#  Typical usage:
#        lmtinfo.py grep ....   >> sci.log
#        tabcols sci.log  1,2,5,6,7,8,9

#set -e
#set -x

_version="23-sep-2024"

if [ -z "$1" ]; then
    echo "Typical usage:  $0 lmtinfo.txt > README.html"    
    exit 0
else
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Typical usage:  $0 [source] > README.html"
	echo ""
	echo "Expects to be in a directory where obsnums have been reduced and creates a summary html listing"
	echo "Optionally can make a listing for a selected source"
	exit 0
    fi
    tab=$1
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
echo "      ObsNum"
echo "    </th>"
echo "    <th>"
echo "      Map"
echo "    </th>"
echo "    <th>"
echo "      SourceName"
echo "    </th>"
echo "    <th>"
echo "      ProjectID"
echo "    </th>"
echo "    <th>"
echo "      RestFreq"
echo "    </th>"
echo "    <th>"
echo "      inttime [s]"
echo "    </th>"
echo "  </tr>"

log=mk_summary2.log
tabcols $tab  1,2,5,6,7,8,9 > $log

n=0
while IFS= read -r line; do
    ((n++))
    w=($line)
    #
    date_obs=${w[0]}
    o=${w[1]}
    map=${w[2]}
    src=${w[3]}
    pid=${w[4]}
    restfreq=${w[5]}
    inttime=${w[6]}


    echo '  <tr class="item">'
    echo "    <td>"
    echo "     ${n}."
    echo "    </td>"
    echo "    <td>"
    echo "      $date_obs"
    echo "    </td>"
    echo "    <td>"
    echo "      <A HREF=$pid/$o/README.html> ${o}</A>"
    echo "    </td>"
    echo "    <td>"
    echo "      $map"
    echo "    </td>"
    echo "    <td>"
    echo "      $src"
    echo "    </td>"
    echo "    <td>"
    echo "      $pid"
    echo "    </td>"
    echo "    <td>"
    echo "      $restfreq"
    echo "    </td>"
    echo "    <td>"
    echo "      $inttime"
    echo "    </td>"
    echo "    <td>"
    echo "  </tr>"
    
done < $log

echo "</table>"

echo "<br>"
echo "Created:  $(date)"
echo "<hr>"  

