#!/bin/bash
#PBS -N auto_rav_coupv6
#PBS -P e53
#PBS -q normalbw
#PBS -l walltime=0:30:00
#PBS -l mem=190gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+gdata/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -M ng04l@csiro.au
#PBS -m abe

module use /g/data3/hh5/public/modules
module load conda/analysis3
module load ncl

run_name='"noresm2-mm"'
yyyy_start='1980'
yyyy_end='2014'
var='"pr"'
season='"annual"'
statistic='"avg"'

# output from previous 3 scripts
fl='"./noresm2-mm_pr_annual_added_value_bias_rmse_awap_grid.nc"'
#fl='"./noresm2-mm_tasmax_annual_added_value_bias_rmse_awap_grid.nc"'
#fl='"./noresm2-mm_tasmin_annual_added_value_bias_rmse_awap_grid.nc"'


echo $prf
ncl plot_var_bias_rmse_rav_automate.ncl fl=$fl run_name=$run_name yyyy_start=$yyyy_start yyyy_end=$yyyy_end var=$var season=$season statistic=$statistic
