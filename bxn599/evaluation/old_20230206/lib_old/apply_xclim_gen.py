from __future__ import annotations
import xarray as xr
import os
import numpy as np
import xclim
import cmip6_interface
import era5_interface
from datetime import datetime as dt
from datetime import timedelta as delt
from xclim.core.calendar import percentile_doy
import copy
import dask

dask.config.set({"array.slicing.split_large_chunks": False})

"""
Compute monthly or yearly xclim indicators from daily BARPA, AGCD, CMIP6 and GPCC data, and hourly ERA5 data.
"""
# Constants for AGCD
agcdpath = "/g/data/zv2/agcd/v1/{var}/{agg}/r005/01day/agcd_v1_{var}_{agg}_r005_daily_{year}.nc"
# Constants for GPCC
gpccpath = '/g/data/ia39/aus-ref-clim-data-nci/gpcc/data/full_data_daily_v2020/{res}/full_data_daily_{version}_{res0}_{year}.nc'
# Constants for BARPA-R
revisions = {"ERA5":('ECMWF','r1i1p1f1'),
                "ACCESS-CM2":("CSIRO-BOM","r4i1p1f1"),
                "ACCESS-ESM1-5":('CSIRO-BOM','r6i1p1f1'),
                'NorESM2-MM':('NCC','r1i1p1f1'),
                'EC-Earth3':('EC-Earth-Consortium','r1i1p1f1')}
ia39path = "/g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/{model}/{scen}/{rev}/BOM-BARPA-R/v1/{time}/{var}/{var}_AUS-15_{model}_{scen}_{rev}_BOM-BARPA-R_v1_{time}_{year}01-{year}12.nc"
# Implemented and checked xclim indicators
indicators = {'rr1': 'xclim.indicators.icclim.RR1(ds, freq=freq)',
              'dry_days': 'xclim.indicators.atmos.dry_days(ds, freq=freq)',
              'r10mm': 'xclim.indicators.icclim.R10mm(ds, freq=freq)',
              'r20mm': 'xclim.indicators.icclim.R20mm(ds, freq=freq)',
              'rx1day': 'xclim.indicators.icclim.RX1day(ds, freq=freq)',
              'rx5day': 'xclim.indicators.icclim.RX5day(ds, freq=freq)',
              'prcptot': 'xclim.indices.prcptot(ds, freq=freq)',
              'r95p': 'xclim.indicators.icclim.R95p(ds, ds_per, freq=freq)',
              'r99p': 'xclim.indicators.icclim.R99p(ds, ds_per, freq=freq)',
              'r95ptot': 'xclim.indicators.icclim.R95pTOT(ds, ds_per, freq=freq)',
              'r99ptot': 'xclim.indicators.icclim.R99pTOT(ds, ds_per, freq=freq)',
              'tn10p': 'xclim.indicators.icclim.TN10p(ds, ds_per, freq=freq)',
              'tn90p': 'xclim.indicators.icclim.TN90p(ds, ds_per, freq=freq)',
              'tx10p': 'xclim.indicators.icclim.TX10p(ds, ds_per, freq=freq)',
              'tx90p': 'xclim.indicators.icclim.TX90p(ds, ds_per, freq=freq)',
              'tx_days_above30': 'xclim.indices.tx_days_above(ds, thresh="30 degC", freq=freq)',
              'tx_days_above35': 'xclim.indices.tx_days_above(ds, thresh="35 degC", freq=freq)',
              'tx_days_above40': 'xclim.indices.tx_days_above(ds, thresh="40 degC", freq=freq)',
              'fd': 'xclim.indicators.icclim.FD(ds, freq=freq)',
              'txn': 'xclim.indicators.cf.txn(ds, freq=freq)',
              'txx': 'xclim.indicators.cf.txx(ds, freq=freq)',
              'txm': 'xclim.indicators.cf.txm(ds, freq=freq)',
              'tnn': 'xclim.indicators.cf.tnn(ds, freq=freq)',
              'tnx': 'xclim.indicators.cf.tnx(ds, freq=freq)',
              'tnm': 'xclim.indicators.cf.tnm(ds, freq=freq)',
              'tmm': 'xclim.indicators.cf.tmm(ds, freq=freq)',
              'dtr': 'xclim.indicators.atmos.daily_temperature_range(ds_min, ds_max, freq=freq)',
              'hwn': 'xclim.indicators.atmos.heat_wave_frequency(ds_min, ds_max, freq=freq, thresh_tasmin=thresh_min, thresh_tasmax=thresh_max, window=window)',
              'hwd': 'xclim.indicators.atmos.heat_wave_max_length(ds_min, ds_max, freq=freq, thresh_tasmin=thresh_min, thresh_tasmax=thresh_max, window=window)',
              'cdd': 'xclim.indicators.atmos.maximum_consecutive_dry_days(ds, freq=freq)',
              'cwd': 'xclim.indicators.atmos.maximum_consecutive_wet_days(ds, freq=freq)',
              'sdii': 'xclim.indicators.cf.sdii(ds, freq=freq)'
             }
# Standard set up to extract the source data
standard_kwargs = {}
standard_kwargs['precip'] = {'agcd': {'var': 'precip', 
                                      'agg': 'calib', 
                                      'units': 'mm/day'},
                                 'gpcc': {'res': 'g10', 
                                          'units': 'mm/day'},
                                 'era5': {'var': 'mtpr', 
                                          'stream': 'single-levels', 
                                          'operation': 'resample(time="1D").mean().compute()',
                                          'scaling': 60*60*24,
                                          'units': 'mm/day'},
                                 'barpa': {'var': 'pr', 
                                           'scaling': 60*60*24, 
                                           'units': 'mm/day'},
                                 'cmip6': {'var': 'pr',
                                           'scaling': 60*60*24, 
                                           'units': 'mm/day'}
                                }
standard_kwargs['tmax'] = {'agcd': {'var': 'tmax', 
                                    'agg': 'mean',
                                    'units': 'degC'},
                               'era5': {'var': '2t', 
                                        'stream': 'single-levels', 
                                        'operation': 'resample(time="1D").max().compute()',
                                        'units': 'K'},
                               'barpa': {'var': 'tasmax'},
                               'cmip6': {'var': 'tasmax'}
                              }
standard_kwargs['tmin'] = {'agcd': {'var': 'tmin', 
                                        'agg': 'mean',
                                    'units': 'degC'},
                               'era5': {'var': '2t', 
                                        'stream': 'single-levels', 
                                        'operation': 'resample(time="1D").min().compute()',
                                        'units': 'K'},
                               'barpa': {'var': 'tasmin'},
                               'cmip6': {'var': 'tasmin'}
                              }
standard_kwargs['tmean'] = {'era5': {'var': '2t', 
                                        'stream': 'single-levels', 
                                        'operation': 'resample(time="1D").mean().compute()',
                                        'units': 'K'},
                               'barpa': {'var': 'tasmean'},
                               'cmip6': {'var': 'tasmean'}
                              }
# Padding around the data
# nday_offset = 0

#
# Methods
#
def get_data(source, years, **kwargs):
    """
    Returns the data in xarray.DataArray.
    Inputs:
        source: str
            Source data, either agcd, gpcc, cmip6, era5 or barpa
        years: list of int
            List of years to extract
        kwargs
            agcd:
                var: str - variable name, either precip, tmax, tmin
                agg: str - total, calib, mean
            gpcc:
                res: str - resolution, either g10, g05, g25
            barpa: 
                gcm: str - downscaled GCM to compute metric for, e.g., ACCESS-CM2, ACCESS-ESM1-5, EC-Earth3
                var: str - variable name
                scen: str - CMIP experiment. Can be evaluation, historical, ssp126, ssp370
            cmip6:
                gcm: str - GCM name to compute for, e.g., ACCESS-CM2, ACCESS-ESM1-5, EC-Earth3
                var: str - variable name
                scen: str - CMIP experiment. Can be evaluation, historical, ssp126, ssp370
            era5:
                stream: str - single-levels or pressure-levels
                var: str - variable name
                operation: str - xarray operation as a str, e.g., "resample(time="1D").sum()"
                
    Returns:
        xarray.DataArray - extracted data from the requested source
    """
    print(kwargs)
    
    #day_offset = delt(days=nday_offset)
    
    if type(years) == int:
        years = [years]
    
    tstart = dt(years[0], 1, 1, 0) # - day_offset
    tend = dt(years[-1], 12, 31, 23, 59) # + day_offset
    #years = [years[0]-1] + years + [years[-1]+1]
    
    if source == 'agcd':        
        var = kwargs['var']
        agg = kwargs['agg']
        filepaths = [agcdpath.format(var=var, agg=agg, year=yr) for yr in years]
    elif source == 'gpcc':
        var = 'precip'
        res = kwargs['res']
        version = 'v2020'
        filepaths = [gpccpath.format(res=res, res0=res[1:], version=version, year=yr) for yr in years]
    elif source == 'barpa':
        var = kwargs['var']
        scen = kwargs['scen']
        gcm = kwargs['gcm']
        centre, rev = revisions[gcm]
        filepaths = [ia39path.format(model=centre+'-'+gcm, scen=scen, time='day', var=var, year=yr, rev=rev) for yr in years]
    elif source == 'cmip6':
        var = kwargs['var']
        scen = kwargs['scen']
        gcm = kwargs['gcm']
        freq = 'day'
        filepaths = cmip6_interface.get_cmip6_files(gcm, scen, freq, var, trange=(tstart, tend))
    elif source == 'era5':
        freq = 'reanalysis'
        var = kwargs['var']
        stream = kwargs['stream']
        assert stream in ['single-levels', 'pressure-levels'], "stream must be either single-levels or pressure-levels"
        
        filepaths = era5_interface.get_era5_files(stream, freq, var, trange=(tstart, tend))
    else:
        assert False, "Undefined source"
    
    assert len(filepaths) >= 1, "Cannot find any input files"
    if len(filepaths) == 1:
        filepaths = filepaths[0]
        reader = xr.open_dataset
    elif len(filepaths) > 0:
        reader = xr.open_mfdataset

    DS = reader(filepaths)
    
    # Problematic issues with the NCI archive where the variable name is different
    # between the filename and inside the file
    if source == 'era5' and var == '2t':
        DS = DS.rename(t2m='2t')
    
    ds = DS[var]
    ds = ds.sel(time=slice(tstart, tend))
        
    # Add any pre-processing needed
    if 'scaling' in kwargs.keys():
        print("Applying scaling of {:}".format(kwargs['scaling']))
        ds = ds * kwargs['scaling']
        
    if 'offset' in kwargs.keys():
        print("Applying offset of {:}".format(kwargs['offset']))
        ds = ds + kwargs['offset']
     
    if 'operation' in kwargs.keys():
        operation = kwargs['operation']
        print("Applying operation {:}".format(operation))
        ds = eval("ds.%s" % operation)
    
    if 'units' in kwargs.keys():
        print("Setting units to {:}".format(kwargs['units']))
        ds = ds.assign_attrs(units=kwargs['units'])
        
    if 'lat' in ds.dims:
        ds = ds.rename(lat='latitude')
    if 'lon' in ds.dims:
        ds = ds.rename(lon='longitude')
        
    return ds
              
def run_xclim(indicator, source, years, freq='MS', standard_data=True, outpath=None, outname=None, **kwargs):
    """
    Computes the xclim indicators.
    Inputs:
        indicator: str
            indicator name
        source: str
            Data source, either agcd, gpcc, era5, barpa, or cmip6
        years: int or list of int
            List of years of data to consider
        freq: str
            Resampling frequency, either MS (start of month, monthly) or YS (start of year, yearly)
            Default is MS
        standard_data: boolean
            Whether to use the standard set up for the data source extraction. Default is True.
        outpath: str
            Path to write out the indicator data in netCDF
            Default is None, which no file is written.
        outname: str
            Basename of the output netCDF file.
            Default is None, which if outpath is not None, automatically generate a filename.
        kwargs:
            Where source is,
            agcd:
                var: str - variable name, either precip, tmax, tmin
                agg: str - total, calib, mean
            gpcc:
                res: str - resolution, either g10, g05, g25
            barpa: 
                gcm: str - downscaled GCM to compute metric for, e.g., ACCESS-CM2, ACCESS-ESM1-5, EC-Earth3
                var: str - variable name
                scen: str - CMIP experiment. Can be evaluation, historical, ssp126, ssp370
            cmip6:
                gcm: str - GCM name to compute for, e.g., ACCESS-CM2, ACCESS-ESM1-5, EC-Earth3
                var: str - variable name
                scen: str - CMIP experiment. Can be evaluation, historical, ssp126, ssp370
            era5:
                stream: str - single-levels or pressure-levels
                var: str - variable name
                operation: str - xarray operation as a str, e.g., "resample(time="1D").sum()"
                
            Where indicator is,
            r95p, r99p, r95ptot, r99ptot, tn10p, tx90p:
                ds_per: xarray.DataArray
                    Xth percentile value, best to compute on the data extracted by get_data()
                
            hwn, hwd: 
                thresh_min: float
                    Minimum threshold for tmin. If not provided, default is 22 degC
                thresh_max: flaot
                    Maximum threshold for tmax. If not provided, default is 30 degC
                window: int
                    Minimum number of days witgh temperature above hresholds to qualify as heatwave.
                    If not provided, the default is 3
                    
        Returns:
            xarray.DataArray
                Computed xclim indicator
    """
    
    indicator = indicator.lower()
    
    assert freq in ['MS', 'YS'], "freq must be either MS or YS"
    
    if type(years) == int:
        years = [years]
    
    assert indicator in indicators.keys(), "Undefined indicator"
    
    if indicator in ['rr1', 'dry_days', 'r10mm', 'r20mm', 'rx1day', 'rx5day', 'prcptot', 'cdd', 'cwd', 'sdii', 'r95p', 'r99p', 'r95ptot', 'r99ptot']:
        # get precip data
        if standard_data:
            kwargs.update(standard_kwargs['precip'][source])
    
        ds = get_data(source, years, **kwargs)
    
    elif indicator in ['tn10p', 'tn90p', 'fd', 'tnn', 'tnx', 'tnm']:
        # get tmin data
        if standard_data:
            kwargs.update(standard_kwargs['tmin'][source])
        
        ds = get_data(source, years, **kwargs)
    
    elif indicator in ['tx10p', 'tx90p', 'tx_days_above30', 'tx_days_above35', 'tx_days_above40', 'txn', 'txx', 'txm']:
        # get tmin data
        if standard_data:
            kwargs.update(standard_kwargs['tmax'][source])
    
        ds = get_data(source, years, **kwargs)
    
    elif indicator in ['tmm']:
        # get tmean data
        if source != 'agcd':
            if standard_data:
                kwargs.update(standard_kwargs['tmean'][source])
    
            ds = get_data(source, years, **kwargs)
        else:
            kwargs_min = copy.deepcopy(kwargs)
            kwargs_max = copy.deepcopy(kwargs)
            if standard_data:
                kwargs_min.update(standard_kwargs['tmin'][source])
                kwargs_max.update(standard_kwargs['tmax'][source])
            ds_min = get_data(source, years, **kwargs_min)
            ds_max = get_data(source, years, **kwargs_max)
            # Assume for agcd, it is the mean of min and max
            ds = (ds_max + ds_min)/2.
            #n = nday_offset
            #m = nday_offset+1
            #p = nday_offset-1
            #ds = xr.DataArray((ds_max.values[n:-n,:] + ds_min.values[m:-p,:])/2., 
            #                       dims=['time', 'latitude', 'longitude'], 
            #                       coords=dict(time=ds_max.time[n:-n], 
            #                                   latitude=ds_max.latitude, 
            #                                   longitude=ds_max.longitude))
            ds = ds.assign_attrs(units=ds_max.units)
        
    elif indicator in ['dtr', 'hwn', 'hwd']:
        kwargs_min = copy.deepcopy(kwargs)
        kwargs_max = copy.deepcopy(kwargs)
        if standard_data:
            kwargs_min.update(standard_kwargs['tmin'][source])
            kwargs_max.update(standard_kwargs['tmax'][source])
            
        ds_min = get_data(source, years, **kwargs_min)
        ds_max = get_data(source, years, **kwargs_max)
        
        #if source == 'agcd':
        #    n = nday_offset
        #    m = nday_offset+1
        #    p = nday_offset-1
        #    ds_max = ds_max[n:-n,:]
        #    ds_min = ds_min[m:-p,:]
    
    # If this indicator requires a percentile argument
    if 'ds_per' in indicators[indicator]:
        
        # Do a rechunking along the time dimension for ease of compute percentile
        ds = ds.chunk(dict(time=-1))
        
        if 'ds_per' in kwargs.keys():
            # If already provided in kwargs, use those
            ds_per = kwargs['ds_per']
        else:
            # Compute it based on the extracted data
            percentile_value = int("".join([i for i in indicator if i.isdigit()]))
            print("Compute percentile {:} with extracted data".format(percentile_value))
            
            if indicator in ['r95p', 'r99p', 'r95ptot', 'r99ptot']:
                ds_per = ds.where(ds >= 1).quantile(percentile_value/100., dim='time')
            elif indicator in ['tn10p', 'tx90p', 'tn90p', 'tx10p']:
                ds_per = percentile_doy(ds, per=percentile_value).sel(percentiles=percentile_value)
            else:
                ds_per = ds.quantile(percentile_value/100., dim='time')
                
            ds_per = ds_per.assign_attrs(units=ds.units)
            #ds_per = percentile_doy(ds, per=percentile_value).sel(percentiles=percentile_value)
    
    # If this indicator requires thresh_min, thresh_max, window arguments
    if indicator in ['hwn', 'hwd']:
        # Default values for these heatwave indicators
        thresh_min = '22.0 degC'
        thresh_max = '30 degC'
        window = 3
        if 'thresh_min' in kwargs.keys():
            thresh_min = kwargs['thresh_min']
            print("Using thresh_min={:}".format(thresh_min))
        if 'thresh_max' in kwargs.keys():
            thresh_max = kwargs['thresh_max']
            print("Using thresh_max={:}".format(thresh_max))
        if 'window' in kwargs.keys():
            window = kwargs['window']
            print("Using window={:}".format(window))
    
    # Finally compute the xclim indicator
    print(ds)
    #sys.exit(0)
    
    result = eval(indicators[indicator])
    result.name = indicator
        
    # Write to file
    if outpath is not None:
        if outname is None:
            if source in ['barpa', 'cmip6']:
                outname = "{indicator}.{source}-{gcm}-{scen}_{freq}_{year1}01-{year2}12.nc".format(indicator=indicator, source=source, gcm=kwargs['gcm'], scen=kwargs['scen'], freq=freq, year1=years[0], year2=years[-1])
            else:
                outname = "{indicator}.{source}_{freq}_{year1}01-{year2}12.nc".format(indicator=indicator, source=source, freq=freq, year1=years[0], year2=years[-1])
            outfile = os.path.join(outpath, outname)
        
        result.to_netcdf(outfile)
        print("Written to {:}".format(outfile))
        
    return result
            
    