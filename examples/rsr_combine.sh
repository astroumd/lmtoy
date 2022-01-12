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
#  Example:   rsr_combine.sh obsnum=33551,71610,92068 

version="rsr_combine: 6-jan-2022"

if [ -z $1 ]; then
    echo "LMTOY>> Usage: obsnums=ON1,ON2,..."
    echo "LMTOY>> $version"
    echo ""
    echo "This will combine OBSNUM based RSR data that were reduced with rsr_reduce.sh"
    echo "Parameters are taken from the first lmtoy_OBSNUM.rc file, but can be overridden here"
    echo "where we implemented this (TBD)"
    exit 0
else
    echo "LMTOY>> $version"
fi

source lmtoy_functions.sh

# debug
# set -x
debug=0

# input parameters
#            - start or restart
obsnums=0
pdir=""
output=""
#            - procedural
admit=1
#            - parameters that directly match the SLR scripts

# unset a view things, since setting them will give a new meaning
unset vlsr

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in $*; do\
  export $arg
done

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
    files=$(*/$on/lmtoy_$on.rc)
    echo $on : ${#files[@]} ${files[@]}
    if [ ${#files[@]} != 1 ]; then
	echo Too many matching files for $on : ${files[@]}
	exit 0
    fi	
    if [ $rc = 0 ]; then
	if [ -e $file ]; then
	    rc=$file
	fi
    fi
done
source $rc
echo First RC will be used : $rc

pdir=$ProjectId/${on0}_${on1}
echo Using pdir=$pdir
echo src=$src

first=0

# loop again to accumulate the parameter files
rm -f $pdir/rsr.${on0}_${on1}.badlags $pdir/rsr.${on0}_${on1}.blanking  $pdir/rsr.obsnum
for on in $obsnums1; do
    file=$(ls */$on/lmtoy_$on.rc)
    echo Using $on : $file
    cat */$on/rsr.$on.rfile    >> $pdir/rsr.${on0}_${on1}.rfile
    cat */$on/rsr.$on.badlags  >> $pdir/rsr.${on0}_${on1}.badlags
    cat */$on/rsr.$on.blanking >> $pdir/rsr.${on0}_${on1}.blanking
    cat */$on/rsr.obsnum       >> $pdir/rsr.obsnum
done
cp $rc $pdir/lmtoy_${on0}_${on1}.rc
obsnum=${on0}_${on1}
echo "obsnum=${obsnum}" >> $pdir/lmtoy_${on0}_${on1}.rc

cd $pdir

blanking=rsr.${on0}_${on1}.blanking
   rfile=rsr.${on0}_${on1}.rfile
 badlags=rsr.${on0}_${on1}.badlags

lmtoy_rsr1

echo OBSNUM range: $on0 .. $on1


