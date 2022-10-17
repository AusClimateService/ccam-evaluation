# Evaluation protocol and standards for CCAM

## Standards (2022-10-17)
### Window length: 30 years
  - Historical: 1985-01-01 to 2014-12-31
  - Future: 2070-01-01 to 2099-12-31
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
