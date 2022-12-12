# README

This directory contains config files and scripts for running ILAMB

Cannot use `R75/95/99pTOT` in ILAMB due to empty/FillValue grid points. This causes a plotting issue and stops ILAMB from running successfully. In Climpact, these indices are calculated ANN only, not monthly

### To view ILAMB
1. Create a virtual desktop interface (VDI) on NCI [ARE](https://are.nci.org.au/) with Queue: copyq and Storage: gdata/xv83
2. In VDI, open a terminal and enter `cd /g/data/xv83/bxn599/ACS/ilamb`
3. Run `./launch_webserver.sh`
4. Open Firefox and browse to `http://localhost:8000/`
