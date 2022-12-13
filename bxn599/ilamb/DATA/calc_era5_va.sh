#!/bin/bash

#PBS -N job_era5_va
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -P xv83
# PBS -W umask=0007
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/xv83
#PBS -l mem=128G
#PBS -l ncpus=12

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR

declare -a StringArray=("va200" "va300" "va500" "va850")

for var in ${StringArray[@]}; do
#  echo $var
  ovar="v"
#  echo $ovar
  fvar="v_era5_*.nc"
#  echo $fvar
  ifiles="$(find /g/data/rt52/era5/pressure-levels/monthly-averaged/v -name $fvar)"
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
    cdo -P 12 -b F64 --reduce_dim -sellevel,"$level" -chname,$ovar,$var $file $opath
  done

done
