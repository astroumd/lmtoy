#! /bin/bash
#
#  LMTOY's simple frontend for sbatch 
#
#  SLURM cheat list for LMTOY (we use the "toltec-cpu" )
#     sinfo
#     sbatch run_12345.sh               (this example)
#     squeue -u lmtslr_umass_edu        (also shows your JOBID's)
#     scancel JOBID
#     srun -n 1 -c 4 --mem=16G -p toltec-cpu --x11 --pty bash


# https://unity.rc.umass.edu/docs/#slurm/   IECK, this also stopped working.

# catch the single argument batch call first
if [ -e "$1" ]; then
    echo Processing lines from $1 line by line
    while IFS= read -r line; do
	echo "LINE: $line"
	sbatch_lmtoy.sh $line
    done < $1
    exit 1
fi

# process it as pipeline script, either obsnum= or obsnums= (but not both) should be present on CLI

obsnum=0
obsnums=0

# processing CLI when key=var
for arg in $*; do
    if [[ "$arg" =~ "=" ]]; then
	export $arg
    fi
done

#                                        version
version="14-may-2022"

#                                        prefix to run
prefix="/usr/bin/time xvfb-run -a"

#                                        figure out the run ID
if [ $obsnums != 0 ]; then
    runid=$(echo $obsnums | awk -F, '{printf("%s_%s\n",$1,$NF)}')
else
    runid=$obsnum
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

if [ "$(which sbatch)" != "/usr/bin/sbatch" ]; then
    echo "$0 version=$version"    
    echo "run=$run"
    echo "ERROR:  No sbatch system here on $(hostname)"
    #exit 0
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

$prefix $*

EOF


chmod +x $run
echo "$run      - use scancel JOBID to kill this one, JOBID is:"
sbatch $run
#   report last few
sleep 2
ls -ltr $WORK_LMT/sbatch/slurm*.out | tail -6
squeue -u lmtslr_umass_edu
echo "squeue -u lmtslr_umass_edu"

