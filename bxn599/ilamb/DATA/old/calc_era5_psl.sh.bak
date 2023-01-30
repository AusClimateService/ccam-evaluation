#!/bin/bash

#PBS -N job_era5_psl
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

  var="psl"
#  echo $var
  ovar="msl"
#  echo $ovar
  fvar="msl_era5_*.nc"
#  echo $fvar
  ifiles="$(find /g/data/rt52/era5/single-levels/monthly-averaged/msl/ -name $fvar)"
#  echo $ifiles

  mkdir -p $var

  for file in $ifiles; do
#   echo $file
    ofile="$var${file:(-35)}"
#   echo $ofile
    opath="./$var/$ofile"
#   echo $opath
    cdo -b F64 -chname,$ovar,$var $file $opath
  done
