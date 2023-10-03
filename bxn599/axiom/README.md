Modify `generate_payloads_loop_model_experiment.py` to run over the model, scenario, and years you want. These scripts should generate payloads for 1H, 6H, 1D, 1M. Example Python scripts to generate the payloads can be found in this repo.

To use `generate_payloads_loop_model_experiment.py` to generate the payload json files:
```
module load conda/analysis3
conda activate /g/data/xv83/users/bxn599/miniconda3/envs/axiom_dev
python generate_payloads_loop_model_experiment.py
```

Once payloads are generated, we use `axiom drs_launch` to submit the payloads to the Gadi job queues:

`axiom drs_launch "path/to/payloads/in/quotes" /g/data/xv83/users/bxn599/ACS/axiom/jobscript.sh path/to/log/directory`

e.g. 
```
axiom drs_launch "/g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km/1M-payload-*.json" /g/data/xv83/users/bxn599/ACS/axiom/jobscript.sh /g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km
```
Note that `jobscript.sh` uses Gadi Normal queue and `jobscript_sl.sh` uses Skylake queue.

It is a good idea to save the logs in the same directory as the payloads so then `axiom drs_rerun_failures` can be used

e.g.
```
axiom drs_rerun_failures /g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km
axiom drs_launch "/g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km/rerun/*.json" /g/data/xv83/users/bxn599/ACS/axiom/jobscript.sh /g/data/xv83/users/bxn599/ACS/axiom/ccam_cmcc-esm2_ssp126_aus-10i_12km/rerun
```

Please see [axiom documentation](https://axiom.readthedocs.io/en/v0.1.6/drs/payloads.html#) for further info
