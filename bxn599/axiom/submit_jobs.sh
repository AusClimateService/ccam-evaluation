#!/bin/bash

export LOG_DIR=/g/data/xv83/users/bxn599/ACS/axiom/ccam_access-cm2_historical_aus-10i_12km/axiom_logs/1M/

for i in /g/data/xv83/users/bxn599/ACS/axiom/ccam_access-cm2_historical_aus-10i_12km/payloads/1M/payload_*.json;
do
  JOBNAME=${i//"/g/data/xv83/users/bxn599/ACS/axiom/ccam_access-cm2_historical_aus-10i_12km/payloads/1M/"/""}
  echo $JOBNAME
  echo $i
  qsub -v AXIOM_PAYLOAD=$i,AXIOM_LOG_DIR=$LOG_DIR -N $JOBNAME /g/data/xv83/users/bxn599/ACS/axiom/jobscript.sh
done
