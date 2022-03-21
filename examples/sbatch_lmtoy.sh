#! /bin/bash
#

obsnum=0

for arg in $*; do
    export $arg
done

run=$WORK_LMT/run_$obsnum.sh


if [ $obsnum == 0 ]; then
    echo "ERROR: Needs obsnum=, then creates $run and uses sbatch to submit work"
    exit 0
fi

if [ "$(which sbatch)" != "/usr/bin/sbatch" ]; then
    echo "run=$run"
    echo "ERROR:  No sbatch system here on $(hostname)"
    exit 0
fi



cat <<EOF > $run
#! /bin/bash
#
#SBATCH -J lmtoy_$obsnum
#SBATCH -o slurm-%j-%x.out
#SBATCH -t 01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition toltec_cpu
#SBATCH --parsable

/usr/bin/time SLpipeline.sh $*

EOF


chmod +x $run
echo $run
sbatch $run
