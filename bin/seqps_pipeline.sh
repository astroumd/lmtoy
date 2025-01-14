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

_version="seqps_pipeline: 3-oct-2024"

echo "LMTOY>> $_version"

#--HELP
#  A simple LMT Sequoia Ps pipeline 
#
#  input parameters
#            - start or restart
path=${DATA_LMT:-data_lmt}
obsnum=0
pdir=""
admit=1
clean=1
debug=0
#            - meta parameters that will compute other parameters for SLR scripts
dv=100
dw=250
#            - parameters that directly match the SLR scripts
pix_list=10       # the on-source beam
stype=2
rms_cut=-4
bank=-1           # -1 means all banks 0..numbands-1
#--HELP

# @todo
show_vars="dv dw \
          "
# LMTOY 
source lmtoy_functions.sh
lmtoy_args "$@"

# PI parameters, as merged from defaults and CLI
rc0=$WORK_LMT/tmp/lmtoy_${obsnum}.rc
show_vars $show_vars > $rc0

# unset a view things, since setting them will give a new meaning
unset vlsr

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#             see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo "LMTOY>> Working directory $pdir"
    mkdir -p $pdir
    cd $pdir
else
    echo "LMTOY>> No PDIR directory used, all work from the current directory $(pwd)"
fi

if [ -e lmtoy.rc ]; then
    first=0
else
    first=1
fi



#             process the parameter file (or force new one with first=1)
rc=./lmtoy_${obsnum}.rc
if [ -e $rc ]; then
    echo "LMTOY>> creating bootstrap $rc"
    echo "#! rc=$rc:"                             > $rc
    echo "# $_version bootstrap version rc"      >> $rc
    echo "lmtoy_repo=$(lmtoy_repo)"              >> $rc
    lmtinfo.py $obsnum                           >> $rc   # <lmtinfo>
    cat $rc0                                     >> $rc   # <show_vars>
    show_args                                    >> $rc   # <show_args>
    source $rc
    # deal with old pre-2023 data
    if [ $numbands = 1 ]; then
	echo "bank=0   # old data"               >> $rc
    fi
fi
source $rc
show_args  > $rc0
source $rc0

if [ $bank -ge 0 ]; then
    # 2nd time with numbands=2 or 1st time with numbands=1
    rc1=lmtoy_${obsnum}__${bank}.rc
    if [ -e $rc1 ]; then
	source $rc1
	echo "LMTOY>> Found rc1=$rc1"
	echo "#! rc=$rc1"                        >> $rc1
	echo "date=\"$date\"     # begin"        >> $rc1    
    else
	cp $rc $rc1
    fi
    show_args                                    >> $rc1   # <show_args>	
    rc=$rc1
else
    # only first time with numbands=2
    echo "date=\"$date\"     # begin2"           >> $rc
    show_args                                    >> $rc    # <show_args>
fi
source $rc


if [ $first = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path"
    echo "# $_version"                           > $rc
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    echo "# obsnum=$obsnum" >> $rc

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
    lmtoy_ps1
elif [ $numbands == 2 ]; then
    # new style, April 2023 and beyond
    echo "LMTOY>> looping over numbands=$numbands restfreq=$restfreq"
    IFS="," read -a skyfreqs <<< $skyfreq
    IFS="," read -a restfreqs <<< $restfreq
    IFS="," read -a bandwidths <<< $bandwidth
    # "expr 1 - 1" returns an error state 1 to the shell (it's a feature)
    for bank in $(seq 0 $(expr $numbands - 1)); do
	echo "LMTOY>> Preparing for bank=$bank"
	rc1=lmtoy_${obsnum}__${bank}.rc
	if [ ! -e $rc1 ]; then
	   cp $rc $rc1
	   rc=$rc1
	   echo "skyfreq=${skyfreqs[$bank]}      # special for bank=$bank " >> $rc
	   echo "restfreq=${restfreqs[$bank]}    # special for bank=$bank " >> $rc
	   echo "bandwidth=${bandwidths[$bank]}  # special for bank=$bank " >> $rc	   
	fi
	s_on=${src}_${obsnum}__${bank}
	s_nc=${s_on}.nc
	s_fits=${s_on}.fits
	w_fits=${s_on}.wt.fits
	lmtoy_ps1	
    done
    nb=$numbands
elif [ $numbands == 1 ]; then
    # old style, we should not use it anymore
    bank=0
    lmtoy_ps1
else
    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)
	echo "======================================"
	echo "Preparing for bank = $bank / $numbands"
	lmtoy_ps1
    done
    # exit 0
fi

echo "LMTOY>> Processed $nb bands"
