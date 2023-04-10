#!/bin/bash
#PBS -l walltime=4:00:00
#PBS -l ncpus=1
#PBS -l mem=40GB
#PBS -l wd
#PBS -m n
#PBS -P xv83
#PBS -q normal
#PBS -l storage=gdata/hh5+gdata/hd50+gdata/ia39+gdata/tp28+gdata/dp9+gdata/xv83

module use /g/data3/hh5/public/modules
module load conda/analysis3

logfile=${outdir}/stats/stats.${aset}_${variable}.log
figdir=${outdir}/fig
sanityfile=${outdir}/sanity/sanity.${aset}_${variable}.log

monthlyflag=""
if [ "$aset" == "mon" ]; then
	monthlyflag="--monthly"
fi

mkdir -p ${outdir}/stats | true
mkdir -p ${figdir} || true
mkdir -p ${outdir}/sanity || true
cmd="python qc_util.py --indir $indir --logfile $logfile --figdir $figdir --sanityfile $sanityfile $monthlyflag"
echo $cmd
$cmd

if [ $? -eq 0 ]; then
        echo "SUCCEED"
        exit 0
else
        echo "FAILED"
        exit 1
fi

