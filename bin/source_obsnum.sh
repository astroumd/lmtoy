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

mk_header() {
    echo 'import os'
    echo 'import sys'
    echo ''
    echo 'from lmtoy import runs'
}

mk_trailer() {
    echo 'if __name__ == "__main__":'
    echo '    runs.mk_runs(project, on, pars1, pars2, pars3, sys.argv)'
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

grep -w $pid $dat | grep $intent | grep -v Cal | tabcols - 6,2,7  > $log

echo "# Using $dat"
for pid in $(tabcols $log 3 | sort | uniq); do
    echo "# $pid - $intent"
done



mk_header
echo ""
echo "project=\"$pid\""
echo ""
echo "# Dictionary of sources, each with a list of obsnum's in this project"
echo "# negative obsnums are ignored in the combinations"
echo "on = {}"
    
for src in $(tabcols $log 1 | sort | uniq); do
    if [ $g == 0 ]; then 
	echo $src
	grep -w $src $log | tabcols - 2 | sort
    else
	echo ""
	echo "on[\"$src\"] = \\"
	printf " ["
	for o in $(grep -w $src $log | tabcols - 2 | sort -n); do
	    printf " %d," $o
	done
        echo "]"
    fi
done

echo ""
echo "# parameters for the first pass of the pipeline"
echo "pars1 = {}"
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars1[\"$src\"] = \"\""
done

echo ""
echo "# parameters for the (optional) second pass of the pipeline (e.g. for bank=0)"
echo "pars2 = {}"
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars2[\"$src\"] = \"\""
done

echo ""
echo "# parameters for the (optional) thirds pass of the pipeline (usually for bank=1)"
echo "pars2 = {}"
echo ""

for src in $(tabcols $log 1 | sort | uniq); do
    echo "pars3[\"$src\"] = \"\""
done


ns=$(tabcols $log 1 | sort | uniq | wc -l)
echo ""
echo "# Found $ns source(s) for $pid"
echo ""

mk_trailer
