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

_version="rsr_pipeline: 16-mar-2023"

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
badcb=""      # set to a comma separated list of (chassis/board) combinations, badcb=2/3,3/5
badlags=""    # set to a badlags file if to use this instead of dynamically generated (use 0 to force not to use it)
shortlags=""  # set to a short_min and short_hi to avoid flagged strong continuum source lags

linecheck=0   # set to 1, to use the source name to grab the correct xlines=
bandzoom=5    # the band for the zoomed window
speczoom=""   # override bandzoom with a manual speczoom=CENTER,HALF_WIDTH pair
rthr=0.01     # -r option for rsr_driver Threshold sigma value when averaging single observations repeats
cthr=0.01     # -t option for rsr_driver Threshold sigma value when coadding all observations
              # -t option for rsr_sum as well
sgf=0         # Savitzky-Golay high pass filter ; odd number > 21
notch=0       # sigma cut for notch filter to eliminate large frecuency oscillations. Needs sgf > 21
blo=1         # order of polynomial baseline subtraction

#            - procedural
admit=0
#            - debug
debug=0

# An interactive example: for a given o= this shows roughly how the pipeline works:
#
#      o=104090
#      echo $o > rsr.obsnum
#      badlags.py $o                               # watch the badcb=
#      rsr_tsys.py --badlags rsr.badlags $o        # watch the badcb=
#      badcb=1/1,2/4,3/5                           # merge the two badcb's
#      rsr_blanking $o            > rsr.blanking
#      rsr_rfile    $o            > rsr.rfile
#      rsr_badcb -b -o $o $badcb >> rsr.blanking   # optional if there are badcb's
#      rsr_badcb -r -o $o $badcb >> rsr.rfile      # optional if there are badcb's
#      rsr_sum.py -b rsr.blanking  --badlags rsr.badlags  --o1 1 -t 0.01
#      python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  --badlags rsr.badlags --rfile rsr.rfile  -o rsr.driver.sum.txt -w rsr.wf.pdf -p -b 1 -r 999 -t 0.05
#      rsr_spectra.py rsr.blanking.sum.txt and rsr.driver.sum.txt
#
# The last command throws up the two spectra for comparison in matplotlib, where some panning and zooming can be done.
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
    echo "LMTOY>> Processing badcb=$badcb"

    if [[ ! -z "$badcb" ]]; then
	# badcb needs to be formatted as "c1/b1,c2/b2,....."
	rsr_badcb -b -o $obsnum $badcb >> $blanking
	rsr_badcb -r -o $obsnum $badcb >> $rfile
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
