#!/bin/bash
#PBS -N auto_rav_coupv6
#PBS -P e53
#PBS -q normalbw
#PBS -l walltime=1:00:00
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

run_name='"coupled_v6"'

# variable to analyse
#var='"pr"'
#obs_var_name='"precip"'
#rcm_var_name='"pr"'
#gdd_var_name='"tp"'

var='"tasmax"'
obs_var_name='"tmax"'
rcm_var_name='"tasmax"'
gdd_var_name='"mx2t"'

#var='"tasmin"'
#obs_var_name='"tmin"'
#rcm_var_name='"tasmin"'
#gdd_var_name='"mn2t"'

# start year
yyyy_start='1980'
# end year
yyyy_end='2019'

# path to data
#ls_obs='"/g/data/zv2/agcd/v1/precip/calib/r005/01day/agcd_v1_precip_calib_r005_daily_"'
#ls_rcm='"./data/pr_day_surf.ccam_25.km."' # RCM run
#ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/tp_day_"' # global driving data

# tasmax
ls_obs='"/g/data/zv2/agcd/v1/tmax/mean/r005/01day/agcd_v1_tmax_mean_r005_daily_"'
ls_rcm='"./data/tasmax_surf.ccam_25.km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/mx2t_era5_"' # global driving data

# tasmin
#ls_obs='"/g/data/zv2/agcd/v1/tmin/mean/r005/01day/agcd_v1_tmin_mean_r005_daily_"'
#ls_rcm='"./data/tasmin_surf.ccam_25.km."' # RCM run
#ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/mn2t_era5_"' # global driving data

ncl calc_var_added_value_bias_rmse_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

# output from previous 3 scripts
#prf='"./pr_annual_added_value_bias_rmse_awap_grid.nc"'
#tasmaxf='"./tasmax_annual_added_value_bias_rmse_awap_grid.nc"'
#tasminf='"./tasmin_annual_added_value_bias_rmse_awap_grid.nc"'

#ncl plot_bias_and_rmse_automate.ncl prf=$prf tasmaxf=$tasmaxf tasminf=$tasminf run_name=$run_name yyyy_start=$yyyy_start yyyy_end=$yyyy_end
#
#ncl plot_added_value_automate.ncl yyyy_start=$yyyy_start yyyy_end=$yyyy_end prf=$prf tasmaxf=$tasmaxf tasminf=$tasminf run_name=$run_name
wait
