import geopandas as gp
import spatial_selection
import xarray as xr
import numpy as np
import glob
# Domain extents for analysis
DOMAINS = {"CORDEX-AA": (-52.36, 12.21, 89.25, 206.57),  # as per CORDEX definition
           "Australia": (-44.5, -10, 112, 156.25)}  # as per AGCD

# Methods for regridding
REGRID_UPSCALE_METHOD = "conservative"
REGRID_DOWNSCALE_METHOD = "bilinear"
REGRID_UPSCALE_METHOD_WITH_MASK = "conservative_normed"

# AGCD data quality mask
#AGCD_MASK = "/g/data/tp28/dev/evaluation_datasets/awap_mask.nc"
AGCD_MASK = "/g/data/xv83/users/bxn599/ACS/evaluation/AGCDv1_precip_weights_1960-2020_average.nc"


def region_aggregation(ds, aggregator, region=None):
    """
    Inputs:
        ds: xarray.DataArray
            Input data, 2d or 3d
        aggregator: str
            Name of x-array reduction method to apply. Valid entries:
                ['weightmean','all','any','count','cumprod','cumsum','max',
                'mean','median','min','prod','std','sum','ar']
        region: str 
            Choose from, Australia, Northern Australia, Rangelands, Eastern Australia, 
            Southern Australia, Central Slopes, East Coast, Murray Basin, 
            Monsoonal North, Rangelands, Southern Slopes, 
            Southern and South-Western Flatlands, Wet Tropics
    """

    assert(aggregator in ['weightmean', 'all', 'any', 'count', 'cumprod', 'cumsum', 'max', 'mean', 'median', 'min', 'prod', 'std', 'sum', 'ar'])

    dims = ['lat', 'lon']

    if region is not None:
        if aggregator in ['weightmean']:
            mask = get_region_mask(ds, region, method='weight')
        else:
            mask = get_region_mask(ds, region, method='centre')
            mask.values[mask.values == 0] = 1

        if aggregator == 'weightmean':
            result = (mask*ds).where(mask > 0).sum(dims) / mask.sum(dims)
        else:
            result = getattr(ds.where(mask > 0), aggregator)(dims)

    else:
        result = eval('ds.%s()' % aggregator)

    return result

#
# APPLY DOMAIN INFORMATION
#

def get_subnrm_names():
    """
    Returns the labelling names of the various NRM sub regions.
    
    Returns:
        list of str
    """
    return ['Wet Tropics', 'Rangelands (North)', 'Monsoonal North (East)',\
       'Monsoonal North (West)', 'East Coast (South)', 'Central Slopes',\
       'Murray Basin', 'Southern and South Western Flatlands (West)',\
       'Southern and South Western Flatlands (East)',\
       'Southern Slopes (Vic/NSW East)', 'Southern Slopes (Vic West)',\
       'Southern Slopes (Tas East)', 'Southern Slopes (Tas West)',\
       'East Coast (North)', 'Rangelands (South)']

def get_nrm_names():
    """
    Returns the labelling names of the various NRM cluster egions.
    
    Returns:
        list of str
    """
    return ['Central Slopes', 'East Coast', 'Monsoonal North', 'Murray Basin',\
       'Rangelands', 'Southern Slopes', 'Southern and South Western Flatlands', 'Wet Tropics']

def get_supernrm_names():
    """
    Returns the labelling names of the various Super NRM regions.
    
    Returns:
        list of str
    """
    return ['Eastern Australia', 'Northern Australia', 'Rangelands','Southern Australia']


def get_subnrm_shape(name):
    """
    Returns the GeoDataFrame of the selected NRM sub region.
    
    Returns:
        GeoDataFrame
    """
    nrm_names = get_subnrm_names()
    assert name in nrm_names, "Unknown NRM, only from {:}".format(nrm_names)
    
    index = nrm_names.index(name)
    SHP_NRM = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/nrm_regions/nrm_regions.shp"
    SUBNRM_SHAPE = gp.read_file(SHP_NRM)
    return SUBNRM_SHAPE.iloc[[index]]

def get_nrm_shape(name):
    """
    Returns the GeoDataFrame of the selected NRM region.
    
    Returns:
        GeoDataFrame
    """
    nrm_names = get_nrm_names()
    assert name in nrm_names, "Unknown NRM, only from {:}".format(nrm_names)
    
    index = nrm_names.index(name)
    SHP_NRM = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/nrm_regions/nrm_regions.shp"
    # NRM sub clusters
    SUBNRM_SHAPE = gp.read_file(SHP_NRM)
    # NRM clusters
    NRM_SHAPE = SUBNRM_SHAPE.dissolve(by='ClusterNm', as_index=False)
    NRM_SHAPE = NRM_SHAPE.drop(columns=['SubClusNm', 'SubClusAb'])
    NRM_SHAPE = NRM_SHAPE[['ClusterNm', 'ClusterAb', 'SupClusNm', 'SupClusAb', 'geometry']]
    return NRM_SHAPE.iloc[[index]]
    
def get_supernrm_shape(name):
    """
    Returns the GeoDataFrame of the selected Super NRM region.
    
    Returns:
        GeoDataFrame
    """
    nrm_names = get_supernrm_names()
    assert name in nrm_names, "Unknown NRM, only from {:}".format(nrm_names)
    
    index = nrm_names.index(name)
    # Regions
    SHP_NRM = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/nrm_regions/nrm_regions.shp"

    # NRM sub clusters
    SUBNRM_SHAPE = gp.read_file(SHP_NRM)
    # NRM clusters
    NRM_SHAPE = SUBNRM_SHAPE.dissolve(by='ClusterNm', as_index=False)
    NRM_SHAPE = NRM_SHAPE.drop(columns=['SubClusNm', 'SubClusAb'])
    NRM_SHAPE = NRM_SHAPE[['ClusterNm', 'ClusterAb', 'SupClusNm', 'SupClusAb', 'geometry']]
    # NRM superclusters
    SUPNRM_SHAPE = NRM_SHAPE.dissolve(by='SupClusNm', as_index=False)
    SUPNRM_SHAPE = SUPNRM_SHAPE.drop(columns=['ClusterNm', 'ClusterAb'])
    SUPNRM_SHAPE = SUPNRM_SHAPE[['SupClusNm', 'SupClusAb', 'geometry']]
    return SUPNRM_SHAPE.iloc[[index]]

def get_region_shape(region):
    available_regions = ['Australia'] + get_supernrm_names() + get_subnrm_names() + get_nrm_names()
    assert region in available_regions, "Unknown region {:}: {:}".format(region, available_regions)
    
    if region == 'Australia':
        SHP_AUS = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp"
        AUS_SHAPE = gp.read_file(SHP_AUS)
        return AUS_SHAPE
    elif region in get_subnrm_names():
        return get_subnrm_shape(region)
    elif region in get_nrm_names():
        return get_nrm_shape(region)
    elif region in get_supernrm_names():
        return get_supernrm_shape(region)
     
def apply_region_mask(ds, region, overlap_fraction=None):
    """
    Masks the xarray.DataArray to return data over specific regions.
    
    Inputs:
        ds: xarray.DataArray
            Input data to be masked
        regions: str
            Region to be masked. 
            Choose from, Australia, 
            
            or sub-NRM clusters: {Wet Tropics, Rangelands (North), Monsoonal North (East), Monsoonal North (West), East Coast (South), Central Slopes, Murray Basin, Southern and South Western Flatlands (West), Southern and South Western Flatlands (East), Southern Slopes (Vic/NSW East), Southern Slopes (Vic West), Southern Slopes (Tas East), Southern Slopes (Tas West), East Coast (North), Rangelands (South)}
            
            or NRM clusters: {Central Slopes, East Coast, Monsoonal North, Murray Basin, Rangelands, Southern Slopes, Southern and South Western Flatlands, Wet Tropics}
            
            or super NRM clusters: {Eastern Australia, Northern Australia, Rangelands, Southern Australia}
            
        overlap_fraction: float
            Fraction that a grid cell must overlap with a shape to be included.
            If no fraction is provided, grid cells are selected if their centre
            point falls within the shape.

    Returns:
        xarray.DataArray
    """    
    ds_out = ds
    region_shape = get_region_shape(region)
    ds_out = spatial_selection.select_shapefile_regions(ds, region_shape, overlap_fraction=overlap_fraction)
    
    return ds_out

def add_region_land_mask(ds, region):
    """
    Add a dataarray named mask to the input xarray.DataArray.
    
    Inputs:
        ds: xarray.DataArray
            Input data to be masked
        region: str
            Choose from, Australia, 
            
            or sub-NRM clusters: {Wet Tropics, Rangelands (North), Monsoonal North (East), Monsoonal North (West), East Coast (South), Central Slopes, Murray Basin, Southern and South Western Flatlands (West), Southern and South Western Flatlands (East), Southern Slopes (Vic/NSW East), Southern Slopes (Vic West), Southern Slopes (Tas East), Southern Slopes (Tas West), East Coast (North), Rangelands (South)}
            
            or NRM clusters: {Central Slopes, East Coast, Monsoonal North, Murray Basin, Rangelands, Southern Slopes, Southern and South Western Flatlands, Wet Tropics}
            
            or super NRM clusters: {Eastern Australia, Northern Australia, Rangelands, Southern Australia}
    Returns:
        xarray.DataArray
    """

    ds_out = ds
    mask = get_region_mask(ds, region)
    mask_binary = np.where(np.isnan(mask), 0, 1)
    ds_out['mask'] = (["lat", "lon"], mask_binary)
        
    return ds_out

def get_region_mask(ds, region, method='centre', overlap_fraction=0.5):
    """
    Returns a land mask for a given region.

    Inputs:
        ds: xarray.DataArray
            Input data to be masked
        region: str
            Choose from, Australia, 
            
            or sub-NRM clusters: {Wet Tropics, Rangelands (North), Monsoonal North (East), Monsoonal North (West), East Coast (South), Central Slopes, Murray Basin, Southern and South Western Flatlands (West), Southern and South Western Flatlands (East), Southern Slopes (Vic/NSW East), Southern Slopes (Vic West), Southern Slopes (Tas East), Southern Slopes (Tas West), East Coast (North), Rangelands (South)}
            
            or NRM clusters: {Central Slopes, East Coast, Monsoonal North, Murray Basin, Rangelands, Southern Slopes, Southern and South Western Flatlands, Wet Tropics}
            
            or super NRM clusters: {Eastern Australia, Northern Australia, Rangelands, Southern Australia}
        overlap_fraction: float
            Fraction that a grid cell must overlap with a shape to be included.
            If no fraction is provided, grid cells are selected if their centre
            point falls within the shape.
    Returns:
        xarray.DataArray
    """

    region_shape = get_region_shape(region)
    
    lat = ds['lat'].values
    lon = ds['lon'].values

    if method == 'centre':
        mask_values = spatial_selection.centre_mask(region_shape, lon, lat, output="2D")
    elif method == 'overlap':
        mask_values = spatial_selection.fraction_overlap_mask(region_shape, lon, lat, overlap_fraction)
    elif method == 'weight':
        mask_values = spatial_selection.fraction_weight_mask(region_shape, lon, lat)
    
    ds_mask = xr.DataArray(
        data = mask_values,
        dims = ["lat", "lon"],
        coords = dict(
            lat = (["lat"], lat),
            lon = (["lon"], lon)
        ),
        name = 'mask'
    )
    
    return ds_mask

def apply_agcd_data_mask(ds):
    """
    Apply masking based on AGCD data quality mask
    Inputs:
        ds: xarray.dataset
    Output:
        xarray.dataset
            The same dataarray but with the mask applied.
    """
    amask = xr.open_dataset(AGCD_MASK)
    amask_regrid = amask['weight'].interp_like(ds, method='nearest')
    return ds.where(amask_regrid == 1)
