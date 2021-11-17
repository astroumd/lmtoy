#! /bin/bash
#
#  A simple LMT OTF combination, see lmtoy_reduce.md for help
#
#  Note:   this will combine reductions from different OBSNUM's.
#          Two methods:
#          1. combine all the SpecFiles
#          2. combine the weighted maps  (comes with assumptions)     [not implemented yet]
#             this assumes OBJECT_OBSNUM.fits and OBJECT_OBSNUM.wt.fits for all OBSNUM
#


version="rsr_combine: 16-nov-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnum=ON1,ON2,..."
    echo "LMTOY>> $version"
    echo ""
    echo "This will combine OBSNUM based RSR data that were reduced with rsr_reduce.sh"
    echo "Parameters are taken from the first lmtoy_OBSNUM.rc file, but can be overridden here"
    echo "where we implemented this (TBD)"
    exit 0
else
    echo "LMTOY>> $version"
    echo "##### Warning: this script is under development"
fi


# debug
# set -x
debug=0

# input parameters
#            - start or restart
obsnum=85776,85778,85824
pdir=""
output=""
#            - procedural
makecube=1
viewcube=0
viewnemo=1
#            - parameters that directly match the SLR scripts
unset pix_list
rms_cut=4
location=0,0
resolution=12.5   # will be computed from skyfreq
cell=6.25         # will be computed from resolution/2
rmax=3
otf_select=1
otf_a=1.1
otf_b=4.75
otf_c=2
noise_sigma=1
b_order=0
stype=2

# unset a view things, since setting them will give a new meaning
unset vlsr

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
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


#             differentiate if obsnum is a file or list of obsnums
#             set first and last obsnum, and make a list
if [ -e $obsnum ]; then
    # obsnum is a file
    on0=$(grep -v ^# $obsnum | head -1)
    on1=$(grep -v ^# $obsnum | tail -1)
    obsnum=$(grep -v ^# $obsnum)
else
    # obsnum is a comma separated list
    #         figure out the first obsnum, to inherit basic pars
    on0=$(echo $obsnum | awk -F, '{print $1}')
    on1=$(echo $obsnum | awk -F, '{print $NF}')
    obsnum=$(echo $obsnum | sed 's/,/ /g')
fi
obsnums=$obsnum

rc=0
for on in $obsnums; do
    file=$(ls */$on/lmtoy_$on.rc)
    echo $on : $file
    if [ $rc = 0 ]; then
	if [ -e $file ]; then
	    rc=$file
	fi
    fi
done
source $rc
echo First RC will be used : $rc

pdir=$ProjectId/${on0}_${on1}
echo Using pdir=$pdir
	  
mkdir -p $pdir

# loop again to accumulate the parameter files
rm -f $pdir/rsr.${on0}_${on1}.badlags $pdir/rsr.${on0}_${on1}.blanking  $pdir/rsr.obsnum
for on in $obsnums; do
    file=$(ls */$on/lmtoy_$on.rc)
    echo ACCUM $on : $file
    cat */$on/rsr.$on.rfile    >> $pdir/rsr.${on0}_${on1}.rfile
    cat */$on/rsr.$on.badlags  >> $pdir/rsr.${on0}_${on1}.badlags
    cat */$on/rsr.$on.blanking >> $pdir/rsr.${on0}_${on1}.blanking
    cat */$on/rsr.obsnum       >> $pdir/rsr.obsnum
done

cd $pdir

blanking=rsr.${on0}_${on1}.blanking
rfile=rsr.${on0}_${on1}.rfile
badlags=rsr.${on0}_${on1}.badlags


b="--badlags  $badlags"
r="--rfile    $rfile"
python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r -w rsr.wf.pdf -p -b 3  > rsr1.log 2>&1

python $LMTOY/examples/rsr_sum.py -b rsr.obsnum    $b                           > rsr2.log 2>&1

python $LMTOY/examples/rsr_sum.py -b $blanking  $b                              > rsr3.log 2>&1

# NEMO summary spectra
if [ ! -z $NEMO ]; then
    echo "LMTOY>> Some NEMO post-processing"
    dev=$(yapp_query png ps)
    tabplot  ${src}_rsr_spectrum.txt    line=1,1 color=2 ycoord=0     yapp=${src}_rsr_spectrum.sp.$dev/$dev  debug=-1
    tabplot  rsr.obsnum.sum.txt         line=1,1 color=2 ycoord=0     yapp=rsr.obsnum.sum.sp.$dev/$dev       debug=-1
    tabplot  ${blanking}.sum.txt        line=1,1 color=2 ycoord=0     yapp=${blanking}.sum.sp.$dev/$dev      debug=-1
    tabtrend ${src}_rsr_spectrum.txt 2 | tabhist - robust=t xcoord=0  yapp=${src}_rsr_spectrum.rms.$dev/$dev debug=-1
    tabtrend rsr.obsnum.sum.txt      2 | tabhist - robust=t xcoord=0  yapp=rsr.obsnum.sum.rms.$dev/$dev      debug=-1
    tabtrend ${blanking}.sum.txt     2 | tabhist - robust=t xcoord=0  yapp=${blanking}.sum.rms.$dev/$dev     debug=-1
    tabstat  ${src}_rsr_spectrum.txt 2 bad=0 robust=t qac=t
    tabstat  rsr.obsnum.sum.txt      2 bad=0 robust=t qac=t
    tabstat  ${blanking}.sum.txt     2 bad=0 robust=t qac=t
else
    echo "LMTOY>> Skipping NEMO"
fi


echo OBSNUM range: $on0 $on1

echo "LMTOY>> Parameter file used: $rc"

