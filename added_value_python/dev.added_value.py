import xarray as xr
import tempfile
import dask
from collections import OrderedDict
import os
import argparse
import lib_added_value as lav
import gc

#< Location for temporary files
try:
    dummy_fs = os.environ['PBS_JOBFS']
except:
    dummy_fs = '/scratch/q49/bxn599/tmp'



# Parse input arguments
def parse_args(parser):
    parser.add_argument("--ifile_gdd", dest='ifile_gdd', nargs='+', help="Driving model (coarse resolution) data")
    parser.add_argument("--ifile_rcm", dest='ifile_rcm', nargs='+', help="Regional model (high resolution) data")
    parser.add_argument("--ifile_obs", dest='ifile_obs', nargs='+', help="Reference (high resolution) data")
    parser.add_argument("--varnames", nargs='?', help="Comma-separated list of input variable names (in the order of gdd, rcm, obs)")
    parser.add_argument("--outunit", dest='outunit', nargs='+', help="Output units (e.g. mm day-1)")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Where to save the output")
    parser.add_argument("--yrStart", type=int, help="Year to start processing.")
    parser.add_argument("--yrEnd", type=int, help="Year to end processing.")
    parser.add_argument("--quantiles", dest='quantiles', type=str, nargs='?', help="Comma-separated list of quantiles to calculate added value for (e.g. mean, 0.99).")
    parser.add_argument("--seasons", nargs='?', default='annual', help="Comma-separated list of seasons (annual, DJF, etc.)")
    parser.add_argument("--prefix", dest='prefix', type=str, nargs=1, default='', help="Prefix for output files")
    parser.add_argument("--interp_method", dest='interp_method', type=str, nargs=1, default=["nearest"], help="Interpolation method used to interpolate to high-res")
    parser.add_argument("--curvilinear", dest='curvilinear', type=str, default=[""], help="Path to a weights file to regrid curvilinear input to rectilinear; modifies read in routine (e.g. possible regrid from curvilinear to rectilinear grid for narclim)")
    return parser.parse_args()


def main():

    #< Increase garbage threshold
    g0, g1, g2 = gc.get_threshold()
    gc.set_threshold(g0 * 3, g1 * 3, g2 * 3)

    # User argument input
    parser    = argparse.ArgumentParser(description='Produce added value analysis.')
    args      = parse_args(parser)
    ifile_gdd = args.ifile_gdd
    ifile_rcm = args.ifile_rcm
    ifile_obs = args.ifile_obs
    varnames  = list(filter(None, args.varnames.split(",")))
    outpath   = args.outpath
    yrStart   = args.yrStart
    yrEnd     = args.yrEnd
    outunit   = ' '.join(args.outunit)
    quantiles = [i for i in list(filter(None, args.quantiles.split(",")))]
    seasons   = list(filter(None,args.seasons.split(",")))
    prefix    = args.prefix[0]
    interp_method = args.interp_method[0]
    curvilinear   = args.curvilinear

    var_gdd = varnames[0]
    var_rcm = varnames[1]
    var_obs = varnames[2]

    if var_rcm == 'tmax':
        var = 'tasmax'
    elif var_rcm == 'tmin':
        var = 'tasmin'
    elif var_rcm == 'rr':
        var = 'pr'
    else:
        var = var_rcm #< After opening just name everything like the rcm name


    #< read data
    print('Read in the data files...')
    print('Driving model data...')
    arr_gdd = lav.read_dataarray(ifile_gdd, var=var_gdd, engine='netcdf4')
    if varnames[0] == 'tp': #< Only for erainterim precipitation
        arr_gdd = arr_gdd.resample(time="12H").nearest().resample(time='24H').sum() * 1000
        arr_gdd.attrs['units'] = 'mm day-1'
    print('Regional model data...')
    arr_rcm = lav.read_dataarray(ifile_rcm, var=var_rcm, engine='netcdf4', curvilinear=curvilinear)
    print('Reference (obs) data...')
    arr_obs = lav.read_dataarray(ifile_obs, var=var_obs, engine='netcdf4')
    print('Done opening the data sets...')
    print()


    ####
    # Some fixes for BARPA
    print('&&&&&&&&&&&&&&&&&&')
    print('SELECTING LON >= 128.43')
    with xr.set_options(keep_attrs=True):
        import numpy as np
        attrs         = arr_rcm.attrs
##        arr_rcm       = arr_rcm.sel(lon=slice(128.43,None))
        arr_rcm.attrs = attrs
    print('&&&&&&&&&&&&&&&&&&')

    if var == 'pr':
        print('&&&&&&&&&&&&&&&&&&')
        print(f'LIMITING {var} to 1000 mm/day')
        with xr.set_options(keep_attrs=True):
            attrs         = arr_rcm.attrs
            arr_rcm       = arr_rcm.where(arr_rcm<=1000.)
            arr_rcm.attrs = attrs
        print('&&&&&&&&&&&&&&&&&&')



    if 'valid_range' in arr_obs.attrs:
        del arr_obs.attrs['valid_range']
        print('Removed valid range...')


    #< Select yrStart and yrEnd
    print('Select start and end year...')
    arr_gdd = arr_gdd.sel(time=slice(str(yrStart),str(yrEnd)))
    arr_rcm = arr_rcm.sel(time=slice(str(yrStart),str(yrEnd)))
    arr_obs = arr_obs.sel(time=slice(str(yrStart),str(yrEnd)))


    #< Select the overlapping domain
    print('Select the overlapping domain in time, lat and lon dimension...')
    arr_gdd, arr_rcm, arr_obs = lav.cut_overlap(*[arr_gdd, arr_rcm, arr_obs], dims=['time', 'lat', 'lon'])
    print(f'The time ranges from {arr_obs["time"].dt.year[0].values} to {arr_obs["time"].dt.year[-1].values}')
    print(f'The horizontal dimension ranges from {arr_obs["lat"][0].values:.2f} to {arr_obs["lat"][-1].values:.2f} degrees latitude and from {arr_obs["lon"][0].values:.2f} to {arr_obs["lon"][-1].values:.2f} degrees longitude')
    print()


    arr_gdd = arr_gdd.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
    arr_rcm = arr_rcm.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
    arr_obs = arr_obs.chunk({'time':None, 'lat':'auto', 'lon':'auto'})


    print(f'After selecting time and domain for gdd: The size is {lav.getSizeGB(arr_gdd)}')
    print(f'and the chunks are {lav.getChunkSize(arr_gdd)} and there are {lav.getNumberChunks(arr_gdd)} chunks\n')
    print(f'After selecting time and domain for rcm: The size is {lav.getSizeGB(arr_rcm)}')
    print(f'and the chunks are {lav.getChunkSize(arr_rcm)} and there are {lav.getNumberChunks(arr_rcm)} chunks\n')
    print(f'After selecting time and domain for obs: The size is {lav.getSizeGB(arr_obs)}')
    print(f'and the chunks are {lav.getChunkSize(arr_obs)} and there are {lav.getNumberChunks(arr_obs)} chunks\n')



    print('Intermediate calculations...')
    saver1 = arr_gdd.to_dataset(name=var).to_zarr(dummy_fs+'/data1.zarr', mode='w', compute=False)
    saver2 = arr_rcm.to_dataset(name=var).to_zarr(dummy_fs+'/data2.zarr', mode='w', compute=False)
    saver3 = arr_obs.to_dataset(name=var).to_zarr(dummy_fs+'/data3.zarr', mode='w', compute=False)
    future = client.persist([saver1])
    dask.distributed.progress(future)
    dask.compute(*future)
    print()
    future = client.persist([saver2])
    dask.distributed.progress(future)
    dask.compute(*future)
    print()
    future = client.persist([saver3])
    dask.distributed.progress(future)
    dask.compute(*future)
    print()

    #< Close the original files
    arr_gdd.close(); arr_rcm.close(); arr_obs.close()
    client.cancel(arr_gdd); client.cancel(arr_rcm); client.cancel(arr_obs)
    del arr_gdd; del arr_rcm; del arr_obs; gc.collect()
    #
    #< Open the original data set again
    arr_gdd = xr.open_zarr(dummy_fs+'/data1.zarr')[var]
    arr_rcm = xr.open_zarr(dummy_fs+'/data2.zarr')[var]
    arr_obs = xr.open_zarr(dummy_fs+'/data3.zarr')[var]
    print('Done with intermediate calculations...')
    print()


    print(f'Convert units to common output units of {outunit}')
    arr_gdd, arr_rcm, arr_obs = lav.convert_units(*[arr_gdd, arr_rcm, arr_obs], outunit=outunit)


    for q in quantiles:
        if lav.isfloat(q):
            q = float(q)

        if isinstance(q, float):
            print(f'{q*100} quantile...')
            qstr = '{}'.format(q).replace('.','p')
        elif isinstance(q, str):
            print(f'{q}...')
            qstr = q
        else:
            print(f'Type {type(q)} of q not supported')

        for season in seasons:
            print(f'{season}')
            if not season == 'annual':
                arr_obs_seas = arr_obs[arr_obs['time.season']==season]
                arr_gdd_seas = arr_gdd[arr_gdd['time.season']==season]
                arr_rcm_seas = arr_rcm[arr_rcm['time.season']==season]
            else:
                arr_obs_seas = arr_obs
                arr_gdd_seas = arr_gdd
                arr_rcm_seas = arr_rcm

            arr_dict = OrderedDict({
                'gdd': arr_gdd_seas,
                'obs': arr_obs_seas,
                'rcm': arr_rcm_seas,
            })

            #< Define output file
            ofile_X = outpath + '/' + 'X.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStart}-{yrEnd}' + f'.interp_{interp_method}' + '.nc' # Outfile for statistics
            ofile_A = outpath + '/' + 'A.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStart}-{yrEnd}' + f'.interp_{interp_method}' + '.nc' # Outfile for added value (squared error) map


            #< Calculate added value for the past period
            lav.addedValueStats(client, arr_dict, q, ofile_X=ofile_X, ofile_A=ofile_A, interp_method=interp_method)

            #< clear memory
            client.cancel(arr_gdd_seas); client.cancel(arr_obs_seas); client.cancel(arr_rcm_seas); client.cancel(arr_dict);
            del arr_gdd_seas; del arr_obs_seas; del arr_rcm_seas; del arr_dict
            gc.collect()


################################################################################


if __name__ == '__main__':
    import dask.distributed
    import sys

    global client

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
