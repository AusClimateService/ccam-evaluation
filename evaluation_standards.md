# Evaluation standards for CCAM

### Window length: 30 years
  - Historical: 1985-01-01 to 2014-12-31
  - Future: 2015-01-01 to 2044-12-31, 2035-01-01 to 2064-12-31, 2070-01-01 to 2099-12-31
  - Note: A 20-year window may be preferred due to the transient climate in the future

### Regions
  - NRM cluster and subclusters
  - Masks are generated using Damien Irving's [script](https://github.com/AusClimateService/model-evaluation/blob/master/report_EOFY22/spatial_selection.py)
  - Use fractional weighting when generating masks to allow for more accurate masking when extending analysis to CMIP6 models
    + As discussed at Model Evaluation meeting (2022-12-09), current plan is to downscale GCM to AGCD grid using Nearest Neighbour and then use geopandas and shapefiles to generate masks

### Indices
  - A table comparing xclim/icclim/climpact can be found [here](https://github.com/AusClimateService/model-evaluation/blob/master/indices.md)
  - Use icclim to calculate indices
    - icclim code
       - [BARPA](https://github.com/AusClimateService/BARPA_evaluation/tree/main/chs/indices)
       - [CCAM](https://github.com/AusClimateService/ccam-evaluation/tree/main/bxn599/icclim_indices)
    - There are some differences between xclim and climpact, see indices list above

### Standard evaluation tools (developed by Chun-Hsu Su and Emma Howard)
  - See [here](https://github.com/AusClimateService/BARPA_evaluation/blob/main/lib/lib_standards.py)

### Observation datasets
  - Daily
    - AGCDv1 (`/g/data/xv83/agcd-csiro/`)
      - Use the commercial copy in xv83 for analysis
      - 2022-11-11: There is a single day difference (2013-05-02) in tmin between `/g/data/xv83/agcd-csiro/tmin/daily` and `/g/data/zv2/agcd/v1/tmin/mean/r005/01day`
          
          <img src="https://user-images.githubusercontent.com/34051150/200422503-33ef8cb1-56a1-4864-9698-96958e5d7359.png" width="250" height="250">

  - Sub-daily
    - ERA5
    - BARRA

### Regridding
  - Observations and GCMs should be regridded to RCM grid using conservative area weighted remapping if upscaling
  - As discussed at model evaluation meeting on 25/11/2022
    - Conventions for upscaling (regridding to a coarser grid): Conservative
    - Conventions for downscaling (regridding to a finer grid): Bilinear suggested with no lapse rate adjustments
    - Previously noted/discussed in Data & Code group, see [data_standards.md](https://github.com/AusClimateService/AusClimateService/blob/main/technical_notes/regridding.md)

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
