"""
 Purpose: Part of the quality check of the ACS DRS data
 Reads in netcdf files and writes out and plots the stats per time step
"""

import os, sys
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import argparse
import glob
from datetime import datetime as dt
from netCDF4 import Dataset, num2date, date2num
import pandas as pd
from scipy.ndimage import label
from scipy.stats import norm

_default_realization = 'hres'

def check_file_yearmonth(file, startym, endym):
    """
    Return Boolean on whether the file is within or outside the time range.
    """
    bn = os.path.basename(file)
    timerange = bn.split(".")[0].split("_")[-1]
    t0 = timerange.split("-")[0]
    t1 = timerange.split("-")[1]
    if len(t0) == 4:
        time_format = '%Y'
    elif len(t0) == 6:
        time_format = '%Y%m'
    elif len(t0) == 8:
        time_format = '%Y%m%d'

    t0 = dt.strptime(t0, time_format)
    t1 = dt.strptime(t1, time_format)
    if t0 < startym:
        return False
    if t1 > endym:
        return False
    return True

def get_varname(infile):
    """
    Return the variable name as a string.
    """
    # Assume it is already in the filename
    bn = os.path.basename(infile)
    toks = bn.split("_")

    # Assume it is in the first element of the basename
    return toks[0]

def get_freq(infile):
    """
    Return the time freq of the data as a string.
    """
    # Assume it is already in the file path
    toks = infile.split('/')

    return toks[-3]

def get_levelname(infile, varname):
    """
    Return the variable name for the level dimension.
    Return None if none.
    """
    fid = Dataset(infile, 'r')
    for dim in fid.variables[varname].dimensions:
        if dim in ['time', 'lat', 'lon', 'realization']:
            continue
        return dim

    return None

def numnull(x):
    """
    Return integer - number of null values in the xarray.DataArray
    """
    return x.isnull().sum()

def nummasked(x):
    """
    Return integer - number of masked values in the xarray.DataArray
    This implementation is not working yet
    """
    return np.ma.count_masked(x)

def get_stats_xr(infile):
    ds = xr.open_dataset(infile)
    ds_grp = ds.chunk(chunks={"time":1}).groupby("time")
    ds_mean = ds_grp.mean(dim=["lat", "lon"])
    ds_max = ds_grp.mean(dim=["lat", "lon"])
    ds_min = ds_grp.mean(dim=["lat", "lon"])
    ds_null = ds_grp.apply(numnull)
    ds_masked = ds_grp.apply(nummasked)

    # incomplete implementation
    return None

def replace_mask(arr, default_value=-9999):
    if 'mask' in dir(arr):
        arr[arr.mask] = default_value

    return arr

def write_log(infile, realization, chunk_time, varname, level, vmean, vmin, vmax, nummasked, numnan, logfile):
    """
    Write/append the statistic information to the log file.
    """
    flog = open(logfile, 'a')
    chunk_len = len(vmean)
    
    vmean = replace_mask(vmean)
    vmin = replace_mask(vmin)
    vmax = replace_mask(vmax)
    nummasked = replace_mask(nummasked)
    numnan = replace_mask(numnan, default_value=9999)

    for k in range(chunk_len):
        flog.write("{:},{:},{:},{:},{:},{:},{:},{:},{:},{:}\n".format(os.path.basename(infile),
                realization,
                chunk_time[k].strftime('%Y-%m-%d %H:%M'),
                varname,
                level,
                vmean[k],
                vmin[k],
                vmax[k],
                nummasked[k],
                numnan[k] ) )

    flog.close()
    return

def get_stats(infile, logfile, realizations=[_default_realization]):
    """
    For the given netcdf file, read the data in chunk, compute the statistics and write the statistics to the log file.
    """
    # using netCDF4
    varname = get_varname(infile)
    levelname = get_levelname(infile, varname)
    fid = Dataset(infile, 'r')
    time = num2date(fid.variables['time'][:], fid.variables['time'].units)
    chunk_size = 100
    L = fid.variables[varname].shape[0]
    chunk_start = list(range(0, L, chunk_size))
    chunk_end = chunk_start[1:] + [L]

    for realization in realizations:
        has_realization = False
        
        if realization != _default_realization:
            realization_values = list(fid.variables['realization'][:])
            assert realization in realization_values, "Cannot find realization={:} in available realizations: {:}".format(realization, realization_values)
            realization_index = realization_values.index(realization)
            has_realization = True

        if levelname is None:
            # 2d fields
            for i, j in zip(chunk_start, chunk_end):
                chunk_time = time[i:j]

                if has_realization:
                    chunk = fid.variables[varname][i:j,:,:,realization_index]
                else:
                    chunk = fid.variables[varname][i:j,:]

                chunk_len = chunk.shape[0]
                chunk_1d = chunk.reshape(chunk_len, -1)
                # compute stats
                vmin = chunk_1d.min(axis=1)
                vmax = chunk_1d.max(axis=1)
                vmean = chunk_1d.mean(axis=1)
                nummasked = np.ma.count_masked(chunk_1d, axis=1)
                numnan = np.isnan(chunk_1d).sum(axis=1)
                # write to file
                write_log(infile, realization, chunk_time, varname, 0, vmean, vmin, vmax, nummasked, numnan, logfile)
        else:
            levels = fid.variables[levelname][:]
            # 3d fields
            for p, level in enumerate(levels):
                for i, j in zip(chunk_start, chunk_end):
                    chunk_time = time[i:j]

                    if has_realization:
                        chunk = fid.variables[varname][i:j,p,:,:,realization_index]
                    else:
                        chunk = fid.variables[varname][i:j,p,:,:]

                    chunk_len = chunk.shape[0]
                    chunk_1d = chunk.reshape(chunk_len, -1)
                    # compute stats
                    vmin = chunk_1d.min(axis=1)
                    vmax = chunk_1d.max(axis=1)
                    vmean = chunk_1d.mean(axis=1)
                    nummasked = np.ma.count_masked(chunk_1d, axis=1)
                    numnan = np.isnan(chunk_1d).sum(axis=1)
                    # write to file
                    write_log(infile, realization, chunk_time, varname, level, vmean, vmin, vmax, nummasked, numnan, logfile)
    
    fid.close()

    return

def check_validtime(df, sanityfile, monthly=False):
    """
    Check whether there is any missing gaps in the timeseries.
    Write the results to the sanityfile text file.
    """
    fwarn = open(sanityfile, 'a')

    level = df.level.values[0]
    realization = df.realization.values[0]
    header = "validtime(lev={:},realization={:})".format(level, realization)

    # Check that the minutes are 0, 15, 30 or 45
    minutes = [a.minute for a in df.validtime]
    indices = np.where(~np.equal(minutes, 0) & ~np.equal(minutes,15) & ~np.equal(minutes,30) & ~np.equal(minutes,45) )[0]
    for i in indices:
        fwarn.write("{:}: ERROR {:}\n".format(header, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))

    # Check whether ther is any missing gaps in the tiemseries
    vdiff = np.diff(df.validtime)
    cond = len(np.unique(vdiff)) > 1
    if monthly:
        indices = np.where(np.greater([int(v/(60*60*24*1e9)) for v in vdiff], 31))[0]
        for i in indices:
            fwarn.write("{:}: ERROR {:}\n".format(header, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))
    elif len(np.unique(vdiff)) > 1:
        vdiff_sort = np.sort(np.unique(vdiff))
        occur = [np.equal(vdiff,vd).sum() for vd in vdiff_sort]
        for j in range(len(vdiff_sort)):
            vd = vdiff_sort[j]
            if j == np.argmax(occur):
                continue

            indices = np.where(np.equal(vdiff, vd))[0]
            for i in indices:
                fwarn.write("{:}: ERROR {:}\n".format(header, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))
    else:
        fwarn.write("{:}: OK\n".format(header))

    fwarn.close()
    return

def check_repeats(df, sanityfile):
    """
    Check for repeated statistics in QC outputs 
    Write the results to the sanityfile text file.
    """
    fwarn = open(sanityfile, 'a')

    level = df.level.values[0]
    realization = df.realization.values[0]
    var = df.varname.values[0]
    header = "repeats(lev={:},realization={:})".format(level, realization)

    delta = (df['fieldmean'][1:].values == df['fieldmean'][:-1].values) * (df['fieldmin'][1:].values == df['fieldmin'][:-1].values) * (df['fieldmax'][1:].values == df['fieldmax'][:-1].values)
    # compute times where min,max,mean are identical across three timesteps
    delta = delta[1:]*delta[:-1]
    # consider cases where repeats occur
    error = 0
    if delta.sum() >= 1:
        # we expect repeated zeros in frozen soil, sea ice, and snow (especially in summer) and in shortwave radiation overnight, so don't report these
        if np.any([x in var for x in ["mrf", "sic", "rsd","rsu", "snm", "snw"]]):
            # if zero is an expected repeated value, exclude it from the statistics
            delta[df['fieldmean'][1:-1].values==0] = 0
        # split into chunks which contain each repeated value
        labels,n = label(delta)
        for i in range(1,n+1):
            # pull out erroneous values for each chunk and write to file
            t0 = df[:-2][labels==i].validtime.iloc[0]
            n = (labels==i).sum() 
            meanvalue = df[:-2][labels==i].fieldmean.iloc[0]
            fwarn.write("{:}: ERROR {:}: {:} repeats of {:} \n".format(header, pd.to_datetime(t0).strftime("%Y-%m-%d %H:%M"),n,meanvalue))
            error = 1
    if error==0:
        fwarn.write("{:}: OK\n".format(header))

    fwarn.close()
    return


def check_mask(df, sanityfile):
    """
    Check whether number of masked values is constant.
    Write the results to sanityfile text file.
    """
    fwarn = open(sanityfile, 'a')

    level = df.level.values[0]
    realization = df.realization.values[0]
    header = "nummasked(lev={:},realization={:})".format(level, realization)

    # check whether nummasked is constant value
    vdiff = np.diff(df.nummasked)
    level = df.level.values[0]
    if len(np.unique(vdiff)) > 1:
        vdiff_sort = np.sort(np.unique(vdiff))
        occur = [np.equal(vdiff,vd).sum() for vd in vdiff_sort]
        for j in range(len(vdiff_sort)):
            vd = vdiff_sort[j]
            if j == np.argmax(occur):
                continue

            indices = np.where(np.equal(vdiff, vd))[0]
            for i in indices:
                fwarn.write("{:}: ERROR {:}\n".format(header, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))
    else:
        fwarn.write("{:}: OK\n".format(header))

    fwarn.close()
    return

def check_nan(df, sanityfile):
    """
    check whether there is any nan values.
    Write the results to sanityfile text file.
    """
    fwarn = open(sanityfile, 'a')

    level = df.level.values[0]
    realization = df.realization.values[0]
    header = "numnan(lev={:},realization={:})".format(level, realization)

    # check any nan data
    numnan = df.numnan.values
    level = df.level.values[0]
    if numnan.sum() > 0:
        indices = np.where(np.greater(numnan, 0))[0]
        for i in indices:
            fwarn.write("{:}: ERROR {:}\n".format(header, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))
    else:
        fwarn.write("{:}: OK\n".format(header))

    fwarn.close()
    return

def check_outlier(df, y, sanityfile):
    """
    check whether there is outlier values, defined as exceeding 
    scipy.stats.norm.ppf(1-10/len(df)) x stdev
    this should give the 10 highest values if the data is normally distributed
    Write the results to sanityfile text file.
    """
    fwarn = open(sanityfile, 'a')

    level = df.level.values[0]
    realization = df.realization.values[0]
    header = "{:}(lev={:},realization={:})".format(y, level, realization)

    level = df.level.values[0]
    threshold = norm.ppf(1-10/len(df[y])) * df[y].std()
    upper_limit = df[y].mean() + threshold
    lower_limit = df[y].mean() - threshold
    indices = np.where(np.greater(df[y].values, upper_limit))[0]
    if len(indices) == 0:
        fwarn.write("{:}: OK UPPER\n".format(header))
    for i in indices:
        fwarn.write("{:}: WARN {:} > {:} at {:}\n".format(header, df[y].values[i], upper_limit, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))

    indices = np.where(np.less(df[y].values, lower_limit))[0]
    if len(indices) == 0:
        fwarn.write("{:}: OK LOWER\n".format(header))
    for i in indices:
        fwarn.write("{:}: WARN {:} < {:} at {:}\n".format(header, df[y].values[i], lower_limit, pd.to_datetime(df.validtime.values[i]).strftime("%Y-%m-%d %H:%M")))

    fwarn.close()
    return

def get_df(df, level=None, realization=_default_realization):
    if not level is None:
        df = df[df.level == level]
    if realization != _default_realization:
        df = df[df.realization == realization]
    return df

if __name__ == '__main__':
    parser =  argparse.ArgumentParser(description='Reads in netcdf files and writes out and plots the stats per time step')
    parser.add_argument("--indir", nargs='?', required=True, help='Input netcdf file directory')
    parser.add_argument("--logfile", nargs='?', required=True, type=str, help='Output text file containing the statistics')
    parser.add_argument("--figdir", nargs='?', type=str, help='Output directory containing the timeseries plots')
    parser.add_argument("--sanityfile", nargs='?', type=str, help='Output text file containing sanity check results')
    parser.add_argument("--monthly", action='store_true')
    parser.add_argument("--startym", type=str, default='190001', help="Minimum yearmonth")
    parser.add_argument("--endym", type=str, default='230001', help="Maximum yearmonth")
    parser.add_argument("--realizations", default=_default_realization, nargs='?', help='Comma separated list of realization numbers')

    args = parser.parse_args()
    indir = args.indir
    infiles = glob.glob(os.path.join(indir, '*.nc'))
    infiles.sort()

    logfile = None
    sanityfile = None
    figdir = None
    if not args.logfile is None:
        logfile = args.logfile

    if not args.sanityfile is None:
        sanityfile = args.sanityfile

    if not args.figdir is None:
        figdir = args.figdir
        if not os.path.exists(figdir):
            print("[INFO] Creating the output figure directory")
            os.makedirs(figdir)

    startym = dt.strptime(args.startym, '%Y%m')
    endym = dt.strptime(args.endym, '%Y%m')

    realizations = args.realizations.split(",")

    assert len(infiles) > 0, "No input files to check"

    flog = open(logfile, 'w')
    headers = ["filename", "realization", "validtime", "varname", "level", "fieldmean", "fieldmin", "fieldmax", "nummasked", "numnan"]

    flog.write(",".join(headers) + "\n")
    flog.close()

    # Compute and write the stats to logfile
    for infile in infiles:
        if not check_file_yearmonth(infile, startym, endym):
            print("[INFO] Skip checking {:}".format(infile))
            continue
        else:
            print("[INFO] Checking {:}".format(infile))

        varname = get_varname(infile)
        freq = get_freq(infile)
        get_stats(infile, logfile, realizations=realizations)
        print("[OUT] Written to {:}".format(logfile))

    # Analyse the log file to look for issues
    df = pd.read_csv(logfile, sep=',')
    df['validtime'] = pd.to_datetime(df['validtime'])
    tstart = pd.to_datetime(df.validtime.values[0]).strftime("%Y%m%dT%H%M")
    tend = pd.to_datetime(df.validtime.values[-1]).strftime("%Y%m%dT%H%M")

    # Sanity check log
    if not sanityfile is None:
        fwarn = open(sanityfile, 'w')
        fwarn.write(" ".join(sys.argv) + "\n")
        fwarn.close()

        for realization in realizations:
            for level in np.unique(df.level.values):
                df_filter = get_df(df, level=level, realization=realization)

                # Check any missing time step
                if args.monthly:
                    check_validtime(df_filter, sanityfile, monthly=True)
                else:
                    check_validtime(df_filter, sanityfile)
                # check any inconsistent mask
                check_mask(df_filter, sanityfile)
                # check any nan
                check_nan(df_filter, sanityfile)
                # check for repeats
                check_repeats(df_filter, sanityfile)
    
                # Check any outliers
                for y in ['fieldmean', 'fieldmin', 'fieldmax']:
                    check_outlier(df_filter, y, sanityfile)
            
            print("[OUT] Write sanity check to {:}".format(sanityfile))

        # Plot the timeseries of the stats
        if not figdir is None:
            for level in np.unique(df.level.values):
                outfig = os.path.join(figdir, "%s_%s_%s_%s-%s.png" % (freq, varname, level, tstart, tend))
                fig = plt.figure(figsize=(10,10))
                for i, y in enumerate(['fieldmean', 'fieldmin', 'fieldmax', 'nummasked', 'numnan']):
                    ax = plt.subplot(5,1,i+1)
                    for realization in realizations:
                        df_filter = get_df(df, level=level, realization=realization)
                        df_filter.plot(x='validtime', y=y, kind='line', ax=ax)
                        if i == 0:
                            ax.set_title('{:}, lev={:}, {:} to {:}'.format(varname, level, tstart, tend))
                    ax.get_legend().remove()
                    ax.set_ylabel(y)

                plt.savefig(outfig)
                print("[OUT] Write figure to {:}".format(outfig))



