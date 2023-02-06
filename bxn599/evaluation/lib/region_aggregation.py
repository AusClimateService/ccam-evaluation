import spatial_selection
import numpy as np
import geopandas as gp
import xarray as xr
import os

def check_all(x):
    try:
        return x.all()
    except:
        return x

def region_aggregation(data,gridname,shapefile = 'NRM_clusters',aggregator='weightmean',landmask=None,latrange=(None, None), lonrange=(None, None),read=True,rechunk=False):
    """
    Aggregate a data-array over the NRM regions
    default is to take a spatial mean, but other aggregators are available
    Parameters
    ----------
    data: x-array 
        input x-array, must have coordinates lon, lat
    gridname: string
        codename for grid to enable caching of region masks 
    shapefile: string
        indicates shapefile containing regions to aggregate over.
        Should be either a full filepath or one of 'NRM_clusters', 'NRM_sub_clusters', 'NRM_super_clusters'
    aggregator: string
         name of x-array reduction method to apply. Valid entries:
         ['weightmean','all','any','count','cumprod','cumsum','max','mean','median','min','prod','std','sum','ar']
         Weightmean applies area-weights based on the subsetted regions
    landmask: xarray or None
         if not None, binary land-sea mask to apply in addition to regions
    Returns
    -------
      result: x-array
          Aggregated data array
      labels: pandas.Series
          Region labels from shapefile
    """
    
    latmin = -90  if latrange[0] is None else latrange[0]
    latmax = 90   if latrange[1] is None else latrange[1]
    lonmin = -360 if lonrange[0] is None else lonrange[0]
    lonmax = 360  if lonrange[1] is None else lonrange[1]    
    
    data2 = data.sel(lat=slice(latmin, latmax), lon=slice(lonmin, lonmax))
    
    assert(aggregator in ['weightmean','all','any','count','cumprod','cumsum','max','mean','median','min','prod','std','sum','ar'])
    #load shapefile
    if shapefile in ['NRM_clusters', 'NRM_sub_clusters', 'NRM_super_clusters']:
        shapefilepath = '/g/data/tp28/dev/evaluation_datasets/{cluster}/{cluster}.shp'.format(cluster=shapefile)
    else:
        shapefilepath = shapefile
    print('reading shapefile')
    mask = gp.read_file(shapefilepath)
    # extract region names from shapefile
    labels = mask.label
    # define cache path
    ncpath = shapefilepath.strip('.shp')+"_{grid}.nc".format(grid=gridname)
    if os.path.exists(ncpath):
        # if cached version exists, load it
        print('loading cached mask')
        mask_xarray = xr.load_dataset(ncpath).mask.sel(lat=slice(latmin, latmax), lon=slice(lonmin, lonmax))
        assert check_all(mask_xarray.lon.values == data2.lon.values)
        assert check_all(mask_xarray.lat.values == data2.lat.values)
    else:
        print('creating new mask - may be memory intensive')
        # else, compute it. This is be memory-intensive
        mask_xarray = spatial_selection.fraction_weight_mask(mask, data2.lon.values, data2.lat.values)
        mask_xarray.to_netcdf(ncpath)
    if landmask is not None:
        print('applying land-sea mask')
        mask_xarray = mask_xarray * landmask.sel(lat=slice(latmin, latmax), lon=slice(lonmin, lonmax)).values
    # Concatenate regions into 3D xarray
    #regions = xr.concat(
    #                    [(nrm_regrid == region_id).expand_dims(region=[i])
    #                     for i, region_id in enumerate(labels)], 
    #                      dim='region'
    #                   )
    # aggregate data array by region
    print('aggregating')
    if aggregator == 'weightmean':
        result = (mask_xarray*data2).where(mask_xarray>0).sum(['lat','lon'])/mask_xarray.sum(['lat','lon'])
    else:
        result = getattr(data2.where(mask_xarray>0),aggregator)(['lat', 'lon'])   # if aggregator=mean, this is equivanlent to data2[var].where(regions).mean(['lat','lon'])
    if read:
        # now the data is small (8 timeseries), commit to memory
        print('loading data into memory')
        result = result.load()  
    if rechunk:
        result = result.chunk(dict(time=-1))
    return result,labels

