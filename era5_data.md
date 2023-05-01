# ERA5 data

## Locations
NCI Repo: `/g/data/rt52/era5`

Concatenated data: `/g/data/xv83/bxn599/ACS/data/era5/concatenated`

For consistency with icclim data we use hourly `t2m` and `mtpr` to calculate min/max daily temperature and mean precipitation. These are found in the concatenated data directory `/g/data/xv83/bxn599/ACS/data/era5/concatenated`. The CDO commands used to calculate the daily min/max/mean are as follows:

#### tasmax/tasmin
```
cdo -P 14 -b F64 sellonlatbox,88.0,208.0,-54.0,14.0 t2m_era5_oper_sfc_19790101-19790131.nc t2m_era5_oper_sfc_19790101-19790131_cordex_aus.nc
cdo -P 14 -b F64 cat t2m_era5_oper_sfc_19790101-19790131_cordex_aus.nc ... t2m_era5_oper_sfc_19790101-20211231_cordex_aus.nc
cdo -P 14 -b F64 -daymax -chname,t2m,tasmax t2m_era5_oper_sfc_19790101-20211231_cordex_aus.nc tasmax_daily_era5_19790101-20211231.nc
cdo -P 14 -b F64 -daymin -chname,t2m,tasmin t2m_era5_oper_sfc_19790101-20211231_cordex_aus.nc tasmin_daily_era5_19790101-20211231.nc
```
#### pr
```
cdo -P 14 -b F64 -selyear,1979/2021 -daymean -shifttime,-1hour -chname,mtpr,pr mtpr_era5_oper_sfc_19790101-20220131_cordex_aus.nc pr_daily_era5_19790101-20211231.nc
cdo -P 14 -b F64 cat mtpr_era5_oper_sfc_19790101-19790131_cordex_aus.nc ... mtpr_era5_oper_sfc_19790101-20220131_cordex_aus.nc
cdo -P 14 -b F64 sellonlatbox,88.0,208.0,-54.0,14.0 mtpr_era5_oper_sfc_19790101-19790131.nc mtpr_era5_oper_sfc_19790101-19790131_cordex_aus.nc
```
#### Notes
`mtpr` data needs to be concatenated first before calculating the daily mean as it is an accumulation variable and the timestep needs to be shifted back one hour (see below for more info and [here](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Meanrates/fluxesandaccumulations))

## Instantaneous and accumulation variables
Some variables in ERA5 are instantaneous (i.e., valid at the specified timestep (validity time)) whereas others are an accumulation (e.g., for the previous hour or 3 hours). See [ERA5 documentation](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Table2) for a list of instantaneous variables.

For quick reference: 
- `2t` (2m air temperature) is instantaneous
- `10u` (10m u component of wind) and `10v` (10m v component of wind) are instantaneous and are used to calculate `si10` (daily wind speed, `/g/data/xv83/users/bxn599/ACS/data/era5/raw/si10`)
- `10fg` (10m wind gust since previous processing) is a maximum/minimum and therefore the timestep (validity time) is for the previous hour
  - reanalysis: the minimum or maximum values are in the hour (the processing period) ending at the validity date/time. [ERA5 documentation](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Minimum/maximumsincethepreviouspostprocessing)
- `mtpr` (mean total precipitation rate) is rates/fluxes and therefore the timestep (validity time) is for the previous hour
  - For the CDS time, or validity time, of 00 UTC, the mean rates/fluxes and accumulations are over the hour (3 hours for the EDA) ending at 00 UTC i.e. the mean or accumulation is during part of the previous day. [ERA5 documentation](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Meanrates/fluxesandaccumulations)

Other references: 
- https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#heading-Instantaneousparameters
- https://confluence.ecmwf.int/display/CKB/ERA5%3A+2+metre+temperature
- https://confluence.ecmwf.int/display/CKB/Parameters+valid+at+the+specified+time
- https://confluence.ecmwf.int/pages/viewpage.action?pageId=85402030
  
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

### Old data
Hourly rainfall downloaded from ECMWF: `/g/data/xv83/users/bxn599/era5/hourly/tp`
- `tp_20210101-20210530.nc` is 4D and has an exp_ver dimension, this is removed in `tp_20210101-20210530_remove_exp_ver.nc` using the following CDO command: `cdo --reduce_dim -sellevidx,1 tp_20210101-20210530.nc tp_20210101-20210530_remove_exp_ver.nc` 
  
