import numpy as np
import xarray as xr
import xesmf as xe
import gc
import os
import glob
import regionmask
import dask

def getSizeGB(arr):
    return '{:.3f} GB'.format(arr.nbytes / 1024 ** 3)

def getChunkSize(arr):
    return '{:.3f} mb'.format(np.prod(arr.data.chunksize)*arr.data.itemsize / 1024**2)

def getNumberChunks(arr):
    return arr.data.npartitions

def sortCoordsAscending(data, ifiles):
    for c in data.coords:
        if c == 'forecast_reference_time': # Don't worry about sorting forecast_reference_time
            continue
        if c == 'rlon' or c=='rlat': # Don't sort rotated lat and lon
            continue
        if data[c].shape: # check if it has a length (e.g. ignore single length dimensions)
            if len(data[c].shape) == 1: #< Only for rectilinear grid (i.e. lat and lon are 1d)
                if data[c][-1] < data[c][0]:
                    print(f'{c} is not in ascending order for {ifiles[0]}!\nI will sort it!')
                    print('TEMPORARY FIX WHERE SORTING COORDS RESULTS IN TINY CHUNKS')
                    with dask.config.set({"array.chunk-size": "25 GiB"}): #< Fixes an issue with dask where sorting re-chunks array to tiny sizes
                        data = data.sortby(data[c])

    return data


def read_dataset(ifiles, **kwargs):

    read_kwargs = {'combine':'nested', 'concat_dim':'time', 'parallel':True, 'coords':'minimal', 'data_vars':'minimal', 'engine':'h5netcdf', 'compat':'override'}
    for key in read_kwargs:
        if key in kwargs:
            read_kwargs[key] = kwargs[key]

    ifiles = convert_comma_joker_to_list(ifiles)

    data = xr.open_mfdataset(ifiles, **read_kwargs)


    # Remove duplicate times if any.
    if 'time' in data.coords:
        _,index = np.unique(data['time'], return_index=True)
        if not len(index) == len(data['time']):
            print('In read_dataset: Duplicate time indicies found and removed!')
        data = data.isel(time=index)

    # Rename 'latitude' to 'lat' and 'longitude' to 'lon'
    try:
        data = data.rename({'latitude':'lat', 'longitude':'lon'})
    except:
        pass
    try:
        data = data.rename({'lev':'pressure'})
    except:
        pass

    if 'lat' in data.coords:
        data['lat'] = data['lat'].astype('float32')
    if 'lon' in data.coords:
        data['lon'] = data['lon'].astype('float32')


    if 'pressure' in data.coords:
        if data['pressure'].attrs['units'] == 'Pa':
            print('Convert pressure units from Pa to hPa')
            data = data.assign_coords(pressure=(data['pressure'] / 100))
            data['pressure'].attrs['units'] = 'hPa'


    #< Make sure lon range is 0 to 360
    if 'lon' in data.coords:
        data = data.assign_coords(lon=(data['lon'] % 360))
        data['lon'].attrs = {
            'axis'      : "X",
            'units'     : 'degrees_east',
            'standard_name' : 'longitude',
            'long_name' : 'longitude',
            }

    #< Make sure lat and lon are sorted in ascending order
    data = sortCoordsAscending(data, ifiles)

    print('Opening dataset of {}'.format(getSizeGB(data)))

    return data

def read_dataarray(ifiles, var, **kwargs):
    arr = read_dataset(ifiles, **kwargs)[var]

    if 'curvilinear' in kwargs and kwargs['curvilinear']:
        if len(arr['lon'].shape) == 2 and len(arr['lat'].shape) == 2:
            print('Working on curvilinear data!!!')
            print('Found curvilinear grid...')

            #< Some domain settings for BARPA
            xRes = 0.35
            yRes = 0.42
            xMax = 167.81
            xMin = 127
            yMax = 3.21
            yMin = -53
            ds_out = xe.util.grid_2d(xMin-xRes/2, xMax+xRes/2, xRes, yMin-yRes/2, yMax+yRes/2, yRes)

            #< For narclim rename rlat and rlon
            arr           = arr.rename({'rlat':'y', 'rlon':'x'})
            arr           = arr.reset_index(['x','y'], drop=True)
            filename      = kwargs['curvilinear']
            reuse_weights = True if os.path.isfile(filename) else False

            print(arr)

            print(f'Using {filename} as weights file for regridding to rectilinear grid...')
            arr = curvilinear2rectilinear_grid(arr, ds_out, filename, reuse_weights=reuse_weights)

    print(f'{getNumberChunks(arr)} chunks with each chunk {getChunkSize(arr)}')

    return arr


def saver(client, ofile, arr, **kwargs):

    #< Create new directory if it does not exist
    odir = os.path.dirname(ofile)
    if not odir == '' and not os.path.exists(odir):
        os.makedirs(odir)
        print('function saver: created new directories')

    if '..' in ofile:
        print(f'Output filename: {ofile}')
        print('Found .. (double dot) in output filename. Replacing with single .')
        ofile = ofile.replace('..','.')

    saver = arr.to_netcdf(ofile, compute=False, **kwargs)

    # Add a progress bar and do the calculations
    future = client.persist(saver)
    dask.distributed.progress(future)
    future.compute()
    print('\n')
    del saver
    del future
    arr.close()


# Bring all input arrays to same extent
def cut_overlap(*args, dims=None, **kwargs):

    minval = {}
    maxval = {}
    for dim in dims:

        #< Assume sorted dimensions
        if any([arr[dim][0] > arr[dim][-1] for arr in args]):
            print('Dimension is not sorted properly.\nEXITING NOW!')
            exit()

        if f'tol_{dim}' in kwargs:
            tol = kwargs[f'tol_{dim}']
            minval[dim] = max([arr[dim][0]  for arr in args]) - tol
            maxval[dim] = min([arr[dim][-1] for arr in args]) + tol
        else:
            minval[dim] = max([arr[dim][0]  for arr in args])
            maxval[dim] = min([arr[dim][-1] for arr in args])


    sel = {}
    for dim in dims:
        sel[dim] = slice(minval[dim], maxval[dim])

    return [arr.sel(sel) for arr in args]

def check_coordinates_match(*args, dims):

    arr_ref = args[0]
    for dim in dims:
        checks = []
        for iarg, arg in enumerate(args):
            check = arr_ref[dim].values == arg[dim].values

            #< If check is a list make sure all are true
            if isinstance(check,list):
                check = all(check)
            elif isinstance(check,np.ndarray):
                check = check.all()
            checks.append(check)

        if not all(checks):
            print('!!!!')
            print(f'{dim} does not have the same values for {iarg}th argument.')
            print('##############')
            print(arr_ref[dim])
            print('--------------')
            print(arg[dim])
            print('##############')

def str2bool(v):
    if isinstance(v, bool):
       return v
    if v.lower() in ('yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def isfloat(value):
  try:
    float(value)
    return True
  except ValueError:
    return False


def convert_comma_joker_to_list(ifiles):
    #< For comma seperated files with a joker sign combine into one big list
    if isinstance(ifiles, list):
        if len(ifiles) == 1:
            #< If there are more than one comma seperated entries with a joker sign -> split into list
            if ',' in ifiles[0] and '*' in ifiles[0]:
                ifiles = ifiles[0].split(',')

                dummy = []
                for i in range(len(ifiles)):
                    dummy.extend(glob.glob(ifiles[i])) #< List the files and put into a single list
                file_list = dummy
            #< If the list has just one entry with a joker sign -> use glob to get a list of all files
            elif '*' in ifiles[0]:
                file_list = glob.glob(ifiles[0])
            #< If there is no joker sign and the length is one it is just one file
            else:
                file_list = ifiles
        else:
            file_list = ifiles
    elif isinstance(ifiles, str):
        if '*' in ifiles:
            file_list = glob.glob(ifiles)
        else:
            file_list = ifiles
    else:
        print('Input files are neither list nor string!')
        exit()

    if isinstance(file_list, list):
        file_list = sorted(file_list)

    return file_list


def resampleIntegrate(arr, resamp, **kwargs):
    """
    Calculates daily integrated values for a input xarray.

    :param arr: xarray input
    :param resamp: dictionary containing the resample instruction (e.g. {'time':'1D'})

    :return: xarray containing daily integrated values
    """

    dt  = arr.time[1] - arr.time[0]
    dts = dt.data.astype('timedelta64[s]') # dt in seconds
    dts = dts.astype('float64') # Convert seconds to float number


    with xr.set_options(keep_attrs=True):
        #< Calculate the sum over the resampled data set
        #< and multiply with time step to get integral
        Int = arr.resample(resamp).sum() * dts
        Int = shift_time_center(Int)
        Int = guess_time_bounds(Int)

        #< Loop over resamples (e.g. time and latitude)
        for iresamp in resamp:
            #< Add attribute to each variable in data set
            Int = add_cell_methods_allvar(Int, f'{iresamp}: integrated (interval: {resamp[iresamp]})')

    return Int



def mask_ocean(arr, maskValue=np.nan):
    land = regionmask.defined_regions.natural_earth.land_110.mask(arr)
    masked = xr.where(land==0, arr, maskValue)
    masked.attrs = arr.attrs

    return masked


def covariance(x, y, dim=None):
    valid_values = x.notnull() & y.notnull()
    valid_count = valid_values.sum(dim)

    demeaned_x = (x - x.mean(dim)).fillna(0)
    demeaned_y = (y - y.mean(dim)).fillna(0)

    return xr.dot(demeaned_x, demeaned_y, dims=dim) / valid_count

def correlation(x, y, dim=None):
    # dim should default to the intersection of x.dims and y.dims
    r = covariance(x, y, dim) / (x.std(dim) * y.std(dim)) if (x.std(dim) * y.std(dim)) != 0. else x.mean(dim)*0 #< If there is no std set correlation to zero, but keep attributes etc.
    return r

def AVse(X_obs, X_gdd, X_rcm):
    """
    Calculate added value (AV) using the root mean square error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (RMSE) for each grid-point
    """

    with xr.set_options(keep_attrs=True):
        out = ((X_gdd-X_obs)**2) - ((X_rcm-X_obs)**2)
    return out

def AVse_norm(X_obs, X_gdd, X_rcm):
    """
    Calculate combined error of the GDD and RCM using the root mean square error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    Used to normalise the AV (MSE) to be between -1 and 1.

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (RMSE) for each grid-point
    """

    with xr.set_options(keep_attrs=True):
        out = ((X_gdd-X_obs)**2) + ((X_rcm-X_obs)**2)
    return out

def AVmse(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the root mean square error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (RMSE) for each grid-point
    """

    with xr.set_options(keep_attrs=True):
        out = AVse(X_obs, X_gdd, X_rcm).mean(dim=['lat','lon'])
    return out

def AVmse_norm(X_obs, X_gdd, X_rcm):
    """
    Calculate mean combined error over lat/lon of the GDD and RCM using the root mean square error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    Used to normalise the AV (MSE) to be between -1 and 1.

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (RMSE) for each grid-point
    """

    with xr.set_options(keep_attrs=True):
        out = AVse_norm(X_obs, X_gdd, X_rcm).mean(dim=['lat','lon'])
    return out

def AVcorr(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the correlation error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (corr) for each grid-point
    """
    with xr.set_options(keep_attrs=True):
        out = (1-correlation(X_gdd, X_obs, dim=['lat','lon'])) - (1-correlation(X_rcm, X_obs, dim=['lat','lon']))
    return out


def AVcorr_norm(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the correlation error between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (corr) for each grid-point
    """
    with xr.set_options(keep_attrs=True):
        out = (1-correlation(X_gdd, X_obs, dim=['lat','lon'])) + (1-correlation(X_rcm, X_obs, dim=['lat','lon']))
    return out

def AVbias(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the bias between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (bias) for each grid-point
    """
    with xr.set_options(keep_attrs=True):
        out = ((np.abs(X_gdd-X_obs)) - (np.abs(X_rcm-X_obs))).mean(dim=['lat','lon'])
    return out

def AVbias_norm(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the bias between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (bias) for each grid-point
    """
    with xr.set_options(keep_attrs=True):
        out = ((np.abs(X_gdd-X_obs)) + (np.abs(X_rcm-X_obs))).mean(dim=['lat','lon'])
    return out

def AVstd(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the standard deviation between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (standard deviation)
    """
    with xr.set_options(keep_attrs=True):
        var_obs = X_obs.std(dim=['lat','lon']); var_gdd = X_gdd.std(dim=['lat','lon']); var_rcm = X_rcm.std(dim=['lat','lon'])
        out = np.abs(var_gdd - var_obs)  -  np.abs(var_rcm - var_obs)
    return out

def AVstd_norm(X_obs, X_gdd, X_rcm):
    """
    Calculate mean added value (AV) over lat/lon using the standard deviation between the global
    driving model (gdd), the regional climate model (rcm) and observations (obs).

    :param X_obs: xarray containing the observations
    :param X_gdd: xarray containing the global driving data
    :param X_rcm: xarray containing the regional climate model
    :return:      xarray containting the AV (standard deviation)
    """

    with xr.set_options(keep_attrs=True):
        var_obs = X_obs.std(dim=['lat','lon']); var_gdd = X_gdd.std(dim=['lat','lon']); var_rcm = X_rcm.std(dim=['lat','lon'])
        out = np.abs(var_gdd - var_obs)  +  np.abs(var_rcm - var_obs)
    return out


def func_grouped(arr, LR, func):
    """
    Group high-resolution array (arr) in latitude / longitude boxes defined by low resolution (LR) using a function (e.g. mean).

    :param arr:  high-resolution input xarray
    :param LR:   low-resolution reference xarray. Must contain lat lon coordinates
    :param func: function used to group together (e.g. mean, var, etc.)
    :return:     xarray containting the grouped variable
    """

    latLR = LR['lat']
    lonLR = LR['lon']

    dLatLR  = ( latLR[1]-latLR[0] ) / 2
    latBins = (latLR - dLatLR).values
    latBins = np.append(latBins, latLR[-1]+dLatLR)

    dLonLR  = ( lonLR[1]-lonLR[0] ) / 2
    lonBins = (lonLR - dLonLR).values
    lonBins = np.append(lonBins, lonLR[-1]+dLonLR)

    dummyLat = []
    for ilat in range(len(latBins)-1):
        dummyLon = []
        for ilon in range(len(lonBins)-1):
            lat0 = latBins[ilat]
            lat1 = latBins[ilat+1]
            lon0 = lonBins[ilon]
            lon1 = lonBins[ilon+1]

            group = arr.sel(lat=slice(lat0,lat1), lon=slice(lon0,lon1))

            d = func(group)
            d = d.expand_dims(dim={'lat':[(lat0+lat1)/2], 'lon':[(lon0+lon1)/2]})

            dummyLon.append(d)
        dummyLat.append(xr.concat(dummyLon, 'lon'))
    out = xr.concat(dummyLat, 'lat')

    out.attrs = arr.attrs

    return out



def get_latlongrid_xr(arr, l_mask=False):

    lat = arr['lat'].values
    lon = arr['lon'].values

    dlat = lat[1]-lat[0]
    dlon = lon[1]-lon[0]

    lat_b = np.append(lat - dlat/2,lat[-1]+dlat/2)
    lon_b = np.append(lon - dlon/2,lon[-1]+dlon/2)


    grid         = xr.Dataset({'lon': lon,'lat': lat, 'lon_b': lon_b, 'lat_b': lat_b})

    if l_mask: # If there is masking set masked values to 0
        grid['mask'] = xr.where(~np.isnan(arr), 1, 0)
        #< The mask should only have lat/lon dimension
        try:
            grid['mask'] = grid['mask'].any('time')
        except:
            pass
    else: # If there is no masking set all to 1
        grid['mask'] = xr.where(~np.isnan(arr), 1, 1)
        #< The mask should only have lat/lon dimension
        try:
            grid['mask'] = grid['mask'].any('time')
        except:
            pass


    return grid


def xr_regrid(arr_in, arr_out, **kwargs):

    #< Make sure arr_in has not chunks over horizontal dimensions
    arr_in = arr_in.chunk({'lat':None, 'lon':None})
    if 'time' in arr_in.coords:
        arr_in = arr_in.chunk({'time':'auto'})


    # Get the grids
    grid_out = get_latlongrid_xr(arr_out, l_mask=False)
    grid_in  = get_latlongrid_xr(arr_in, l_mask=True)


    #< Regrid
    regridder  = xe.Regridder(grid_in, grid_out, **kwargs) #< Periodic true is needed for global data
    regridder._grid_in  = None # Otherwise there is trouble with dask
    regridder._grid_out = None # Otherwise there is trouble with dask
    arr_regrid = regridder(arr_in)


    return arr_regrid


def upscale_helper(arr, LR, interp_method):
    """
    This helps to upscale an xarray to a coarser grid using conservative regridding.
    The array is then interpolated back to its original resolution.

    :param arr:      xarray to be upscaled
    :param LR:       low-res array
    :param interp_method:    interpolation method used to interpolate back to original resolution

    :return: upscaled xarray and deviations from the large scale field (both on the original resolution grid)
    """
    #< Get the original resolution
    lat_orig = arr['lat']
    lon_orig = arr['lon']

    print('\n!!!! CAUTION !!!')
    print('USING EXPERIMENTAL XESMF PACKAGE')
    print('!!!!!!!!!!!!!!!!!!')

    outpath = '/scratch/q49/bxn599/CaRSA/example_rav_cs/regrid_files'
    method  = 'conservative_normed'
    filename = f'{outpath}/upscale_helper_{method}_{len(arr["lat"])}x{len(arr["lon"])}_{len(LR["lat"])}x{len(LR["lon"])}.nc'
    reuse_weights = True if os.path.isfile(filename) else False
    arrLR = xr_regrid(arr,
                            LR, periodic=True,
                            method       = method,
                            filename     = filename,
                            reuse_weights= reuse_weights,
                            )

    #< Return to original resolution
    arrLR = arrLR.chunk({'lat':None, 'lon':None})
    #< First fill some nans otherwise the defined domain gets smaller than before
    limit = None
    arrLR = arrLR.interpolate_na(dim='lat', method='nearest', fill_value='extrapolate', limit=limit)
    #< Now interpolate
    arrLR = arrLR.interp(lat=lat_orig, lon=lon_orig, method=interp_method)


    #< Set to Nan what was Nan before
    arrLR = arrLR.where(~xr.ufuncs.isnan(arr))


    return arrLR


def helper_match_resolution(X, HR, model, interp_method):
    #< Check if arr and HR have the same resolution
    tol      = 0.0001
    dlat     = X['lat'][1] - X['lat'][0]
    dlon     = X['lon'][1] - X['lon'][0]
    dlatHR   = HR['lat'][1] - HR['lat'][0]
    dlonHR   = HR['lon'][1] - HR['lon'][0]
    if abs(dlat - dlatHR) > tol or abs(dlon - dlonHR) > tol:
        if dlat < dlatHR or dlon < dlonHR: #< If arr has a higher resolution than the HR upscale arr to HR
            print()
            print(f'{model} has a higher resolution than HR.')
            print(f'HRlat: {dlatHR.data} < arrLat: {dlat.data}')
            print(f'HRlon: {dlonHR.data} < arrLon: {dlon.data}')
            print(f'Upscaling {model} to HR resolution')

            outpath  = '/scratch/q49/bxn599/CaRSA/example_rav_cs/regrid_files'
            method   = 'conservative_normed'
            filename = f'{outpath}/upscale_helper_{model}2HR_{method}_{len(X["lat"])}x{len(X["lon"])}_{len(HR["lat"])}x{len(HR["lon"])}.nc'
            reuse_weights = True if os.path.isfile(filename) else False
            X = xr_regrid(X, HR, periodic=False,
                                    method       = method,
                                    filename     = filename,
                                    reuse_weights= reuse_weights,
                                    )
            X = X.chunk({'lat':'auto', 'lon':'auto'})


        elif dlat > dlatHR or dlon > dlonHR: #< If arr has a lower resolution than the HR interpolate arr to HR
            print()
            print(f'Interpolate {model} to HR using {interp_method}...')
            X = X.chunk({'lat':'auto', 'lon':'auto'}).interp(lat=HR['lat'], lon=HR['lon'], method=interp_method)


    elif 0. < abs(dlat - dlatHR) <= tol or 0 < abs(dlon - dlonHR) <= tol:
        print()
        print(f'{model} has neither heigher nor lower resolution than HR, but they are not exaclty the same')
        print(f'{model} res is: {dlon.data} x {dlat.data} BUT HR res is: {dlonHR.data} x {dlatHR.data}')
        print(f'Interpolate {model} to exactly the same resolution')
        X = X.chunk({'lat':'auto', 'lon':'auto'}).interp(lat=HR['lat'], lon=HR['lon'], method=interp_method)

    return X


def upscaleQuantileHelper(arr, model, HR, LR, q, interp_method, l_mask_ocean=True):
    """
    This helps to calculate a given quantile interpolate the data to the highest resolution
    and then upscales it to a coarser grid.

    :param arr:      xarray containing to be upscaled
    :param model:    quantile the added value is calculated for
    :param HR:       high-res the output is interpolated on using interp_method
    :param LR:       low-res output is upscaled on by using conservative regriggind
    :param q:        quantile to calculate
    :param interp_method: interpolation method used
    :param l_mask_ocean:  should the ocean be masked (default=False)?

    :return: upscaled xarray and deviations from the large scale field (both on latHR/lonHR-grid)
    """

    #< Calculate quantiles if q is a float
    if isinstance(q, float):
        print('Calculating quantiles on original resolution...')
        arr = arr.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
        print(f'Calculate quantiles... (Chunk sizes are: {getChunkSize(arr)})' )
        print(f'In total there are {getNumberChunks(arr)} chunks')
        with xr.set_options(keep_attrs=True):
            X   = arr.quantile(q, 'time')

    #< Use different operation (i.e. mean) is q is a string
    elif isinstance(q, str):
        if q == 'mean':
            print(f'Calculating {q} on original resolution...')
            arr = arr.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
            print(f'Calculate {q}... (Chunk sizes are: {getChunkSize(arr)})' )
            print(f'In total there are {getNumberChunks(arr)} chunks')
            with xr.set_options(keep_attrs=True):
                X   = arr.mean('time')
            X = X.assign_coords({'quantile':'mean'})

        else:
            print(f'Operation {q} not found!')
            exit()

    #< Demote 'quantile' dimension to an attribute
    X.attrs['quantile'] = q
    X = X.drop('quantile')


    #< Check if arr and HR have the same resolution
    X = helper_match_resolution(X, HR, model, interp_method)


    # #< Mask out the ocean
    if l_mask_ocean:
        X = mask_ocean(X, maskValue=np.nan)


    #< Upscale
    if 'gdd' in model: #< No need to upscale gdd data (it already is the coarse resolution)
        XLR   = X
    else:
        XLR   = upscale_helper(X, LR, interp_method=interp_method)


    #< Add to fine resolution
    if 'gdd' in model:
        with xr.set_options(keep_attrs=True):
            XHRd = X * 0. #< Fine scale part of gdd is zero per definition
        XHRd = mask_ocean(XHRd, maskValue=np.nan) if l_mask_ocean else XHRd #< If this one is not masked all are zero instead of some nans

    else:
        with xr.set_options(keep_attrs=True):
            XHRd  = X - XLR


    XLR  = XLR.to_dataset(name=f'{model}LR')
    XHRd = XHRd.to_dataset(name=f'{model}HRd')


    return XLR, XHRd


# Convert units to commen output units
def convert_units(*args, outunit, **kwargs):

    with xr.set_options(keep_attrs=True):
        out = []
        for arg in args:
            if outunit == 'mm day-1':
                if arg.attrs['units'] == 'kg m-2 s-1' or arg.attrs['units'] == 'kg/m2/s':
                    arg = arg * 86400 #< Convert seconds to days; kg m-2 is the same as mm
                elif arg.attrs['units'] == 'm':
                    arg = arg * 1000 / 43200 * 86400


            elif outunit == 'K':
                if arg.attrs['units'] == 'degrees_Celsius' or arg.attrs['units'] == 'C' or arg.attrs['units'] == 'degC':
                    arg = arg + 273.15
                    if 'valid_range' in arg.attrs:
                        arg.attrs['valid_range'] = arg.attrs['valid_range'] + 273.15

            arg.attrs['units'] = outunit

            out.append(arg)

    return out



def addedValueStats(client, arr_dict, q, ofile_X, ofile_A, interp_method='nearest'):
    """
    Calculate added value stats.

    :param client:   dask client used for parallel execution
    :param arr_dict: sorted dictionary of xarrays containing global driving data (gdd), observations (obs), regional climate model (rcm)
    :param q:        quantile the added value is calculated for
    :param ofile_X:  Output file for statistics
    :param ofile_A:  Output file for added value (Squared error)
    :param interp_method: interpolation method for bringing every input to same resolution

    :return: None
    """

    ##########
    #< Init

    #< Get the coarse resolution from the driving model
    LR  = arr_dict['gdd']
    #< Get the fine resolution from the regional model
    HR  = arr_dict['rcm']
    #< Different resolutions
    ress = ['LR', 'HRd']

    keys = arr_dict.keys()

    #< If LR or HR have a time coord -> get rid of it; it is not needed.
    if 'time' in LR.coords:
        LR = LR.isel(time=0).drop('time')
    if 'time' in HR.coords:
        HR = HR.isel(time=0).drop('time')


    ##########
    #< Quantiles on different resolutions

    #< Upscale each array in arr_dict and save the results to netcdf
    lfirst = True #< The netcdf has to be created on the first iteration, after just append
    for key in keys:
        mode='w' if lfirst else 'a'
        lfirst = False
        XLR, XHRd = upscaleQuantileHelper(arr_dict[key], key, HR, LR, q, interp_method)


        print(f'Save the results to {ofile_X}...')
        ds       = xr.merge([XLR, XHRd])
        enc      = {'{}LR'.format(key):{'dtype':'float32', 'shuffle': True},
                    '{}HRd'.format(key):{'dtype':'float32', 'shuffle': True},
                    'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
        saver(client, ofile_X, ds, encoding=enc, mode=mode)

    del arr_dict
    gc.collect()


    ##########
    #< Added value analysis

    #< Read in what you just wrote to netcdf
    X = {}
    for key in keys:
        for res in ress:
                X['{}{}'.format(key,res)]  = xr.open_dataset(ofile_X)['{}{}'.format(key,res)].load()


    #< Add the resolutions together (original = LR + HRd) for the original stats
    for key in keys:
        X[key] = 0.
        for res in ress:
            with xr.set_options(keep_attrs=True):
                X[key] += X['{}{}'.format(key,res)]


    #< Added value stats
    #< Considering added value on different spatial scales
    av = 0
    av_norm = 0
    for res in ress:
        av += AVse(X['obs{}'.format(res)], X['gdd{}'.format(res)], X['rcm{}'.format(res)])
        av_norm += AVse_norm(X['obs{}'.format(res)], X['gdd{}'.format(res)], X['rcm{}'.format(res)])
    #< Normalise added value
    avs = av / av_norm

    #< Copy attrs over
    av.attrs = av_norm.attrs = avs.attrs = X['rcm'].attrs


    #< Not considering different spatial scales
    avg      = AVse(X['obs'], X['gdd'], X['rcm'])
    avg_norm = AVse_norm(X['obs'], X['gdd'], X['rcm'])
    avgs     = avg / avg_norm

    avg.attrs = avg_norm.attrs = avgs.attrs = X['rcm'].attrs

    #< Remove units for the normalised added values
    avs.attrs['units']  = ''
    avgs.attrs['units'] = ''

    #< Create output dataset
    av   = av.to_dataset(name='av')
    avs  = avs.to_dataset(name='avs')
    avg  = avg.to_dataset(name='avg')
    avgs = avgs.to_dataset(name='avgs')


    #< Save output
    print(f'Save the added value (squared error) to {ofile_A}...')

    enc      = {'av':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_A, av, encoding=enc)

    enc      = {'avs':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_A, avs, mode='a', encoding=enc)

    enc      = {'avg':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_A, avg, mode='a', encoding=enc)

    enc      = {'avgs':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_A, avgs, mode='a', encoding=enc)

    gc.collect()

    #< Return value
    return


def potentialAddedValueStats(client, arr_dict, q, ofile_X, ofile_P, interp_method='nearest'):
    """
    Calculate potential added value stats.

    :param client:   dask client used for parallel execution
    :param arr_dict: sorted dictionary of xarrays containing global driving data (gdd), regional climate model (rcm)
    :param q:        quantile the added value is calculated for
    :param ofile_X:  Output file for statistics
    :param ofile_P:  Output file for potential added value
    :param interp_method: interpolation method for bringing every input to same resolution

    :return: None
    """

    ##########
    #< Init

    #< Get the coarse resolution from the driving model
    LR  = arr_dict['gddPast']
    #< Get the fine resolution from the regional model
    HR  = arr_dict['rcmPast']
    HR['lat'] = HR['lat'].astype('float32')
    HR['lon'] = HR['lon'].astype('float32')
    #< Different resolutions
    ress = ['LR', 'HRd']

    #< If LR or HR have a time coord -> get rid of it; it is not needed.
    if 'time' in LR.coords:
        LR = LR.isel(time=0).drop('time')
    if 'time' in HR.coords:
        HR = HR.isel(time=0).drop('time')




    ##########
    #< Quantiles on different resolutions

    #< Upscale each array in arr_dict and save the results to netcdf
    lfirst = True #< The netcdf has to be created on the first iteration, after just append
    for key in arr_dict:
        mode='w' if lfirst else 'a'
        lfirst = False
        XLR, XHRd = upscaleQuantileHelper(arr_dict[key], key, HR, LR, q, interp_method)


        print(f'Save the results to {ofile_X}...')
        ds       = xr.merge([XLR, XHRd])
        enc      = {'{}LR'.format(key):{'dtype':'float32', 'shuffle': True},
                    '{}HRd'.format(key):{'dtype':'float32', 'shuffle': True},
                    'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
        saver(client, ofile_X, ds, encoding=enc, mode=mode)



    ##########
    #< Potential added value analysis

    #< Read in what you just wrote to netcdf
    X = {}
    for key in arr_dict:
        for res in ress:
                X[f'{key}{res}']  = xr.open_dataset(ofile_X)[f'{key}{res}'].load()


    #< Calculate the climate change signal
    with xr.set_options(keep_attrs=True):
        CC_RCM_HRd = X['rcmFutHRd'] - X['rcmPastHRd']
        CC_RCM_LR  = X['rcmFutLR'] - X['rcmPastLR']
        CC_RCM     = (X['rcmFutLR'] + X['rcmFutHRd']) - (X['rcmPastLR'] + X['rcmPastHRd'])
        CC_GCM     = (X['gddFutLR'] + X['gddFutHRd']) - (X['gddPastLR'] + X['gddPastHRd'])


    #pav_ss: as in DiLuca 2013 eq. 18
    #pav_ss_norm: as in DiLuca 2013 eq. 19
    #rpav_ss: as in DiLuca 2013 eq. 19
    #pav_cc: as in Di Virgilio 2020 "calculated as the RCM climate change signal minus the GCM climate change signal"

    #< Potential added value stats (as in DiLuca 2013)
    pav_ss      = func_grouped(CC_RCM_HRd, LR, np.var)
    pav_ss_norm = func_grouped(CC_RCM_LR, LR, np.mean)

    #< Potential added value stats (as in DiVirgilio 2020)
    with xr.set_options(keep_attrs=True):
        pav_cc      = CC_RCM - CC_GCM


    #< Interpolate to high-res
    with xr.set_options(keep_attrs=True):
        pav_ss      = pav_ss.interp(lat=HR['lat'], lon=HR['lon'], method=interp_method)
        pav_ss_norm = pav_ss_norm.interp(lat=HR['lat'], lon=HR['lon'], method=interp_method)
        # pav_cc does not need to be interpolated. It already has the HR res

    #< Set to Nan what was Nan before
    with xr.set_options(keep_attrs=True):
        pav_ss      = pav_ss.where(~xr.ufuncs.isnan(HR))
        pav_ss_norm = pav_ss_norm.where(~xr.ufuncs.isnan(HR))
        # pav_cc already has the correct NaNs


    # Calculate relative potential added value
    with xr.set_options(keep_attrs=True):
        rpav_ss     = pav_ss / (pav_ss_norm**2)

    #< Convert to dataset
    pav_ss      = pav_ss.to_dataset(name='pav_ss')
    pav_ss_norm = pav_ss_norm.to_dataset(name='pav_ss_norm')
    rpav_ss     = rpav_ss.to_dataset(name='rpav_ss')
    pav_cc      = pav_cc.to_dataset(name='pav_cc')


    #< Save output
    print(f'Save the added value (squared error) to {ofile_P}...')

    enc      = {'pav_ss':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_P, pav_ss, encoding=enc)

    enc      = {'pav_ss_norm':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_P, pav_ss_norm, mode='a', encoding=enc)

    enc      = {'rpav_ss':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_P, rpav_ss, mode='a', encoding=enc)

    enc      = {'pav_cc':{'dtype':'float32', 'shuffle': True},
                'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
    saver(client, ofile_P, pav_cc, mode='a', encoding=enc)

    #< Return value
    return
