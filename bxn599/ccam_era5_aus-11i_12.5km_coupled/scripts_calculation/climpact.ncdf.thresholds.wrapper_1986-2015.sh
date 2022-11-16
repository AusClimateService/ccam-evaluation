#!/bin/sh
#PBS -N climpact
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=36:00:00
#PBS -l mem=190GB
#PBS -l ncpus=14
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/rt52+gdata/al33+gdata/oi10+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd
#PBS -M ng04l@csiro.au
#PBS -m abe

module use /g/data/hh5/public/modules
module load conda/analysis3
module load ncl
module load R/4.1.0
module load udunits/2.2.26
module load proj/6.2.1
module load intel-compiler/2021.3.0
module load intel-mkl/2021.3.0
module load netcdf/4.7.4
module load gcc/11.1.0

set -xv

cd $PBS_O_WORKDIR

Rscript climpact.ncdf.thresholds.wrapper_1986-2015.r
