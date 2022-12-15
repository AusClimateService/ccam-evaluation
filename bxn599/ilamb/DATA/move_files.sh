#!/bin/bash

cd "/g/data/xv83/bxn599/ACS/ilamb/DATA"
pwd

declare -a StringArray=("ua200" "ua300" "ua500" "ua850" "va200" "va300" "va500" "va850" "ta300" "ta500" "ta600" "ta700" "ta850" "zg200" "zg300" "zg500" "zg850" "hus600" "hus700" "hus850" "psl" "tas" "omega500" "pr")

for var in ${StringArray[@]}; do

  echo "$var/*.nc"
  mkdir -p $var"/separate"
  mv $var/*.nc "$var/separate/."
  mv $var/separate/*19590101-20220831.nc "$var/ERA5/."

done
