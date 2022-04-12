#!/bin/bash
#PBS -N climpact_av
#PBS -q normalbw
#PBS -l walltime=5:00:00
#PBS -l mem=64gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+gdata/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=10GB
#PBS -l wd
#PBS -M ng04l@csiro.au
#PBS -m abe

# User specific aliases and functions

module use /g/data3/hh5/public/modules
module load conda/analysis3
module load ncl

yyyy_start='1986'
yyyy_end='2015'
run_name='"ccam_era5_aus-11i_12.5km_coupled"'

# AGCD min/max lat/lon
latS='-44.5'
latN='-10'
lonL='112'
lonR='156.25'

# variable to analyse
obs_name='"_MON_climpact.agcd_historical_NA_1986-2015.nc"'
rcm_name='"_MON_climpact.ccam.era5_historical_NA_1986-2015.nc"'
gdd_name='"_MON_climpact.sample_historical_NA_1986-2015.nc"'
ls_obs='"/g/data/xv83/bxn599/CaRSA/climpact_agcd/climpact_output_1986-2015/"'
ls_rcm='"../calculated/climpact_output_1986-2015/"'
ls_gdd='"/g/data/xv83/bxn599/CaRSA/climpact_era5_reanalysis/climpact_output_1986-2015/"'

var='"txx"'
info='"Maximum_value_of_daily_maximum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"txn"'
info='"Minimum_value_of_daily_maximum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tnx"'
info='"Maximum_value_of_daily_minimum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tnn"'
info='"Minimum_value_of_daily_minimum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"r10mm"'
info='"Count_of_days_when_pr_>=_10mm"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"r20mm"'
info='"Count_of_days_when_pr_>=_20mm"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"r30mm"'
info='"Count_of_days_when_pr_>=_30mm"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"prcptot"'
info='"Total_precipitation_on_wet_days"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"rx1day"'
info='"Maximum_1_day_precipitation"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"rx5day"'
info='"Maximum_consecutive_5-day_precipitation"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"rx7day"'
info='"Maximum_consecutive_7-day_precipitation"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tnm"'
info='"Mean_daily_minimum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"txm"'
info='"Mean_daily_maximum_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tmm"'
info='"Mean_daily_mean_temperature"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tx10p"'
info='"Percentage_of_days_when_TX_<_10th_percentile"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tn10p"'
info='"Percentage_of_days_when_TN_<_10th_percentile"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tn90p"'
info='"Percentage_of_days_when_TN_>_90th_percentile"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tx90p"'
info='"Percentage_of_days_when_TX_>_90th_percentile"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"dtr"'
info='"Daily_temperature_range"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"su"'
info='"Number_of_summer_days"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"fd"'
info='"Number_of_frost_days"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tmge10"'
info='"Number_of_days_when_TM_>=_10_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tmge5"'
info='"Number_of_days_when_TM_>=_5_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tmlt10"'
info='"Number_of_days_when_TM_<_10_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tmlt5"'
info='"Number_of_days_when_TM_<_5_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tnltm2"'
info='"Number_of_days_when_TN_<_-2_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tnlt2"'
info='"Number_of_days_when_TN_<_2_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

#var='"tnltm20"'
#info='"Number_of_days_when_TN_<_-20_degrees_C"'
#ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"txge30"'
info='"Number_of_days_when_TX_>=_30_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"txge35"'
info='"Number_of_days_when_TX_>=_35_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"txgt50p"'
info='"Number_of_days_when_TX_>_50th_percentile"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

#var='"id"'
#info='"Number_of_icing_days"'
#ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

var='"tr"'
info='"Number_of_days_when_TN_>_20_degrees_C"'
ncl calc_climpact_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_name=$obs_name rcm_name=$rcm_name gdd_name=$gdd_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

wait
