#!/bin/bash
#PBS -l walltime=08:00:00
#PBS -l ncpus=16
#PBS -l mem=180GB
#PBS -l wd
#PBS -m n
#PBS -P xv83
#PBS -q normal
#PBS -l storage=scratch/du7+gdata/du7+gdata/access+gdata/hh5+gdata/r87+gdata/ub4+gdata/rr3+gdata/al33+gdata/ma05+gdata/dp9+gdata/rr8+scratch/e53+gdata/wr45+gdata/rt52+gdata/wr45+gdata/hd50+gdata/tp28+scratch/hd50+scratch/tp28+gdata/xv83+gdata/ia39

# Environment
#
# tg,tn,tx,dtr,etr,vdtr,su,tr,wsdi,tg90p,tn90p,tx90p,txx,tnx,csu,gd4,fd,cfd,hd17,id,tg10p,tn10p,tx10p,txn,tnn,csdi,cdd,prcptot,rr1,sdii,cwd,rr,r10mm,r20mm,rx1day,rx5day,r75p,r75ptot,r95p,r95ptot,r99p,r99ptot,sd,sd1,sd5cm,sd50cm,cd,cw,wd,ww
# 

#set -x

# Script definition
icclim_path=/g/data/xv83/bxn599/ACS/icclim
script="/g/data/xv83/dbi599/miniconda3/envs/icclim/bin/python ${icclim_path}/run_icclim.py"

# CSIRO's AGCD data
INSTITUTION=none
MODEL=none
GCM=BOM-AGCD
SCENARIO=historical
REALISATION=none
IN_VERSION=v1
IN_ROOT_DIR=/g/data/xv83/agcd-csiro
DOMAIN=AUS-r005
OUT_ROOT_DIR=/g/data/xv83/$USER/ACS/icclim_indices
OUT_VERSION=v1
#SLICE_MODE=month
TIME_PERIOD="1979-01-01 2021-12-31"
START_DATE=$(echo $TIME_PERIOD | cut -d' ' -f1)
END_DATE=$(echo $TIME_PERIOD | cut -d' ' -f2)

mkdir -p ${OUT_ROOT_DIR} || true

label=${DOMAIN}_${GCM}_${SCENARIO}_${OUT_VERSION}
subdir=${DOMAIN}/${INSTITUTION}/${GCM}/${SCENARIO}/${REALISATION}/${MODEL}

slice_list="year month DJF MAM JJA SON"

echo $index_list

for slice in $slice_list; do
	SLICE_MODE=$slice
	echo $SLICE_MODE
for var_index in $index_list; do
	count=$(echo $var_index | tr -cd ':' | wc -c)
	
  if [ "$count" == "1" ]; then
		index=`echo $var_index | cut -d':' -f2`
		var_list=`echo $var_index | cut -d':' -f1`
		var_list=${var_list/&/ }
		echo $var_list
		
		outdir=${OUT_ROOT_DIR}/${subdir}/${OUT_VERSION}/climdex/${index}
	        mkdir -p ${outdir} || true
	
		cmd="${script} --slice_mode ${SLICE_MODE} --verbose"
	
		if [ "${TIME_PERIOD}" != "" ]; then
			cmd="${cmd} --start_date ${START_DATE} --end_date ${END_DATE}"
		fi
	
		for var_name in ${var_list}; do
			if [ "$var_name" == "tasmax" ]; then
	          	      var_name=tmax
		        fi
			if [ "$var_name" == "tasmin" ]; then
	        	        var_name=tmin
		        fi
			if [ "$var_name" == "pr" ]; then
	                	var_name=precip
		        fi
			if [ "$var_name" == "tas" ]; then
	                	var_name=tavg
		        fi
	
			echo "${var_name} - $index"
	
			indir=${IN_ROOT_DIR}/${var_name}/daily
			input_files="${indir}/${var_name}*.nc"
			first_file=`ls ${indir}/${var_name}*.nc | head -n 1`
			last_file=`ls ${indir}/${var_name}*.nc | tail -n 1`
			first_file=`basename ${first_file/.nc/}`
			last_file=`basename ${last_file/.nc/}`
		
			if [ "${TIME_PERIOD}" == "" ]; then
				tstart=`echo ${first_file##*_} | cut -d'-' -f1`
				tend=`echo ${last_file##*_} | cut -d'-' -f2`
				output_file=${outdir}/${index}_${label}_${SLICE_MODE}_${tstart}-${tend}.nc
			else
				tmp=`echo ${TIME_PERIOD//-/}`
				output_file=${outdir}/${index}_${label}_${SLICE_MODE}_${tmp/ /-}.nc
			fi
			
			cmd="${cmd} --input_files ${input_files} --variable ${var_name} --drop_time_bounds"
	  done
	
		rm ${output_file}
	  
	  cmd="${cmd} ${index} ${output_file}"
	  echo $cmd
		
		$cmd
	fi

# bivariate
  if [ "$count" == "2" ]; then
		index=`echo $var_index | cut -d':' -f3`
		var_list1=`echo $var_index | cut -d':' -f1`
		var_list1=${var_list1/&/ }
		echo $var_list1
		var_list2=`echo $var_index | cut -d':' -f2`
		var_list2=${var_list2/&/ }
		echo $var_list2
		
		outdir=${OUT_ROOT_DIR}/${subdir}/${OUT_VERSION}/climdex/${index}
	        mkdir -p ${outdir} || true
	
		cmd="${script} --slice_mode ${SLICE_MODE} --verbose"
	
		if [ "${TIME_PERIOD}" != "" ]; then
			cmd="${cmd} --start_date ${START_DATE} --end_date ${END_DATE}"
		fi
	
		for var_name1 in ${var_list1}; do
			if [ "$var_name1" == "tasmax" ]; then
	          	      var_name1=tmax
		        fi
			if [ "$var_name1" == "tasmin" ]; then
	        	        var_name1=tmin
		        fi
			if [ "$var_name1" == "pr" ]; then
	                	var_name1=precip
		        fi
			if [ "$var_name1" == "tas" ]; then
	                	var_name1=tavg
		        fi
	
			indir1=${IN_ROOT_DIR}/${var_name1}/daily
			input_files1="${indir1}/${var_name1}*.nc"
			first_file1=`ls ${indir1}/${var_name1}*.nc | head -n 1`
			last_file1=`ls ${indir1}/${var_name1}*.nc | tail -n 1`
			first_file1=`basename ${first_file1/.nc/}`
			last_file1=`basename ${last_file1/.nc/}`

			if [ "${TIME_PERIOD}" == "" ]; then
				tstart1=`echo ${first_file1##*_} | cut -d'-' -f1`
				tend1=`echo ${last_file1##*_} | cut -d'-' -f2`
				output_file=${outdir}/${index}_${label}_${SLICE_MODE}_${tstart1}-${tend1}.nc
			else
				tmp=`echo ${TIME_PERIOD//-/}`
				output_file=${outdir}/${index}_${label}_${SLICE_MODE}_${tmp/ /-}.nc
			fi
	  done

		for var_name2 in ${var_list2}; do
			if [ "$var_name2" == "tasmax" ]; then
	          	      var_name2=tmax
		        fi
			if [ "$var_name2" == "tasmin" ]; then
	        	        var_name2=tmin
		        fi
			if [ "$var_name2" == "pr" ]; then
	                	var_name2=precip
		        fi
			if [ "$var_name2" == "tas" ]; then
	                	var_name2=tavg
		        fi

			indir2=${IN_ROOT_DIR}/${var_name2}/daily
			input_files2="${indir2}/${var_name2}*.nc"
	  done
			
		cmd="${cmd} --input_files ${input_files1} --variable ${var_name1} --input_files ${input_files2} --variable ${var_name2} --drop_time_bounds"
	
		rm ${output_file}
	  
	  cmd="${cmd} ${index} ${output_file}"
	  echo $cmd
	
		$cmd
	fi

	if [ $? -ne 0 ]; then
		echo "Fail $index with $var_name"
		touch fail.agcd.${index}
	else
		touch success.agcd.${index}
	fi
done
done