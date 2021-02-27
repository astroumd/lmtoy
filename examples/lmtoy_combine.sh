#! /bin/bash
#
#  A simple LMT OTF combination, see lmtoy_reduce.md for help
#
#  Note:   this will combine reductions from different OBSNUM's.
#          Two methods:
#          1. combine all the SpecFiles
#          2. combine the weighted maps  (comes with assumptions)     [not implemented yet]
#


version="lmtoy_combine: 27-feb-2021"

if [ -z $1 ]; then
    echo "LMTOY>>  Usage: obsnum=ON1,ON2,..."
    echo "LMTOY>>  $version"
    echo ""
    echo "This will combine OBSNUM based OTF data that were reduced with lmtoy_reduce.sh"
    echo "Parameters are taken from the first lmtoy_OBSNUM.rc file, but can be overridden here"
    echo "where we implemented this (TBD)"
    echo "See lmtoy_reduce.md for examples on usage"
    exit 0
fi


# debug
# set -x
debug=0

# input parameters
#            - start or restart
obsnum=85776,85778,85824
#            - procedural
makecube=1
viewcube=0
#            - parameters that directly match the SLR scripts
unset pix_list
rms_cut=4
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


#             figure out the first obsnum, to inherit basic gridding pars
on0=$(echo $obsnum | awk -F, '{print $1}')
on1=$(echo $obsnum | awk -F, '{print $NF}')

#             process the parameter file (or force new one with newrc=1)
rc=lmtoy_${on0}.rc
if [ -e $rc ] ; then
    echo "LMTOY>> reading $rc"
    source $rc
    # read cmdline again to override the old rc values
    for arg in $*; do\
       export $arg
    done
else
    echo No $rc found
    exit 1
fi

#             derived parameters (you should not have to edit these)

# first find out which .nc files we have
ons=""
for on in $(echo $obsnum | sed 's/,/ /g'); do
    # echo OBSNUM: $on
    fon=${src}_${on}.nc
    if [ -e $fon ]; then
	ons="$ons ${src}_${on}.nc"
    else
	echo Warning $fon not found
    fi
done
s_ons=$(echo $ons | sed 's/ /,/g')

s_on=${src}_${on0}_${on1}
s_fits=${s_on}.fits
w_fits=${s_on}.wt.fits

echo OBSNUM range: $on0 $on1
echo FILES: $s_ons

#  convert SpecFile to FITScube
if [ $makecube = 1 ]; then
    echo "LMTOY>> grid_data"
    grid_data.py \
	--program_path spec_driver_fits \
	-i $s_ons \
	-o $s_fits \
	-w $w_fits \
	--resolution  $resolution \
	--cell        $cell \
	--pix_list    $pix_list \
	--rms_cut     $rms_cut \
	--x_extent    $x_extent \
	--y_extent    $y_extent \
	--otf_select  $otf_select \
	--rmax        $rmax \
	--otf_a       $otf_a \
	--otf_b       $otf_b \
	--otf_c       $otf_c \
	--sample      -1 \
	--n_samples   256 \
	--noise_sigma $noise_sigma
fi

# limits controls figure 5, but not figure 3, which is scaled for the whole map
# @todo  tmax_range   tint_range
if [ $viewcube = 1 ]; then
    echo "LMTOY>> view_cube"
    view_cube.py -i $s_fits \
		 --v_range=$v_range \
		 --v_scale=1000 \
		 --location=$location \
		 --scale=0.000278 \
		 --limits=-$x_extent,$x_extent,-$y_extent,$y_extent \
		 --tmax_range=-1,12 \
		 --tint_range=-1,400 \
		 --plot_type TMAX \
		 --interpolation bilinear
fi

if [ ! -z $NEMO ]; then
    echo "LMTOY>>    Some NEMO post-processing"

    # cleanup, just in case
    rm -f $s_on.ccd $s_on.wt.ccd $s_on.wtn.ccd $s_on.n.ccd $s_on.mom2.ccd $s_on.head1 \
       $s_on.data1 $s_on.n.fits $s_on.nfs.fits $s_on.mom0.ccd $s_on.mom1.ccd \
       $s_on.wt2.fits $s_on.wt3.fits $s_on.wtr.fits
    
    if [ -e $s_fits ]; then
	fitsccd $s_fits $s_on.ccd    axistype=1
	fitsccd $w_fits $s_on.wt.ccd axistype=1
	
        ccdspec $s_on.ccd > $s_on.spectab
	ccdstat $s_on.ccd bad=0 robust=t planes=0 > $s_on.cubestat
	echo "LMTOY>>    STATS  $s_on.ccd     centerbox robust"
	ccdsub  $s_on.ccd -    centerbox=0.5,0.5 | ccdstat - bad=0 robust=t
	echo "LMTOY>>    STATS  $s_on.wt.ccd  centerbox robust"	
	ccdsub  $s_on.wt.ccd - centerbox=0.5,0.5 | ccdstat - bad=0 robust=t

	# convert flux flat to noise flat
	wmax=$(ccdstat $s_on.wt.ccd  | grep ^Min | awk '{print $6}')

	ccdmath $s_on.wt.ccd $s_on.wtn.ccd "sqrt(%1/$wmax)"
	ccdmath $s_on.ccd,$s_on.wtn.ccd $s_on.n.ccd '%1*%2' replicate=t
	ccdmom $s_on.n.ccd $s_on.mom0.ccd  mom=0	
	ccdmom $s_on.n.ccd $s_on.mom1.ccd  mom=1 rngmsk=t
	ccdmom $s_on.n.ccd $s_on.mom2.ccd  mom=-2
	
	ccdmom $s_on.ccd -  mom=-3 keep=t | ccdmom - - mom=-2 | ccdmath - $s_on.wt2.ccd "ifne(%1,0,2/(%1*%1),0)"
	ccdfits $s_on.wt2.ccd $s_on.wt2.fits fitshead=$w_fits
	# e.g. [[-646,-396],[-196,54]] -> -646,-396,-196,54
	zslabs=$(echo $b_regions | sed 's/\[//g' | sed 's/\]//g')
	echo SLABS: $b_regions == $zslabs
	ccdslice $s_on.ccd - zslabs=$zslabs zscale=1000 | ccdmom - - mom=-2  | ccdmath - $s_on.wt3.ccd "ifne(%1,0,1/(%1*%1),0)"
	ccdfits $s_on.wt3.ccd $s_on.wt3.fits fitshead=$w_fits
	ccdmath $s_on.wt2.ccd,$s_on.wt3.ccd - %2/%1 | ccdfits - $s_on.wtr.fits fitshead=$w_fits
	
	scanfits $s_fits $s_on.head1 select=header
	ccdfits $s_on.n.ccd  $s_on.n.fits

	scanfits $s_on.n.fits $s_on.data1 select=data
	cat $s_on.head1 $s_on.data1 > $s_on.nf.fits

	ccdsmooth $s_on.n.ccd - dir=xyz nsmooth=5 | ccdfits - $s_on.nfs.fits fitshead=$s_fits

	# hack
	fitsccd $s_on.nfs.fits - | ccdspec -  > $s_on.specstab
	echo -n "spectab : ";  tail -1  $s_on.spectab
	echo -n "specstab: ";  tail -1  $s_on.specstab
	
	# remove useless files
	rm -f $s_on.n.fits $s_on.head1 $s_on.data1 $s_on.ccd $s_on.wt.ccd $s_on.wt2.ccd  $s_on.wt3.ccd

	echo "LMTOY>> Created $s_on.nf.fits and $s_on.nfs.fits"

    else
	echo "LMTOY>> Problems finding $s_fits. Skipping NEMO work."
    fi
    
fi

if [ ! -z $ADMIT ]; then
    echo "LMTOY>>    Some ADMIT post-processing"
    if [ -e $s_on.nf.fits ]; then
	runa1 $s_on.nf.fits
    else
	runa1 $s_fits
    fi
fi

echo "LMTOY>> Created $s_fits and $w_fits"
echo "LMTOY>> Parameter file used: $rc"

