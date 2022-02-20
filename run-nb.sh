#!/bin/bash
#
# run RS notebook with specific data set.
#
#
module load Anaconda3/2021.11

#source /share/apps/rc/software/Anaconda3/2020.11/etc/profile.d/conda.sh
conda  activate mpd3

./watchme.sh ${SLURM_TASK_PID} &

TAGNAME=slurm-${SLURM_JOBID}

papermill \
        -p dataset ${DATASET} \
        -p challenge_name ${CNAME} \
        -p tagname ${TAGNAME} \
        -p resultsdir ${RESULTSDIR} \
        -p method ${NB} \
        -k mpd3 \
	${NB}.ipynb \
	${RESULTSDIR}${NB}_${CNAME}_${DATASET}_slurm-${SLURM_JOBID}.ipynb

if [ $? -ne 0 ]
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

