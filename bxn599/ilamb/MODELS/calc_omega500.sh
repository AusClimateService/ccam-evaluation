#!/bin/bash

  var="omega500"
#  echo $var
  ovar="wap"
#  echo $ovar
  fvar="wap_*.nc"
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
