#!/bin/bash
#PBS -N pr_av
#PBS -P xv83
#PBS -q hugemem
#PBS -l walltime=8:00:00
#PBS -l mem=400gb
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd

# User specific aliases and functions

module use /g/data3/hh5/public/modules
module load conda/analysis3
module load ncl

cd $PBS_O_WORKDIR

ncl calc_av_pr_ccam_era5_aus-11i_12.5km_coupled.ncl
wait
