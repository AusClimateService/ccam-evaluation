"""
 Data interface to extract BARRA2 data from the yb19 project.
 Note that at this point, only BARRA_R is implemented.
 
 Chun-Hsu Su, August 2022
"""
import os, sys
from datetime import datetime as dt
from datetime import timedelta as delt
import pandas as pd
import numpy as np
import xarray as xr
import glob

def time_to_basetime_barra2(time):
    """
    Return the corresponding basetime of the cycle for a given valid time.
    This works for BARRA-R2.
    
    basetime = time_to_basetime_barra1(valid_time)
        validtime is datetime.datetime object
        basetime is datatime.datetime object
    """
    if time.hour >= 3 and time.hour < 9:
        bt = dt(time.year, time.month, time.day, 0)
    elif time.hour >= 9 and time.hour < 15:
        bt = dt(time.year, time.month, time.day, 6)
    elif time.hour >= 15 and time.hour < 21:
        bt = dt(time.year, time.month, time.day, 12)
    elif time.hour >= 21:
        bt = dt(time.year, time.month, time.day, 18)
    elif time.hour < 3:
        bt = dt(time.year, time.month, time.day, 18) - delt(days=1)

    return bt

def get_barra2_files(model, tres, variable, tstart, tend):
    """
    Return the BARRA-R2 files.
    
    files = get_barra2_files(model, tres, variable, tstart, tend)
    where
        model = string such as BARRA_R
        tres = time resolution
        variable = string such as temp_scrn, ttl_cld, etc
        tstart = start of time range, datatime.datetime object
        tend = end of time range, datatime.datetime object
        
        files = list of full paths to the files
        
        NB: model, stash, variable as per labelling in 
        /g/data/yb19/australian-climate-service/stage/ACS-BARRA2/output/
          [model]/BOM/ECMWF-ERA5/historical/[res]/BOM-BARRA-R2/v1/[time]/[variable]
          AUS-22/BOM/ECMWF-ERA5/historical/eda/BOM-BARRA-RE2/v1
    """
    basepath="/g/data/yb19/australian-climate-service/stage/ACS-BARRA2/output"
    tstart0 = time_to_basetime_barra2(tstart)
    tend0 = time_to_basetime_barra2(tend)
    tspan = pd.date_range(tstart0, tend0, freq='M')
    if len(tspan)==0:
       tspan = pd.date_range(tstart0, tend0, freq='D')
    print(tspan)
    files = []
    if model == "AUS-11":
       res="hres"
       system='R2'
    elif model == "AUS-22":
       res="eda"
       system='RE2'
    rootdir = "{basepath}/{model}/BOM/ECMWF-ERA5/historical/{res}/BOM-BARRA-{system}/v1/{tres}/{variable}".format(basepath=basepath,model=model,res=res,system=system, tres=tres, variable=variable)
    for time in tspan:
        print(os.path.join(rootdir, '{:}_*_{:}-*.nc'.format(variable, time.strftime("%Y%m"))))
        files += glob.glob(os.path.join(rootdir, '{:}_*_{:}-*.nc'.format(variable, time.strftime("%Y%m"))))
    #print("Opening {:}".format(files))
    
    return list(set(files))

def get_barra2_data(model, timeres, variable, tstart, tend, lat0=None, lon0=None, latrange=None, lonrange=None):
    """
    Return the BARRA-R2 data.
    
    data = get_barra2_data(model, stash, variable, tstart, tend, lat0, lon0)
    where
        model = string such as 'AUS-11','AUS-22'
        timeres = time resolution of data, e.g. 10m 1hr 3hr day fx mon
        variable = string such as temp_scrn, ttl_cld, etc
        tstart = start of time range, datatime.datetime object
        tend = end of time range, datatime.datetime object
        lat0 = float, optional, if requesting data closest to a point location
        lon0 = float, optional, if requesting data closest to a point location
        latrange = [latmin, latmax], optional, to request a range
        lonrange = [lonmin, lonmax], optional, to request a range
        
        data = xarray data array containing the retrieved data.
        
        NB: model, stash, variable as per labelling in /g/data/cj37/BARRA/[model]/v1/forecast/[stash]/[variable]
    """
    barra_files = get_barra2_files(model, timeres, variable, tstart, tend)
    ds = xr.open_mfdataset(barra_files)
    if lat0 is not None:
        ds = ds.sel(lat=lat0, method='nearest')
    if lon0 is not None:
        ds = ds.sel(lon=lon0, method='nearest')
    if latrange is not None:
        ds = ds.sel(lat=slice(latrange[0], latrange[1]))
    if lonrange is not None:
        ds = ds.sel(lon=slice(lonrange[0], lonrange[1]))
        
    ds_slice = ds.sel(time=slice(tstart, tend))

    return ds_slice
