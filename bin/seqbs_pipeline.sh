#! /bin/bash
#
#  A simple LMT Bs pipeline in bash.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#          in the current directory, parameters will be read from it.
#          If it does not exist, it will be created on the first run and you can edit it
#          for subsequent runs
#          If projectid is set, this is the subdirectory, within which obsnum is set
#

version="seqbs_pipeline: 30-sep-2024"

echo "LMTOY>> $version"

#--HELP
#  A simple LMT Sequoia Bs pipeline 
#
#  input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=-1
newrc=0
pdir=""
admit=1
clean=1
debug=0
error=0
#            - meta parameters that will compute other parameters for SLR scripts
dv=100
dw=250
#            - parameters that directly match the SLR scripts
pix_list=10,8     # two selected beams for the nodding beams
stype=2
rms_cut=-4
bank=-1           # -1 means all banks 0..numbands-1
#--HELP

source lmtoy_functions.sh
lmtoy_args "$@"

# unset a view things, since setting them will give a new meaning
unset vlsr

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

if [ -e lmtoy.rc ]; then
    first=0
else
    first=1
fi

#             see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work from the current directory
fi


#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${obsnum}.rc
if [ -e $rc ] && [ $newrc = 0 ]; then
    echo "LMTOY>> reading $rc"
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    for arg in "$@"; do
       export "$arg" >> $rc
    done
    source ./$rc
    newrc=0
else
    newrc=1
fi


if [ $newrc = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path"
    echo "# $version"                            > $rc
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    echo "# obsnum=$obsnum" >> $rc

    if [ ! -d ${path}/ifproc ]; then
	echo There is no ifproc directory in ${path}
	rm $rc
	exit 1
    fi
    if [ ! -d ${path}/spectrometer ]; then
	echo There is no spectrometer directory in ${path}
	rm $rc	
	exit 1
    fi
    if [ ! -d ${path}/spectrometer/roach0 ]; then
	echo There is no spectrometer/roach0 directory in ${path}
	rm $rc	
	exit 1
    fi
    
    ifproc=$(ls ${path}/ifproc/*${obsnum}*.nc)
    if [ -z $ifproc ]; then
	rm -f $rc
	echo No matching obsnum=$obsnum and path=$path
	echo The following rc files are present here:
	ls lmtoy_*.rc | sed s/lmtoy_// | sed s/.rc//
	exit 0
    fi
    echo "# Using ifproc=$ifproc" >> $rc
    echo "# path=$path"           >> $rc

    # lmtinfo grabs some useful parameters from the ifproc file
    lmtinfo.py $obsnum | tee -a $rc
    source ./$rc
    
    #   w0   v0   v1     w1
    v0=$(echo $vlsr - $dv | bc -l)
    v1=$(echo $vlsr + $dv | bc -l)
    w0=$(echo $v0 - $dw | bc -l)
    w1=$(echo $v1 + $dw | bc -l)

    b_order=$b_order
    b_regions=[[$w0,$v0],[$v1,$w1]]
    l_regions=[[$v0,$v1]]
    slice=[$w0,$w1]
    v_range=$v0,$v1

    echo "# based on vlsr=$vlsr, dv=$dv,  dw=$dw" >> $rc
    echo b_order=$b_order           >> $rc
    echo b_regions=$b_regions       >> $rc
    echo l_regions=$l_regions       >> $rc
    echo slice=$slice               >> $rc
    echo v_range=$v_range           >> $rc
    echo pix_list=$pix_list         >> $rc
    echo stype=$stype               >> $rc
    
    # source again to ensure the changed variables are in
    source ./$rc
    

    echo "LMTOY>> this is your startup $rc file:"
    cat $rc
    echo "LMTOY>> Sleeping for 5 seconds, you can  abort, edit $rc, then continuing"
    sleep 5
else
    echo "LMTOY>> updating"
fi

#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

#             derived parameters (you should not have to edit these)
p_dir=${path}
#             redo CLI again  - @todo     do we still need this?
lmtoy_args "$@"


#             pick one bank, or loop over all allowed banks
if [ $bank != -1 ]; then
    lmtoy_bs1
elif [ $numbands == 1 ]; then
    # old style, we should not use it anymore
    bank=0
    lmtoy_bs1
else
    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)
	echo "======================================"	
	echo "Preparing for bank = $bank / $numbands"
	lmtoy_bs1
    done
fi
