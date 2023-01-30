# README

This directory contains config files and scripts for running ILAMB

Cannot use `R75/95/99pTOT` in ILAMB due to empty/FillValue grid points. This causes a plotting issue and stops ILAMB from running successfully. In Climpact, these indices are calculated ANN only, not monthly

### To view ILAMB
1. Create a virtual desktop interface (VDI) on NCI [ARE](https://are.nci.org.au/) with Queue: copyq and Storage: gdata/xv83
2. In VDI, open a terminal and enter `cd /g/data/xv83/users/bxn599/ACS/ilamb`
3. Run `./launch_webserver.sh`
4. Open Firefox and browse to `http://localhost:8000/`

### --study_limits issue
There is an issue when using the `--study_limits` flag where data is shifted 1 month earlier, leading to an incorrect/out of phase annual cycle. 
Data which fits the study limits period doesn't appear to be affected by this, but data longer (and possibly shorter, not tested) than the study limits period are affected. Removing the `--study_limits` flag solves this issue. There doesn't seem to be any noticeable increase in resources when *not* using the `--study_limits` flag.

CMIP6_NorESM2-MM
![image](https://user-images.githubusercontent.com/34051150/215453088-7a51e084-fb12-42a8-aae9-fc1fd6feae40.png)

CMIP6_NorESM2-MM (no --study_limits)
![image](https://user-images.githubusercontent.com/34051150/215453567-54cf7fb2-5413-4248-a3a6-b3da49b094e8.png)

BARPA_ACCESS-CM2
![image](https://user-images.githubusercontent.com/34051150/215454207-fc6b4e02-0159-47aa-b765-c082f742fb86.png)

BARPA_ACCESS-CM2 (no --study_limits)
![image](https://user-images.githubusercontent.com/34051150/215454371-2e40d92c-76be-4247-8230-220a63cae673.png)
