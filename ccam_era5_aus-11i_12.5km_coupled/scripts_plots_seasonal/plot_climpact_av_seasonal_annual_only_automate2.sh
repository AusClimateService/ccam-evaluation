#!/bin/sh
#PBS -N av_climpact_plot
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=48:00:00
#PBS -l mem=32GB
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/rt52+gdata/al33+gdata/oi10+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -M ng04l@csiro.au
#PBS -m abe

module use /g/data/hh5/public/modules
module load conda/analysis3
module load ncl

set -xv

cd $PBS_O_WORKDIR

yrStrt='1986'
yrLast='2015'
run_name='"ccam_era5_aus-11i_12.5km_coupled"'

var='"tn90p"'
info='"Percentage_of_days_when_TN_>_90th_percentile"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tx90p"'
info='"Percentage_of_days_when_TX_>_90th_percentile"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"dtr"'
info='"Daily_temperature_range"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"su"'
info='"Number_of_summer_days"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"fd"'
info='"Number_of_frost_days"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmge10"'
info='"Number_of_days_when_TM_>=_10_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmge5"'
info='"Number_of_days_when_TM_>=_5_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmlt10"'
info='"Number_of_days_when_TM_<_10_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmlt5"'
info='"Number_of_days_when_TM_<_5_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnltm2"'
info='"Number_of_days_when_TN_<_-2_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnlt2"'
info='"Number_of_days_when_TN_<_2_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

#var='"tnltm20"'
#info='"Number_of_days_when_TN_<_-20_degrees_C"'
#ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txge30"'
info='"Number_of_days_when_TX_>=_30_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txge35"'
info='"Number_of_days_when_TX_>=_35_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txgt50p"'
info='"Number_of_days_when_TX_>_50th_percentile"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

#var='"id"'
#info='"Number_of_icing_days"'
#ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tr"'
info='"Number_of_days_when_TN_>_20_degrees_C"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info
