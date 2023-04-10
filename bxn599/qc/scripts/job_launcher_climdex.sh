#!/bin/bash

#set -x

# README
# This script submits pbs jobs to perform qc for each variable.
# That is one job for each freq/variable, e.g., 1hr/CAPE.
# The job script are the qc_job_<freq>.sh
# where freq is 15min, 1hr, 6hr, day or mon.
# Before running this script, edit
# datadir - to point to the directory containing the Level 1 data
# sets - which set of data. It can be the whole lot "15min 1hr 6hr day mon" but this 
#       launches too many jobs. So I generally run "1hr 6hr" first, then "day mon 15min"
# outdir - to point to the directory containing the qc output
#

#========================
# Start - Edit ME!
#era5 historical data
datadir=/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/indices/AUS-15/BOM/ECMWF-ERA5/evaluation/none/BOM-BARPA-R/v1/climdex/
outdir=/g/data/xv83/users/bxn599/ACS/icclim_indices/qc
# # cm2 historical
# datadir=/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/CSIRO-BOM-ACCESS-CM2/historical/r4i1p1f1/BOM-BARPA-R/v1
# sets="15min 1hr 6hr day mon"
#sets="1hr 6hr day mon"
# sets="1hr 6hr"
# sets="day mon"
# sets="15min"
#sets="mon day"
sets="mon"
#sets="15min"
#sets="mon"
# End - Edit ME!
#=========================

for aset in $sets; do
	ncdir_list=`ls -d $datadir/*`
	for ncdir in $ncdir_list; do
		export indir=$ncdir
		export variable=`basename $ncdir`
		export aset=$aset
		export outdir=$outdir
		jobname=qc.${aset}_${variable}
		echo "Submit $jobname"
		qsub -N $jobname -v indir,variable,aset,outdir qc_job_${aset}.sh
	done
done
