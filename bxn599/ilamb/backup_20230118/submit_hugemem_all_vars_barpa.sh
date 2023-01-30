#!/bin/bash

#PBS -N job_all_vars_barpa
#PBS -l walltime=48:00:00
#PBS -q hugemem
#PBS -P xv83
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/ia39+gdata/xv83+scratch/xv83+gdata/zv2+gdata/oi10+gdata/fs38
#PBS -l mem=1470G
#PBS -l ncpus=48

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR
export ILAMB_ROOT=/g/data/xv83/users/bxn599/ACS/ilamb
mpirun -n 48 ./ilamb-run --config all_vars_all_models.cfg --model_root $ILAMB_ROOT/MODELS/ --study_limits 1985 2014 --build_dir ./_build_all_vars_all_models --regions global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC --models BARPA_ACCESS-CM2 BARPA_ACCESS-ESM1-5 BARPA_EC-Earth3 --clean

### NRM clusters
###centralslopes eastcoast murraybasin monsoonalnorth rangelands southernslopes sswflatlands wettropics

### NRM subclusters (fullname)
###global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC 
