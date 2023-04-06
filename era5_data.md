## ERA5 data location and concatenation

### Locations
NCI Repo: `/g/data/rt52/era5`
  
Hourly rainfall downloaded from ECMWF: `/g/data/xv83/users/bxn599/era5/hourly/tp`
  
- `tp_20210101-20210530.nc` is 4D and has an exp_ver dimension, this is removed in `tp_20210101-20210530_remove_exp_ver.nc` using the following CDO command: `cdo --reduce_dim -sellevidx,1 tp_20210101-20210530.nc tp_20210101-20210530_remove_exp_ver.nc` 
  
Concatenated data: `/g/data/xv83/bxn599/ACS/data/era5`
  
### Concatenation process
ERA5 stored is in short data format and the scale factor and offset can vary between files. 
Therefore, when concatenating ERA5 data with CDO it is best to use the `-b F64` flag. 
This will convert the data to double and avoid any issues.

This figure shows the difference between data which has been concatenated without (temp_daysum) and with the `-b F64` flag (temp_f64_daysum). 

<img src="https://user-images.githubusercontent.com/34051150/201275706-008fc951-fdc5-4d00-9edc-3d97c077d11d.png" width="250" height="250">

The difference between the two files only occurs for time steps [367:458].

<img src="https://user-images.githubusercontent.com/34051150/201282049-2c47a89b-5e73-45a4-967c-4118263a9c3d.png" width="250" height="250">

These two files can be found in `/g/data/xv83/users/bxn599/era5/hourly/tp/test`

Concatenated data is calculated using the `-b F64` flag on all steps.
