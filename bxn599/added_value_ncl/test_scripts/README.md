# Scripts to calculate added value using updated method

calc_av_pr_ccam_era5_aus-11i_12.5km_coupled.ncl/.sh
 - Note that this script only runs on historical data (e.g., CCAM ERA5 runs). It does not calculate PAV/RAV
 - requires hugemem (400GB) due to the high resolution of the data and the interpolation/number of calculations.
 - Script calculates added value for monthly, seasonal, and annual data

calc_av_pav_rav_pr/tasmin/tasmax.ncl/.sh
 - Calculates AV, PAV, RAV. Runs on CCAM ACCESS1.0 test run
 - Script calculates AV, PAV, RAV for monthly, seasonal, and annual data