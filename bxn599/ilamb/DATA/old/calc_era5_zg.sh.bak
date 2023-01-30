#!/bin/bash

#PBS -N job_era5_zg
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -P xv83
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/xv83
#PBS -l mem=20G
#PBS -l ncpus=1

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR

declare -a StringArray=("zg200" "zg300" "zg500" "zg850")

for var in ${StringArray[@]}; do
#  echo $var
  ovar="z"
#  echo $ovar
  fvar="z_era5_*.nc"
#  echo $fvar
  ifiles="$(find /g/data/rt52/era5/pressure-levels/monthly-averaged/z -name $fvar)"
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
    cdo -b F64 -vertsum -sellevel,"$level" -setattribute,"$var@units"="m" -chname,$ovar,$var -divc,9.8 $file $opath
  done

done
