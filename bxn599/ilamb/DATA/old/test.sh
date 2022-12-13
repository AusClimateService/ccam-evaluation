#!/bin/bash

declare -a StringArray=("ua200" "ua300" "ua500" "ua850" "va200" "va300" "va500" "va850" "ta200" "ta300" "ta500" "ta850" "zg200" "zg300" "zg500" "zg850" "hus200" "hus300" "hus500" "hus850" "psl" "tas" "omega500" "pr")

for var in ${StringArray[@]}; do

  ivar=$(ls $var/$var_*.nc)
  #echo $ivar
  
  first=$(ls $var/$var_*.nc | head -1)
  last=$(ls $var/$var_*.nc | tail -n 1)
  
  echo $first
  firstd=${first:(-11):(-3)}
  echo $firstd
  
  echo $last
  lastd=${last:(-11):(-3)}
  echo $lastd
  
  ovar=${first//$firstd/$lastd}
  echo $ovar
  
  #cdo -P 12 -b F64 cat $ivar $ovar

done