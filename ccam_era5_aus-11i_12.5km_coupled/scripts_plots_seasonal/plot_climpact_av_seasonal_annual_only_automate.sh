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

var='"txx"'
info='"Maximum_value_of_daily_maximum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txn"'
info='"Minimum_value_of_daily_maximum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnx"'
info='"Maximum_value_of_daily_minimum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnn"'
info='"Minimum_value_of_daily_minimum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r10mm"'
info='"Count_of_days_when_pr_>=_10mm"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r20mm"'
info='"Count_of_days_when_pr_>=_20mm"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r30mm"'
info='"Count_of_days_when_pr_>=_30mm"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"prcptot"'
info='"Total_precipitation_on_wet_days"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx1day"'
info='"Maximum_1_day_precipitation"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx5day"'
info='"Maximum_consecutive_5-day_precipitation"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx7day"'
info='"Maximum_consecutive_7-day_precipitation"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnm"'
info='"Mean_daily_minimum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txm"'
info='"Mean_daily_maximum_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmm"'
info='"Mean_daily_mean_temperature"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tx10p"'
info='"Percentage_of_days_when_TX_<_10th_percentile"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tn10p"'
info='"Percentage_of_days_when_TN_<_10th_percentile"'
ncl plot_climpact_av_seasonal_annual_only_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info
