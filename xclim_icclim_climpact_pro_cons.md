## xclim
#### Pros
- Scalable, fast
- Python more widely used by evaluation group
- Can read multiple input files (chunks)
- Supports compound indices

#### Cons
- Calculating percentiles requires rechunking and a lot of resources or percentiles to be pre-computed
- Calculates some heat wave metrics/indices but defines them using absolute values

## icclim
#### Pros
- Built on xclim
- Interface might be a bit friendlier than xclim, uses API
- Supports user-defined indices
- Supports compound indices

#### Cons
- Calculating percentiles requires rechunking and a lot of resources
- No heat wave metrics/indices

## Climpact
#### Pros
- Supports percentile calculations
- Calculates multiple heat wave metrics using percentile or excess heat factor. This is preferred over using an absolute value for thresholds

#### Cons
- Differences in rx5day calculation, centering window may not be accurate based on definition (it should center on the last day of the 5-day window)
- Requires input data to be 1 file for each variable, cannot read multiple files/chunks
- May be slower than xclim, less scalable
