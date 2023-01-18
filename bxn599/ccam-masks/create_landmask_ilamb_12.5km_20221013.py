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

res    = 0.125
latbnd = np.asarray([np.arange(-53.25-(res), 12.75, res),np.arange(- 53.25+(res), 12.75+(2*res), res)]).T
lonbnd = np.asarray([np.arange(88.75-(res), 207.25, res),np.arange(88.75+(res), 207.25+(2*res), res)]).T
lat    = latbnd.mean(axis=1)
lon    = lonbnd.mean(axis=1)

land_mask = regionmask.defined_regions.natural_earth_v5_0_0.land_10.mask(lon, lat)

land_mask = land_mask.rename("land_mask")

ids = land_mask.to_numpy()
miss = -999
np.nan_to_num(ids, copy=False, nan=miss)
ids = np.ma.masked_values(ids,miss)
lbl = np.asarray(["global"])
names = np.asarray(["Global - Land"])

# Create netCDF dimensions
dset = Dataset("ccam_landmask.nc",mode="w")
dset.createDimension("lat" ,size=lat.size)
dset.createDimension("lon" ,size=lon.size)
dset.createDimension("nb"  ,size=2       )
dset.createDimension("n"   ,size=lbl.size)

# Create netCDF variables
X  = dset.createVariable("lat"        ,lat.dtype,("lat"      ))
XB = dset.createVariable("lat_bnds"   ,lat.dtype,("lat","nb" ))
Y  = dset.createVariable("lon"        ,lon.dtype,("lon"      ))
YB = dset.createVariable("lon_bnds"   ,lon.dtype,("lon","nb" ))
I  = dset.createVariable("ids"        ,ids.dtype,("lat","lon"))
L  = dset.createVariable("labels"     ,lbl.dtype,("n"        ))
N  = dset.createVariable("names"      ,lbl.dtype,("n"        ))

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

N[...]  = names

dset.close()