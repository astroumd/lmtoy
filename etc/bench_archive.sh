# run this via bash and all three benchN.run have been run via 
#   sbatch_lmtoy.sh bench1.run bench2.run bench3.run
# or
#   cat bench[1-3].run > bench_all.run ; sbatch_lmtoy2.sh bench_all.run
#
SLpipeline.sh obsnum=33551 archive=1
SLpipeline.sh obsnum=79448 archive=1
SLpipeline.sh obsnum=110399 archive=1
