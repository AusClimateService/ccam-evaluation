import xarray as xr
import numpy as np
import tempfile
import dask
import os
import argparse
import lib_added_value as lav
import matplotlib.pyplot as plt
from cartopy import crs as ccrs
import matplotlib.gridspec as gridspec
import matplotlib as mpl
import gc


#< Location for temporary files
try:
    dummy_fs = os.environ['PBS_JOBFS']
except:
    dummy_fs = '/scratch/q49/bxn599/tmp'


def plot_helper(arr, ax, title, **kwargs):

    fmt = '%5.2f'

    #< Get the units from the input array
    if 'units' in arr.attrs:
        units = arr.attrs['units']
    else:
        units = ''

    im = arr.plot.pcolormesh(ax=ax, add_colorbar=False, **kwargs)
    ax.set_title(title)
    cb = plt.colorbar(im, ax=ax, orientation="horizontal", pad=0.05, extend='both', format=fmt)
    cb.set_label(label=units, size='large', weight='bold')
    cb.ax.tick_params(labelsize='large')

    labels_str   = ['{:5.2f}'.format(i) for i in cb.locator()]
    print(labels_str)
    labels_float = [float(i) for i in labels_str]
    cb.ax.set_xticks(labels_float)
    cb.ax.set_xticklabels(labels_str, rotation=45)

    ax.coastlines()


# Parse input arguments
def parse_args(parser):
    parser.add_argument("--ipath", dest='ipath', type=str, help="Path to input data.")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Comma-separated list of input files. (The first file will be the reference)")
    parser.add_argument("--varname", type=str, default='', help="Input variable name")
    parser.add_argument("--yrStartPast", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndPast", type=int, help="Year to end processing.")
    parser.add_argument("--yrStartFut", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndFut", type=int, help="Year to end processing.")
    parser.add_argument("--quantiles", dest='quantiles', type=str, nargs='?', help="Quantiles to calculate added value for.")
    parser.add_argument("--seasons", nargs='?', default='annual', help="Comma-separated list of seasons (annual, DJF, etc.)")
    parser.add_argument("--prefix", dest='prefix', type=str, nargs=1, default='', help="Prefix for output files")
    parser.add_argument("--interp_method", dest='interp_method', type=str, nargs=1, default=["nearest"], help="Interpolation method used to interpolate to high-res")
    return parser.parse_args()


def main():

    #< Increase garbage threshold
    g0, g1, g2 = gc.get_threshold()
    gc.set_threshold(g0 * 3, g1 * 3, g2 * 3)

    # User argument input
    parser    = argparse.ArgumentParser(description='Plot some overview plots of the added value analysis.')
    args      = parse_args(parser)
    ipath     = args.ipath
    var       = args.varname
    outpath   = args.outpath
    yrStartPast  = args.yrStartPast
    yrEndPast    = args.yrEndPast
    yrStartFut   = args.yrStartFut
    yrEndFut     = args.yrEndFut
    quantiles = [i for i in list(filter(None, args.quantiles.split(",")))]
    seasons   = list(filter(None,args.seasons.split(",")))
    prefix    = args.prefix[0]
    interp_method = args.interp_method[0]


    cbmin_clim_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':0,
                  }

    cbmax_clim_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':80,
                  }

    cbsteps_clim_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':40,
                  }

    cbmin_resp_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':-40,
                  }

    cbmax_resp_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':40,
                  }

    cbsteps_resp_dict = {
                    'tasmin':None,
                    'tasmax':None,
                    'pr':40,
                  }


    cbmin_av_dict = {
                    'tasmin':-30,
                    'tasmax':-30,
                    'pr':-30,
                  }

    cbmax_av_dict = {
                    'tasmin':30,
                    'tasmax':30,
                    'pr':30,
                  }

    cbsteps_av_dict = {
                    'tasmin':40,
                    'tasmax':40,
                    'pr':40,
                  }

    cbmin_pav_dict = {
                    'tasmin':-2,
                    'tasmax':-2,
                    'pr':-40,
                  }

    cbmax_pav_dict = {
                    'tasmin':2,
                    'tasmax':2,
                    'pr':40,
                  }

    cbsteps_pav_dict = {
                    'tasmin':40,
                    'tasmax':40,
                    'pr':40,
                  }

    cbmin_rav_dict = {
                    'tasmin':-1,
                    'tasmax':-1,
                    'pr':-1,
                  }

    cbmax_rav_dict = {
                    'tasmin':1,
                    'tasmax':1,
                    'pr':1,
                  }

    cbsteps_rav_dict = {
                    'tasmin':40,
                    'tasmax':40,
                    'pr':40,
                  }





##########################################
### Figure: Overview
##########################################

    #< Select season of interest
    for q in quantiles:
        if lav.isfloat(q):
            q = float(q)

        if isinstance(q, float):
            print(f'{q*100} quantile...')
            qstr = f'{q}'.replace('.','p')
        elif isinstance(q, str):
            print(f'{q}...')
            qstr = q
        else:
            print(f'Type {type(q)} of q not supported')

        for season in seasons:

            #< read data
            if isinstance(q, float):
                print(f'Read in the data files for {var} ({season}) and quantile {q*100}...')
            elif isinstance(q, str):
                print(f'Read in the data files for {var} ({season}) and quantile {q}...')

            varname   = 'rcmPastLR'
            ifile_X   = ipath + '/X.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
            X_LR      = lav.read_dataarray(ifile_X, var=varname, engine='netcdf4').squeeze()
            varname   = 'rcmPastHRd'
            X_HRd     = lav.read_dataarray(ifile_X, var=varname, engine='netcdf4').squeeze()
            with xr.set_options(keep_attrs=True):
                Xpast     = X_LR + X_HRd
            varname   = 'rcmFutLR'
            X_LR      = lav.read_dataarray(ifile_X, var=varname, engine='netcdf4').squeeze()
            varname   = 'rcmFutHRd'
            X_HRd     = lav.read_dataarray(ifile_X, var=varname, engine='netcdf4').squeeze()
            with xr.set_options(keep_attrs=True):
                Xfut      = X_LR + X_HRd
                Xcc       = Xfut - Xpast

            varname   = 'avg'
            ifile_av  = ipath + '/A.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}' + f'.interp_{interp_method}' + '.nc'
            arr_av    = lav.read_dataarray(ifile_av, var=varname, engine='netcdf4').squeeze()

            varname   = 'avgs'
            arr_avs   = lav.read_dataarray(ifile_av, var=varname, engine='netcdf4').squeeze()

            varname   = 'pav_cc'
            ifile_pav = ipath + '/P.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
            arr_pav   = lav.read_dataarray(ifile_pav, var=varname, engine='netcdf4').squeeze()

            varname   = 'rav'
            ifile_rav = ipath + '/R.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
            arr_rav   = lav.read_dataarray(ifile_rav, var=varname, engine='netcdf4').squeeze()

            varname   = 'ravs'
            arr_ravs  = lav.read_dataarray(ifile_rav, var=varname, engine='netcdf4').squeeze()

            varname   = 'var'
            ifile_rav = ipath + '/R.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'
            arr_var   = lav.read_dataarray(ifile_rav, var=varname, engine='netcdf4').squeeze()

            print('Done opening the data sets...')
            print()

            print('Cut all data sets to same extend...')
            Xpast, Xcc, arr_av, arr_avs, arr_pav, arr_rav = lav.cut_overlap(*[Xpast, Xcc, arr_av, arr_avs, arr_pav, arr_rav], dims=['lat', 'lon'])

            #< Plotting
            #< Using added value
            ncols = 6
            nrows = 1
            fig = plt.figure(figsize=((4.7*ncols,3.7*nrows)))

            # Setup axes
            width_ratios = [1]*ncols
            gs  = gridspec.GridSpec(nrows, ncols, figure=fig, wspace=0.45)
            axs = {}

            # Set projections
            axs['Xpast'] = fig.add_subplot(gs[0], projection=ccrs.PlateCarree(central_longitude=0))
            axs['Xcc']   = fig.add_subplot(gs[1], projection=ccrs.PlateCarree(central_longitude=0))
            axs['av']    = fig.add_subplot(gs[2], projection=ccrs.PlateCarree(central_longitude=0))
            axs['pav']   = fig.add_subplot(gs[3], projection=ccrs.PlateCarree(central_longitude=0))
            axs['rav']   = fig.add_subplot(gs[4], projection=ccrs.PlateCarree(central_longitude=0))
            axs['var']   = fig.add_subplot(gs[5], projection=ccrs.PlateCarree(central_longitude=0))

            if not cbmin_clim_dict[var] is None:
                cbmin   = cbmin_clim_dict[var]
                cbmax   = cbmax_clim_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmax_clim_dict[var]
                cbsteps = cbsteps_clim_dict[var]
                plot_helper(Xpast, axs['Xpast'], f'Clim: {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps))
            else:
                plot_helper(Xpast, axs['Xpast'], f'Clim: {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=20)

            if not cbmin_resp_dict[var] is None:
                cbmin   = cbmin_resp_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmin_resp_dict[var]
                cbmax   = cbmax_resp_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmax_resp_dict[var]
                cbsteps = cbsteps_resp_dict[var]
                vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
                plot_helper(Xcc, axs['Xcc'], f'{yrStartFut}-{yrEndFut} minus {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            else:
                plot_helper(Xcc, axs['Xcc'], f'{yrStartFut}-{yrEndFut} minus {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=20)

            cbmin   = cbmin_av_dict[var]
            cbmax   = cbmax_av_dict[var]
            cbsteps = cbsteps_av_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_av, axs['av'], 'Added value', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_av, axs['av'], 'Added value', transform=ccrs.PlateCarree(), levels=20)

            cbmin   = cbmin_pav_dict[var] / 20 if var == 'pr' and q == 'mean' else cbmin_pav_dict[var]
            cbmax   = cbmax_pav_dict[var] / 20 if var == 'pr' and q == 'mean' else cbmax_pav_dict[var]
            cbsteps = cbsteps_pav_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_pav, axs['pav'], 'Potential added value', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_pav, axs['pav'], 'Potential added value', transform=ccrs.PlateCarree(), levels=20)

            cbmin   = cbmin_rav_dict[var]
            cbmax   = cbmax_rav_dict[var]
            cbsteps = cbsteps_rav_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_rav, axs['rav'], 'Realised added value', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_rav, axs['rav'], 'Realised added value', transform=ccrs.PlateCarree(), levels=20)


            plot_helper(arr_var, axs['var'], 'Variance', transform=ccrs.PlateCarree(), levels=20)


            if isinstance(q, float):
                plt.suptitle(f'{q*100}th perc. {var} ({season})')
            elif isinstance(q, str):
                plt.suptitle(f'{q} {var} ({season})')

            plt.tight_layout()

            ofile = outpath + '/' + 'overview_added_value.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.png'
            plt.savefig(ofile)


            ###
            #< Using normalised added value
            ncols = 6
            nrows = 1
            fig = plt.figure(figsize=((4.7*ncols,3.7*nrows)))

            # Setup axes
            width_ratios = [1]*ncols
            gs  = gridspec.GridSpec(nrows, ncols, figure=fig, wspace=0.45)
            axs = {}

            # Set projections
            axs['Xpast'] = fig.add_subplot(gs[0], projection=ccrs.PlateCarree(central_longitude=0))
            axs['Xcc']   = fig.add_subplot(gs[1], projection=ccrs.PlateCarree(central_longitude=0))
            axs['av']    = fig.add_subplot(gs[2], projection=ccrs.PlateCarree(central_longitude=0))
            axs['pav']   = fig.add_subplot(gs[3], projection=ccrs.PlateCarree(central_longitude=0))
            axs['rav']   = fig.add_subplot(gs[4], projection=ccrs.PlateCarree(central_longitude=0))
            axs['var']   = fig.add_subplot(gs[5], projection=ccrs.PlateCarree(central_longitude=0))

            if not cbmin_clim_dict[var] is None:
                cbmin   = cbmin_clim_dict[var]
                cbmax   = cbmax_clim_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmax_clim_dict[var]
                cbsteps = cbsteps_clim_dict[var]
                plot_helper(Xpast, axs['Xpast'], f'Clim: {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps))
            else:
                plot_helper(Xpast, axs['Xpast'], f'Clim: {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=20)

            if not cbmin_resp_dict[var] is None:
                cbmin   = cbmin_resp_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmin_resp_dict[var]
                cbmax   = cbmax_resp_dict[var] / 10 if var == 'pr' and q == 'mean' else cbmax_resp_dict[var]
                cbsteps = cbsteps_resp_dict[var]
                vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
                plot_helper(Xcc, axs['Xcc'], f'{yrStartFut}-{yrEndFut} minus {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            else:
                plot_helper(Xcc, axs['Xcc'], f'{yrStartFut}-{yrEndFut} minus {yrStartPast}-{yrEndPast}', transform=ccrs.PlateCarree(), levels=20)


            cbmin   = -1
            cbmax   = 1
            cbsteps = cbsteps_av_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_avs, axs['av'], 'Added value (norm)', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_avs, axs['av'], 'Added value', transform=ccrs.PlateCarree(), levels=20)

            cbmin   = cbmin_pav_dict[var] / 20 if var == 'pr' and q == 'mean' else cbmin_pav_dict[var]
            cbmax   = cbmax_pav_dict[var] / 20 if var == 'pr' and q == 'mean' else cbmax_pav_dict[var]
            cbsteps = cbsteps_pav_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_pav, axs['pav'], 'Potential added value', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_pav, axs['pav'], 'Potential added value', transform=ccrs.PlateCarree(), levels=20)

            cbmin   = -1
            cbmax   = 1
            cbsteps = 40 #cbsteps_rav_dict[var]
            vmin = cbmin; vmax = cbmax; norm = mpl.colors.DivergingNorm(vmin=vmin, vcenter=0, vmax=vmax)
            plot_helper(arr_ravs, axs['rav'], 'Realised added value (norm)', transform=ccrs.PlateCarree(), levels=np.linspace(cbmin,cbmax,cbsteps), cmap='RdBu_r', norm=norm, vmin=vmin, vmax=vmax)
            # plot_helper(arr_ravs, axs['rav'], 'Realised added value', transform=ccrs.PlateCarree(), levels=20)


            plot_helper(xr.ufuncs.sqrt(arr_var), axs['var'], 'std', transform=ccrs.PlateCarree(), levels=20)


            if isinstance(q, float):
                plt.suptitle(f'{q*100}th perc. {var} ({season})')
            elif isinstance(q, str):
                plt.suptitle(f'{q} {var} ({season})')

            plt.tight_layout()

            ofile = outpath + '/' + 'overview_added_value_norm.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.png'
            plt.savefig(ofile)





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
    print()

    #< Call the main function
    main()

    #< Close the client
    client.shutdown()
