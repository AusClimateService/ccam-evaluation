#!/bin/bash

declare -a StringArray=("hus600" "hus700" "hus850" "omega500" "ta300" "ta500" "ta600" "ta700" "ta850" "ua200" "ua300" "ua500" "ua850" "va200" "va300" "va500" "va850" "zg200" "zg300" "zg500" "zg850")

for var in ${StringArray[@]}; do
#  echo $var
  ovar="${var::-3}"
#  echo $ovar
  fvar="${var::-3}_*.nc"
#  echo $fvar
  ifiles="$(find ./*/ -name $fvar)"
#  echo $ifiles

  level="${var:(-3)}"
  pascals="$(( level*100 ))"
#  echo $level
#  echo "$pascals"

  mkdir -p $var

  for file in $ifiles; do
#  	echo $file
  	ofile="$var${file:(-58)}"
#  	echo $ofile
  	opath="./$var/$ofile"
#  	echo $opath
  	cdo --reduce_dim -sellevel,"$pascals" -chname,$ovar,$var $file $opath
  done

done
