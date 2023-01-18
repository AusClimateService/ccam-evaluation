import matplotlib.pyplot as plt
import xarray as xr
import tempfile
import dask
from dask.diagnostics import ProgressBar
import os
import numpy as np
import pandas as pd
import matplotlib.gridspec as gridspec
from cartopy import crs as ccrs
import lib_added_value as lav
import argparse
import gc

#< Location for temporary files
try:
    dummy_fs = os.environ['PBS_JOBFS']
except:
    dummy_fs = '/g/data/xv83/users/bxn599/tmp'


def addedValueStatMSE(X_dict):
    av = lav.AVmse(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    return av

def addedValueStatMSE_norm(X_dict):
    avg      = lav.AVmse(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avg_norm = lav.AVmse_norm(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avgs     = avg / avg_norm
    return avgs

def addedValueStatCorr(X_dict):
    av = lav.AVcorr(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    return av

def addedValueStatCorr_norm(X_dict):
    avg      = lav.AVcorr(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avg_norm = lav.AVcorr_norm(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avgs     = avg / avg_norm
    return avgs

def addedValueStatBias(X_dict):
    av = lav.AVbias(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    return av

def addedValueStatBias_norm(X_dict):
    avg      = lav.AVbias(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avg_norm = lav.AVbias_norm(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avgs     = avg / avg_norm
    return avgs

def addedValueStatStd(X_dict):
    av = lav.AVstd(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    return av

def addedValueStatStd_norm(X_dict):
    avg      = lav.AVstd(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avg_norm = lav.AVstd_norm(X_dict['obs'], X_dict['gdd'], X_dict['rcm'])
    avgs     = avg / avg_norm
    return avgs

def corrCommonBias(X_dict):
    Xgdd = X_dict['gdd']
    Xrcm = X_dict['rcm']
    Xobs = X_dict['obs']
    r = lav.correlation(Xgdd-Xobs, Xrcm-Xobs, dim=['lat','lon'])

    return r


def boxPlotHelper(arrList, nameList, title='', ylabel='', ofile=None):

    fig = plt.figure(figsize=(5, 3.7))
    leg = []
    xx = 0
    yy = []


    lss = []
    for i, dummy in enumerate(arrList):
        x, y  = zip(*sorted(dummy.items()))
        ls = []
        if len(y) > 1: # Only plot if there is more than one entry for this (e.g. don't plot gdds if there is only one gdd)
            for p in range(len(y)):
                if np.isnan(y[p]): #< Skip if correlation is nan
                    continue
                l, = plt.plot(xx+(0.1*(p+1)/len(y)), y[p], marker='o', label=x[p])
                ls.append(l)
            lss.append(ls)
            xx += 1
            yy.append(nameList[i])

    plt.xticks(range(xx), yy, rotation=20, weight='bold')  # Set text labels and properties.
    plt.gca().axhline(c='grey', lw=2, linestyle='--')


    #< legend
    xx = 0
    plt.ylim([-0.5, 0.5])
    plt.yticks([-0.5, -0.25, 0, 0.25, 0.5], weight='bold')
    locs, labels = plt.yticks()            # Get locations and labels
    dloc = locs[1]-locs[0]
    leg_ypos = locs[0]-0.75*dloc-0.1
    ax = plt.gca()
    for i, dummy in enumerate(arrList):
        x, y  = zip(*sorted(dummy.items()))
        if len(y) > 1:
            leg.append(ax.legend(lss[xx], x, loc='upper center', bbox_to_anchor=(xx-0.25,leg_ypos, 0.5, 0.1), bbox_transform=ax.transData))
            xx += 1

    [ax.add_artist(l) for l in leg]
    ax.set_title(title, size='large', weight='bold')
    ax.set_ylabel(ylabel, weight='bold')

    plt.savefig(ofile, bbox_inches='tight', bbox_extra_artists=leg)


# Parse input arguments
def parse_args(parser):
    parser.add_argument("--ipath", dest='ipath', type=str, help="Path to input data.")
    parser.add_argument("--ifiles_obs", dest='ifiles_obs', nargs='?', help="Comma seperated list of observation (high resolution) data (same order as varnames)")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Comma-separated list of input files. (The first file will be the reference)")
    parser.add_argument("--op", default='mse', type=str, help="What statistic should be used to summarise the added value (mse, corr, bias, var, commbias)")
    parser.add_argument("--gdds", nargs='?', help="Comma-separated list of input driving models (e.g. ACCESS1-0)")
    parser.add_argument("--varnames", nargs='?', help="Comma-separated list of input variable names (for model data; same order as ifiles_obs)")
    parser.add_argument("--varnames_obs", nargs='?', help="Comma-separated list of input variable names (for observation data; same order as ifiles_obs)")
    parser.add_argument("--yrStartPast", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndPast", type=int, help="Year to end processing.")
    parser.add_argument("--yrStartFut", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndFut", type=int, help="Year to end processing.")
    parser.add_argument("--quantiles", dest='quantiles', type=str, nargs='?', help="Quantiles to calculate added value for.")
    parser.add_argument("--seasons", nargs='?', default='annual', help="Comma-separated list of seasons (annual, DJF, etc.)")
    parser.add_argument("--interp_method", dest='interp_method', type=str, default="nearest", help="Interpolation method used to interpolate to high-res")
    parser.add_argument("--normalise", dest='normalise', type=lav.str2bool, const=True, nargs='?', default=False, help="Use normalised added value")
    parser.add_argument("--resolution", dest='resolution', type=str, default='', help="Resolution (i.e. 0p05deg or 0p11deg)")
    parser.add_argument("--prefix", dest='prefix', type=str, default='', help="Prefix for output files")
    parser.add_argument("--prefix_data", dest='prefix_data', type=str, default='', help="Prefix for output files")
    parser.add_argument("--l_new", dest='l_new', type=lav.str2bool, const=True, nargs='?', default=False, help="Create new netcdf file or use existing RAV values")
    parser.add_argument("--project", dest='project', type=str, default='', help="Project (e.g. barpa, narclim) used for filename")
    parser.add_argument("--regions", dest='regions', type=str, default='', help="Regions input file.")
    parser.add_argument("--debug", dest='debug', type=lav.str2bool, const=True, nargs='?', default=False, help="Debugging plots")
    return parser.parse_args()


def debug_plot_helper(arr, title='', **kwargs):
    #< Plotting
    #< Using added value
    ncols = 1
    nrows = 1
    fig = plt.figure(figsize=((4.7*ncols,3.7*nrows)))

    # Setup axes
    width_ratios = [1]*ncols
    gs  = gridspec.GridSpec(nrows, ncols, figure=fig, wspace=0.45)

    # Set projections
    ax = fig.add_subplot(gs[0], projection=ccrs.PlateCarree(central_longitude=0))
    im = arr.plot.pcolormesh(ax=ax, add_colorbar=True, **kwargs)
    ax.set_title(title)
    ax.coastlines()


def main():

        #< Increase garbage threshold
        g0, g1, g2 = gc.get_threshold()
        gc.set_threshold(g0 * 3, g1 * 3, g2 * 3)

        # User argument input
        parser    = argparse.ArgumentParser(description='Plot some overview plots of the added value analysis.')
        args      = parse_args(parser)
        ipath     = args.ipath
        ifiles_obs = list(filter(None,args.ifiles_obs.split(",")))
        gdds      = list(filter(None, args.gdds.split(",")))
        varnames  = list(filter(None, args.varnames.split(",")))
        varnames_obs = list(filter(None, args.varnames_obs.split(",")))
        outpath   = args.outpath
        op        = args.op
        yrStartPast = args.yrStartPast
        yrEndPast   = args.yrEndPast
        yrStartFut  = args.yrStartFut
        yrEndFut    = args.yrEndFut
        quantiles   = [i for i in list(filter(None, args.quantiles.split(",")))]
        seasons     = list(filter(None,args.seasons.split(",")))
        interp_method = args.interp_method
        l_norm      = args.normalise
        res         = args.resolution
        verbosity   = 3
        prefix      = args.prefix
        prefix_data = args.prefix_data
        l_new       = args.l_new
        project     = args.project
        ifile_regions = args.regions
        l_debug_first = args.debug

        if not prefix_data:
            prefix_data = prefix

        if l_norm:
            print('Normalise...') if verbosity >= 2 else None
        else:
            print('Absolute values...') if verbosity >= 2 else None

        oplot  = outpath + '/' + prefix + '.boxplot.rav.{}.{}.q{}.EASTAUS.{}.{}.png'

        #< Realised added value netcdf file
        if l_norm:
            rav_ofile = ipath + '/' + prefix_data + f'.rav_norm_{op}_summary' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
        else:
            rav_ofile = ipath + '/' + prefix_data + f'.rav_{op}_summary' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'


        if l_new:
            #< Read the regions files
            print('Read in the added value regions definition...') if verbosity >= 2 else None
            print(ifile_regions)
            regions = xr.load_dataset(ifile_regions)['regions']
            regions['lat'] = regions['lat'].astype('float32')
            regions['lon'] = regions['lon'].astype('float32')


            qDummy  = {}
            for gdd in gdds:
                varDummy  = {}

                for ivar, var in enumerate(varnames):
                    seasonDummy  = {}

                    #< read data
                    print('Read in the observation files...') if verbosity >= 2 else None
                    ifile_obs      = ifiles_obs[ivar]
                    print(ifile_obs)
                    arr_obs        = lav.read_dataarray(ifile_obs, var=varnames_obs[ivar], engine='h5netcdf')
                    arr_obs['lat'] = arr_obs['lat'].astype('float32')
                    arr_obs['lon'] = arr_obs['lon'].astype('float32')
                    print('Done opening the observation data set...')
                    print()


                    #< Select start and end year of observations
                    print('Select start and end year of observations...') if verbosity >= 2 else None
                    arr_obs = arr_obs.sel(time=slice(str(yrStartPast),str(yrEndPast)))


                    #< Cut observations to region of interest (using dummy added value file)
                    print('Cutting observations to overlap...') if verbosity >= 2 else None
                    if lav.isfloat(quantiles[0]):
                        qdummy = float(quantiles[0])
                    else:
                        qdummy = quantiles[0]
                    if isinstance(qdummy, float):
                        print(f'{qdummy*100} quantile...') if verbosity >= 2 else None
                        qstr = '{}'.format(qdummy).replace('.','p')
                    elif isinstance(qdummy, str):
                        print(f'{qdummy}...') if verbosity >= 2 else None
                        qstr = qdummy
                    else:
                        print(f'Type {type(q)} of q not supported')
                    ifile_dummy = ipath + '/' + 'X.' + f'{project}_{gdd}.{var}.{res}' + f'.q{qstr}.' + f'{seasons[0]}' + f'.{yrStartPast}-{yrEndPast}' + f'.interp_{interp_method}' + '.nc'
                    arr_dummy   = lav.read_dataarray(ifile_dummy, var='gddLR', engine='netcdf4')
                    arr_dummy   = arr_dummy.squeeze()
                    arr_obs,_   = lav.cut_overlap(*[arr_obs, arr_dummy], dims=['lat', 'lon'])


                    print('Intermediate calculations...') if verbosity >= 2 else None
                    arr_obs = arr_obs.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
                    saver1  = arr_obs.to_dataset(name=var).to_zarr(dummy_fs+'/data1.zarr', mode='w', compute=False)
                    future  = client.persist([saver1])
                    dask.distributed.progress(future)
                    dask.compute(*future)
                    print()
                    #< Close the original files
                    arr_obs.close(); gc.collect()
                    #
                    #< Open the original data set again
                    arr_obs = xr.open_zarr(dummy_fs+'/data1.zarr')[var]
                    print('Done with intermediate calculations...') if verbosity >= 2 else None


                    for q in quantiles:
                        regionDummy = {}
                        qstr = '{}'.format(q).replace('.','p')



                        for season in seasons:
                            rav     = {}


                            #< Calculate standard deviation of observations for the season in question
                            #< select season
                            if not season == 'annual':
                                arr_obs_seas = arr_obs[arr_obs['time.season']==season]
                            else:
                                arr_obs_seas = arr_obs
                            #< calculate quantile for each year separately
                            if lav.isfloat(q):
                                q = float(q)
                            if isinstance(q, float):
                                q_obs_seas = arr_obs_seas.groupby('time.year').quantile(q, dim='time')
                                q_obs_seas = q_obs_seas.rename({'year':'time'})
                            elif isinstance(q, str):
                                if q == 'mean': #< if operation is 'mean' take variation of yearly means
                                    q_obs_seas = arr_obs_seas.groupby('time.year').mean(dim='time')
                                    q_obs_seas = q_obs_seas.rename({'year':'time'})
                                else:
                                    print(f'Operation {q} not found!')
                                    exit()
                            #< calculate variance
                            print('Calc variance over time...') if verbosity >= 2 else None
                            var_obs_seas = q_obs_seas.var('time')


                            #< Make obs match added value resolution
                            print('Match resolutions...') if verbosity >= 2 else None
                            var_obs_seas = lav.helper_match_resolution(var_obs_seas, arr_dummy, 'obs', interp_method=interp_method)
                            var_obs_seas = var_obs_seas.persist()
                            dask.distributed.progress(var_obs_seas)
                            print()


                            #< Read in quantiles for obs, gdd and rcm
                            print('Read pre-calculated quantiles...') if verbosity >= 2 else None
                            X        = {}
                            ifile_X  = ipath + '/' + 'X.' + f'{project}_{gdd}.{var}.{res}' + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}' + f'.interp_{interp_method}' + '.nc'
                            print(ifile_X)
                            for model in ['obs', 'gdd', 'rcm']:
                                with xr.set_options(keep_attrs=True):
                                    X[model] = xr.load_dataset(ifile_X)[f'{model}LR'] + xr.open_dataset(ifile_X)[f'{model}HRd'] # Add low and high res together for original quantile


                            # ###################
                            # # TESTING
                            # ###################
                            # # X['rcm'] = X['gdd'] # AV -> 0
                            # X['rcm'] = X['obs'] # AV -> 1
                            # X['rcm'] = (X['obs'] + X['gdd']) / 2 # AV -> 0.6
                            # ###################

                            #< Read in potential added value
                            #< Construct the file names
                            ifile_P = ipath + '/' + 'P.' + f'{project}_{gdd}.{var}.{res}' + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
                            print(ifile_P)
                            pav     = xr.load_dataset(ifile_P)['pav_cc']

                            # ###################
                            # # TESTING
                            # ###################
                            # pav = xr.ufuncs.sqrt(var_obs_seas)   # norm -> 1
                            # # pav = 0 * xr.ufuncs.sqrt(var_obs_seas) # norm -> 0
                            # ###################


                            print('Take absolute value of PAV...') if verbosity >= 2 else None
                            pav = xr.ufuncs.fabs(pav).persist()

                            print('Cutting potential added value to overlap...') if verbosity >= 2 else None
                            regions, X['obs'], X['gdd'], X['rcm'], pav, var_obs_seas = lav.cut_overlap(regions, X['obs'], X['gdd'], X['rcm'], pav, var_obs_seas, dims=['lat', 'lon'])

                            regions = regions.interp(lat=X['obs']['lat'], lon=X['obs']['lon'], method='nearest') #< Fixs a problem where regions is slightly different to the other arrays
                            lav.check_coordinates_match(regions, X['obs'], X['gdd'], X['rcm'], pav, var_obs_seas, dims=['lat','lon'])


                            for region in ['coast', 'topo', 'flat']:
                                if region == 'coast':
                                    iregion = 1
                                elif region == 'topo':
                                    iregion = 2
                                elif region == 'flat':
                                    iregion = 3


                                #< Group by region
                                print('Group by region...') if verbosity >= 2 else None
                                X_dict              = {'obs': X['obs'].where(regions==iregion), 'gdd': X['gdd'].where(regions==iregion), 'rcm': X['rcm'].where(regions==iregion)}
                                pav_region          = pav.where(regions==iregion)
                                var_obs_seas_region = var_obs_seas.where(regions==iregion)


                                if l_debug_first:
                                    plt.figure()
                                    X_dict['obs'].plot.pcolormesh()
                                    plt.figure()
                                    X_dict['gdd'].plot.pcolormesh()
                                    plt.figure()
                                    X_dict['rcm'].plot.pcolormesh()
                                    plt.figure()
                                    pav_region.plot.pcolormesh()
                                    plt.figure()
                                    var_obs_seas_region.plot.pcolormesh()
                                    plt.show()


                                #< Select the operation in which added value is measured
                                if op == 'mse':
                                    av = addedValueStatMSE_norm(X_dict) if l_norm else addedValueStatMSE(X_dict)
                                elif op == 'corr':
                                    av = addedValueStatCorr_norm(X_dict) if l_norm else addedValueStatCorr(X_dict)
                                elif op == 'bias':
                                    av = addedValueStatBias_norm(X_dict) if l_norm else addedValueStatBias(X_dict)
                                elif op == 'var':
                                    av = addedValueStatStd_norm(X_dict) if l_norm else addedValueStatStd(X_dict)
                                elif op == 'commbias':
                                    av = corrCommonBias_norm(X_dict) if l_norm else corrCommonBias(X_dict)

                                #< keep some stuff in memory
                                print('Calc addded value...') if verbosity >= 2 else None
                                av = av.persist()

                                ###
                                #< Option #1

                                # #< Get mean potential added value
                                # pav_mean = (xr.ufuncs.fabs(pav_region)).mean()
                                # pav_mean = pav_mean.persist()
                                #
                                #
                                # #< Combine in realised added value (rav)
                                # if l_norm:
                                #     norm        = pav_mean / xr.ufuncs.sqrt(var_obs_seas_region).mean()
                                #     rav[region] = av * norm
                                # else:
                                #     norm        = pav_mean / var_obs_seas_region.mean()
                                #     rav[region] = av * norm
                                #
                                #
                                # print(q, var, season, region)
                                # if l_norm:
                                #     print(av.values, pav_mean.values, xr.ufuncs.sqrt(var_obs_seas_region).mean().values, rav[region].values)
                                # else:
                                #     print(av.values, pav_mean.values, var_obs_seas_region.mean().values, rav[region].values)

                                ###
                                #< Option #2

                                #< Combine in realised added value (rav)
                                if l_norm:
                                    std  = xr.ufuncs.sqrt(var_obs_seas_region)
                                    std  = xr.where(std==0., np.nan, std) #< No division by zero

                                    lav.check_coordinates_match(pav_region,std, dims=['lat','lon'])
                                    norm = ( pav_region / std ).mean()
                                else:
                                    variance = var_obs_seas_region
                                    variance = xr.where(variance==0., np.nan, variance) #< No division by zero

                                    lav.check_coordinates_match(pav_region,variance, dims=['lat','lon'])
                                    norm = (pav_region / variance).mean()
                                #< Keep some stuff in memory
                                print('Calc norm...') if verbosity >= 2 else None
                                norm        = norm.compute()

                                #< Get realised added value
                                rav[region] = av * norm

                                #< Keep some stuff in memory
                                print('Calc ravs...') if verbosity >= 2 else None
                                rav[region] = rav[region].compute()

                                #< Remove some attrs
                                if 'height' in rav[region].coords:
                                    print('dropping height')
                                    rav[region] = rav[region].drop('height')
                                if 'pseudo_level' in rav[region].coords:
                                    print('dropping pseudo_level')
                                    rav[region] = rav[region].drop('pseudo_level')
                                if 'realization' in rav[region].coords:
                                    print('dropping realization')
                                    rav[region] = rav[region].drop('realization')
                                if 'time' in rav[region].coords:
                                    print('dropping time')
                                    rav[region] = rav[region].drop('time')
                                if 'quantile' in rav[region].coords:
                                    print('dropping quantile')
                                    rav[region] = rav[region].drop('quantile')

                                #< Print
                                print(q, var, season, region)
                                print(av.values, norm.values, rav[region].values)

                                #< Clear data for next loop
                                # client.cancel(av); client.cancel(norm); client.cancel(var_obs_seas_region);
                                # del av; del norm; del var_obs_seas_region
                                gc.collect()

                                # debug_plot_helper(X_dict['obs'], title='obs')
                                # debug_plot_helper(X_dict['gdd'], title='gdd')
                                # debug_plot_helper(X_dict['rcm'], title='rcm')
                                # debug_plot_helper(pav_region, title='pav')
                                # debug_plot_helper(std, title='std')
                                # debug_plot_helper(pav_region/std, title='pav/std')
                                # plt.show()
                                # print('########################################################')
                                # print('########################################################')
                                # print('########################################################')
                                # print()

                            l_debug_first = False

                #< Combine the added values in dictionaries and convert to xarray in the end
                            regionDummy[season] = xr.concat([rav[key] for key in rav], dim=pd.Index(rav.keys(), name='region'), coords='minimal')
                        seasonDummy[str(q)] = xr.concat([regionDummy[key] for key in regionDummy], dim=pd.Index(regionDummy.keys(), name='season'), coords='minimal')
                    varDummy[var] = xr.concat([seasonDummy[str(key)] for key in seasonDummy], dim=pd.Index([str(k) for k in seasonDummy.keys()], name='q'), coords='minimal')
                qDummy[gdd] = xr.concat([varDummy[key] for key in varDummy], dim=pd.Index(varDummy.keys(), name='var'), coords='minimal')
            rav = xr.concat([qDummy[key] for key in qDummy], dim=pd.Index(qDummy.keys(), name='gdd'), coords='minimal')


            #< Save realised added value in a netcdf file
            rav.to_netcdf(rav_ofile)

        else:
            rav = xr.load_dataarray(rav_ofile)
            rav = rav.sel(var=varnames)

        #< Calculate mean over every other dimension
        ravregion = rav.mean(['var', 'q', 'season', 'gdd']).to_dict()
        ravseason = rav.mean(['var', 'q', 'region', 'gdd']).to_dict()
        ravvar    = rav.mean(['region', 'q', 'season', 'gdd']).to_dict()
        ravq      = rav.mean(['var', 'region', 'season', 'gdd']).to_dict()
        ravgdd    = rav.mean(['var', 'region', 'season', 'q']).to_dict()


        #< Combine in dict
        regionDummy = dict(zip(ravregion['coords']['region']['data'], ravregion['data']))
        seasonDummy = dict(zip(ravseason['coords']['season']['data'], ravseason['data']))
        varDummy    = dict(zip(ravvar['coords']['var']['data'], ravvar['data']))
        qDummy      = dict(zip(ravq['coords']['q']['data'], ravq['data']))
        gddDummy    = dict(zip(ravgdd['coords']['gdd']['data'], ravgdd['data']))


        #< Select the operation in which added value is measured
        if op == 'mse':
            title  = 'Realised added value (MSE) summary'
            ofile  = oplot.format('av.mse.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'RAV'
        elif op == 'corr':
            title  = 'Realised added value (Corr) summary'
            ofile  = oplot.format('av.corr.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'RAV'
        elif op == 'bias':
            title  = 'Realised added value (Bias) summary'
            ofile  = oplot.format('av.bias.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'RAV'
        elif op == 'var':
            title  = 'Realised added value (Standard deviation) summary'
            ofile  = oplot.format('av.variance.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'RAV'
        elif op == 'commbias':
            title  = 'Common large-scale Bias\nR(GDD-Obs,RCM-Obs) summary'
            ofile  = oplot.format('av.bias-corr.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'Corr'

        boxPlotHelper(arrList=[regionDummy, seasonDummy, varDummy, gddDummy, qDummy],
                      nameList=['region', 'season', 'var', 'gdd', 'q'], title=title,
                      ylabel=ylabel, ofile=ofile)


################################################################################


if __name__ == '__main__':
    import dask.distributed
    import sys

    #< Print the script name
    print(sys.argv[0])


    # Get the number of CPUS in the job and start a dask.distributed cluster
    threads      = int(os.environ.get('THREADS_PER_WORKER','1'))
    n_workers    = 2 if os.environ["HOSTNAME"].startswith("gadi-login") else max(int(os.environ["PBS_NCPUS"]) // threads,1)
    memory_limit = '1000mb' if os.environ["HOSTNAME"].startswith("gadi-login") else int(os.environ["PBS_VMEM"]) / n_workers
    client       = dask.distributed.Client(n_workers=n_workers, threads_per_worker=threads, memory_limit=memory_limit, local_dir=tempfile.mkdtemp())


    #< Print client summary
    print('### Client summary')
    print(client)
    print('\n\n')

    #< Call the main function
    main()

    #< Close the client
    client.shutdown()
