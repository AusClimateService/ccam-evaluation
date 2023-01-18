#!/bin/bash
#PBS -N noresm_rav
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
var='"txx"'
obs_var_name='"txx"'
rcm_var_name='"txx"'
gdd_var_name='"txx"'
ls_obs='"/g/data/xv83/users/bxn599/CaRSA/climpact_agcd/climpact_output_1980-2014/txx_MON_climpact.sample_historical_NA_1980-2014.nc"'
ls_rcm='"/g/data/xv83/users/bxn599/CaRSA/ccam_25km/noresm2-mm/climpact_output_1980-2014/txx_MON_climpact.sample_historical_NA_1980-2014.nc"' # RCM run
ls_gdd='"/g/data/xv83/users/bxn599/CaRSA/ccam_25km/noresm2-mm/gdd_climpact_output_1980-2014/txx_MON_climpact.sample_historical_NA_1980-2014.nc"' # global driving data

ncl calc_climpact_var_bias_rmse_rav_automate.ncl run_name=$run_name var=$var yyyy_start=$yyyy_start yyyy_end=$yyyy_end ls_obs=$ls_obs ls_rcm=$ls_rcm ls_gdd=$ls_gdd obs_var_name=$obs_var_name rcm_var_name=$rcm_var_name gdd_var_name=$gdd_var_name

wait
