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


version="seq_combine: 10-oct-2022"

echo "LMTOY>> $version"    

#--HELP

# This will combine OBSNUM based OTF data that were reduced with seq_pipeline.sh
# Parameters are taken from the first lmtoy_OBSNUM.rc file in the OBSNUM list,
# but can be overridden here where we implemented this (TBD)

# input parameters
#            - start or restart
obsnums=0                       # comma separated list of obsnums to combine
pdir=""                         # directory where to work
output=""    
#            - procedural
makecube=1
viewcube=0
viewnemo=1
admit=0
clean=1
#                   debug
debug=0
#    @todo fix this for combo
if [ 1 = 1 ]; then
    unset pix_list
    rms_cut=-4
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
    edge=0
fi

#--HELP

if  [ -z $1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ] ;then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

# unset a view things, since setting them will give a new meaning
# unset vlsr

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in "$@"; do
  export "$arg"
done

source lmtoy_functions.sh

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

if [ $obsnums = 0 ]; then
    echo obsnums= not given
    exit 0
fi
lmtoy_decipher_obsnums


rc=0
for on in $obsnums1; do
    files=(*/$on/lmtoy_$on.rc)
    echo $on : ${#files[@]} ${files[@]}
    if [ ${#files[@]} != 1 ]; then
	echo "Too many matching files for $on : ${files[@]}"
	echo "Will use the most recent one:"
	ls -ltr ${files[@]}
	# take the most recent one
	rc=$(ls -tr ${files[@]} | tail -1)
    fi	
    if [ $rc = 0 ]; then
        if [ -e $files ]; then
            rc=$files
        fi
    fi
done
source $rc
echo First RC will be used : $rc

pdir=$ProjectId/${on0}_${on1}
echo Using pdir=$pdir
echo src=$src

# first find out which .nc files we have
ons=""

for on in $obsnums1; do
    fon=$(ls */$on/${src}_${on}.nc)
    if [ -e $fon ]; then
	ons="$ons ${fon}"
    else
	echo Warning $fon not found
    fi
done
echo ONS: $ons

s_nc=../../$(echo $ons | sed 's| |,../../|g')

# combinations work in a subdirectory

mkdir -p $pdir
cp $rc $pdir/lmtoy_${on0}_${on1}.rc
obsnum=${on0}_${on1}
echo obsnums=${obsnums} >> $pdir/lmtoy_${on0}_${on1}.rc
echo obsnum=${obsnum}   >> $pdir/lmtoy_${on0}_${on1}.rc
cd $pdir

s_on=${src}_${on0}_${on1}
if [ ! -z $output ]; then
    s_on=$output
fi
s_fits=${s_on}.fits
w_fits=${s_on}.wt.fits

echo "OBSNUM range: $on0 $on1"
echo "FILES: s_nc: $s_nc"


makespec=0
viewspec=0
makewf=0
# override CLI again
for arg in "$@"; do
  export "$arg"
done

lmtoy_seq1

echo "LMTOY>> Created $s_fits and $w_fits"
echo "LMTOY>> Parameter file used: $rc"

