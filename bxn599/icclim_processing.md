# RCM/GCM ICCLIM indices calculation

This file maintains a list of Obs (AGCDv1), reanalysis (ERA5), GCMs and downscaled runs which have been processed using [icclim](https://github.com/AusClimateService/indices)

### Observations & Reanalysis
| Model | Realisation | Processed | QC | Location | Person responsible | Notes |
| - | - | - | - | - | - | - |
| AGCDv1 | - | :heavy_check_mark: | :x: | - | @ngben | Missing tas |
| ERA5 | - | :heavy_check_mark: | :x: | - | @ngben | - |

### GCMs
| Model | Realisation | Processed | QC | Location | Person responsible | Notes |
| - | - | - | - | - | - | - |
| ACCESS-CM2 | r4i1p1f1 | :heavy_check_mark: | :x: | - | @ngben | - |
| ACCESS-ESM1-5 | r6i1p1f1 | :heavy_check_mark: | :x: | - | @ngben | - |
| CESM2 | r4i1p1f1 | :x: | :x: | - | @ngben | Missing daily tasmax and tasmin |
| CMCC-ESM2 | r1i1p1f1 | :x: | :x: | - | @ngben | Error in icclim, issue raised |
| CNRM-ESM2-1 | r1i1p1f2 | :heavy_check_mark: | :x: | - | @ngben | - |
| EC-Earth3 | r1i1p1f1 | :heavy_check_mark: | :x: | - | @ngben | - |
| NorESM2-MM | r1i1p1f1 | :x: | :x: | - | @ngben | Error in icclim, issue raised |

### CCAM
| Model | Realisation | Processed | QC | Location | Person responsible | Notes |
| - | - | - | - | - | - | - |
| CCAM-ERA5 | - | :heavy_check_mark: | :x: | - | @ngben | - |
| CCAM-NorESM2-MM | r1i1p1f1 | :heavy_check_mark: | :x: | - | @ngben | - |