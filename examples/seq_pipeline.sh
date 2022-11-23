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
# There is no good mechanism here to make a new variable depend on re-running a certain task on which it depends
# that's perhaps for a more advanced pipeline
#
# @todo   close to running out of memory, process_otf_map2.py will kill itself. This script does not gracefully exit

version="seq_pipeline: 10-oct-2022"

echo "LMTOY>> $version"


#--HELP   
# input parameters (only obsnum is required)
#            - start or restart
obsnum=79448
obsid=""
newrc=0
pdir=""
path=${DATA_LMT:-data_lmt}
#            - procedural
makespec=1
makecube=1
makewf=1
viewspec=1
viewcube=0
viewnemo=1
admit=0
clean=1
#            - meta parameters that will compute other parameters for SLR scripts
extent=0
dv=100
dw=250
#            - birdies (list of channels, e.g.   10,200,1021)
birdies=0
#            - parameters that directly match the SLR scripts
pix_list=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
rms_cut=-4
location=0,0
resolution=12.5   # will be computed from skyfreq
cell=6.25         # will be computed from resolution/2
nppb=2            # number of points per beam
rmax=3
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

if [ -z $1 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi

# unset a view things, since setting them will give a new meaning
unset vlsr
unset restfreq

#             simple keyword=value command line parser for bash - don't make any changing below
for arg in "$@"; do
  export "$arg"
done

#
source lmtoy_functions.sh


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


#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${obsnum}.rc
if [ -e $rc ] && [ $newrc = 0 ]; then
    echo "LMTOY>> reading $rc"
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    for arg in "$@"; do
        echo "$arg" >> $rc
    done
    source ./$rc
    newrc=0
else
    newrc=1
fi


if [ $newrc = 1 ]; then
    echo "LMTOY>> Hang on, creating a bootstrap $rc from path=$path"
    echo "# $version"                            > $rc
    echo "# DATE: `date +%Y-%m-%dT%H:%M:%S.%N`" >> $rc
    echo "# obsnum=$obsnum" >> $rc

    if [ ! -d ${path}/ifproc ]; then
	echo There is no ifproc directory in ${path}
	rm $rc
	exit 1
    fi
    if [ ! -d ${path}/spectrometer ]; then
	echo There is no spectrometer directory in ${path}
	rm $rc	
	exit 1
    fi
    if [ ! -d ${path}/spectrometer/roach0 ]; then
	echo There is no spectrometer/roach0 directory in ${path}
	rm $rc	
	exit 1
    fi
    
    ifproc=$(ls ${path}/ifproc/*${obsnum}*.nc)
    if [ -z $ifproc ]; then
	rm -f $rc
	echo No matching obsnum=$obsnum and path=$path
	echo The following rc files are present here:
	ls lmtoy_*.rc | sed s/lmtoy_// | sed s/.rc//
	exit 0
    fi
    echo "# Using ifproc=$ifproc" >> $rc
    echo "# path=$path"           >> $rc

    # lmtinfo grabs some useful parameters from the ifproc file
    lmtinfo.py $obsnum | tee -a $rc
    # exceptions allowed to be overridden:   vlsr, restfreq
    if [ ! -z $vlsr ]; then
	echo "vlsr=$vlsr              # set" >> ./$rc
    fi
    if [ ! -z $restfreq ]; then
	echo "restfreq=$restfreq      # set" >> ./$rc
    fi
    source ./$rc

    #   w0   v0   v1     w1
    #v0=$(echo $vlsr - $dv | bc -l)
    #v1=$(echo $vlsr + $dv | bc -l)
    #w0=$(echo $v0 - $dw | bc -l)
    #w1=$(echo $v1 + $dw | bc -l)

    v0=$(nemoinp $vlsr-$dv)
    v1=$(nemoinp $vlsr+$dv)
    w0=$(nemoinp $v0-$dw)
    w1=$(nemoinp $v1+$dw)

    b_order=$b_order
    b_regions=[[$w0,$v0],[$v1,$w1]]
    l_regions=[[$v0,$v1]]
    slice=[$w0,$w1]
    v_range=$v0,$v1

    echo "# based on vlsr=$vlsr, dv=$dv,  dw=$dw" >> $rc
    echo b_order=$b_order           >> $rc
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
    
    echo pix_list=$pix_list         >> $rc
    
    echo rmax=$rmax                 >> $rc
    echo otf_a=$otf_a               >> $rc
    echo otf_b=$otf_b               >> $rc
    echo otf_c=$otf_c               >> $rc
    echo sample=$sample             >> $rc
    echo otf_cal=$otf_cal           >> $rc
    echo edge=$edge                 >> $rc

    # new hack to allow resolution/cell > 2
    echo resolution=$resolution     >> $rc
    cell=$(nemoinp $resolution/$nppb)
    echo cell=$cell                 >> $rc

    # source again to ensure the changed variables are in
    source ./$rc

    echo "LMTOY>> this is your startup $rc file:"
    cat $rc
    echo "LMTOY>> Sleeping for 5 seconds, you can  abort, edit $rc, then continuing"
    sleep 5
else
    echo "LMTOY>> updating"
fi

#             sanity checks
if [ ! -d $p_dir ]; then
    echo "LMTOY>> directory $p_dir does not exist"
    exit 1
fi

#             derived parameters (you should not have to edit these)
p_dir=${path}
#             redo CLI again
for arg in "$@"; do
  export "$arg"
done


#             pick one bank, or loop over all allowed banks
if [ $bank != -1 ]; then
    s_on=${src}_${obsnum}_${bank}
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    lmtoy_seq1
elif [ $numbands == 1 ]; then
    # old style, we should not use it anymore
    s_on=${src}_${obsnum}
    s_nc=${s_on}.nc
    s_fits=${s_on}.fits
    w_fits=${s_on}.wt.fits
    bank=0
    lmtoy_seq1
else
    for b in $(seq 1 $numbands); do
	bank=$(expr $b - 1)
	echo "Preparing for bank = $bank / $numbands"
	s_on=${src}_${obsnum}_${bank}
	s_nc=${s_on}.nc
	s_fits=${s_on}.fits
	w_fits=${s_on}.wt.fits
	#s_fits=${s_on}_${bank}.fits
	#w_fits=${s_on}_${bank}.wt.fits
	lmtoy_seq1	
    done
    # exit 0
fi
