#! /usr/bin/env bash
#
#  find which source/obsnum combinations are in an LMT project
#


usage() {
    echo "Usage: $0 [options] ProjectId"
    echo "   Makes a list of obsnums, sorted per source, for a given ProjectId, ready for the script generator"
    echo "   Options:"
    echo "   -l    report LineCheck instead of Science intent. Useful for RSR only"
    echo "   -p    report Pointing instead of Science intent."
    echo "   -h    this help"
}

if [ -z "$1" ]; then
    usage
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
if [ "$1" == "-h" ]; then
    usage
    exit 0
fi

pid=$1

dat=$DATA_LMT/data_lmt.log 
log=$WORK_LMT/tmp/$pid.obsnums.log
g=1

grep $pid $dat | grep $intent | grep -v Cal | tabcols - 6,2,7  > $log

echo "# Using $dat"
for pid in $(tabcols $log 3 | sort | uniq); do
    echo "# $pid - $intent"
done

echo ""
echo "on = {}"
    
for src in $(tabcols $log 1 | sort | uniq); do
    if [ $g == 0 ]; then 
	echo $src
	grep -w $src $log | tabcols - 2 | sort
    else
	echo ""
	echo "on[\"$src\"] = "
	printf " ["
	for o in $(grep -w $src $log | tabcols - 2 | sort -n); do
	    printf " %d," $o
	done
        echo "]"
    fi
done

echo ""
echo "pars1 = {}"
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars1[\"$src\"] = \"\""
done

echo ""
echo "pars2 = {}"
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars2[\"$src\"] = \"\""
done
