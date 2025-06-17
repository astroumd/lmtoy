#! /usr/bin/env bash
#
#  Create a new session off the current $WORK_LMT_BASE (the original WORK_LMT)
#

set -x

if [ ! -e PID ]; then
    echo "File 'PID' does not exist. You need to be in the script generator directory"
    exit 0
fi

#  old files have a space around the =
source ./PID

if [ ! -d $PID ]; then
    echo "$PID does not exist, links have not been set up?"
    exit 0
fi

echo ok $PID

#  define the PID (ProjectID) and the PIS (Session number)
PIS=$1

# start from scratch
export WORK_LMT=$WORK_LMT_BASE/$PID/Session-$PIS
mkdir -p $WORK_LMT
cd $WORK_LMT

#  get the infrastructure set up just for this PID
lmtoy_run $PID
cd lmtoy_run/lmtoy_$PID

#  in future we may want to allow branches with the sessions name
#  as to not interfere with the main branch
#  but this also interferes with the incremenrtal nature of the special
#  PL1 session
# git checkout -b $PIS
# make runs


