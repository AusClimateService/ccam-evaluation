## xclim
#### Pros
- Scalable, fast
- Python more widely used by the evaluation group
- Can read multiple input files (chunks)
- Supports compound indices
- xclim development is funded through Ouranos, Environment and Climate Change Canada (ECCC), the Fonds vert and the Fonds d’électrification et de changements climatiques (FECC), the Canadian Foundation for Innovation (CFI), and the Fonds de recherche du Québec (FRQ). [https://github.com/Ouranosinc/xclim]

#### Cons
- Calculating percentiles requires rechunking and a lot of resources, or percentiles need to be pre-computed
- Calculates some heat wave metrics/indices but defines them using absolute values

## icclim
#### Pros
- Built on xclim
- Interface might be a bit friendlier than xclim, uses API
- Supports user-defined indices
- Supports compound indices
- Development lead by CERFACS [https://github.com/cerfacs-globc/icclim]

#### Cons
- Calculating percentiles requires rechunking and a lot of resources
  - This may have been fixed in the latest version of icclim 6.0.0 (Damien ran some tests)
- No heat wave metrics/indices

## Climpact
#### Pros
- Supports percentile calculations
- Calculates multiple heat wave metrics using percentile or excess heat factor. This is preferred over using an absolute value for thresholds
- Package is widely used
- Funding/support is from ARCCSS climate extremes [https://github.com/ARCCSS-extremes/climpact]

#### Cons
- Differences in rx5day calculation, centering window may not be accurate based on definition (it should center on the last day of the 5-day window)
- Requires input data to be 1 file for each variable, cannot read multiple files/chunks
- May be slower than xclim, less scalable
- Less expertise in R among the evaluation group
- Not actively developed?
