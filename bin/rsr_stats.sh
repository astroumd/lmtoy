#! /usr/bin/env bash
#
#   specific stats per band in RSR data
#

#--HELP
# Specific stats per band in RSR data

in=spec.tab       # input table (xcol=1 ycol=2)
xcol=1
ycol=2
yscale=1000       # convert to mK
label=""          # optional stats label
yapp=xs           # xs,png,ps,_ps
debug=-1          # not so verbose for NEMO
xlines=""         # if given, line integral also determined

#--HELP

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

#             simple keyword=value command line parser for bash - don't make any changes below
for arg in "$@"; do
  export "$arg"
done

# yapp helper function
yapp() {
    if test $yapp = "xs"; then
        echo $1/$yapp
    elif test $yapp = "_ps"; then
        echo ${fit}$1.ps
    else
        echo ${fit}$1.$yapp/$yapp
    fi
}

# sanity check
if [ ! -e $in ]; then
    echo File in=$in does not exist
    exit 1
fi

# NEMO's debug level
export DEBUG=$debug

# band_edges = [ (71.72, 79.69), (78.02 , 85.99),  (85.41,  93.38),
#               (90.62, 98.58), (96.92, 104.88), (104.31, 112.28)]
# 73.00078 110.96953125
rsr_band_edges="71.72,79.69 78.02,85.99 85.41,93.38 90.62,98.58 96.92,104.88 104.31,112.28"
rsr_band_edges="73.00,79.69 78.02,85.99 85.41,93.38 90.62,98.58 96.92,104.88 104.31,110.97"

for b in $rsr_band_edges; do
    grep -v nan $in |\
	tabmath - - %${ycol}*${yscale} all "selfie=range(%${xcol},$b)" |\
	tabstat - qac=t robust=t label="$label $b"
done
