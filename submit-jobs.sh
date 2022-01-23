#!/bin/bash

# submit jobs from different scaling runs
sizes=$1
methods=$2
challenges=$3
miscargs=$4
resultsdir=$5

# save slurm output with results
if [ "x${resultsdir}" != "x" ]
then
  miscargs="$miscargs -o ${resultsdir}slurm-%j.out"
  mkdir -p "${resultsdir}"
fi
# if resultsdir a dir (ends in /) and not a prefix mkdir if needed
if [ "${resultsdir: -1:1}" == "/" ]
then
  mkdir -p ${resultsdir}
fi


for size in $sizes
do
  for notebook in $methods
  do
    for chall in $challenges
    do
      NB=$notebook DATASET=mympd-full-${size}k CNAME=$chall RESULTSDIR=$resultsdir && \
      NB=$NB DATASET=$DATASET CNAME=$CNAME  RESULTSDIR=$RESULTSDIR \
      sbatch --job-name=$NB-$CNAME-$DATASET \
        -n 1 -N 1 \
        --time=120 \
        --mem=200G \
        --partition=amd-hdr100 $miscargs \
        run-nb.sh
      sleep 1
    done
  done
done
