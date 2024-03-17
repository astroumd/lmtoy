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


version="seq_combine: 16-mar-2024"

echo "LMTOY>> $version"    

#--HELP

# This will combine OBSNUM based OTF data that were reduced with seq_pipeline.sh
# Parameters are taken from the first lmtoy_OBSNUM.rc file in the OBSNUM list,
# but can be overridden here where we implemented this (TBD)

# input parameters
#            - start or restart
obsnums=0                       # comma separated list of obsnums to combine
bank=-1                         # process a specific bank, or loop over all banks
output=""                       # override the OFIRST_OLAST name?   == don't use yet ==
#            - procedural
makecube=1
viewcube=0
viewnemo=1
admit=0
maskmoment=1
clean=1
#                   debug
debug=0
#--HELP


#    @todo fix this for combo, we should not need parameters as they are all inherited from the single obsnum run(s)
if [ 1 = 0 ]; then
    unset pix_list
    location=0,0
    resolution=12.5   # will be computed from skyfreq
    cell=6.25         # will be computed from resolution/2
    nppb=-1           # 
    rmax=3            # convolution size in terms of resolution
    otf_select=1      # beam type
    otf_a=1.1
    otf_b=4.75
    otf_c=2
    noise_sigma=1
    b_order=0
    stype=2
    edge=0
fi

show_vars="bank"

source lmtoy_functions.sh
lmtoy_args "$@"

#             put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

if [ $obsnums = 0 ]; then
    echo obsnums= not given
    exit 0
fi
lmtoy_decipher_obsnums

# WARNING:   the current workflow always does a restart=1 type computation

# if bank was already given, use that. The default should be -1, ie. find all banks available
ext=""
if [ $bank -ge 0 ]; then
    ext="__$bank"
fi
echo "bank=$bank"

# $on0 is the first obsnum, so look for the appropriate rc file, but first use the bootstrap rc
# this wildcard will actually allow us to combine obsnum across ProjectId's
#

# @todo   always do boostrap,   read the $bank if $bank was given

files=(*/$on0/lmtoy_${on0}.rc)
echo "LMTOY>> For $on0 : ${#files[@]} ${files[@]}"
if [ ${#files[@]} == 1 ]; then
    rc0=$files
elif [ ${#files[@]} -gt 1 ]; then
    echo "LMTOY>> winging it with the first one"
    rc0=${files[0]}
else    
    echo "LMTOY>>  no bootstrap rc file found for $on0"
    exit 0
fi

files=(*/$on0/lmtoy_${on0}${ext}.rc)
echo "For $on0 : ${#files[@]} ${files[@]}"
if [ ${#files[@]} == 1 ]; then
    rc1=$files    
elif [ ${#files[@]} -gt 1 ]; then
    # very odd, should exit ?
    echo "Too many matching files for $on0 : ${files[@]}"
    echo "Will use the most recent one:"
    ls -ltr ${files[@]}
    # take the most recent one
    rc1=$(ls -tr ${files[@]} | tail -1)
else
    echo "LMTOY>>  no rc file found for $on0"
    exit 0
fi

loopbanks=0 ; [ $bank -lt 0 ] && loopbanks=1
echo "rc1=$rc1"
source $rc1
echo "bank=$bank"
if [ $loopbanks = 1 ]; then
    banks=0
    [ $numbands -gt 1 ] && banks="0 1"
else
    banks=$bank
fi
echo "banks=$banks"

    
obsnum=${on0}_${on1}
wdir=$ProjectId/${obsnum}
echo "Using wdir=$wdir for src=$src"

# loop over the banks that needs to be processed
for bank in $banks; do
    cd $WORK_LMT
    mkdir -p $wdir

    # ensure we inherited the bootstrap RC file
    rc2=$wdir/lmtoy_${obsnum}.rc
    if [ ! -e $rc2 ]; then
	echo "LMTOY>> Copy bootstrap $rc2 from $rc0"
	cp $rc0 $rc2
	echo "obsnum=$obsnum   # new for combo"         >> $rc2
    fi
    unset rc2

    rc=lmtoy_${obsnum}__${bank}.rc

    # ensure we inherited the RC file for this bank
    if [ ! -e $wdir/$rc ]; then
	rc2=(*/$on0/lmtoy_${on0}__${bank}.rc)
	echo rc2=$rc2
	echo "LMTOY>> creating $wdir/$rc from $rc2"
	cp $rc2 $wdir/$rc
	echo "obsnum=$obsnum   # new for combo"         >> $wdir/$rc
    fi
    source $wdir/$rc

    # loop to first find out which .nc files we have for this bank
    ons=""        # accumulates the .nc filenames
    sumtime=0     # accumulates the integration time
    for on in $obsnums1; do
	fon=$(ls */$on/*_${on}__${bank}.nc)
	# there better be just one
	if [ -e $fon ]; then
	    ons="$ons ${fon}"
	else
	    echo "Warning $fon not found"
	    exit 0
	fi
	frc=$(ls */$on/lmtoy_${on}__${bank}.rc)
	if [ -e $frc ]; then
	    sumtime=$(nemopars inttime $frc | tabmath - - %1+$sumtime all)
	else
	    echo "Warning $frc not found"
	    exit 0
	fi
    done
    echo ONS: $ons
    echo SUMTIME: $sumtime
    
    # construct the names as they are seen from $wdir
    s_nc=../../$(echo $ons | sed 's| |,../../|g')
    echo ONSE:  $s_nc

    cd $wdir

    echo "obsnums=${obsnums}"                      >> $rc
    echo "obsnum=${obsnum}"                        >> $rc
    echo "bank=$bank"                              >> $rc
    echo "inttime=$sumtime  # summed all obsnums"  >> $rc

    s_on=${src}_${on0}_${on1}__${bank}
    if [ ! -z $output ]; then
	s_on=$output
    fi
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits

    echo "OBSNUM range: $on0 $on1 for $obsnum"
    echo "FILES: s_nc: $s_nc"

    #  make sure procedural keywords for seq reduction to not re-make the specfile
    makespec=0
    viewspec=0
    makewf=0

    # override CLI again 
    lmtoy_args "$@"

    lmtoy_seq1

    echo "LMTOY>> Created $s_fits and $w_fits"
    echo "LMTOY>> Parameter file used: $rc"

done
