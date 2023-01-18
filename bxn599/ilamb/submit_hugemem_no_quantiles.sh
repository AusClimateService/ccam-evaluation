#!/bin/bash

#PBS -N job_all_vars
#PBS -l walltime=48:00:00
#PBS -q hugemem
#PBS -P xv83
#PBS -l storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/ia39+gdata/xv83+scratch/xv83+gdata/zv2+gdata/oi10
#PBS -l mem=1470G
#PBS -l ncpus=48

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3

cd $PBS_O_WORKDIR
export ILAMB_ROOT=/g/data/xv83/bxn599/ACS/ilamb
mpirun -n 48 ./ilamb-run --config no_quantiles.cfg --model_root $ILAMB_ROOT/MODELS/ --study_limits 1985 2014 --build_dir ./_build_no_quantiles --regions global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC

### NRM clusters
###centralslopes eastcoast murraybasin monsoonalnorth rangelands southernslopes sswflatlands wettropics

### NRM subclusters (fullname)
###global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC 
