Scripts to calculate icclim indices using Damien Irving's (CSIRO) software. Modified from Chun-Hsu Su (BoM)

Note that time bounds need to be 'dropped'/removed for calculated indices to work properly in ILAMB

Currently (2022-11-23), percentile calculations are output (lat, lon, time) but ILAMB seems to require time as the left-most dimension (i.e., time, lat, lon)