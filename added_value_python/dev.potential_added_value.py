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
    parser.add_argument("--varnames", nargs='?', help="Comma-separated list of input variable names (in the order of gdd, rcm)")
    parser.add_argument("--outunit", dest='outunit', nargs='+', help="Output units (e.g. mm day-1)")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Where to save the output.")
    parser.add_argument("--yrStartPast", type=int, help="Historical year to start processing.")
    parser.add_argument("--yrEndPast", type=int, help="Historical year to end processing.")
    parser.add_argument("--yrStartFut", type=int, help="Future year to start processing.")
    parser.add_argument("--yrEndFut", type=int, help="Future year to end processing.")
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
    parser    = argparse.ArgumentParser(description='Produce potential added value analysis.')
    args      = parse_args(parser)
    ifile_gdd = args.ifile_gdd
    ifile_rcm = args.ifile_rcm
    varnames  = list(filter(None, args.varnames.split(",")))
    outpath   = args.outpath
    yrStartPast  = args.yrStartPast
    yrEndPast    = args.yrEndPast
    yrStartFut   = args.yrStartFut
    yrEndFut     = args.yrEndFut
    outunit   = ' '.join(args.outunit)
    quantiles = [i for i in list(filter(None, args.quantiles.split(",")))]
    seasons   = list(filter(None,args.seasons.split(",")))
    prefix    = args.prefix[0]
    interp_method = args.interp_method[0]
    curvilinear   = args.curvilinear

    var_gdd = varnames[0]
    var_rcm = varnames[1]

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
    print('Regional model data...')
    arr_rcm = lav.read_dataarray(ifile_rcm, var=var_rcm, engine='netcdf4', curvilinear=curvilinear)
    print('Done opening the data sets...')
    print()

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


    print(f'Convert units to common output units of {outunit}')
    arr_gdd, arr_rcm = lav.convert_units(*[arr_gdd, arr_rcm], outunit=outunit)


    #< Select the overlapping domain
    print('Select the overlapping domain in lat and lon dimension...')
    arr_gdd, arr_rcm = lav.cut_overlap(*[arr_gdd, arr_rcm], dims=['lat', 'lon'])
    print(f'The horizontal dimension ranges from {arr_rcm["lat"][0].values:.2f} to {arr_rcm["lat"][-1].values:.2f} degrees latitude and from {arr_rcm["lon"][0].values:.2f} to {arr_rcm["lon"][-1].values:.2f} degrees longitude')
    print()

    #< Select past and future periods
    print('Select past and future periods...')
    arr_gdd_past = arr_gdd.sel(time=slice(str(yrStartPast),str(yrEndPast)))
    arr_gdd_fut  = arr_gdd.sel(time=slice(str(yrStartFut),str(yrEndFut)))
    arr_rcm_past = arr_rcm.sel(time=slice(str(yrStartPast),str(yrEndPast)))
    arr_rcm_fut  = arr_rcm.sel(time=slice(str(yrStartFut),str(yrEndFut)))

    arr_gdd_past = arr_gdd_past.chunk({'time':30, 'lat':None, 'lon':None})
    arr_gdd_fut  = arr_gdd_fut.chunk({'time':30, 'lat':None, 'lon':None})
    arr_rcm_past = arr_rcm_past.chunk({'time':30, 'lat':None, 'lon':None})
    arr_rcm_fut  = arr_rcm_fut.chunk({'time':30, 'lat':None, 'lon':None})

    print(f'After selecting time and domain for gdd_past: The size is {lav.getSizeGB(arr_gdd_past)}')
    print(f'and the chunks are {lav.getChunkSize(arr_gdd_past)}\n')
    print(f'After selecting time and domain for rcm_past: The size is {lav.getSizeGB(arr_rcm_past)}')
    print(f'and the chunks are {lav.getChunkSize(arr_rcm_past)}\n')

    print('Intermediate calculations...')
    saver1 = arr_gdd_past.to_dataset(name=var).to_zarr(dummy_fs+'/data1.zarr', mode='w', compute=False)
    saver2 = arr_gdd_fut.to_dataset(name=var).to_zarr(dummy_fs+'/data2.zarr', mode='w', compute=False)
    saver3 = arr_rcm_past.to_dataset(name=var).to_zarr(dummy_fs+'/data3.zarr', mode='w', compute=False)
    saver4 = arr_rcm_fut.to_dataset(name=var).to_zarr(dummy_fs+'/data4.zarr', mode='w', compute=False)
    #< For some reason, can't save all at once...
    future = client.persist([saver1])
    dask.distributed.progress(future)
    dask.compute(*future)
    future = client.persist([saver2])
    dask.distributed.progress(future)
    dask.compute(*future)
    future = client.persist([saver3])
    dask.distributed.progress(future)
    dask.compute(*future)
    future = client.persist([saver4])
    dask.distributed.progress(future)
    dask.compute(*future)
    print()

    #< Close the original files
    # arr_gdd_past.close(); arr_gdd_fut.close(); arr_rcm_past.close(); arr_rcm_fut.close()

    #< Open the original data set again
    arr_gdd_past = xr.open_zarr(dummy_fs+'/data1.zarr')[var]
    arr_gdd_fut  = xr.open_zarr(dummy_fs+'/data2.zarr')[var]
    arr_rcm_past = xr.open_zarr(dummy_fs+'/data3.zarr')[var]
    arr_rcm_fut  = xr.open_zarr(dummy_fs+'/data4.zarr')[var]
    print('Done with intermediate calculations...')
    print()


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
                arr_gdd_past_seas = arr_gdd_past[arr_gdd_past['time.season']==season]
                arr_gdd_fut_seas  = arr_gdd_fut[arr_gdd_fut['time.season']==season]
                arr_rcm_past_seas = arr_rcm_past[arr_rcm_past['time.season']==season]
                arr_rcm_fut_seas  = arr_rcm_fut[arr_rcm_fut['time.season']==season]
            else:
                arr_gdd_past_seas = arr_gdd_past
                arr_gdd_fut_seas  = arr_gdd_fut
                arr_rcm_past_seas = arr_rcm_past
                arr_rcm_fut_seas  = arr_rcm_fut

            arr_dict = OrderedDict({
                'gddPast': arr_gdd_past_seas,
                'gddFut': arr_gdd_fut_seas,
                'rcmPast': arr_rcm_past_seas,
                'rcmFut': arr_rcm_fut_seas,
            })

            #< Define output file
            ofile_X = outpath + '/' + 'X.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc' # Outfile for statistics
            ofile_P = outpath + '/' + 'P.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc' # Outfile for added value (squared error) map


            #< Calculate added value for the past period
            lav.potentialAddedValueStats(client, arr_dict, q, ofile_X=ofile_X, ofile_P=ofile_P, interp_method=interp_method)


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
