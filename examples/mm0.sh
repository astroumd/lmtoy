#! /bin/bash
#
#  Wrapper to bin channels by 15 (for now)
#
#  Because both LMTOY and ADMIT (via casa) have their own python, we need a
#  wrapper that loads CASA inside this script (via admit)
#


version="mm0.sh: 17-aug-2023"

if [ -z $2 ]; then
    echo "LMTOY>> Usage: input.fits output.fits"
    echo ""
    exit 0
else
    echo "LMTOY>> $version"
fi


# debug
# set -x
debug=0


ifile=$1
ofile=$2

#  put in bash debug mode
if [ $debug = 1 ]; then
    set -x
fi

#  exists?
if [ ! -e $ifile ]; then
    echo Warning: file $ffile does not exist, no ADMIT processing
    exit 0
fi    

if [ -d $LMTOY/admit ]; then
    source $LMTOY/admit/admit_start.sh
    # debug: report version
    admit
elif [ ! -z $ADMIT ]; then
    echo "Found no attached $LMTOY/admit, but found $ADMIT, so winging it."
    admit
elif [ ! -z "${CASA_PATH}" ]; then
    echo "Found CASA_PATH, winging it"
else    
    echo 'Warning: ADMIT was not attached to LMTOY, there was no $LMTOY/admit symlink'
    exit 0
fi

# casa -c 'imrebin(imagename="Arp91_97559_97913__0.fits", outfile="junk15.im", factor=[1, 1, 15]);exportfits("junk15.im","junk15.fits")'

rm -rf junk15.im

cmd1="imrebin(imagename=\"${ifile}\", outfile=\"junk15.im\", factor=[1, 1, 15])"
cmd2="exportfits(\"junk15.im\",\"${ofile}\")"


echo cmd1: $cmd1
echo cmd2: $cmd2

casa --nogui --nologger -c "${cmd1};${cmd2}"
