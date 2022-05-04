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
var='"ua850"' # 850hPa zonal wind
rcm_var_name='"ua850"'
gdd_var_name='"u"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/ua850_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/u_day_850mb_"' # global driving data/ERA5

#ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"va850"' # 850hPa meridional wind
rcm_var_name='"va850"'
gdd_var_name='"v"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/va850_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/v_day_850mb_"' # global driving data

#ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"psl"' # sea level pressure / mean sea level pressure
rcm_var_name='"psl"'
gdd_var_name='"msl"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/psl_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/msl_day_era5_oper_sfc_"' # global driving data

ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"ps"' # surface pressure
rcm_var_name='"ps"'
gdd_var_name='"sp"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/ps_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/sp_day_era5_oper_sfc_"' # global driving data

ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"ua500"' # 500hPa zonal wind
rcm_var_name='"ua500"'
gdd_var_name='"u"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/ua500_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/u_day_500mb_"' # global driving data/ERA5

#ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

var='"va500"' # 500hPa meridional wind
rcm_var_name='"va500"'
gdd_var_name='"v"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/va500_day_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/v_day_500mb_"' # global driving data

#ncl calc_var_bias_rmse_monthly_means_no_agcd_automate.ncl run_name=$run_name var=$var $season=season yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_rcm=$ls_rcm ls_gdd=$ls_gdd rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

wait
