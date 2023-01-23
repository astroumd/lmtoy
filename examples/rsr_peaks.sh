#! /usr/bin/env bash
#
#   fit the first 4 peaks in a spectrum (x and y must be the first two columns)
#

#--HELP
# Fit the first "$peaks" peaks to an ascii spectrum. Columns 1 and 2 need to contain
# the X and Y values.
# Keywords and their defaults

in=spec.tab       # input table (xcol=1 ycol=2)
peaks=1:4         # which peaks, e.g 1:4
yapp=xs           # xs,png,ps,_ps
debug=-1          # not so verbose for NEMO

#--HELP

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in "$@"; do
  export "$arg"
done

# yapp helper function
yapp() {
    if test $yapp = "xs"; then
        echo $1/$yapp
    elif test $yapp = "_ps"; then
        echo fit$1.ps
    else
        echo fit$1.$yapp/$yapp
    fi
}

# sanity check
if [ ! -e $in ]; then
    echo File in=$in does not exist
    exit 1
fi

export DEBUG=$debug

# loop over each peak finder
for ipeak in $(nemoinp $peaks); do
    tabpeak $in npeak=$ipeak | tabnllsqfit - fit=gauss1d out=- |\
	tee fit${ipeak}.log |\
	tabcomment - |\
	tabplot - 1 2,3,4 color=2,3,4 line=1,1 yapp=$(yapp $ipeak)
    #cat fit${ipeak}.log
done

# report the peaks
echo "# $in: fitting a+b*exp(-(x-c)^2/(2*d^2))"
echo "# a (mK)        b (mK)       c (GHz)       d (Ghz)"
for ipeak in $(nemoinp $peaks); do
    txtpar fit${ipeak}.log $ipeak,%1*1000,%2*1000,%3*1000,%4*1000,%5,%6,%7,%8  \
	   p0=a=,1,2 p1=a=,1,3 \
	   p2=b=,1,2 p3=b=,1,3 \
	   p4=c=,1,2 p5=c=,1,3 \
	   p6=d=,1,2 p7=d=,1,3
done
