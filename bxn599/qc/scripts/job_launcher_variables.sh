#!/bin/bash

#set -x

# README
# This script submits pbs jobs to perform qc for each variable.
# That is one job for each freq/variable, e.g., 1hr/CAPE.
# The job script are the qc_job_<freq>.sh
# where freq is 15min, 1hr, 6hr, day or mon.
# Before running this script, edit
# datadir - to point to the directory containing the Level 1 data
# aset - which set of data. Set to 15min 1hr 6hr day or mon.
# variables - a list of variable to qc.
# outdir - to point to the directory containing the qc output
#

#==========================
# Start - Edit ME!
# era5 historical data
#datadir=/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/ECMWF-ERA5/evaluation/r1i1p1f1/BOM-BARPA-R/v1
#outdir=/g/data/tp28/dev/chs548/productive/qc/cg282_ERA5_historical_1979_sciB
# cm2 historical
#datadir=/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/CSIRO-BOM-ACCESS-CM2/historical/r4i1p1f1/BOM-BARPA-R/v1
#outdir=/g/data/hd50/chs548/barra2_shared_dev/qc/cg282_ACCESS-CM2_historical_1960_sciB
# BARRA-R2
datadir=/g/data/yb19/australian-climate-service/stage/ACS-BARRA2/output/AUS-11/BOM/ECMWF-ERA5/evaluation/hres/BOM-BARRA-R2/v1
outdir=/g/data/tp28/dev/chs548/productive/qc/BARRA-R2_stage1
aset="mon"
#aset="3hr"
#aset="10min"
variables="ta600"
# End - Edit ME!
#==========================

for variable in $variables; do
	ncdir=$datadir/$aset/$variable
	export indir=$ncdir
	export variable=$variable
	export aset=$aset
	export outdir=$outdir
	jobname=qc.${aset}_${variable}
	echo "Submit $jobname"
	qsub -N $jobname -v indir,variable,aset,outdir qc_job_${aset}.sh
done
