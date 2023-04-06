#!/bin/bash

module use ~access/modules
module use /g/data/hh5/public/modules
module load conda/analysis3-22.07

cd $PBS_O_WORKDIR
export ILAMB_ROOT=/g/data/xv83/users/bxn599/ACS/ilamb
echo ${PROCS} ${ILAMB_OPTIONS}
echo "mpirun -n $PROCS ./ilamb-run $ILAMB_OPTIONS --config all_vars_all_models.cfg --model_root $ILAMB_ROOT/MODELS/ --study_limits 1985 2014 --build_dir ./_build_all_vars_all_models --regions global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC --default_region Australia"
mpirun -n $PROCS ./ilamb-run $ILAMB_OPTIONS --config all_vars_all_models.cfg --model_root $ILAMB_ROOT/MODELS/ --study_limits 1985 2014 --build_dir ./_build_all_vars_all_models --regions global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC --default_region Australia >> stdout

### NRM subclusters (fullname)
###global australia wettropics rangelandsnorth monsoonalnortheast monsoonalnorthwest eastcoastsouth centralslopes murraybasin southernandsouthwesternflatlandswest southernandsouthwesternflatlandseast southernslopesvicnsweast southernslopesvicwest southernslopestaseast southernslopestaswest eastcoastnorth rangelandssouth MC 

### NRM clusters
###global australia centralslopes eastcoast murraybasin monsoonalnorth rangelands southernslopes sswflatlands wettropics MC
