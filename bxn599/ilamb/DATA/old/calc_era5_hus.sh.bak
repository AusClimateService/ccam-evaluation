#!/bin/bash

#PBS -N job_era5_hus
#PBS -l walltime=8:00:00
#PBS -q normal
#PBS -P xv83
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/xv83
#PBS -l mem=20G
#PBS -l ncpus=1

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR

declare -a StringArray=("hus600" "hus700" "hus850")

for var in ${StringArray[@]}; do
#  echo $var
  ovar="q"
#  echo $ovar
  fvar="q_era5_*.nc"
#  echo $fvar
  ifiles="$(find /g/data/rt52/era5/pressure-levels/monthly-averaged/q -name $fvar)"
#  echo $ifiles

  level="${var:(-3)}"
#  echo $level

  mkdir -p $var

  for file in $ifiles; do
#   echo $file
    ofile="$var${file:(-34)}"
#   echo $ofile
    opath="./$var/$ofile"
#   echo $opath
    cdo -b F64 -vertsum -sellevel,"$level" -chname,$ovar,$var $file $opath
  done

done
