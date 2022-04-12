#!/bin/bash
#PBS -N calc_av_bias
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=2:00:00
#PBS -l mem=100gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=100GB
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

# variable to analyse
var='"pr"'
obs_var_name='"precip"'
rcm_var_name='"pr"'
gdd_var_name='"tp"'
ls_obs='"/g/data/zv2/agcd/v1/precip/calib/r005/01day/agcd_v1_precip_calib_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/pr_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/tp_day_"' # global driving data

ncl calc_var_bias_rmse_monthly_means_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"tasmax"'
obs_var_name='"tmax"'
rcm_var_name='"tasmax"'
gdd_var_name='"mx2t"'
ls_obs='"/g/data/zv2/agcd/v1/tmax/mean/r005/01day/agcd_v1_tmax_mean_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/tasmax_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/mx2t_era5_"' # global driving data

ncl calc_var_bias_rmse_monthly_means_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"tasmin"'
obs_var_name='"tmin"'
rcm_var_name='"tasmin"'
gdd_var_name='"mn2t"'
ls_obs='"/g/data/zv2/agcd/v1/tmin/mean/r005/01day/agcd_v1_tmin_mean_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/tasmin_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/mn2t_era5_"' # global driving data

ncl calc_var_bias_rmse_monthly_means_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

wait
