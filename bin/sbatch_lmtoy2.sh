#! /bin/bash


# sbatch_lmtoy2.sh  run1a run1b run1c run2a

for f in $*; do
    sbatch_lmtoy.sh $f
    # this stores a list of JOB_ID's in a file $f.jid
    nj=1
    while [ $nj -gt 0 ]; do
	nj=0
	for j in $(cat $f.jid); do
	    squeue --me | tail +2 | grep -q -w $j
	    if [ $? == 0 ]; then
		((nj++))
		sleep 5
		continue
	    fi
	done
    done
    echo "DONE WITH $f"
done
