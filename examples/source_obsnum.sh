#! /usr/bin/env bash
#
#  find which source/obsnum combinations are in an LMT project
#


if [ -z "$1" ]; then
    echo "Usage: $0 [-l] ProjectId"
    echo "   Makes a list of obsnums, sorted per source, for a given ProjectId"
    echo "   -l    report LineCheck instead of Science intent. Useful for RSR only"
    echo "   -p    report Pointing instead of Science intent."
    exit 0
fi

intent="Science"
if [ "$1" == "-l" ]; then
    intent="LineCheck"
    shift
fi

if [ "$1" == "-p" ]; then
    intent="Pointing"
    shift
fi

pid=$1


log=$WORK_LMT/tmp/$pid.obsnums.log
g=1

grep $pid $DATA_LMT/data_lmt.log | grep $intent | tabcols - 6,2,7  > $log

for pid in $(tabcols $log 3 | sort | uniq); do
    echo "# $pid - $intent"
done

echo ""
    
for src in $(tabcols $log 1 | sort | uniq); do
    if [ $g == 0 ]; then 
	echo $src
	grep -w $src $log | tabcols - 2 | sort
    else
	echo ""
	echo "on[\"$src\"] = "
	for o in $(grep -w $src $log | tabcols - 2 | sort -n); do
	    printf " %d," $o
	done
    fi
done

echo ""
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars1[\"$src\"] = \"\""
done

echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars2[\"$src\"] = \"\""
done
