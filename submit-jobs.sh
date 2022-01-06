#!/bin/bash

# submit jobs from different scaling runs
sizes=$1
methods=$2
challenges=$3

for size in $sizes
do
  for notebook in $methods
  do
    for chall in $challenges
    do
      NB=$notebook DATASET=mympd-full-${size}k CNAME=$chall && NB=$NB DATASET=$DATASET CNAME=$CNAME sbatch --job-name=$NB-$CNAME-$DATASET --mem=200G -n 4 -N 1 --partition=amd-hdr100 run-nb.sbatch                                                     
      sleep 1
    done
  done
done
