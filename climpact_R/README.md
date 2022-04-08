# R script to calculate Climpact/Climdex indices

Uses R script from Climpact (https://github.com/ARCCSS-extremes/climpact/). Takes ~8 hours to run on CCAM 1980-2019 25km data when calculating all indices.

Requires the following modules on Gadi:
 - module load R/4.1.0
 - module load proj/6.2.1
 - module load udunits/2.2.26
 - module load intel-compiler/2021.3.0
 - module load netcdf/4.7.4
 - module load intel-mkl/2021.3.0
 - module load gcc/11.1.0

Input variables:
 - rainfall (kg m-2 d-1 or kg m-2 s-1)
 - tasmax
 - tasmin
 - Each variable must be concatenated into a single file (e.g., ccam_rainfall_19800101-20191231.nc)

Base installation of R scripts are located here (the R script will reference files in this directory) : /g/data/xv83/bxn599/CaRSA/climpact