# ------------------------------------------------
# This wrapper script calls the 'create.indices.from.files' function from the modified climdex.pcic.ncdf package
# to calculate ETCCDI, ET-SCI and other indices, using data and parameters provided by the user.
# Note even when using a threshold file, the base.range parameter must still be specified accurately.
# ------------------------------------------------

library(climdex.pcic.ncdf)
# list of one to three input files. e.g. c("a.nc","b.nc","c.nc")
infiles=c("../concatenated_data/pr_day_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc","../concatenated_data/tasmax_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc","../concatenated_data/tasmin_surf.ccam_12.5km.198601-201512_no_bnds_attr.nc")
#infiles="./era5_v5/pr_day_surf.ccam_25.km.198601-201512.nc"

# list of variable names according to above file(s)
vars=c(prec="pr",tmax="tasmax",tmin="tasmin")
#vars=c(prec="pr")

# output directory. Will be created if it does not exist.
outdir="../calculated/climpact_output_1986-2015/"

# Output filename format. Must use CMIP5 filename convention. i.e. "var_timeresolution_model_scenario_run_starttime-endtime.nc"
file.template="var_daily_climpact.ccam.era5_historical_NA_1986-2015.nc"

# author data
author.data=list(institution="My University", institution_id="MU")

# reference period
base.range=c(1986,2015)

# number of cores to use, or FALSE for single core.
cores=14

# list of indices to calculate, or NULL to calculate all.
indices=NULL	#c("hw","tnn")
#indices=c("prcptot","r95ptot","r95p")

# input threshold file to use, or NULL for none.
thresholds.files=NULL#"./www/output/gridded/thresholds.test.1991-1997.nc"

# Directory where Climpact is stored. Use full pathname. Leave as NULL if you are running this script from the Climpact directory (where this script was initially stored).
root.dir="/g/data/xv83/bxn599/CaRSA/climpact"


#######################################################
# Esoterics below, do not modify without a good reason.

# definition used for Excess Heat Factor (EHF). "PA13" for Perkins and Alexander (2013), this is the default. "NF13" for Nairn and Fawcett (2013).
EHF_DEF = "PA13"

# axis to split data on. For chunking up of grid, leave this.
axis.name="Y"

# Number of data values to process at once. If you receive "Error: rows.per.slice >= 1 is not TRUE", try increasing this to 20. You might have a large grid.
maxvals=20

# output compatible with FCLIMDEX. Leave this.
fclimdex.compatible=FALSE

# Call the package.
create.indices.from.files(infiles,outdir,file.template,author.data,variable.name.map=vars,base.range=base.range,parallel=cores,axis.to.split.on=axis.name,climdex.vars.subset=indices,thresholds.files=thresholds.files,fclimdex.compatible=fclimdex.compatible,root.dir=root.dir,
	cluster.type="SOCK",ehfdef=EHF_DEF,max.vals.millions=maxvals,wsdin_n=5,csdin_n=5,hddheatn_n=18,cddcoldn_n=18,gddgrown_n=10,rxnday_n=7,rnnmm_n=30,ntxntn_n=3,ntxbntnb_n=3,project.lat2d.coords=TRUE,
	thresholds.name.map=c(tx05thresh="tx05thresh",tx10thresh="tx10thresh", tx50thresh="tx50thresh", tx90thresh="tx90thresh",tx95thresh="tx95thresh", 
			tn05thresh="tn05thresh",tn10thresh="tn10thresh",tn50thresh="tn50thresh",tn90thresh="tn90thresh",tn95thresh="tn95thresh",
			tx90thresh_15days="tx90thresh_15days",tn90thresh_15days="tn90thresh_15days",tavg90thresh_15days="tavg90thresh_15days",
			tavg05thresh="tavg05thresh",tavg95thresh="tavg95thresh",
			txraw="txraw",tnraw="tnraw",precraw="precraw", 
			r95thresh="r95thresh", r99thresh="r99thresh"))
