#! /bin/bash
#
# Submit a series of runfiles that depend on each other
# If this directory is a script generator directory, also
# "make summary"
#
# Usage:    sbatch_lmtoy2.sh runfile1 runfile2 ....
#

sleep=10

if [ -z $1 ]; then
    echo "Usage: $0 runfile1 runfile2 ..."
    echo ""
    echo "   submit runfiles that wait for each other"
    echo "   probing for obsnums happens every $sleep seconds"
    exit 0
fi

d0=$(date)

nf=0
if [ -e PID ]; then
    source PID
else
    PID=""
fi

for f in $*; do
    ((nf++))
    if [ ! -e $f ]; then
	echo "File $f does not exist, skipping"
	continue
    fi
    # submit a file from the asrgument list, 
    # this also stores the JOBID's in $f.jobid
    sbatch_lmtoy.sh $f
    nj=1
    # top template progress bar
    fmt1="%${nf}s\n"
    fmt2=$(printf $fmt1 | tr ' ' '-')
    echo "$f [$fmt2]"
    while [ $nj -gt 0 ]; do
	nj=0
	echo "Progress bar for $(cat $f|wc -l) obsnums: #${nf} @ ${sleep}s:"
        echo -n "${pid} $f :"
	for j in $(cat $f.jobid); do
	    squeue --me | tail +2 | grep -q -w $j
	    if [ $? == 0 ]; then
                echo -n "-"
		((nj++))
		sleep $sleep
		continue
            else
		echo -n "*"
	    fi
	done
        echo ""
    done
    echo "DONE WITH $f"
done

if [ -f Makefile ]; then
    make summary index
    echo "Summary and index made, all done."
else
    echo "All done."    
fi

d1=$(date)
echo "start: $d0"
echo "stop:  $d1"
