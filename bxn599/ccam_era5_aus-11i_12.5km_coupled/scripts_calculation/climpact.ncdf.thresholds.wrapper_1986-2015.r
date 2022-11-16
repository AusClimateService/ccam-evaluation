# ------------------------------------------------
# This wrapper script calls the 'create.thresholds.from.file' function from the modified climdex.pcic.ncdf package
# to create thresholds, using data and parameters provided by the user.
# ------------------------------------------------

library(climdex.pcic.ncdf)
# list of one to three input files. e.g. c("a.nc","b.nc","c.nc")
#input.files=c("./www/sample_data/climpact.sampledata.gridded.1991-2010.nc")
input.files=c("../concatenated_data/pr_day_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc","../concatenated_data/tasmax_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc","../concatenated_data/tasmin_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc")

# list of variable names according to above file(s)
#vars=c(tmax="tmax", tmin="tmin", prec="precip")
vars=c(prec="pr",tmax="tasmax",tmin="tasmin")

# output file name
output.file="../calculated/climpact_output_1986-2015/thresholds.1986-2015.nc"

# author data
author.data=list(institution="CSIRO", institution_id="CSIRO")

# reference period
base.range=c(1986,2015)

# number of cores to use (or FALSE)
cores=14

# print messages?
verbose=TRUE

# Directory where Climpact is stored. Use full pathname. Leave as NULL if you are running this script from the Climpact directory (where this script was initially stored).
#root.dir=NULL
root.dir="/g/data/xv83/bxn599/CaRSA/climpact"


######################################
# Do not modify without a good reason.
maxvals=20

fclimdex.compatible=FALSE

create.thresholds.from.file(input.files,output.file,author.data,variable.name.map=vars,base.range=base.range,parallel=cores,verbose=verbose,fclimdex.compatible=fclimdex.compatible,root.dir=root.dir)
