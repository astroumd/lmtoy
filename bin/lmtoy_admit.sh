#! /bin/bash
#
#  Running ADMIT within LMTOY
#
#  Because both LMTOY and ADMIT (via casa) have their own python, we need a
#  wrapper that loads ADMIT inside this script.
#


version="lmtoy_admit: 31-oct-2021"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: [.fits | .txt]"
    echo ""
    echo "   .fits files are assumed to be cubes and 'admit1' will be used"
    echo "   .txt  files are assumed to be spectra and 'admit4' will be used"
    exit 0
else
    echo "LMTOY>> $version"
fi


# debug
# set -x
debug=0


ffile=$1
pdir=""

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

#  put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#  exists?
if [ ! -e $ffile ]; then
    echo Warning: file $ffile does not exist, no ADMIT processing
    exit 0
fi    

#  see if pdir working directory needs to be used
if [ ! -z $pdir ]; then
    echo Working directory $pdir
    mkdir -p $pdir
    cd $pdir
else
    echo No PDIR directory used, all work in the current directory
fi


if [ -d $LMTOY/admit ]; then
    source $LMTOY/admit/admit_start.sh
    # debug: report version
    admit
elif [ ! -z $ADMIT ]; then
    echo Found no attached $LMTOY/admit, but found $ADMIT, so winging it.
    admit    
else    
    echo 'Warning: ADMIT was not attached to LMTOY, there was no $LMTOY/admit symlink'
    exit 0
fi

if [ ! -z $ADMIT ]; then
    echo "LMTOY>> ADMIT post-processing"
    # hacking the admit run:
    apar=$ffile.apar
    if [ ! -e $apar ]; then
        touch $apar
        echo 'usePV = False'  >> $apar
    fi
    
    # make sure Xvfb has been cleaned up; kill oldest 2 when there are more than 32
    # casaclean foobar
    n=$(ps axo pid,stat,fname | grep Xvfb | wc -l)
    if [ $n -gt 32 ]; then
	echo Found $n Xvfb
	ps axo pid,stat,fname  | grep Xvfb | sort -nr | tail -4
	pkill -o Xvfb
	pkill -o Xvfb
    fi

    if [[ $ffile == *.fits ]] ; then
	runa1 $ffile
    elif [[ $ffile == *.txt ]] ; then
	runa4 $ffile
    else
	echo "Unknown file extension in $ffile (.fits and .txt are currently supported)"
    fi
fi

