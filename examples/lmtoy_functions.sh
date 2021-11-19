#! /usr/bin/env bash
#
#   some functions to share for lmtoy pipeline operations


echo READING $0

function lmtoy_decipher_obsnums {
    # input:    obsnums
    # output:   on0, on1, obsnum
    
    if [ $obsnums = 0 ]; then
	return
    fi
    
    #             differentiate if obsnums is a file or list of obsnums
    #             set first and last obsnum, and make a list
    if [ -e $obsnums ]; then
	# obsnum is a file
	on0=$(grep -v ^# $obsnums | head -1)
	on1=$(grep -v ^# $obsnums | tail -1)
	obsnums1=$(grep -v ^# $obsnums)
	obsnums=$(echo $obsnums1 | sed '/ /,/g')
    else
	# obsnums is a comma separated list
	#         figure out the first obsnum, to inherit basic pars
	on0=$(echo $obsnums | awk -F, '{print $1}')
	on1=$(echo $obsnums | awk -F, '{print $NF}')
	obsnums1=$(echo $obsnums | sed 's/,/ /g')
    fi
    obsnum=${on0}
    echo OBSNUM: $obsnum
    echo OBSNUMS: $obsnums
}

function lmtoy_rsr1 {
    # input:  first, obsnum, badlags, blanking
    

    # first time, do a run with no badlags or rfile
    if [ $first == 1 ]; then
	python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  -w rsr.wf0.pdf -p -b 3   > rsr0.log 2>&1	
    fi
    
    # output: rsr.$obsnum.badlags sbc.png
    if [ ! -e $badlags ]; then
	python $LMTOY/examples/seek_bad_channels.py $obsnum                         > rsr4.log 2>&1
	mv rsr.badlags $badlags
    fi
    
    # output: $src_rsr_spectrum.txt
    b="--badlags $badlags"
    r="--rfile $rfile"
    python $LMTOY/RSR_driver/rsr_driver.py rsr.obsnum  $b $r -w rsr.wf.pdf -p -b 3  > rsr1.log 2>&1
    
    # output: rsr.obsnum.sum.txt
    python $LMTOY/examples/rsr_sum.py -b rsr.obsnum    $b                           > rsr2.log 2>&1

    # output: rsr.blanking.sum.txt
    python $LMTOY/examples/rsr_sum.py -b $blanking  $b                              > rsr3.log 2>&1

    
    # NEMO summary spectra
    if [ ! -z $NEMO ]; then
	echo "LMTOY>> Some NEMO post-processing"
	dev=$(yapp_query png ps)
	tabplot  ${src}_rsr_spectrum.txt    line=1,1 color=2 ycoord=0     yapp=${src}_rsr_spectrum.sp.$dev/$dev  debug=-1
	tabplot  rsr.obsnum.sum.txt         line=1,1 color=2 ycoord=0     yapp=rsr.obsnum.sum.sp.$dev/$dev       debug=-1
	tabplot  ${blanking}.sum.txt        line=1,1 color=2 ycoord=0     yapp=${blanking}.sum.sp.$dev/$dev      debug=-1
	tabtrend ${src}_rsr_spectrum.txt 2 | tabhist - robust=t xcoord=0  yapp=${src}_rsr_spectrum.rms.$dev/$dev debug=-1
	tabtrend rsr.obsnum.sum.txt      2 | tabhist - robust=t xcoord=0  yapp=rsr.obsnum.sum.rms.$dev/$dev      debug=-1
	tabtrend ${blanking}.sum.txt     2 | tabhist - robust=t xcoord=0  yapp=${blanking}.sum.rms.$dev/$dev     debug=-1
	tabstat  ${src}_rsr_spectrum.txt 2 bad=0 robust=t qac=t
	tabstat  rsr.obsnum.sum.txt      2 bad=0 robust=t qac=t
	tabstat  ${blanking}.sum.txt     2 bad=0 robust=t qac=t
    else
	echo "LMTOY>> Skipping NEMO"
    fi


    # ADMIT
    if [ $admit == 1 ]; then
	echo "LMTOY>> ADMIT post-processing" 
	lmtoy_admit.sh ${src}_rsr_spectrum.txt
	lmtoy_admit.sh rsr.obsnum.sum.txt
	lmtoy_admit.sh ${blanking}.sum.txt
    else
	echo "LMTOY>> skipping ADMIT post-processing"
    fi


    # first time?
    if [ $first == 1 ]; then
	echo "RSR: first time run, preserving a few first run figures"
    fi

    echo "LMTOY>> Parameter file used: $rc"
    
    rsr_readme > README.html


} # function rsr1
