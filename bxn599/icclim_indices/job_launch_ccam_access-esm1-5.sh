#!/bin/bash 

data=ccam_access-esm1-5

indices_bi="tasmax:tasmin:DTR tasmax:tasmin:ETR tasmax:tasmin:vDTR"
indices_tasmax="tasmax:TX tasmax:SU tasmax:TXx tasmax:CSU tasmax:ID tasmax:TXn"
indices_tasmin="tasmin:TN tasmin:TR tasmin:TNx tasmin:FD tasmin:CFD tasmin:TNn"
indices_prcp="pr:CDD pr:PRCPTOT pr:RR1 pr:SDII pr:CWD pr:RR pr:R10mm pr:R20mm pr:RX1day pr:RX5day"
indices_tas="tas:TG"
indices_percentile="tas:TG90p tas:TG10p tasmax:TX90p tasmax:TX10p tasmin:TN90p tasmin:TN10p pr:R75p pr:R75pTOT pr:R95p pr:R95pTOT pr:R99p pr:R99pTOT tas:pr:CD tas:pr:CW tas:pr:WD tas:pr:WW"
indices_spi="pr:SPI3 pr:SPI6"
indices_wind="sfcWind:FG sfcWind:FGcalm sfcWind:FG6Bft"

index_list_all="${indices_tasmax} ${indices_tasmin} ${indices_prcp} ${indices_tas} ${indices_bi} ${indices_wind}" ## don't include ${indices_bi} in list due to running a separate script with longer walltime
index_list_per="${indices_percentile}"
index_list_spi="${indices_spi}"

for index in $index_list_all; do
		export index_list=$index
		echo $index_list
		jobname=index.${data}.${index_list//":"/"_"}
		echo "Submit $jobname"
		qsub -N $jobname -v index_list job_${data}_icclim.sh
done

for index in $index_list_per; do
		export index_list=$index
		echo $index_list
		jobname=index.${data}.${index_list//":"/"_"}
		echo "Submit $jobname"
		qsub -N $jobname -v index_list job_${data}_icclim_percentiles.sh
done

for index in $index_list_spi; do
		export index_list=$index
		echo $index_list
		jobname=index.${data}.${index_list//":"/"_"}
		echo "Submit $jobname"
		qsub -N $jobname -v index_list job_${data}_icclim_spi.sh
done