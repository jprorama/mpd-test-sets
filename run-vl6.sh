#!/bin/bash
#
# run RS vl6 with specific data set.
#
#

BASEDIR=`pwd`

cd /home/jpr/projects/recsys18-codes/vl6
. modules
. venv/bin/activate

#./watchme.sh ${SLURM_TASK_PID} &

TAGNAME=slurm-${SLURM_JOBID}
DATESTR=`date +'%Y-%m-%d-%H:%M:%S'`
SOLUTIONFILE=${RESULTSDIR}/method-${METHOD}_${CNAME}_${DATASET}_${DATESTR}_${TAGNAME}.csv

mkdir -p ${BASEDIR}/${RESULTSDIR}/cache/${TAGNAME}/

bash -x run_vl6-param-arg.sh 8 275 \
	${BASEDIR}/data/${DATASET}/data/ \
	${BASEDIR}/data/${CNAME}/challenge_set.json \
	${BASEDIR}/${RESULTSDIR}/cache/${TAGNAME}/ \
	`pwd`/script/svd_py.py \
	${BASEDIR}/${SOLUTIONFILE}

if [ $? -ne 0 ]
then
  echo "vl6 failed"
  exit 1
fi

cd ${BASEDIR}

# verify the expected output of the solution
python verify_submission.py data/${CNAME}/challenge_set.json ${RESULTSDIR}/method*_slurm-${SLURM_JOBID}.csv

if [ $? -ne 0 ]
then
   echo "verify_submission failed"
   exit 1
fi

#  gzip method output
gzip ${BASEDIR}/${SOLUTIONFILE}

if [ $? -ne 0 ]
then
   echo "gzip failed"
   exit 1
fi

# add mpd runs to the aicrowd queue
if [ "$CNAME" == "mpd" ]
then
   cd ${BASEDIR}/results/aicrowd-queue
   ln -s ${BASEDIR}/${SOLUTIONFILE}
else
   exit 0
fi
