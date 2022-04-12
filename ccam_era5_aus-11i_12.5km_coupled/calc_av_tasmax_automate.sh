#!/bin/bash
#PBS -N av_tasmax
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=12:00:00
#PBS -l mem=512gb
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

# AGCD min/max lat/lon
latS='-44.5'
latN='-10'
lonL='112'
lonR='156.25'

# variable to analyse
var='"tasmax"'
obs_var_name='"tmax"'
rcm_var_name='"tasmax"'
gdd_var_name='"mx2t"'
ls_obs='"/g/data/zv2/agcd/v1/tmax/mean/r005/01day/agcd_v1_tmax_mean_r005_daily_"'
ls_rcm='"/g/data/xv83/bxn599/CaRSA/ccam_era5_aus-11i_12.5km_coupled/data/tasmax_surf.ccam_12.5km."' # RCM run
ls_gdd='"/g/data/xv83/bxn599/CaRSA/era5_data/mx2t_era5_"' # global driving data

ncl calc_av_var_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name latS=$latS latN=$latN lonL=$lonL lonR=$lonR

wait
