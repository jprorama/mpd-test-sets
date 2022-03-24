#!/bin/bash

# submit jobs from different scaling runs
sizes=$1
methods=$2
challenges=$3
miscargs=$4
resultsdir=$5
othernbparams="$6"


# save slurm output with results
if [ "x${resultsdir}" != "x" ]
then
  miscargs="$miscargs -o ${resultsdir}slurm-%j.out"
  mkdir -p "${resultsdir}"
fi
# if resultsdir a dir (ends in /) and not a prefix mkdir if needed
if [ "${resultsdir: -1:1}" == "/" ]
then
  mkdir -p ${resultsdir}/cache
fi


for size in $sizes
do
  for method in $methods
  do
    for chall in $challenges
    do
      if [ "$method" == "vl6" ]
      then 
        METHOD=$method DATASET=mympd-full-${size}k CNAME=$chall RESULTSDIR=$resultsdir && \
        METHOD=$METHOD DATASET=$DATASET CNAME=$CNAME  RESULTSDIR=$RESULTSDIR \
        sbatch --job-name=$METHOD-$CNAME-$DATASET \
          -n 28 -N 1 \
          --time=11h \
          --mem=239G \
          --partition=pascalnodes \
          --gpus-per-node=4 \
          --exclusive \
	  $miscargs \
          run-vl6.sh
      else
        NB=$method DATASET=mympd-full-${size}k CNAME=$chall RESULTSDIR=$resultsdir OTHERNBPARAMS="$othernbparams" && \
        NB=$NB DATASET=$DATASET CNAME=$CNAME  RESULTSDIR=$RESULTSDIR OTHERNBPARAMS="$OTHERNBPARAMS" \
        sbatch --job-name=$NB-$CNAME-$DATASET \
          -n 1 -N 1 \
          --time=120 \
          --mem=200G \
          --partition=amd-hdr100 $miscargs \
          run-nb.sh
      fi
      sleep 1
    done
  done
done
