#! /bin/bash
#
#  A simple LMT RSR pipeline in bash.
#
#  Note: this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#        in the current directory, parameters will be read from it.
#        If it does not exist, it will be created on the first run and you can edit 
#        it for subsequent runs
#        If ProjectId is set, this is the subdirectory, within which obsnum is set
#
#

_version="rsr_pipeline: 26-feb-2023"

echo "LMTOY>> $_version"

#--HELP   
# input parameters (only obsnum is required)
#            - start or restart
obsnum=0      # this is a single obsnum pipeline (obsnums=0)
obsid=""      # not used yet
pdir=""       # where to do the work
path=${DATA_LMT:-data_lmt}      # - to be deprecated

#             - PI parameters

xlines=""     # set to a comma separated list of freq,dfreq pairs where strong lines are
badboard=""   # set to a comma separated list of bad boards
badcb=""      # set to a comma separated list of (chassis/board) combinations, badcb=2/3,3/5
badlags=""    # set to a badlags file if to use this instead of dynamically generated (use 0 to force not to use it)
shortlags=""  # set to a short_min and short_hi to avoid flagged strong continuum source lags

linecheck=0   # set to 1, to use the source name to grab the correct xlines=
bandzoom=5    # the band for the zoomed window
speczoom=""   # override bandzoom with a manual speczoom=CEN,WID pair
rthr=0.01     # -r option for rsr_driver Threshold sigma value when averaging single observations repeats
cthr=0.01     # -t                       Threshold sigma value when coadding all observations
              # -t option for rsr_sum as well
sgf=0         # Savitzky-Golay high pass filter ; odd number > 21
notch=0       # sigma cut for notch filter to eliminate large frecuency oscillations. Needs sgf > 21
blo=1         # order of polynomial baseline subtraction

#            - procedural
admit=0
#            - debug
debug=0
#--HELP

# LMTOY
source lmtoy_functions.sh
lmtoy_args "$@"

# PI parameters, as merged from defaults and CLI
rc0=$WORK_LMT/tmp/lmtoy_${obsnum}.rc
show_vars \
          xlines badcb badlags linecheck bandzoom speczoom rthr cthr sgf notch blo \
	  > $rc0

#lmtoy_debug
#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#lmtoy_first
if [ -e lmtoy.rc ]; then
    first=0
else
    first=1
fi

#lmtoy_pdir
#             see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


#             process the parameter file
rc=./lmtoy_${obsnum}.rc
if [ ! -e $rc ]; then
    echo "LMTOY>> creating new $rc"
    echo "# $_version"  > $rc
    cat $rc0           >> $rc
    lmtinfo.py $obsnum >> $rc
fi
date=$(lmtoy_date)
echo "#"                                 >> $rc
echo "date=\"$date\"     # begin"        >> $rc
for arg in "$@"; do
    echo "$arg" >> $rc
done
source $rc
rm -f $rc0

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

blanking=rsr.$obsnum.blanking     # for  rsr_sum    - produced by rsr_blanking
rfile=rsr.$obsnum.rfile           # for  rsr_driver - produced by rsr_rfile
if [ -z $badlags ]; then
    badlags=rsr.$obsnum.badlags   # for  rsr_xxx    - produced by badlags.py
fi

if [ $first == 1 ]; then
    # bootstrap  $blanking and $rfile; these are just commented lines w/ examples
    rsr_blanking $obsnum     > $blanking
    rsr_rfile    $obsnum     > $rfile
fi

if [ $obsnum != 0 ]; then
    echo "LMTOY>> Processing badboard=$badboard and badcb=$badcb"

    # should deprecate badboard <--------------------------------------------  deprecate?
    if [[ ! -z "$badboard" ]]; then
	echo "# setting badboard=$badboard" >> $blanking
	echo "# setting badboard=$badboard" >> $rfile
	for b in $(echo $badboard | sed 's/,/ /g'); do
	    for c in 0 1 2 3; do
		echo "$obsnum $c {$b: [(70,115)]}" >> $blanking
		echo "$obsnum,$c,$b"               >> $rfile
	    done
	done
    fi
    if [[ ! -z "$badcb" ]]; then
	# badcb needs to be formatted as "c1/b1,c2/b2,....."
	echo "# setting badcb=$badcb" >> $blanking
	echo "# setting badcb=$badcb" >> $rfile
	cbs=$(echo $badcb | sed 's/,/ /g')
	for cb in $cbs; do
	    cb0=( $(echo $cb | sed 's./. .'))
	    c=${cb0[0]}
	    b=${cb0[1]}
	    echo "$obsnum $c {$b: [(70,115)]}" >> $blanking
	    echo "$obsnum,$c,$b"               >> $rfile
	done
    fi
    # note $badlags is created by badlags.py 
fi

#  grab a "xlines=" from a sourcename based table for linecheck sources
#  @todo  we are not resetting xlines= when linecheck=0 ; user responsibility
if [ $linecheck == 1 ]; then
    if [ -z "$xlines" ]; then
	xlines=$(grep ^${src} $LMTOY/etc/linecheck.tab | awk '{print $2}' | awk -F= '{print $2}')
	echo "xlines=$xlines" >> $rc
    fi
    echo "linecheck=1 for $src : xlines=$xlines"
fi

#             redo CLI again - not needed anymore
# lmtoy_args "$@"

lmtoy_rsr1
