#! /usr/bin/env bash
#
#     emulate how webrun works from a shell
#

#  set a projectid (pid) and obsnum
pid=2023-S1-US-17
obsnum=108859

#             simple keyword=value command line parser for bash
for arg in "$@"; do
  export "$arg"
done

# report
echo "DATA_LMT:  $DATA_LMT"
echo "WORK_LMT:  $WORK_LMT"
echo "pid:       $pid"
echo "obsnum:    $obsnum"

if [ -e $WORK_LMT/$pid/session.dat ]; then
    echo "sessions:  $(cat $WORK_LMT/$pid/session.dat)"
else
    echo "sessions:  none"
fi

echo "Sources available:"
lmtinfo.py grep $pid Science | tabcols - 6 | uniq -c


# pick a session (pis) - @todo   haven't decided how to log sessions in session.dat
pis=test1


# setup
export WORK_LMT=$WORK_LMT/$pid/Session_$pis
mkdir -p $WORK_LMT
cd $WORK_LMT
lmtoy_run $pid

# report
pwd

cd $WORK_LMT
cd lmtoy_run/lmtoy_$pid

make runs
grep $obsnum *.run1a > test1

echo "Running test1:"
cat test1
bash test1

echo "Making summary"
make summary
echo "xdg-open $WORK_LMT/$pid/README.html"
