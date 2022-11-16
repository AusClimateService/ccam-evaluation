#!/bin/bash
#PBS -N auto_rav_coupv6
#PBS -P e53
#PBS -q normalbw
#PBS -l walltime=5:00:00
#PBS -l mem=190gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+gdata/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -M ng04l@csiro.au
#PBS -m abe

# User specific aliases and functions

module use /g/data3/hh5/public/modules
module load conda/analysis3
module load ncl

yyyy_start='1980'
yyyy_end='2014'
run_name='"noresm2-mm"'
# variable to analyse
var='"pr"'
obs_var_name='"precip"'
rcm_var_name='"pr"'
gdd_var_name='"pr"'
ls_obs='"/g/data/zv2/agcd/v1/precip/calib/r005/01day/agcd_v1_precip_calib_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/data/pr_day_surf.ccam_25.km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/gdd_data/pr_day_"' # global driving data

ncl calc_var_added_value_bias_rmse_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"tasmax"'
obs_var_name='"tmax"'
rcm_var_name='"tasmax"'
gdd_var_name='"tasmax"'
ls_obs='"/g/data/zv2/agcd/v1/tmax/mean/r005/01day/agcd_v1_tmax_mean_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/data/tasmax_surf.ccam_25.km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/gdd_data/tasmax_day_"' # global driving data

ncl calc_var_added_value_bias_rmse_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"tasmin"'
obs_var_name='"tmin"'
rcm_var_name='"tasmin"'
gdd_var_name='"tasmin"'
ls_obs='"/g/data/zv2/agcd/v1/tmin/mean/r005/01day/agcd_v1_tmin_mean_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/data/tasmin_surf.ccam_25.km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/ccam_25km/noresm2-mm/gdd_data/tasmin_day_"' # global driving data

ncl calc_var_added_value_bias_rmse_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

wait
