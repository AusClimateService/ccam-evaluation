import xarray as xr
import xesmf as xe
import numpy as np
import geopandas as gp
from lib import spatial_selection
import matplotlib as mpl
from scipy.stats import theilslopes
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import cartopy.crs as ccrs

lon = np.linspace(89.3,182.0,928,endpoint=True,dtype='d')
lon = np.round(lon,1)
lat = np.linspace(-52.3,8.7,611,endpoint=True,dtype='d')
lat = np.round(lat,1)

nrm_clusters = gp.read_file('/g/data/tp28/dev/evaluation_datasets/NRM_clusters/NRM_clusters.shp')
nrm_cluster_xarray = spatial_selection.centre_mask(nrm_clusters, lon,lat, output="2D")