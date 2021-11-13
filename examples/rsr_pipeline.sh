#! /bin/bash
#
#  A simple LMT RSR pipeline in bash.
#  Really should be written in python, but hey, here we go.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#          in the current directory, parameters will be read from it.
#          If it does not exist, it will be created on the first run and you can edit it
#          for subsequent runs
#          If ProjectId is set, this is the subdirectory, within which obsnum is set
#
# There is no good mechanism here to make a new variable depend on re-running a certain task on which it depends
# that's perhaps for a more advanced pipeline
#

version="rsr_pipeline: 13-nov-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=OBSNUM ..."
    echo ""
    echo "RSR pipeline"
    exit 0
else
    echo "LMTOY>> $version"
fi


# debug
# set -x
debug=0

# input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=33551
obsid=""
newrc=0
pdir=""
#            - procedural
makespec=1
makecube=1
makewf=1
viewspec=1
viewcube=0
viewnemo=1

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do
    export $arg
done

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#             see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${obsnum}.rc
if [ -e $rc ] && [ $newrc = 0 ]; then
    echo "LMTOY>> reading $rc"
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    for arg in $*; do
        echo "$arg" >> $rc
    done
    source ./$rc
    newrc=0
else
    newrc=1
fi


if [ $newrc = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path - not implemented"
else
    echo "LMTOY>> updating"
fi

#             derived parameters (you should not have to edit these)
p_dir=${path}
s_on=${src}_${obsnum}
s_nc=${s_on}.nc


#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

# -----------------------------------------------------------------------------------------------------------------

if [ -e rsr.wf0.pdf ]; then
    first=0
else
    first=1
fi

# first time, do a run with no badlags or rfile
if [ $first == 1 ]; then
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  -w rsr.wf0.pdf -p -b 3   > rsr0.log 2>&1	
fi
    
# output: rsr.badlags sbc.png
if [ ! -e rsr.badlags ]; then
    python $LMTOY/examples/seek_bad_channels.py $obsnum                         > rsr4.log 2>&1
fi
    
# output: $src_rsr_spectrum.txt
b="--badlags rsr.badlags"
r="--rfile rsr.rfile"
python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r -w rsr.wf.pdf -p -b 3  > rsr1.log 2>&1

# output: rsr.obsnum.sum.txt
python $LMTOY/examples/rsr_sum.py -b rsr.obsnum    $b                           > rsr2.log 2>&1

# output: rsr.blanking.sum.txt
python $LMTOY/examples/rsr_sum.py -b rsr.blanking  $b                           > rsr3.log 2>&1

# NEMO summary spectra
if [ ! -z $NEMO ]; then
    echo "LMTOY>> Some NEMO post-processing"
    dev=$(yapp_query png ps)
    tabplot ${src}_rsr_spectrum.txt    line=1,1 color=2 ycoord=0      yapp=${src}_rsr_spectrum.sp.$dev/$dev  debug=-1
    tabplot rsr.obsnum.sum.txt         line=1,1 color=2 ycoord=0      yapp=rsr.obsnum.sum.sp.$dev/$dev       debug=-1
    tabplot rsr.blanking.sum.txt       line=1,1 color=2 ycoord=0      yapp=rsr.blanking.sum.sp.$dev/$dev     debug=-1
    tabtrend ${src}_rsr_spectrum.txt 2 | tabhist - robust=t xcoord=0  yapp=${src}_rsr_spectrum.rms.$dev/$dev debug=0
    tabtrend rsr.obsnum.sum.txt      2 | tabhist - robust=t xcoord=0  yapp=rsr.obsnum.sum.rms.$dev/$dev      debug=0
    tabtrend rsr.blanking.sum.txt    2 | tabhist - robust=t xcoord=0  yapp=rsr.blanking.sum.rms.$dev/$dev    debug=0
else
    echo "LMTOY>> Skipping NEMO"
fi

# -----------------------------------------------------------------------------------------------------------------

# ADMIT
if [ $admit == 1 ]; then
    lmtoy_admit.sh rsr.blanking.sum.txt
    lmtoy_admit.sh ${src}_rsr_spectrum.txt
fi
    
#
rsr_readme > README.html

# first time?
if [ $first == 1 ]; then
    echo "RSR: first time run, preserving a few first run figures"
fi

echo "LMTOY>> ADMIT post-processing"
lmtoy_admit.sh

echo "LMTOY>> Parameter file used: $rc"

echo "LMTOY>> Making summary index.html:"
mk_index.sh
