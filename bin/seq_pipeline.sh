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
# @todo   vlsr= only takes correct effect on the first run, not a re-run

_version="seq_pipeline: 9-aug-2023"

echo "LMTOY>> $_version"

#--HELP   
# input parameters (only obsnum is required)
#            - start or restart  ($first is now used here)
obsnum=0                              # required
oid=""                                # optional (usually same as the bank)
pdir=""                               # usually given (otherwise current directory used)
#            - procedural
makespec=1     # (re)make a specfile
makecube=1     # (re)make a fits cube
makewf=1
viewspec=1
viewcube=0
viewnemo=1
admit=0
maskmoment=1
clean=1
#            - meta parameters that will compute other parameters for SLR scripts
extent=0       # half the size of the (square) box on the sky for gridding (arcsec)
dv=100         # half the width around the VLSR where the spectral line is expected
dw=250         # 
#            - birdies (list of channels, e.g.   10,200,1021)   @todo 0 or 1 based
birdies=0
#            - override numbands to read only 1 band if 2 is not correct. 0=auto-detect
#numbands=0
#            - override the default map_coord   (-1,0,1,2 = default, HOR, EQU, GAL)
map_coord_use=-1
#            - parameters that directly match the SLR scripts
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=-4          # absolute or if negative, normalized to robust sigma cut
location=0,0        # location (in arcsec) w.r.t. center where spectrum is shown
# resolution=12.5   # will be computed from skyfreq
# cell=6.25         # will be computed from resolution/2
# nppb=-1           # number of points per beam (positive will override cell=)
rmax=3              # number of pixels/resolutions to extend convolved signal
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
debug=0           # add lots of verbosities


#--HELP
show_vars="extent dv dw birdies map_coord_use pix_list rms_cut location \
           rmax otf_select otf_a otf_b otf_c noise_sigma b_order stype \
           sample otf_cal edge bank \
          "
          #  resolution cell nppb \


# unset these, since setting them will give a new meaning, different from the lmtinfo based defaults
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

# exceptions allowed to be overridden:   vlsr, restfreq
if [ ! -z $vlsr ]; then
    echo "vlsr=$vlsr              # Warning: reset" >> $rc
fi
if [ ! -z $restfreq ]; then
    echo "restfreq=$restfreq      # Warning: reset" >> $rc
fi

echo "ARGS: $_lmtoy_args"

# recompute derived parameters, and write them back to the rc file

if [[ $first == 1 ]] || [[ "$_lmtoy_args"  == *"dv="* ]] || [[ "$_lmtoy_args"  == *"dw="* ]]; then
    echo "LMTOY>> setting (base)line regions from  dv=$dv dw=$dw"

    v0=$(nemoinp $vlsr-$dv)     # $(echo $vlsr - $dv | bc -l)
    v1=$(nemoinp $vlsr+$dv)     # $(echo $vlsr + $dv | bc -l)
    w0=$(nemoinp $v0-$dw)       # $(echo $v0 - $dw | bc -l)
    w1=$(nemoinp $v1+$dw)       # $(echo $v1 + $dw | bc -l)
    
    b_regions=[[$w0,$v0],[$v1,$w1]]
    l_regions=[[$v0,$v1]]
    slice=[$w0,$w1]
    v_range=$v0,$v1
    
    echo "# based on vlsr=$vlsr, dv=$dv,  dw=$dw" >> $rc
    echo b_regions=$b_regions       >> $rc
    echo l_regions=$l_regions       >> $rc
    echo slice=$slice               >> $rc
    echo v_range=$v_range           >> $rc
fi

if [[ $first == 1 ]] || [[ "$_lmtoy_args"  == *"extent="* ]]; then
    echo "# setting extent"         >> $rc
    if [[ $extent != 0 ]]; then
	echo x_extent=$extent       >> $rc
	echo y_extent=$extent       >> $rc
    else
	# deal with gridding bug (map needs to be squared)
	if [ $x_extent -gt $y_extent ]; then
    	    echo y_extent=$x_extent    >> $rc
	fi
	if [ $x_extent -lt $y_extent ]; then
	    echo x_extent=$y_extent    >> $rc
	fi
	echo "#xy_extent forced same"  >> $rc
    fi
fi

if [[ $first == 1 ]] || [[ "$_lmtoy_args"  == *"pix_list="* ]]; then
    echo "# setting pix_list $pix_list"      >> $rc
    #    re-interpret pix_list
    echo "pix_list=$(pix_list.py $pix_list)" >> $rc
fi

if [[ "$_lmtoy_args"  == *"resolution="* ]] || [[ "$_lmtoy_args"  == *"cell="* ]] ||  [[ "$_lmtoy_args"  == *"nppb="* ]]; then
    # @todo   new hack to allow resolution/cell > 2       
    echo "# resolution hack"        >> $rc
    echo resolution=$resolution     >> $rc
    cell=$(nemoinp "ifgt($nppb,0.0,$resolution/$nppb,$cell)")
    echo cell=$cell                 >> $rc
fi

if [[ $first == 1 ]] || [[ "$_lmtoy_args"  == *"vlsr="* ]]; then
    echo "vlsr=$vlsr         # set" >> $rc
fi

# feb 2023 - work around the numbands=2 bug (only one bad obsnum was used: 105907/105908)
if [ $numbands = -2 ]; then
    echo "# feb2023 numbands bug"                      >> $rc
    echo "numbands=1  # feb 2023 bug"                  >> $rc
    echo "skyfreq=$(echo $skyfreq | tabcols - 1)"      >> $rc
    echo "restfreq=$(echo $restfreq | tabcols - 1)"    >> $rc
fi

# check if numbands=2 and only one restfreq given; if so, set numbands=1 etc.
if [ $numbands = 2 ]; then
    rf1="$(echo $restfreq | tabcols - 1)"
    rf2="$(echo $restfreq | tabcols - 2)"
    echo "LMTOY>> rf1=$rf1 rf2=$rf2"
    if [ $rf1 = 0.0 ]; then
	echo "numbands=1  # only RF2 used"             >> $rc
	echo "skyfreq=$(echo $skyfreq | tabcols - 2)"  >> $rc
	echo "restfreq=$(echo $restfreq | tabcols - 2)">> $rc
	echo "oid=1    # not used yet"                 >> $rc
	echo "bank=1"                                  >> $rc
    fi
    if [ $rf2 = 0.0 ]; then
	echo "numbands=1  # only RF1 used"             >> $rc
	echo "skyfreq=$(echo $skyfreq | tabcols - 1)"  >> $rc
	echo "restfreq=$(echo $restfreq | tabcols - 1)">> $rc
	echo "oid=0     # not used yet"                >> $rc
	echo "bank=0"                                  >> $rc
    fi
fi

#
echo map_coord_use=$map_coord_use                      >> $rc
    

# source again - ensure we have the changed variables 
source $rc


echo "LMTOY>> this is your startup rc=$rc file:"
cat $rc
echo "LMTOY>> Sleeping for 2 seconds before continuing"
sleep 2

if [ $bank != -1 ]; then
    # pick only this selected bank
    echo "LMTOY>> selecting only bank $bank with numbands=$numbands"
    rc1=lmtoy_${obsnum}__${bank}.rc    
    [ ! -e $rc1 ] && cp $rc $rc1 && rc=$rc1
    s_on=${src}_${obsnum}__${bank}
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    lmtoy_seq1
    nb=1
elif [ $numbands == 2 ]; then
    # new style, April 2023 and beyond
    echo "LMTOY>> looping over numbands=$numbands restfreq=$restfreq"
    IFS="," read -a restfreqs <<< $restfreq
    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)
	oid=$bank    # not used yet
	echo "LMTOY>> Preparing for bank=$bank"
	rc1=lmtoy_${obsnum}__${bank}.rc
	if [ ! -e $rc1 ]; then
	   cp $rc $rc1
	   rc=$rc1
	   echo "restfreq=${restfreqs[$bank]}  # special for bank=$bank " >> $rc
	fi
	s_on=${src}_${obsnum}__${bank}
	s_nc=${s_on}.nc
	s_fits=${s_on}.fits
	w_fits=${s_on}.wt.fits
	lmtoy_seq1	
    done
    nb=$numbands
elif [ $numbands == 1 ]; then
    # old style, before April 2023, we should not use it anymore
    echo "LMTOY>> numbands=1 -- old style"
    bank=0
    rc1=lmtoy_${obsnum}__${bank}.rc
    [ ! -e $rc1 ] && cp $rc $rc1 && rc=$rc1
    s_on=${src}_${obsnum}__${bank}
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    lmtoy_seq1
    nb=1
else
    nb=0
    echo "LMTOY>> cannot process numbands/bank option"
fi

echo "LMTOY>> Processed $nb bands"
