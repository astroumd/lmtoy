#! /bin/bash
#
#  A simple LMT OTF pipeline in bash.
#  Really should be written in python, but hey, here we go.
#
#  Note:   this will only reduce one OBSNUM.   If you place a file "lmtoy_$obsnum.rc"
#          in the current directory, parameters will be read from it.
#          If it does not exist, it will be created on the first run and you can edit it
#          for subsequent runs
#          If projectid is set, this is the subdirectory, within which obsnum is set
#
# There is no good mechanism here to make a new variable depend on re-running a certain task
# on which it depends that's perhaps for a more advanced pipeline
#
# @todo   if close to running out of memory, process_otf_map2.py will kill itself. This script does not gracefully exit

_version="seq_pipeline: 13-jun-2023"

echo "LMTOY>> $_version"

#--HELP   
# input parameters (only obsnum is required)
#            - start or restart
obsnum=0
oid=""
pdir=""
data_lmt=${DATA_LMT:-data_lmt}
#            - procedural
makespec=1
makecube=1
makewf=1
viewspec=1
viewcube=0
viewnemo=1
admit=0
maskmoment=1
clean=1
#            - meta parameters that will compute other parameters for SLR scripts
extent=0
dv=100
dw=250
#            - birdies (list of channels, e.g.   10,200,1021)   @todo 0 or 1 based
birdies=0
#            - override numbands to read only 1 band if 2 is not correct. 0=auto-detect
numbands=0
#            - override the default map_coord   (-1,0,1,2 = default, HO, EQ, GA)
map_coord_use=-1
#            - parameters that directly match the SLR scripts
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=-4
location=0,0
resolution=12.5   # will be computed from skyfreq
cell=6.25         # will be computed from resolution/2
nppb=-1           # number of points per beam (positive will override cell=)
rmax=3            # number of pixels/resolutions to extend convolved signal
otf_select=1
otf_a=1.1
otf_b=4.75
otf_c=2
noise_sigma=1
b_order=0
stype=2
sample=-1
otf_cal=0
edge=0            #  1:  fuzzy edge  0: good sharp edge where M (mask) > 0 [should be default]
bank=-1           # -1:  all banks 0..numbands-1; otherwise select that bank (0,1,...)

#                 debug (set -x)
debug=0

#--HELP
show_vars="extent dv dw birdies numbands map_coord_use pix_list rms_cut location resolution \
           cell nppb rmax otf_select otf_a otf_b otf_c noise_sigma b_order stype \
           sample otf_cal edge bank \
          "


# unset a view things, since setting them will give a new meaning
unset vlsr
unset restfreq

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
    echo No PDIR directory used, all work from the current directory
fi


#             process the parameter file(s)
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
#             optional "oid" parameter file
rc1=./lmtoy_${obsnum}__${oid}.rc
if [ ! -z "$oid" ]; then
    echo "date=\"$date\"     # begin"        >> $rc1    
    show_vars oid $show_vars                 >> $rc1
fi


# @todo   lmtinfo.py should set this now
ifproc=$(ls ${data_lmt}/ifproc/*${obsnum}*.nc)
if [ -z $ifproc ]; then
    rm -f $rc
    echo No matching obsnum=$obsnum and data_lmt=$data_lmt
    echo The following rc files are present here:
    ls lmtoy_*.rc | sed s/lmtoy_// | sed s/.rc//
    exit 0
fi
echo "# Using ifproc=$ifproc" >> $rc
echo "# data_lmt=$data_lmt"   >> $rc

# exceptions allowed to be overridden:   vlsr, restfreq
if [ ! -z $vlsr ]; then
    echo "vlsr=$vlsr              # set" >> ./$rc
fi
if [ ! -z $restfreq ]; then
    echo "restfreq=$restfreq      # set" >> ./$rc
fi
source $rc

#   w0   v0   v1     w1
#v0=$(echo $vlsr - $dv | bc -l)
#v1=$(echo $vlsr + $dv | bc -l)
#w0=$(echo $v0 - $dw | bc -l)
#w1=$(echo $v1 + $dw | bc -l)

v0=$(nemoinp $vlsr-$dv)
v1=$(nemoinp $vlsr+$dv)
w0=$(nemoinp $v0-$dw)
w1=$(nemoinp $v1+$dw)

# recompute derived parameters, and write them back to the rc file

b_regions=[[$w0,$v0],[$v1,$w1]]
l_regions=[[$v0,$v1]]
slice=[$w0,$w1]
v_range=$v0,$v1

echo "# based on vlsr=$vlsr, dv=$dv,  dw=$dw" >> $rc
echo b_regions=$b_regions       >> $rc
echo l_regions=$l_regions       >> $rc
echo slice=$slice               >> $rc
echo v_range=$v_range           >> $rc
if [ $extent != 0 ]; then
    echo x_extent=$extent       >> $rc
    echo y_extent=$extent       >> $rc
else
    # deal with gridding bug
    if [ $x_extent -gt $y_extent ]; then
    	echo y_extent=$x_extent    >> $rc
    fi
    if [ $x_extent -lt $y_extent ]; then
	echo x_extent=$y_extent    >> $rc
    fi
    echo "#xy_extent should be same">> $rc
fi

#  allow the complement to be removed, e.g. pix_list=-0,-5
echo pix_list=$(pix_list.py $pix_list)  >> $rc
    
# @todo   new hack to allow resolution/cell > 2       
echo "# resolution hack?"       >> $rc
echo resolution=$resolution     >> $rc
cell=$(nemoinp "ifgt($nppb,0.0,$resolution/$nppb,$cell)")
echo cell=$cell                 >> $rc

# feb 2023 - work around the numbands=2 bug (only one bad obsnum was used: 105907/105908)
if [ $numbands = -2 ]; then
    echo "# feb2023 numbands bug"                      >> $rc
    echo "numbands=1  # feb 2023 bug"                  >> $rc
    echo "skyfreq=$(echo $skyfreq | tabcols - 1)"      >> $rc
    echo "restfreq=$(echo $restfreq | tabcols - 1)"    >> $rc
fi

#
echo map_coord_use=$map_coord_use                      >> $rc
    

# source again to ensure the changed variables are in
source $rc


echo "LMTOY>> this is your startup $rc file:"
cat $rc
echo "LMTOY>> Sleeping for 2 seconds, you can  abort, edit $rc, then continuing"
sleep 2

#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

#             derived parameters (you should not have to edit these)
p_dir=${data_lmt}

#             redo CLI again is now not needed anymore
# lmtoy_args "$@"

if [ $bank != -1 ]; then
    # pick only this selected bank
    echo "LMTOY> selecting only bank $bank"
    if [ ! -z "$oid" ]; then
	s_on=${src}_${obsnum}__${oid}
    else
	s_on=${src}_${obsnum}__${bank}
    fi
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    lmtoy_seq1
    nb=1
elif [ $numbands == 2 ]; then
    # new style, April 2023 and beyond
    echo "LMTOY>> looping over numbands=$numbands"
    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)
	echo "LMTOY>> Preparing for bank = $bank / $numbands"
	s_on=${src}_${obsnum}__${bank}
	s_nc=${s_on}.nc
	s_fits=${s_on}.fits
	w_fits=${s_on}.wt.fits
	lmtoy_seq1	
    done
    nb=$numbands
elif [ $numbands == 1 ]; then
    # old style, before April 2023, we should not use it anymore
    echo "LMTOY>> numbands=1"
    s_on=${src}_${obsnum}
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    bank=0
    lmtoy_seq1
    nb=1
else
    nb=0
    echo "LMTOY>> unprocessable numbands/bank option"
fi

echo "LMTOY>> Processed $nb bands"
