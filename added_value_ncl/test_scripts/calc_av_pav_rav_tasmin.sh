#!/bin/bash
#PBS -N tasmin_av
#PBS -P e53
#PBS -q normalbw
#PBS -l walltime=12:00:00
#PBS -l mem=190gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd

# User specific aliases and functions

module use /g/data3/hh5/public/modules
module load conda/analysis3
module load ncl

ncl calc_av_pav_rav_tasmin.ncl
wait
