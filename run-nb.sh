#!/bin/bash
#
# run RS notebook with specific data set.
#
#
module load Anaconda3/2021.11

#source /share/apps/rc/software/Anaconda3/2020.11/etc/profile.d/conda.sh
conda  activate mpd2

papermill \
        -p dataset ${DATASET} \
        -p challenge_name ${CNAME} \
        -k mpd2 \
	${NB}.ipynb \
	${NB}-${CNAME}-${DATASET}.ipynb

# verify the expected output of the solution
#python2 ../mpd-challenge/verify_submission.py data/mympd-full/challenge_set.json method-u2uknn-mympd-full-mympd-full-20k-2022-01-05.csv | egrep -v 'unknown challenge track|submission has 1 error'  
#
#if [ $? -eq 1 ]
#then 
#  gzip method output
#  move to results dir
#else
#  return 1
#fi
