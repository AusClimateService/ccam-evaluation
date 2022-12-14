#!/bin/bash

#PBS -N job_merge
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -P xv83
# PBS -W umask=0007
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/xv83
#PBS -l mem=20G
#PBS -l ncpus=1

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR

declare -a StringArray=("ua200" "ua300" "ua500" "ua850" "va200" "va300" "va500" "va850" "ta200" "ta300" "ta500" "ta850" "zg200" "zg300" "zg500" "zg850" "hus600" "hus700" "hus850" "psl" "tas" "omega500" "pr")

for var in ${StringArray[@]}; do

  ivar=$(ls $var/$var_*.nc)
  #echo $ivar
  
  first=$(ls $var/$var_*.nc | head -1)
  last=$(ls $var/$var_*.nc | tail -n 1)
  
  #echo $first
  firstd=${first:(-11):(-3)}
  #echo $firstd
  
  #echo $last
  lastd=${last:(-11):(-3)}
  #echo $lastd
  
  ovar=${first//$firstd/$lastd}
  #echo $ovar
  
  cdo -b F64 cat $ivar $ovar

done
