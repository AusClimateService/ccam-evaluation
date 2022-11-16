#!/bin/sh
#PBS -N climpact_avg
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=6:00:00
#PBS -l mem=190GB
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

filen='"_climpact.ccam.era5_historical_NA_1986-2015.nc"'
fileo='"_climpact.agcd_historical_NA_1986-2015.nc"'
fileg='"_climpact.sample_historical_NA_1986-2015.nc"'
yrStrt='1986'
yrLast='2015'
run_name='"ccam_era5_aus-11i_12.5km_coupled"'

var='"txx"'
info='"Maximum_value_of_daily_maximum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txn"'
info='"Minimum_value_of_daily_maximum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnx"'
info='"Maximum_value_of_daily_minimum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnn"'
info='"Minimum_value_of_daily_minimum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r10mm"'
info='"Count_of_days_when_pr_>=_10mm"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r20mm"'
info='"Count_of_days_when_pr_>=_20mm"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"r30mm"'
info='"Count_of_days_when_pr_>=_30mm"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"prcptot"'
info='"Total_precipitation_on_wet_days"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx1day"'
info='"Maximum_1_day_precipitation"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx5day"'
info='"Maximum_consecutive_5-day_precipitation"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"rx7day"'
info='"Maximum_consecutive_7-day_precipitation"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnm"'
info='"Mean_daily_minimum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txm"'
info='"Mean_daily_maximum_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmm"'
info='"Mean_daily_mean_temperature"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tx10p"'
info='"Percentage_of_days_when_TX_<_10th_percentile"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tn10p"'
info='"Percentage_of_days_when_TN_<_10th_percentile"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tn90p"'
info='"Percentage_of_days_when_TN_>_90th_percentile"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tx90p"'
info='"Percentage_of_days_when_TX_>_90th_percentile"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"dtr"'
info='"Daily_temperature_range"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"su"'
info='"Number_of_summer_days"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"fd"'
info='"Number_of_frost_days"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmge10"'
info='"Number_of_days_when_TM_>=_10_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmge5"'
info='"Number_of_days_when_TM_>=_5_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmlt10"'
info='"Number_of_days_when_TM_<_10_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tmlt5"'
info='"Number_of_days_when_TM_<_5_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnltm2"'
info='"Number_of_days_when_TN_<_-2_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tnlt2"'
info='"Number_of_days_when_TN_<_2_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

#var='"tnltm20"'
#info='"Number_of_days_when_TN_<_-20_degrees_C"'
#ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txge30"'
info='"Number_of_days_when_TX_>=_30_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txge35"'
info='"Number_of_days_when_TX_>=_35_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"txgt50p"'
info='"Number_of_days_when_TX_>_50th_percentile"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

#var='"id"'
#info='"Number_of_icing_days"'
#ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tr"'
info='"Number_of_days_when_TN_>_20_degrees_C"'
ncl plot_climpact_var_seasonal_annual_rmse_automate.ncl var=$var filen=$filen fileo=$fileo fileg=$fileg yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info
