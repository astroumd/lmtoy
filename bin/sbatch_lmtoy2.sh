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

for f in $*; do
    # submit a file from the asrgument list, 
    # this also stores the JOBID's in $f.jobid
    sbatch_lmtoy.sh $f
    nj=1
    while [ $nj -gt 0 ]; do
	nj=0
        echo -n "$f :"
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
    make summary
    echo "Summary made, all done."
else
    echo "All done."    
fi
