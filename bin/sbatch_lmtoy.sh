#! /bin/bash
#
#
#--HELP
#
#  sbatch_lmtoy.sh :  LMTOY's simple frontend for sbatch
#
#  SLURM cheat list for LMTOY (we use the "toltec-cpu" )
#     sinfo
#     sbatch run_12345.sh               (this example)
#     squeue -u lmtslr_umass_edu        (also shows your JOBID's)
#     scancel JOBID
#     srun -n 1 -c 4 --mem=16G -p toltec-cpu --x11 --pty bash
#
#  Typical usage:
#     sbatch_lmtoy.sh SLpipeline.sh obsnum=12345 
#     sbatch_lmtoy.sh SLpipeline.sh obsnums=12345,12346
#     sbatch_lmtoy.sh 2021-S1-US-3.run1a exist=1
#     sbatch_lmtoy.sh 2021-S1-US-3.run1a obsnum0=123456
#     sbatch_lmtoy.sh 2021-S1-US-3.run2a
#
#     exist=1   will not process an obsnum if it already exists
#     obsnum0=  will only process single obsnums at or beyond this obsnum0 
#
#--HELP

# https://unity.rc.umass.edu/docs/#slurm/   IECK, this also stopped working.

version="28-mar-2023"       # script version
sleep=1                     # don't use 0, unity spawns too fast in a series

if [ -z "$1" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ];then
    set +x
    awk 'BEGIN{s=0} {if ($1=="#--HELP") s=1-s;  else if(s) print $0; }' $0
    exit 0
fi


# catch the single argument batch call first, but pass additional arguments to each pipeline call
if [ -e "$1" ]; then
    runfile=$1
    echo "Processing lines from $runfile line by line"
    echo "$(date +%Y-%m-%dT%H:%M:%S) $*" >> $WORK_LMT/sbatch.log
    nl=$(cat $runfile | wc -l)
    ml=0
    shift
    while IFS= read -r line; do
	((ml++))
	echo "LINE ($ml/$nl): $line $*"
	sbatch_lmtoy.sh $line $*
    done < $runfile
    exit 1
fi

# process it as pipeline script, either obsnum= or obsnums= (but not both) should be present on CLI

obsnum=0
obsnums=0
obsnum0=0

# processing CLI when key=var
for arg in "$@"; do
    if [[ "$arg" =~ "=" ]]; then
	export "$arg"
    fi
done

#                                        prefix to run
prefix="/usr/bin/time xvfb-run -a"

#                                        figure out the run ID
if [ $obsnums != 0 ]; then
    runid=$(echo $obsnums | awk -F, '{printf("%s_%s\n",$1,$NF)}')
else
    runid=$obsnum
fi
if [ $obsnum = 1 ]; then
    shift
fi

if [ $obsnum0 != 0 ]; then
    if [ $obsnum -lt $obsnum0 ]; then
	echo "SKIP obsnum=$obsnum because obsnum0=$obsnum0"
	exit 0
    fi
fi

#                                        sbatch run file
run=run_$runid.sh

#                                        max sbatch time 
tmax=04:00:00

if [ $runid == 0 ]; then
    echo "$0 version=$version"
    echo "ERROR: Needs obsnum= or obsnums=o1,o2,...   then creates $run and uses sbatch to submit work."
    echo "Alternatively, a filename with bash commands can be given. Each line will then be submitted to SLURM."
    echo "Also note the clock limit:    SBATCH -t $tmax"
    exit 0
fi

#if [ "$(which sbatch)" != "/usr/bin/sbatch" ]; then
if [ "$(which sbatch)" == "" ]; then
    echo "$0 version=$version"    
    echo "run=$run"
    echo "ERROR:  No sbatch system here on $(hostname)"
    exit 0
fi

#                     do all sbatch work in $WORK_LMT/sbatch
mkdir -p $WORK_LMT/sbatch
cd $WORK_LMT/sbatch
#

cat <<EOF > $run
#! /bin/bash
#
#   $0 version=$version
#
#SBATCH -J $runid
#SBATCH -o slurm-%j-%x.out
#SBATCH -t $tmax
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition toltec-cpu
#SBATCH --parsable

#  on most slurm type environments you will need to load some modules
#     unity:   module load uri/main Xvfb
#     zaratan: ?  
if [ -e $LMTOY/modules.rc ]; then
 source $LMTOY/modules.rc
fi

$prefix $*

EOF

chmod +x $run
echo "$run      - use scancel JOBID to kill this one, JOBID is:"
sbatch $run
#   report last few, if present
sleep $sleep
ls -ltr $WORK_LMT/sbatch/slurm*.out | tail -6
squeue -u $USER
echo "squeue -u $USER"

