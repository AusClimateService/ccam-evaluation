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
| CAPE       | convective available potential energy               |              |                         |       |
| CINN       | convective inhibition                               |              |                         |       |
| clt        | total cloud cover percentage                        |              |                         |       |
| evspsbl    | evaporation including sublimation and transpiration |              |                         |       |
| hurs       | near-surface relative humidity                      |              |                         |       |
| huss       | near-surface specific humidity                      |              |                         |       |
| mrso       | total soil moisture content                         |              |                         |       |
| pr         | precipitation                                       | AGCD         | Daily, seasonal, annual |       |
| prhmax     | daily maximum hourly precipitation rate             |              |                         |       |
| ps         | surface air pressure                                | ERA5         |                         |       |
| psl        | sea level pressure                                  | ERA5         |                         |       |
| sfcWind    | near-surface wind speed                             |              |                         |       |
| sfcWindmax | daily maximum near-surface wind speed               |              |                         |       |
| tasmax     | daily maximum near-surface air temperature          | AGCD         | Daily, seasonal, annual |       |
| tasmin     | daily minimum near-surface air temperature          | AGCD         | Daily, seasonal, annual |       |
| uas        | eastward near-surface wind                          |              |                         |       |
| ua200      | 200hPa eastward wind                                | ERA5         |                         |       |
| ua500      | 500hPa eastward wind                                | ERA5         |                         |       |
| ua850      | 850hPa eastward wind                                | ERA5         |                         |       |
| vas        | northward near-surface wind                         |              |                         |       |
| va200      | 200hPa northward wind                               | ERA5         |                         |       |
| va500      | 500hPa northward wind                               | ERA5         |                         |       |
| va850      | 850hPa northward wind                               | ERA5         |                         |       |
| wsgsmax    | daily maximum near-surface wind speed of gust       |              |                         |       |
| zg200      | 200hPa geopotential height                          | ERA5         |                         |       |
| zg500      | 500hPa geopotential height                          | ERA5         |                         |       |
| zg850      | 850hPa geopotential height                          | ERA5         |                         |       |
| ???        | aerosol optical depth                               |              |                         |       |

### Hazards to be evaluated
| Hazard            | Tool/Index                                          | Variables required | Notes |
|-------------------|-----------------------------------------------------|--------------------|-------|
| Bushfires         | FFDI, C-Haines                                      |                    |       |
| Tropical cyclones | Tempest extremes, CDD, OWZ                          |                    |       |
| Hail              |                                                     |                    |       |
| Flash flooding    |                                                     |                    |       |
| Storm surges      |                                                     |                    |       |

### Large scale drivers
| Climate driver    | Methodology        | Variables required | Notes |
|-------------------|--------------------|--------------------|-------|
| ENSO              | Composite, impacts |                    |       |
| IOD               |                    |                    |       |
| SAM               |                    |                    |       |
| MJO               |                    |                    |       |
| Monsoon           |                    |                    |       |
