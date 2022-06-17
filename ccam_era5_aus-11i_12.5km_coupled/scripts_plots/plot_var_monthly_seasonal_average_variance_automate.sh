#!/bin/sh
#PBS -N plot_seas_means
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=2:00:00
#PBS -l mem=50GB
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

period='"ANN"'
yrStrt='1986'
yrLast='2015'
run_name='"ccam_era5_aus-11i_12.5km_coupled"'

var='"pr"'
info='"rainfall"'
ncl plot_var_monthly_seasonal_average_variance_automate.ncl var=$var period=$period yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tasmin"'
info='"Minimum_temperature"'
ncl plot_var_monthly_seasonal_average_variance_automate.ncl var=$var period=$period yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info

var='"tasmax"'
info='"Maximum_temperature"'
ncl plot_var_monthly_seasonal_average_variance_automate.ncl var=$var period=$period yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name info=$info