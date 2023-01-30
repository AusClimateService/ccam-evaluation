# README

This directory contains config files and scripts for running ILAMB

Cannot use `R75/95/99pTOT` in ILAMB due to empty/FillValue grid points. This causes a plotting issue and stops ILAMB from running successfully. In Climpact, these indices are calculated ANN only, not monthly

### To view ILAMB
1. Create a virtual desktop interface (VDI) on NCI [ARE](https://are.nci.org.au/) with Queue: copyq and Storage: gdata/xv83
2. In VDI, open a terminal and enter `cd /g/data/xv83/users/bxn599/ACS/ilamb`
3. Run `./launch_webserver.sh`
4. Open Firefox and browse to `http://localhost:8000/`

### --study_limits issue
There is an issue when using the `--study_limits` flag where data is shifted 1 month earlier, leading to an incorrect/out of phase annual cycle. Data which fits the study limits period doesn't appear to be affected by this, but data longer (and possibly shorter, not tested) than the study limits period are affected. Removing the `--study_limits` flag solves this issue.