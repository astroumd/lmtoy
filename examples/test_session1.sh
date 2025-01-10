#! /usr/bin/env bash
#
#  Bench Example of running bench1 in a new session
#  This should emulate the workflow the webrun (pipeline_web) operates.
#  Takes about 1 minute to run.

set +x

#  define the PID (ProjectID) and the PIS (Session number)
PID=2014ARSRCommissioning
PIS=1

# start from scratch
export WORK_LMT=$WORK_LMT_BASE/$PID/Session-$PIS
mkdir -p $WORK_LMT
cd $WORK_LMT

#  get the infrastructure set up just for this PID
lmtoy_run $PID
cd lmtoy_run/lmtoy_$PID
make runs

#  no parameter editing here, this is just proof of concept

#  run some pipelines and a combo
SLpipeline.sh obsnum=33551 linecheck=1 restart=1
SLpipeline.sh obsnum=33552 linecheck=1 restart=1
SLpipeline.sh obsnums=33551,33552 restart=1
make summary

