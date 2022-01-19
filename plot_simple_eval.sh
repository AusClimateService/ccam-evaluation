#!/bin/sh
#PBS -N simple_eval
#PBS -P e53
#PBS -q normalbw
#PBS -l walltime=1:00:00
#PBS -l mem=190GB
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+gdata/rt52+gdata/al33+gdata/oi10+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd

module use /g/data/hh5/public/modules
module load conda/analysis3
module load ncl

set -xv

cd $PBS_O_WORKDIR

path='"/scratch/e53/mxt599/cordex_aus_25km_coupled/daily_v6/"'
var_path='"tasmax_surf."' # include '_surf' if looking at a surface variable (e.g., tasmax_surf) 
var='"tasmax"'
ncl plot_simple_eval.ncl var=$var path=$path var_path=$var_path

var_path='"tasmin_surf."'
var='"tasmin"'
ncl plot_simple_eval.ncl var=$var path=$path var_path=$var_path

# pr is hourly
#var_path='"pr_surf."'
#var='"pr"'
#ncl plot_simple_eval.ncl var=$var path=$path var_path=$var_path

# ts is hourly
#var_path='"ts_surf."'
#var='"ts"'
#ncl plot_simple_eval.ncl var=$var path=$path var_path=$var_path
