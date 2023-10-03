#!/bin/bash
#PBS -P e53
#PBS -l walltime=12:00:00
#PBS -l ncpus=32
#PBS -l mem=192G
#PBS -q normalsl
#PBS -l storage=gdata/xv83+scratch/xv83+gdata/hh5+scratch/e53+gdata/e53
#PBS -l jobfs=400G
#PBS -j oe
#PBS -l wd

set -ex

# Load the conda environment
module use /g/data/hh5/public/modules
module load conda/analysis3
source /g/data/xv83/users/bxn599/miniconda3/etc/profile.d/conda.sh
conda activate /g/data/xv83/users/bxn599/miniconda3/envs/axiom_dev

# Run the consume command
axiom drs_consume $AXIOM_PAYLOAD >> $AXIOM_LOG_DIR/$PBS_JOBNAME.log

# Check if any variables failed in processing by looking for the .failed file
failed_filepath="${AXIOM_PAYLOAD}.failed"
if [ -f "$failed_filepath" ]; then
    echo "$failed_filepath exists. Some variables have failed to process."
    exit 1
else
    echo "$failed_filepath does not exist. All variables have processed successfully."
    exit 0
fi
