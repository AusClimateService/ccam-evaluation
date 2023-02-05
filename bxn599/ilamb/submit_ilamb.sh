#!/bin/bash
storage=scratch/tp28+gdata/tp28+gdata/hh5+gdata/access+gdata/dp9+gdata/rt52+gdata/ia39+gdata/xv83+scratch/xv83+gdata/zv2+gdata/oi10+gdata/fs38

export PROCS=6
export ILAMB_OPTIONS="--init_only"
JID=`qsub -N job_ilamb_init -l walltime=24:00:00 -q normal -P xv83 -l storage=$storage -l mem=64G -l ncpus=$PROCS  -v PROCS,ILAMB_OPTIONS run_command.sh` 
echo $JID

# or put this on high-mem
export PROCS=12
export ILAMB_OPTIONS="--skip_plots --skip_scorecard"
JID=`qsub -N job_ilamb_confront -l walltime=04:00:00 -q normal -P xv83 -l storage=$storage -l mem=190G -l ncpus=$PROCS -W depend=afterok:${JID} -v PROCS,ILAMB_OPTIONS run_command.sh`
echo $JID


export PROCS=8
export ILAMB_OPTIONS="--skip_confront --skip_scorecard"
JID=`qsub -N job_ilamb_postproc -l walltime=02:00:00 -q normal -P xv83 -l storage=$storage -l mem=32G -l ncpus=$PROCS -W depend=afterok:$JID -v PROCS,ILAMB_OPTIONS run_command.sh`
echo $JID

export PROCS=1
export ILAMB_OPTIONS="--skip_confront --skip_plots"
qsub -N job_ilamb_scorecard -l walltime=02:00:00 -q normal -P xv83 -l storage=$storage -l mem=4G -l ncpus=$PROCS -W depend=afterok:$JID -v PROCS,ILAMB_OPTIONS run_command.sh
