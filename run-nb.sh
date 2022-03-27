#!/bin/bash
#
# run RS notebook with specific data set.
#
#
# if we have gpus load cuda modules
if [ "$CUDA_VISIBLE_DEVICES" != "" ]
then
  module load cuda11.3/toolkit
fi
module load Anaconda3/2021.11

#source /share/apps/rc/software/Anaconda3/2020.11/etc/profile.d/conda.sh
conda  activate mpd3

# active openmp if multiple CPUs
export OMP_NUM_THREADS=${SLURM_NPROCS:-1}

./watchme.sh ${SLURM_TASK_PID} &

TAGNAME=slurm-${SLURM_JOBID}

papermill \
        -p dataset ${DATASET} \
        -p challenge_name ${CNAME} \
        -p tagname ${TAGNAME} \
        -p resultsdir ${RESULTSDIR} \
        -p method ${NB} \
        ${OTHERNBPARAMS} \
        -k mpd3 \
	${NB}.ipynb \
	${RESULTSDIR}${NB}_${CNAME}_${DATASET}_slurm-${SLURM_JOBID}.ipynb

pmreturn=$?

# make notebook read only after papermill to avoid corrupting experiment record
chmod -w ${RESULTSDIR}${NB}_${CNAME}_${DATASET}_slurm-${SLURM_JOBID}.ipynb

if [ $pmreturn -ne 0 ]
then
  echo "papermill failed"
  exit 1
fi

# verify the expected output of the solution
python verify_submission.py data/${CNAME}/challenge_set.json ${RESULTSDIR}/method*_slurm-${SLURM_JOBID}.csv

if [ $? -ne 0 ]
then
   echo "verify_submission failed"
   exit 1
fi

#  gzip method output
gzip ${RESULTSDIR}/method*_slurm-${SLURM_JOBID}.csv

if [ $? -ne 0 ]
then
   echo "gzip failed"
   exit 1
fi

# add mpd runs to the aicrowd queue
BASEDIR=`pwd`

if [ "$CNAME" == "mpd" ]
then
   cd ${BASEDIR}/results/aicrowd-queue
   ln -s ${BASEDIR}/${RESULTSDIR}/method*_slurm-${SLURM_JOBID}.csv.gz
else
   exit 0
fi

