import cartopy.crs as ccrs
import geopandas as gp
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe
import numpy as np
import pandas as pd
import pooch
from netCDF4 import Dataset
import regionmask

file0="/g/data/xv83/users/bxn599/CaRSA/mask_files/shapefiles/NRM_clusters.zip"
file1="/g/data/xv83/users/bxn599/CaRSA/mask_files/shapefiles/NRM_sub_clusters.zip"
file2="/g/data/xv83/users/bxn599/CaRSA/mask_files/shapefiles/NRM_super_clusters.zip"

clusters = gp.read_file("zip://" + file0)
subclusters = gp.read_file("zip://" + file1)
superclusters = gp.read_file("zip://" + file2)

res    = 0.1
latbnd = np.asarray([np.arange(-52.3-(res), 8.7, res),np.arange(- 52.3+(res), 8.7+(2*res), res)]).T
lonbnd = np.asarray([np.arange(89.3-(res), 182.0, res),np.arange(89.3+(res), 182.0+(2*res), res)]).T
lat    = latbnd.mean(axis=1)
lon    = lonbnd.mean(axis=1)

subclusters_mask = regionmask.mask_geopandas(subclusters, lon, lat)

subclusters_mask = subclusters_mask.rename("subclusters_mask")

ids = subclusters_mask.to_numpy()
miss = -999
np.nan_to_num(ids, copy=False, nan=miss)
ids = np.ma.masked_values(ids,miss)
lbl = np.asarray(["SC_Wet_Tropics","SC_Rangelands_North","SC_Monsoonal_North_East","SC_Monsoonal_North_West",\
                  "SC_East_Coast_South","SC_Central_Slopes","SC_Murray_Basin","SC_Southern_and_South_Western_Flatlands_West",\
                  "SC_Southern_and_South_Western_Flatlands_East","SC_Southern_Slopes_Vic_NSW_East","SC_Southern_Slopes_Vic_West","SC_Southern_Slopes_Tas_East",\
                  "SC_Southern_Slopes_Tas_West","SC_East_Coast_North","SC_Rangelands_South"])

# Create netCDF dimensions
dset = Dataset("ccam_nrm_subclusters_fullname.nc",mode="w")
dset.createDimension("lat" ,size=lat.size)
dset.createDimension("lon" ,size=lon.size)
dset.createDimension("nb"  ,size=2       )
dset.createDimension("n"   ,size=lbl.size)

# Create netCDF variables
X  = dset.createVariable("lat"        ,lat.dtype,("lat"      ))
XB = dset.createVariable("lat_bounds" ,lat.dtype,("lat","nb" ))
Y  = dset.createVariable("lon"        ,lon.dtype,("lon"      ))
YB = dset.createVariable("lon_bounds" ,lon.dtype,("lon","nb" ))
I  = dset.createVariable("ids"        ,ids.dtype,("lat","lon"))
L  = dset.createVariable("labels"     ,lbl.dtype,("n"        ))

# Load data and encode attributes
X [...] = lat
X.units = "degrees_north"
XB[...] = latbnd

Y [...] = lon
Y.units = "degrees_east"
YB[...] = lonbnd

I[...]  = ids
I.labels= "labels"

L[...]  = lbl

dset.close()
