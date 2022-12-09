import xarray as xr
import xesmf as xe
import numpy as np
import geopandas as gp
import spatial_selection
import matplotlib as mpl
from scipy.stats import theilslopes
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

## import plotting_functions

#
# Standards
#

# Historical and future periods
PERIODS = {"HISTORICAL_WHOLE": ('1985-01-01', '2014-12-31'),
           "HISTORICAL_EARLY": ('1985-01-01', '1994-12-31'),
           "HISTORICAL_LATE": ('2005-01-01', '2014-12-31'),
           "FUTURE_NEAR": ('2015-01-01', '2044-12-31'),
           "FUTURE_MID": ('2035-01-01', '2064-12-31'),
           "FUTURE_FAR": ('2070-01-01', '2099-12-31')}

# Domain extents for analysis
DOMAINS = {"CORDEX-AA": (-52.36, 12.21, 89.25, 206.57),  # as per CORDEX definition
           "Australia": (-44.5, -10, 112, 156.25)}  # as per AGCD

# Methods for regridding
REGRID_UPSCALE_METHOD = "conservative"
REGRID_DOWNSCALE_METHOD = "nearest_s2d"
REGRID_UPSCALE_METHOD_WITH_MASK = "conservative_normed"

# Regions
SHP_NRM = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/nrm_regions/nrm_regions.shp"
SHP_AUS = "/g/data/ia39/aus-ref-clim-data-nci/shapefiles/data/australia/australia.shp"
AUS_SHAPE = gp.read_file(SHP_AUS)

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

# AGCD data quality mask
AGCD_MASK = "/g/data/tp28/dev/evaluation_datasets/awap_mask.nc"

# Standard Grids
GRIDS = {}
GRIDS['BARPA_R'] = xr.Dataset(
                    {"lat": np.linspace(-53.5755, 13.632, 436),
                     "lon": np.linspace(88.0355, 207.9275, 777)
                     }
                    )
GRIDS['AGCD_v1'] = xr.Dataset(
                    {"lat": np.linspace(-44.5, -10, 691),
                     "lon": np.linspace(112, 156.25, 886)
                     }
                    )
GRIDS['CCAM'] = xr.Dataset(
                    {"lat": np.linspace(-52.3, 8.7, 611),
                     "lon": np.linspace(89.3, 182.0, 928)
                     }
                    )

# Colormaps
COLORMAPS = {}
COLORMAPS['precip'] = {'error': 'BrBG',
                        'wet': 'Blues',   # for wet variables such as prcptot, r10mm, etc
                       'dry': 'Reds',    # for dry variables such as cdd
                       'wet_diff': 'RdYlBu',
                       'dry_diff': 'RdYlBu_r'}
COLORMAPS['temp'] = {'error': 'BrBG',
                    'hot': 'plasma',    # for hot variables such as TXx
                     'cold': 'viridis',  # for cold variables such as FD
                     'hot_diff': 'RdYlBu_r',
                     'cold_diff': 'RdYlBu'}
COLORMAPS['any'] = {'error': 'Reds',
                    'bias': 'BrBG'}
COLORMAPS['windspeed'] = {'error': 'BrBG',
                    'high': 'Oranges',
                    'high_diff': 'RdYlBu_r'}

# Still need to be defined
COLORMAPS['wind'] = {}
COLORMAPS['pressure'] = {}
COLORMAPS['height'] = {}

# shorthands, useful when plotting, avoid long strings
SHORTHANDS = {}
SHORTHANDS['Wet Tropics'] = 'Wet Tropics'
SHORTHANDS['Southern and South Western Flatlands'] = 'S&SW Flatlands'
SHORTHANDS['Southern Slopes'] = 'South Slopes'
SHORTHANDS['Rangelands'] = 'Rangelands'
SHORTHANDS['Monsoonal North'] = 'Monsoon North'
SHORTHANDS['Murray Basin'] = 'Murray Basin'
SHORTHANDS['East Coast'] = 'East Coast'
SHORTHANDS['Central Slopes'] = 'Central Slopes'

# seasons definition
SEASONS = {'all': list(range(1, 13)),
           'DJF': [12, 1, 2],
           'MAM': [3, 4, 5],
           'JJA': [6, 7, 8],
           'SON': [9, 10, 11]}

#
# Standardise data
#
def standardise_data(ds, region=None, period=None, compute=True, season=None):
    """
    Applies standardisation to the given xarray.DataArray, namely
    rename latitude to lat, longitude to lon, and apply temporal
    and spatial truncation as per predefined range given in
    lib_standards.DOMAINS and lib_standards.PERIODS.

    Inputs:
        ds: xarray.DataArray
            Input data
        region: str
            Region name, choose from "CORDEX-AA", "Australia"
        period: str
            Period name, choose from "HISTORICAL_WHOLE", "HISTORICAL_EARLY",
            "HISTORICAL_LATE", "FUTURE_NEAR", "FUTURE_MID" ,"FUTURE_MID"
        season: str
            Season name, choose from all, DJF, MAM, JJA and SON
            
        The predefined regions and periods are given in 
        lib_standards.DOMAINS, lib_standards.PERIODS 
        
        compute: boolean
            Whether to apply compute to the xarray.DataArray.
            Default is True.
    Returns:
        xarray.DataArray
    """
    # Ensure dim names
    if 'longitude' in list(ds.dims):
        ds = ds.rename(longitude='lon')
    if 'latitude' in list(ds.dims):
        ds = ds.rename(latitude='lat')

    # If latitude is organised in reverse
    ds = ds.sortby(ds.lat)

    # Spatial truncation
    if region is not None:
        assert region in DOMAINS.keys(), "Unknown region {:}: {:}".format(region, DOMAINS.keys())
        latmin = DOMAINS[region][0]
        latmax = DOMAINS[region][1]
        lonmin = DOMAINS[region][2]
        lonmax = DOMAINS[region][3]
        ds = ds.sel(lat=slice(latmin, latmax), lon=slice(lonmin, lonmax))
        
    # Period truncation
    if period is not None:
        assert period in PERIODS.keys(), "Unknown period {:}: {:}".format(period, PERIODS.keys())
        tmin = PERIODS[period][0]
        tmax = PERIODS[period][1]
        ds = ds.sel(time=slice(tmin, tmax))

    # Select season
    if not (season is None or season == 'all'):
        assert season in SEASONS.keys(), "Unknown season {:}: {:}".format(season, SEASONS.keys())
        ds = ds.sel(time=ds.time.dt.month.isin(SEASONS[season]))
        
    if compute:
        ds = ds.compute()

    return ds

#
# ESTIMATE CHANGE IN TIME
# 
def compute_sen_slope(ds):
    """
    Performs robust linear regression - Theil-Sen estimator, to return the
    slope of the line fit along time dimension.
    It computes the slope as the median of all slopes between paired values.
    Inputs:
        ds: xr.DataArray
            Input data to which the slope along time will be estimated
    Returns:
        ds: xr.DataArray
            Estimated slope
    """
    _, nlat, nlon = ds.shape
    slope_values = np.zeros((nlat, nlon))
    #intercept_values = np.zeros((nlat, nlon))
    
    for i in range(nlat):
        #if i % (nlat//10) == 0:
            #print("Completed {:}".format(i))
                
        for j in range(nlon):
            if np.isnan(ds.values[0,i,j]):
                slope_values[i,j] = np.nan
                continue
            
            (m, c, m_l, m_u) = theilslopes(ds[:,i,j], ds['time'], alpha=0.95)
            slope_values[i,j] = m
            #intercept_values[i,j] = c
    
    ds_m = xr.DataArray(
        data = slope_values,
        dims = ["lat", "lon"],
        coords = dict(
            lat = (["lat"], ds['lat'].values),
            lon = (["lon"], ds['lon'].values)
        ),
        name = 'Theil_Sen_slope'
    )
    
    return ds_m

def compute_lr_slope(ds):
    """
    Performs simple linear regression, to return the
    slope of the line fit along time dimension.
    
    Inputs:
        ds: xr.DataArray
            Input data to which the slope along time will be estimated
    Returns:
        ds: xr.DataArray
            Estimated slope
    """
    
    pfit = ds.polyfit('time', deg=1)
    slope_values = pfit['polyfit_coefficients'][0,:]
    
    ds_m = xr.DataArray(
        data = slope_values,
        dims = ["lat", "lon"],
        coords = dict(
            lat = (["lat"], ds['lat'].values),
            lon = (["lon"], ds['lon'].values)
        ),
        name = 'linear_slope'
    )
    
    return ds_m

def compute_change(ds, dims='time', earlyperiod=None, lateperiod=None):
    """
    Compute change in the mean of the timeseries for two time periods: late - early.
    Inputs:
        ds: xarray.DataArray
            Input data set
        dims: list of dimension names
            Dimensions along which to compute the metric.
            Default is 'time'.
            If dims=None, then the metric is computed across all dimensions
        earlyperiod: list of str or datetime.datetime object or str
            Specify the time period to define the early baseline period.
            E.g., ('1985-01-01', '2014-12-31'), or
                'HISTORICAL_EARLY' as per lib_standards.PERIODS, or
                [datetime.datetime(1985, 1, 1), datetime.datetime(2014,12,31)]
        lateperiod: list of str or datetime.datetime object
            Specify the time period to define the late period of the change.
    Returns:
        ds: xarray.DataArray
    """
    if type(earlyperiod) == str:
        assert earlyperiod in PERIODS.keys(), "Unknown period {:}: {:}".format(PERIODS.keys())
        earlyperiod = PERIODS[earlyperiod]
    if type(lateperiod) == str:
        assert lateperiod in PERIODS.keys(), "Unknown period {:}: {:}".format(PERIODS.keys())
        lateperiod = PERIODS[lateperiod]
        
    early = slice(earlyperiod[0], earlyperiod[1])
    late = slice(lateperiod[0], lateperiod[1])
    ds_change = ds.sel(time=late).mean(dim=dims) - ds.sel(time=early).mean(dim=dims)
    
    ds_change.name = 'Delta'
    
    return ds_change

#
# MEASURING DIFFERENCES BETWEEN TWO DATA
# 
def compute_score(ds1, ds2, metric, dims='time', allow_regrid=False, earlyperiod=None, lateperiod=None):
    """"
    Compute differences between two data sets. 
    The differences can be expressed in terms of
        RMSE - root mean-square errors as sqrt( mean( (ds1 - ds2)^2 ))
        Additive_Bias - mean bias as mean(ds2 - ds1)
        Multiplicative_Bias - multiplicative bias [std(ds2)+1]/[std(ds1)+1] - 1
        Correlation - Pearson's correlation
        MAE - mean absolute error as mean( abs(ds1 - ds2) )
        Sen_Slope_Difference - Differences in Theil–Sen estimated slope
        Linear_Slope_Difference - Differences in Linear regression estimated slope
        Change_Difference - Difference in mean in two time periods
        
    Inputs:
        ds1: xarray.DataArray
            First input data set, considered as the reference data
        ds2: xarray.DataArray
            Second input data set
        metric: str
            Choose from the above metrics.
        dims: list of dimension names
            Dimensions along which to compute the metric.
            Default is 'time'.
            If dims=None, then the metric is computed across all dimensions
            This is not used for 
                Sen_Slope_Difference
                Linear_Slope_Difference
                Change_Difference
        allow_regrid: boolean
            True to allow horizontal regridding of ds2 to ds1
            False (default) to exist if ds2 and ds1 have different grids
        earlyperiod: list of str or datetime.datetime object
            Specify the time period to define the early baseline period for compute
            metric=Change_Difference
        lateperiod: list of str or datetime.datetime object
            Specify the time period to define the late period for compute
            metric=Change_Difference
    Returns:
        score: xr.DataArray
        
        sign_change: xr.DataArray
            Only for,
                Sen_Slope_Difference
                Linear_Slope_Difference
                Change_Difference
            +1 if ds2 has positive trend, and ds1 has negative
            -1 if ds2 has negative trend, and ds1 has positive
            0 if ds2 both have either positive or negative trends
    """
    assert type(ds1) == xr.core.dataarray.DataArray, "ds1 should DataArray"
    assert type(ds2) == xr.core.dataarray.DataArray, "ds2 should DataArray"
    
    if not allow_regrid:
        assert ds1.shape == ds2.shape, "ds1 and ds2 have different shape"
    
    # Regrid ds2 to ds1
    ds2 = regrid(ds2, ds1)
        
    if metric == 'RMSE':
        score = np.sqrt(((ds1 - ds2)**2).mean(dim=dims))
    elif metric == 'Additive_Bias':
        score = (ds2 - ds1).mean(dim=dims)
    elif metric == 'Multiplicative_Bias':
        ds1_std = ds1.std(dim=dims)
        ds2_std = ds2.std(dim=dims)
        score = (ds2_std + 1) / (ds1_std + 1) - 1
    elif metric == 'Correlation':
        score = xr.corr(ds1, ds2, dim=dims)
    elif metric == 'MAE':
        score = np.abs(ds1 - ds2).mean(dim=dims)
    elif metric == 'Sen_Slope_Difference':
        m2 = compute_sen_slope(ds2)
        m1 = compute_sen_slope(ds1)
        score = m2 - m1
    elif metric == 'Linear_Slope_Difference':
        m2 = compute_lr_slope(ds2)
        m1 = compute_lr_slope(ds1)
        score = m2 - m1
    elif metric == 'Change_Difference':
        m1 = compute_change(ds1, dims=dims, earlyperiod=earlyperiod, lateperiod=lateperiod)
        m2 = compute_change(ds2, dims=dims, earlyperiod=earlyperiod, lateperiod=lateperiod)
        score = m2 - m1
    else:
        assert False, "Undefined metric"

    score.name = metric
    
    if metric in ['Sen_Slope_Difference', 'Linear_Slope_Difference', 'Change_Difference']:
        m1_sign = m1.copy(deep=True)
        m1_sign.values[m1_sign.values > 0] = 1
        m1_sign.values[m1_sign.values < 0] = -1
        m2_sign = m2.copy(deep=True)
        m2_sign.values[m2_sign.values > 0] = 1
        m2_sign.values[m2_sign.values < 0] = -1
        
        sign_change = m1_sign * m2_sign
        # zero if there is no sign change between ds1 and ds2
        sign_change.values[np.equal(sign_change.values, 1)] = 0
        # positive 1 if ds2 has a positive sign change
        sign_change.values[np.not_equal(sign_change.values, 0) & np.equal(m2_sign.values, 1)] = 1
        # negative 1 if ds2 has a negative sign change
        sign_change.values[np.not_equal(sign_change.values, 0) & np.equal(m2_sign.values, -1)] = -1
        sign_change.values[np.isnan(score.values)] = np.nan

        sign_change.name = 'direction_change'
        
        return score, sign_change
    else:
        return score

#
# SPATIAL OPERATIONS
#

def get_gridarea(ds):
    """
    Returns the each grid cell area in terms of square-degrees.
    Inputs:
        ds: Input xarray.DataArray
    Returns:
        float: Grid cell area
    """
    if 'longitude' in list(ds.dims):
        ds = ds.rename(longitude='lon')
    if 'latitude' in list(ds.dims):
        ds = ds.rename(latitude='lat')

    dx = np.abs(np.diff(ds['lon'].values)).mean()
    dy = np.abs(np.diff(ds['lat'].values)).mean()
    
    return dx*dy

def regrid_safe(ds_in, ds_ref, method):
    """
    Returns regridded xarray.DataArray.
    This is needed by regrid() function as in older versions of
    xesmf do not recognise lat/lon, but assume latitude/longitude.
    This 
    Inputs:
        ds_in: Input xarray.DataArray to be regridded
        ds_ref: Reference xarray.DataArray
        method: str
            interpolation method as defined by xesmf.Regridder
    Returns:
        xarray.DataArray
            Regridded data
    """
    try:
        regridder = xe.Regridder(ds_in, ds_ref, method)
        ds_regrid = regridder(ds_in).compute()

    except KeyError as e:
        ds_in = ds_in.compute()
        ds_ref = ds_ref.compute()

        mapto = {"lat": "latitude", "lon": "longitude"}
        mapback = {"latitude": "lat", "longitude": "lon"}
        ds_in = ds_in.rename(mapto)
        ds_ref = ds_ref.rename(mapto)
        regridder = xe.Regridder(ds_in, ds_ref, method)
        ds_regrid = regridder(ds_in).compute()
        ds_regrid = ds_regrid.rename(mapback)

    return ds_regrid

def regrid(ds_in, ds_ref):
    """
    Returns regridded xarray.DataArray.
    Inputs:
        ds_in: Input xarray.DataArray to be regridded
        ds_ref: Reference xarray.DataArray
    Returns:
        xarray.DataArray
            Regridded data

    NOTE: for regridding with a mask, the ds_in and ds_ref should contain
    a dataarray named mask. Use add_region_land_mask before regridding.
    https://pangeo-xesmf.readthedocs.io/en/latest/notebooks/Masking.html#Regridding-with-a-mask
    """
    cellarea_in = get_gridarea(ds_in)
    cellarea_ref = get_gridarea(ds_ref)
    
    if cellarea_ref <= cellarea_in:
        # downscaling
        return regrid_safe(ds_in, ds_ref, REGRID_DOWNSCALE_METHOD)
    else:
        # upscaling
        if 'mask' in list(ds_in.variables) or 'mask' in list(ds_ref.variables):
            return regrid_safe(ds_in, ds_ref, REGRID_UPSCALE_METHOD_WITH_MASK)
        else:
            return regrid_safe(ds_in, ds_ref, REGRID_UPSCALE_METHOD)

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
    return list(SUBNRM_SHAPE.SubClusNm)

def get_nrm_names():
    """
    Returns the labelling names of the various NRM cluster egions.
    
    Returns:
        list of str
    """
    return list(NRM_SHAPE.ClusterNm)

def get_supernrm_names():
    """
    Returns the labelling names of the various Super NRM regions.
    
    Returns:
        list of str
    """
    return list(SUPNRM_SHAPE.SupClusNm)

def get_subnrm_shape(name):
    """
    Returns the GeoDataFrame of the selected NRM sub region.
    
    Returns:
        GeoDataFrame
    """
    nrm_names = get_subnrm_names()
    assert name in nrm_names, "Unknown NRM, only from {:}".format(nrm_names)
    
    index = nrm_names.index(name)
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
    return SUPNRM_SHAPE.iloc[[index]]

def get_region_shape(region):
    available_regions = ['Australia'] + get_supernrm_names() + get_subnrm_names() + get_nrm_names()
    assert region in available_regions, "Unknown region {:}: {:}".format(region, available_regions)
    
    if region == 'Australia':
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
    amask_regrid = amask['data_mask'].interp_like(ds, method='nearest')
    return ds.where(amask_regrid == 1)

#
# VISUALISATION
#
def create_cmap(variable, variable_class, levels=None):
    """
    Returns the standard colormap dictionary for given variable and class.
    Inputs:
        variable: str
            One of the keys in the COLORMAPS
        variable_class: str
            One of the keys in the COLORMAPS[variable]
        levels: int of integer or floats or number of levels (optional)
            Levels to define the colormap
    Returns:
        dict: Contains matplotlib.cm.cmap object and norm for use with xarray.DataArray.plot or matplotlib.pcolor etc
    """
    assert variable in COLORMAPS.keys(), "Undefined {:} in COLORMAPS: {:}".format(variable, COLORMAPS.keys())
    assert variable_class in COLORMAPS[variable].keys(), "Undefined {:} in COLORMAPS: {:}".format(variable, COLORMAPS[variable].keys())
    cmap_name = COLORMAPS[variable][variable_class]
    
    if levels is None:
        return {'cmap': eval('mpl.cm.%s' % cmap_name)}
    elif type(levels) == int:
        cmap = mpl.cm.get_cmap(cmap_name, levels)
        return {'cmap': cmap}
    else:
        assert type(levels) == list, "levels must be either an integer or list of float"
        M = len(levels)
        # number of levels should be 1 larger than number of color bands
        cmap = mpl.cm.get_cmap(cmap_name, M-1)
        norm = mpl.colors.BoundaryNorm(levels, cmap.N)
        return {'cmap': cmap, 'norm': norm}

def get_clim(ds, low_percentile=0, high_percentile=100, force_binary=False):
    """
    Estimate the limits for colorbar range, given the values of the xr.dataArray.
    
    Inputs:
        ds: xarray.DataArray
            Input data
        low_percentile: float
            Low end of the percentile, from 0..100
            default = 5
        high_percentile: float
            High end of the percentile, from 0..100
            default = 95
            If the data contains both positive and negative values, only
            high_percentile is used.
    Returns:
        dict:
            Contains vmax and vmax
    """
    has_negative = False
    has_positive = False
    if (ds.values < 0).sum() > 0:
        has_negative = True
    if (ds.values > 0).sum() > 0:
        has_positive = True
    if force_binary:
        has_negative = True
        has_positive = True

    if has_negative and has_positive:
        values = np.abs(ds.values)
        vmax = np.nanpercentile(values, high_percentile)
        vmin = -vmax

    elif has_negative or has_positive:
        values = ds.values
        vmax = np.nanpercentile(values, high_percentile)
        vmin = np.nanpercentile(values, low_percentile)

    return {'vmax': vmax, 'vmin': vmin}

def apply_shorthands(in_str):
    """
    Shorten the input string or list of string based on the mapping in
    lib_standards.SHORTHANDS.

    Inputs:
        in_str: str or list of str

    Returns:
        str or list of str
    """
    if type(in_str) == str:
        if in_str in SHORTHANDS.keys():
            return SHORTHANDS[in_str]
        else:
            return in_str

    else:
        out_str = []
        for s in in_str:
            if s in SHORTHANDS.keys():
                out_str.append(SHORTHANDS[s])
            else:
                out_str.append(s)
        return out_str


def table_plot(ax, data_dict, vmin=None, vmax=None,
        add_xticklabels=True, add_yticklabels=True,
        xlabel=None, ylabel=None, clabel=None, xrotation=90, yrotation=0,
        cmap_variable=None, cmap_class=None, shrink=1):
    """
    Create a "table" plot based on the input data content to the figure handle ax.
    Inputs:
        ax: matplotlib.pyplot.ax
            A single object of matplotlib.axes
        data_dict: dictionary of data values
            The 2d data to be plotted. 
            The data should be organised as
                {label1: 
                    {label2: value}
        vmin: float
            Lower limit of the color bar range
        vmax: float
            Higher limit of the color bar range
        add_xticklabels: boolean
            Whether to add xticklabels based on label1 values
        add_yticklabels: boolean
            Whether to add yticklabels based on label2 values
        xlabel: str
            xlabel to add to ax
        ylabel: str
            ylabel to add to ax
        clabel: str
            clabel to add to the colorbar
        xrotation: int
            Rotation to apply to xticklabels
        yrotation: int
            Rotation t apply to yticklabels
        shrink: float
            Shrinking factor to apply to the colorbar
        cmap_variable: str
            For identifying the cmap to use, choose from lib_standards.COLORMAPS.keys()
        cmap_class: str
            For identifying the cmap to use, choose from lib_standards.COLORMAPS[cmap_variable].keys()
    """

    ax.set_aspect(1)

    xs = list(data_dict.keys())
    ys = []
    for x in xs:
        for y in data_dict[x].keys():
            if not y in ys:
                ys.append(y)

    nx = len(xs)
    ny = len(ys)

    xs_i = range(nx)
    ys_i = range(ny)

    value_map = np.zeros((ny, nx)) - 9999.

    for i, x in enumerate(xs):
        for y in data_dict[x].keys():
            j = ys.index(y)
            value_map[j,i] = data_dict[x][y]

    ds_tmp = xr.DataArray(
        data = value_map,
        dims = ["y", "x"],
        coords = dict(
            x = (["x"], xs_i),
            y = (["y"], ys_i)
        ),
        name=clabel
    )

    if 'delta' in clabel.lower() or 'bias' in clabel.lower():
        clim = get_clim(ds_tmp, high_percentile=100, force_binary=True)
    else:
        clim = get_clim(ds_tmp, high_percentile=100)
        
    if vmin is not None:
        clim['vmin'] = vmin
    if vmax is not None:
        clim['vmax'] = vmax
    
    if cmap_variable is None or cmap_class is None:
        if clim['vmin'] == -clim['vmax']:
            cmap = create_cmap('any', 'bias')
        else:
            cmap = create_cmap('any', 'error')
    else:
        cmap = create_cmap(cmap_variable, cmap_class)

    ds_tmp.plot.pcolormesh(**clim, **cmap, cbar_kwargs={'shrink': shrink})
    if add_xticklabels:
        ax.set_xticks(xs_i, apply_shorthands(xs), rotation=xrotation)
    else:
        ax.set_xticks(xs_i, [])

    if add_yticklabels:
        ax.set_yticks(ys_i, apply_shorthands(ys), rotation=yrotation) 
    else:
        ax.set_yticks(ys_i, [])

    ax.set_xlabel("")
    ax.set_ylabel("")
    if xlabel is not None:
        ax.set_xlabel(xlabel)

    if ylabel is not None:
        ax.set_ylabel(ylabel)

    return

def set_xylim(ax, ds):
    """
    Set xlim and ylim for the given axes handler given the
    lat/lon range in the dataarray.
    Inputs:
        ax: matplotlib.axes
            The axes to be modified
        ds: xarray.Dataset or dataArray
            this provides the lat/lon range
    """
    lonmin = ds['lon'].values.min()
    lonmax = ds['lon'].values.max()
    latmin = ds['lat'].values.min()
    latmax = ds['lat'].values.max()
    
    ax.set_xlim([lonmin, lonmax])
    ax.set_ylim([latmin, latmax])
    
    return
    
def spatial_plot(ds, reference=None, 
                 cmap_variable='temp', cmap_class='hot', 
                 clabel=None,
                 plot_difference=True, include_all_data=True):
    """
    Create spatial plots based on the input data content.
    Inputs:
        ds: dictionary of xarray.DataArray for plotting
            ds = {'AGCD': ...,
                    'ERA5': ...}
        reference: str
            Name of the reference data if using plot_difference=True
        cmap_variable: str
            For identifying the cmap to use, choose from lib_standards.COLORMAPS.keys()
        cmap_class: str
            For identifying the cmap to use, choose from lib_standards.COLORMAPS[cmap_variable].keys()
        clabel: str
            Label to the colorbar
        plot_difference: boolean
            To include a differencing plots against the reference data.
        include_all_data: boolean
            To include the spatial plots for all the data sources. 
            If False, only the reference data is plotted.
    """
    
    N = len(ds)
    if plot_difference:
        fig = plt.figure(figsize=(N*5, 7))
        ny = 2
        assert reference is not None, "reference need to be specified: one of {:}".format(data_dict.keys())
    else:
        fig = plt.figure(figsize=(7, 7))
        ny = 1

    cmap = create_cmap(cmap_variable, cmap_class)
    clim = get_clim(ds[reference], high_percentile=90)
    
    if plot_difference:
        cmap_diff = create_cmap(cmap_variable, cmap_class+"_diff")
        sources = list(ds.keys())
        sources.remove(reference)
        s1 = sources[0]
        clim_diff = get_clim((ds[s1] - ds[reference]), high_percentile=90)
    
    # Plot the reference first
    ax = plt.subplot(ny, N, 1, projection=ccrs.PlateCarree())
    ax.set_aspect(1)
    ds[reference].plot.pcolormesh(**cmap, **clim, cbar_kwargs={'label': clabel, 'shrink': 1})
    ax.set_title(reference)
    ax.coastlines()
    set_xylim(ax, ds[reference])
    
    if reference is None:
        s = list(ds.keys())[0]
    
    c = 1
    for s in ds.keys():
        if s == reference:
            continue
            
        M = 0
        if include_all_data:
            M = N
            ax1 = plt.subplot(ny, N, 1+c, projection=ccrs.PlateCarree())
            ax1.set_aspect(1)
            ds[s].plot.pcolormesh(**cmap, **clim, cbar_kwargs={'label': clabel, 'shrink': 1})
            ax1.set_title(s)
            ax1.set_ylabel("")
            ax1.coastlines()
            set_xylim(ax1, ds[s])
    
        if plot_difference:
            ax2 = plt.subplot(ny, N, M+1+c, projection=ccrs.PlateCarree())
            ax2.set_aspect(1)
            
            ds_diff = (ds[s] - ds[reference])
            
            if include_all_data:
                ax1.set_xlabel("")
                
                ds_diff.name = '%s - %s' % (s, reference)
                ds_diff.plot.pcolormesh(**cmap_diff, **clim_diff, cbar_kwargs={'shrink': 1})
            else:
                ds_diff.plot.pcolormesh(**cmap_diff, **clim_diff, cbar_kwargs={'label':"", 'shrink': 1})
                ax2.set_title('%s - %s' % (s, reference))
                ax2.set_ylabel("")
            
            set_xylim(ax2, ds_diff)
            ax2.coastlines()
            
            if c > 1:
                ax2.set_ylabel("")
                
        c += 1
    return