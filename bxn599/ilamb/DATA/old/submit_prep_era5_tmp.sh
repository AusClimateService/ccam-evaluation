#!/bin/bash

#PBS -N job_era5
#PBS -l walltime=12:00:00
#PBS -q normal
#PBS -P xv83
# PBS -W umask=0007
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/xv83
#PBS -l mem=128G
#PBS -l ncpus=12

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR

mpiexec -n 12 python prep_era5_tmp.py
