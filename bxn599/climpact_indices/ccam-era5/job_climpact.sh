#!/bin/sh
#PBS -N climp_ccam
#PBS -P xv83
#PBS -q normalbw
#PBS -l walltime=48:00:00
#PBS -l mem=190GB
#PBS -l ncpus=28
#PBS -l storage=gdata/hh5+gdata/q49+scratch/oi10+gdata/zv2+gdata/rr3+gdata/ma05+gdata/r87+gdata/ub4+gdata/tp28+scratch/e53+scratch/q49+gdata/rt52+gdata/al33+gdata/oi10+gdata/xv83
#PBS -l jobfs=100GB
#PBS -l wd

###module use /g/data/hh5/public/modules
###module load conda/analysis3
module load R/4.1.0
module load udunits/2.2.26
module load proj/6.2.1
module load intel-compiler/2021.3.0
module load intel-mkl/2021.3.0
module load netcdf/4.7.4
module load gcc/11.1.0

set -xv

cd $PBS_O_WORKDIR

Rscript climpact.ncdf.wrapper_ccam-era5_evaluation_1995-2014.r
