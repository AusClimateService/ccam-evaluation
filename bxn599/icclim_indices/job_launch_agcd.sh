#!/bin/bash

data=agcd

indices_tasmax="tasmax:tx tasmax:su tasmax:txx tasmax:csu tasmax:id tasmax:txn tasmax:tx90p tasmax:tx10p"
indices_tasmin="tasmin:tn tasmin:tr tasmin:tnx tasmin:fd tasmin:cfd tasmin:tnn tasmin:tn90p tasmin:tn10p"
indices_prcp="pr:cdd pr:prcptot pr:rr1 pr:sdii pr:cwd pr:rr pr:r10mm pr:r20mm pr:rx1day pr:rx5day pr:r75p pr:r75ptot pr:r95p pr:r95ptot pr:r99p pr:r99ptot"
##indices_tas="tas:tg tas:tg90p tas:tg10p"
indices_bi="tasmax:tasmin:dtr tasmax:tasmin:etr tasmax:tasmin:vdtr" ## agcd doesn't have tas tas:pr:cd tas:pr:cw tas:pr:wd tas:pr:ww

all_index_list="${indices_tasmax} ${indices_tasmin} ${indices_prcp}" ## don't include ${indices_bi} in list due to running a separate script with longer walltime. don't include ${indices_tas} due to agcd not having tas
index_list_bi="${indices_bi}"

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