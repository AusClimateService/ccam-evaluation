#!/bin/bash

data=era5

indices_tasmax="tasmax:TX tasmax:SU tasmax:TXx tasmax:CSU tasmax:ID tasmax:TXn tasmax:TX90p tasmax:TX10p"
indices_tasmin="tasmin:TN tasmin:TR tasmin:TNx tasmin:FD tasmin:CFD tasmin:TNn tasmin:TN90p tasmin:TN10p"
indices_prcp="pr:CDD pr:PRCPTOT pr:RR1 pr:SDII pr:CWD pr:RR pr:R10mm pr:R20mm pr:RX1day pr:RX5day pr:R75p pr:R75pTOT pr:R95p pr:R95pTOT pr:R99p pr:R99pTOT"
indices_tas="tas:TG tas:TG90p tas:TG10p"
indices_bi="tasmax:tasmin:DTR tasmax:tasmin:ETR tasmax:tasmin:vDTR tas:pr:CD tas:pr:CW tas:pr:WD tas:pr:WW"
#indices_tasmax="tasmax:TX tasmax:SU tasmax:TXx tasmax:CSU tasmax:ID tasmax:TXn"
#indices_tasmin="tasmin:TN tasmin:TR tasmin:TNx tasmin:FD tasmin:CFD tasmin:TNn"
#indices_prcp="pr:CDD pr:PRCPTOT pr:RR1 pr:SDII pr:CWD pr:RR pr:R10mm pr:R20mm pr:RX1day pr:RX5day"
#indices_tas="tas:TG"
#indices_percentile="tas:TG90p tas:TG10p tasmax:TX90p tasmax:TX10p tasmin:TN90p tasmin:TN10p pr:R75p pr:R75pTOT pr:R95p pr:R95pTOT pr:R99p pr:R99pTOT"

all_index_list="${indices_tasmax} ${indices_tasmin} ${indices_prcp} ${indices_tas}" ## don't include ${indices_bi} in list due to running a separate script with longer walltime
index_list_bi="${indices_bi}"
#all_index_list="${indices_percentile}"

for index in $all_index_list; do
		export index_list=$index
		echo $index_list
		jobname=index.${data}.${index_list//":"/"_"}
		echo "Submit $jobname"
		qsub -N $jobname -v index_list job_${data}_icclim.sh
done

for index in $index_list_bi; do
		export index_list=$index
		echo $index_list
		jobname=index.${data}.${index_list//":"/"_"}
		echo "Submit $jobname"
		qsub -N $jobname -v index_list job_${data}_icclim_bivariate.sh
done