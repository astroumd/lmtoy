#! /bin/bash
#
#  Specialized continuum processing with a finite size object
#
#

_version="seq_continuum: 5-sep-2024"

echo "LMTOY>> $_version"

#--HELP   
# input parameters (only obsnum is required)
#            - start or restart  ($first is now used here)
obsnum=0                              # required
pdir=""                               # usually given (otherwise current directory used)
#            - procedural
clean=1
#            - meta parameters that will compute other parameters for SLR scripts
tp=205         # brightness temperature (of planet)
dp=6.5         # diameter (of planet)
bank=-1        # don't use

#                 debug (set -x)
debug=0           # add lots of verbosities


#--HELP
show_vars="obsnum tp dp bank"


# LMTOY
source lmtoy_functions.sh
lmtoy_args "$@"

# PI parameters, as merged from defaults and CLI
rc0=$WORK_LMT/tmp/lmtoy_${obsnum}.rc
show_vars $show_vars > $rc0

#lmtoy_debug
#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#lmtoy_pdir
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

#             process the parameter file(s)
#             WARNING:  for RSR this process is fairly simple, but for SEQ
#             dealing with one or two banks this has become a bit more complex

#             bootstrap file
rc=./lmtoy_${obsnum}.rc
if [ ! -e $rc ]; then
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

rm -f $rc0
unset rc0

echo "ARGS: $_lmtoy_args"

# recompute derived parameters, and write them back to the rc file

if [[ $first == 1 ]] || [[ "$_lmtoy_args"  == *"pix_list="* ]]; then
    echo "# setting pix_list $pix_list"      >> $rc
    #    re-interpret pix_list
    echo "pix_list=$(pix_list.py $pix_list)" >> $rc
fi

# feb 2023 - work around the numbands=2 bug (only one bad obsnum was used: 105907/105908)
if [ $numbands = -2 ]; then
    echo "# feb2023 numbands bug"                      >> $rc
    echo "numbands=1  # feb 2023 bug"                  >> $rc
fi

# check if numbands=2 and only one restfreq given; if so, set numbands=1 etc.
if [ $numbands = 2 ]; then
    if [ $rf1 = 0.0 ]; then
	echo "numbands=1  # only RF2 used"               >> $rc
	echo "bank=1"                                    >> $rc
    fi
    if [ $rf2 = 0.0 ]; then
	echo "numbands=1  # only RF1 used"               >> $rc
	echo "bank=0"                                    >> $rc
    fi
fi

# source again - ensure we have the changed variables 
source $rc


echo "LMTOY>> this is your startup rc=$rc file:"
cat $rc
echo "LMTOY>> Sleeping for 2 seconds before continuing"
sleep 2

if [ $bank != -1 ]; then
    # pick only this selected bank - should never happen
    echo "LMTOY>> selecting only bank $bank with numbands=$numbands"
    rc1=lmtoy_${obsnum}__${bank}.rc    
    [ ! -e $rc1 ] && cp $rc $rc1 && rc=$rc1
    echo lmtoy_seq1
    nb=1
elif [ $numbands == 2 ]; then
    # new style, April 2023 and beyond
    echo "LMTOY>> looping over numbands=$numbands"
    # "expr 1 - 1" returns an error state 1 to the shell (it's a feature)
    for bank in $(seq 0 $(expr $numbands - 1)); do
	echo "LMTOY>> Preparing for bank=$bank"
	rc1=lmtoy_${obsnum}__${bank}.rc
	if [ ! -e $rc1 ]; then
	   cp $rc $rc1
	   rc=$rc1
	fi
	echo mars_continuum
	mars_reduction.py -O $obsnum -T $tp -D $dp > mars.log
	mk_index_mars.sh > README.html
    done
    nb=$numbands
elif [ $numbands == 1 ]; then
    # old style, before April 2023, we should not use it anymore
    echo "LMTOY>> numbands=1 -- old style"
    bank=0
    rc1=lmtoy_${obsnum}__${bank}.rc
    [ ! -e $rc1 ] && cp $rc $rc1 && rc=$rc1
    echo lmtoy_seq1
    nb=1
else
    nb=0
    echo "LMTOY>> cannot process numbands/bank option"
fi

lmtoy_version >> lmtoy.rc

echo "LMTOY>> Processed $nb bands"
