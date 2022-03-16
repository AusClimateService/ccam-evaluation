# Development Roadmap

## Phase 1

Target Date: TBA

Minimum requirements:
- Minimum collection of metrics coded (list TBA)
- Scripts (in any language) to produce indices
- Indices output in NetCDF format
- Basic plots of Indices (in any language)
- Basic execution (i.e. shell script) to compute indices as part of a workflow.
- Parallel Evaluation between Climpact and Python options (xclim etc.)

## Phase 2

Target Date: TBA

Minimum Requirements:
- Refactoring metrics code into Python (xarray/dask).
- Evaluate Python-based computation against native implementations.
- Optimise for speed, while maintaining precision.
- Granular / graph-based execution strategy to compute indices individually, at different times, or as dependencies between each other.
