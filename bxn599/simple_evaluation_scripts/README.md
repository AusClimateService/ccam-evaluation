These NCL and shell scripts can be used to quickly examine CCAM output to ensure there are no major errors before using too much computing resources.
This is similar to the link Claire shared at a previous group meeting for ACCESS QC (e.g. https://accessdev.nci.org.au/p66/cm2704/CMIP6_QC/bj594/Amon/tas_index.html)

Plots the time series at the first grid point, along with the mean/min/max/stdev time series (averaged over all grid points) and a spatial plot of the variable at the first time step.
The shell script feeds command line arguments into the NCL script to determine which variable to examine and file location.
At the moment uses 3 command line arguments (path, var_path, var). Only works on daily and 3D (time, lat, lon) data (hourly data uses too much resources). Outputs a 4 panel PDF.