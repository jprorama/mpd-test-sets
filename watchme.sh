#!/bin/bash

# watch the memory use of the python kernel launched by papermill
# trace the process by way of the job script pid through papermill

jobpid=$1

while true
do
  paperpid=`ps -ef | grep $USER | grep $jobpid | grep papermill | awk '{print $2}'`
  if [ "$paperpid" = "" ]
  then
    sleep 1
  else
    break
  fi
done

while true
do
  pythonpid=`ps -ef | grep $USER | grep $paperpid | grep ipykernel | awk '{print $2}'`
  if [ "$pythonpid" = "" ]
  then
    sleep 1
  else
    break
  fi
done

pidstat -p $pythonpid -dru -h 1 > ${RESULTSDIR}pidstat-${SLURM_JOBID}.out
