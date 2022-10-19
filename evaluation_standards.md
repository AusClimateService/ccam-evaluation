# Evaluation standards for CCAM

### Window length: 30 years
  - Historical: 1985-01-01 to 2014-12-31
  - Future: 2015-01-01 to 2044-12-31, 2035-01-01 to 2064-12-31, 2070-01-01 to 2099-12-31
  - Note: A 20-year window may be preferred due to the transient climate in the future

### Regions
  - NRM cluster and subclusters
  - Masks are generated using Damien Irving's script
    - https://github.com/AusClimateService/model-evaluation/blob/master/spatial_selection.py
  - Use fractional weighting when generating masks to allow for more accurate masking when extending analysis to CMIP6 models

### Indices
  - https://github.com/AusClimateService/ccam-evaluation/blob/main/climpact_xclim_indices.md
  - Use xclim to generate indices
    - xclim code: https://github.com/AusClimateService/BARPA_evaluation/tree/main/lib
    - There are some differences between xclim and climpact, see indices list above

### Observation datasets
  - Daily
    - AGCDv1
  - Sub-daily
    - ERA5
    - BARRA

### Regridding
  - Observations and GCMs should be regridded to RCM/CCAM grid using conservative area weighted remapping

### Variables to be evaluated
| Variable   | Name                                                | Obs datasets | Timescale               | Notes |
|------------|-----------------------------------------------------|--------------|-------------------------|-------|
| pr         | precipitation                                       | AGCD         | Daily, seasonal, annual |       |
| tasmax     | daily maximum near-surface air temperature          | AGCD         | Daily, seasonal, annual |       |
| tasmin     | daily minimum near-surface air temperature          | AGCD         | Daily, seasonal, annual |       |
| u200       | 200hPa zonal wind                                   | ERA5         |                         |       |
| u500       | 500hPa zonal wind                                   | ERA5         |                         |       |
| u850       | 850hPa zonal wind                                   | ERA5         |                         |       |
| v200       | 200hPa meridional wind                              | ERA5         |                         |       |
| v500       | 500hPa meridional wind                              | ERA5         |                         |       |
| v850       | 850hPa meridional wind                              | ERA5         |                         |       |
| sfcWind    | near-surface wind speed                             | ERA5?        |                         |       |
| ps         | surface air pressure                                | ERA5         |                         |       |
| psl        | sea level pressure                                  | ERA5         |                         |       |
| huss       | near-surface specific humidity                      | ERA5?        |                         |       |
| hurs       | near-surface relative humidity                      |              |                         |       |
| zg200      | 200hPa geopotential height                          | ERA5         |                         |       |
| zg500      | 500hPa geopotential height                          | ERA5         |                         |       |
| zg850      | 850hPa geopotential height                          | ERA5         |                         |       |
| prhmax     | daily maximum hourly precipitation rate             |              |                         |       |
| mrso       | total soil moisture content                         |              |                         |       |
| sfcWindmax | daily maximum near-surface wind speed               |              |                         |       |
| uas        | eastward near-surface wind                          |              |                         |       |
| vas        | northward near-surface wind                         |              |                         |       |
| clt        | total cloud cover percentage                        |              |                         |       |
| evspsbl    | evaporation including sublimation and transpiration |              |                         |       |
| CAPE       | convective available potential energy               |              |                         |       |
| CINN       | convective inhibition                               |              |                         |       |
| wsgsmax    | daily maximum near-surface wind speed of gust       |              |                         |       |
| ???        | aerosol optical depth                               |              |                         |       |
