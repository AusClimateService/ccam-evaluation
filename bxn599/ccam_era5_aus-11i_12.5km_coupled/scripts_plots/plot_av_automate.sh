#!/bin/sh
#PBS -N av_plot
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=7:00:00
#PBS -l mem=10GB
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

yrStrt='1986'
yrLast='2015'
run_name='"ccam_era5_aus-11i_12.5km_coupled"'

var='"pr"'
ncl plot_av_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name

var='"tasmax"'
ncl plot_av_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name

var='"tasmin"'
ncl plot_av_automate.ncl var=$var yrStrt=$yrStrt yrLast=$yrLast run_name=$run_name
