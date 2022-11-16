import cartopy.crs as ccrs
import geopandas as gp
import matplotlib.pyplot as plt
import matplotlib.patheffects as pe
import numpy as np
import pandas as pd
import pooch

import regionmask

file0="NRM_clusters.zip"
file1="NRM_sub_clusters.zip"
file2="NRM_super_clusters.zip"

clusters = gp.read_file("zip://" + file0)
subclusters = gp.read_file("zip://" + file1)
superclusters = gp.read_file("zip://" + file2)

lon = np.linspace(88.75,207.25,949,endpoint=True)
lat = np.linspace(-53.25,12.75,529,endpoint=True)

clusters_mask = regionmask.mask_geopandas(clusters, lon, lat)
subclusters_mask = regionmask.mask_geopandas(subclusters, lon, lat)
superclusters_mask = regionmask.mask_geopandas(superclusters, lon, lat)
ar6_mask = regionmask.defined_regions.ar6.land.mask(lon, lat)
land_mask = regionmask.defined_regions.natural_earth_v5_0_0.land_10.mask(lon, lat)

land_mask = land_mask.rename("land_mask")
ar6_mask = ar6_mask.rename("ar6_mask")
clusters_mask = clusters_mask.rename("nrm_clusters_mask")
subclusters_mask = subclusters_mask.rename("nrm_subclusters_mask")
superclusters_mask = superclusters_mask.rename("nrm_superclusters_mask")

land_mask.to_netcdf(path="./ccam_12.5km_masks.nc", mode="w")
ar6_mask.to_netcdf(path="./ccam_12.5km_masks.nc", mode="a")
clusters_mask.to_netcdf(path="./ccam_12.5km_masks.nc", mode="a")
subclusters_mask.to_netcdf(path="./ccam_12.5km_masks.nc", mode="a")
superclusters_mask.to_netcdf(path="./ccam_12.5km_masks.nc", mode="a")