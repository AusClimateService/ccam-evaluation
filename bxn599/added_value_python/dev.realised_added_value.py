import xarray as xr
import tempfile
import dask
import os
import argparse
import lib_added_value as lav
import gc


#< Location for temporary files
try:
    dummy_fs = os.environ['PBS_JOBFS']
except:
    dummy_fs = '/g/data/xv83/users/bxn599/tmp'


# Parse input arguments
def parse_args(parser):
    parser.add_argument("--ipath", dest='ipath', type=str, help="Path to input data.")
    parser.add_argument("--ifile_obs", dest='ifile_obs', nargs='+', help="Observation (high resolution) data")
    parser.add_argument("--varname_obs", type=str, help="Input variable name of observations")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Comma-separated list of input files. (The first file will be the reference)")
    parser.add_argument("--yrStartPast", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndPast", type=int, help="Year to end processing.")
    parser.add_argument("--yrStartFut", type=int, help="Year to start processing.")
    parser.add_argument("--yrEndFut", type=int, help="Year to end processing.")
    parser.add_argument("--quantiles", dest='quantiles', type=str, nargs='?', help="Comma-separated list of quantiles to calculate added value for (e.g. mean, 0.99).")
    parser.add_argument("--seasons", nargs='?', default='annual', help="Comma-separated list of seasons (annual, DJF, etc.)")
    parser.add_argument("--prefix", dest='prefix', type=str, default='', help="Prefix for output files")
    parser.add_argument("--interp_method", dest='interp_method', type=str, default="nearest", help="Interpolation method used to interpolate to high-res")
    return parser.parse_args()


def main():

    #< Increase garbage threshold
    g0, g1, g2 = gc.get_threshold()
    gc.set_threshold(g0 * 3, g1 * 3, g2 * 3)

    # User argument input
    parser    = argparse.ArgumentParser(description='Produce potential added value analysis.')
    args      = parse_args(parser)
    ipath     = args.ipath
    ifile_obs = args.ifile_obs
    varname   = args.varname_obs
    outpath   = args.outpath
    yrStartPast  = args.yrStartPast
    yrEndPast    = args.yrEndPast
    yrStartFut   = args.yrStartFut
    yrEndFut     = args.yrEndFut
    quantiles = [i for i in list(filter(None, args.quantiles.split(",")))]
    seasons   = list(filter(None,args.seasons.split(",")))
    prefix    = args.prefix
    interp_method = args.interp_method


    #< read data
    print('Read in the data files...')
    print('Observation data...')
    arr_obs = lav.read_dataarray(ifile_obs, var=varname, engine='netcdf4')
    arr_obs['lat'] = arr_obs['lat'].astype('float32')
    arr_obs['lon'] = arr_obs['lon'].astype('float32')
    print('Done opening the data sets...')
    print()


    #< Select start and end year of observations
    print('Select start and end year of observations...')
    arr_obs = arr_obs.sel(time=slice(str(yrStartPast),str(yrEndPast)))


    #< Cut observations to region of interest (using dummy added value file)
    print('Cutting observations to overlap...')
    if lav.isfloat(quantiles[0]):
        qdummy = float(quantiles[0])
    else:
        qdummy = quantiles[0]
    if isinstance(qdummy, float):
        print(f'{qdummy*100} quantile...')
        qstr = '{}'.format(qdummy).replace('.','p')
    elif isinstance(qdummy, str):
        print(f'{qdummy}...')
        qstr = qdummy
    else:
        print(f'Type {type(q)} of q not supported')
    ifile_av = ipath + '/' + 'A.' + prefix + f'.q{qstr}.' + f'{seasons[0]}' + f'.{yrStartPast}-{yrEndPast}' + f'.interp_{interp_method}' + '.nc'
    arr_av   = lav.read_dataarray(ifile_av, var='avg', engine='netcdf4')
    arr_av   = arr_av.squeeze()
    arr_obs,_ = lav.cut_overlap(*[arr_obs, arr_av], dims=['lat', 'lon'])

    print('Intermediate calculations...')
    arr_obs = arr_obs.chunk({'time':None, 'lat':'auto', 'lon':'auto'})
    saver1  = arr_obs.to_dataset(name=varname).to_zarr(dummy_fs+'/data1.zarr', mode='w', compute=False)
    future  = client.persist([saver1])
    dask.distributed.progress(future)
    dask.compute(*future)
    print()
    #< Close the original files
    arr_obs.close(); gc.collect()
    #
    #< Open the original data set again
    arr_obs = xr.open_zarr(dummy_fs+'/data1.zarr')[varname]
    print('Done with intermediate calculations...')


    #< Check if q is numeric, then it is interpreted as quantile
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

        #< Select season of interest
        for season in seasons:
            print(f'{season}')
            #< Construct the file names
            ifile_av  = ipath + '/' + 'A.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}' + f'.interp_{interp_method}' + '.nc'
            ifile_pav = ipath + '/' + 'P.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc'

            #< read data
            print('Read in the data files...')
            print('Added value data...')
            arr_av  = lav.read_dataarray(ifile_av, var='avg', engine='netcdf4')
            arr_av  = arr_av.squeeze()
            arr_avs = lav.read_dataarray(ifile_av, var='avgs', engine='netcdf4')
            arr_avs = arr_avs.squeeze()
            print('Potential added value data...')
            arr_pav = lav.read_dataarray(ifile_pav, var='pav_cc', engine='netcdf4')
            arr_pav = arr_pav.squeeze()
            print('Done opening the data sets...')
            print()



            #< Calculate standard deviation of observations for the season in question
            #< select season
            if not season == 'annual':
                arr_obs_seas = arr_obs[arr_obs['time.season']==season]
            else:
                arr_obs_seas = arr_obs
            #< calculate quantile for each year separately
            if isinstance(q, float):
                q_obs_seas = arr_obs_seas.groupby('time.year').quantile(q, dim='time')
                q_obs_seas = q_obs_seas.rename({'year':'time'})
            elif isinstance(q, str):
                if q == 'mean': #< if operation is 'mean' take the variation of yearly means
                    q_obs_seas = arr_obs_seas.groupby('time.year').mean(dim='time')
                    q_obs_seas = q_obs_seas.rename({'year':'time'})
                else:
                    print(f'Operation {q} not found!')
                    exit()

            #< calculate variance
            var_obs_seas = q_obs_seas.var('time')
            var_obs_seas = var_obs_seas.persist()

            print('Intermediate calculations...')
            lav.saver(client, dummy_fs+'/data1.nc', var_obs_seas)
            var_obs_seas = xr.load_dataset(dummy_fs+'/data1.nc')[varname]
            print('Done intermediate calculations...')


            #< Make obs match added value resolution
            print('Match resolutions...')
            var_obs_seas = lav.helper_match_resolution(var_obs_seas, arr_av, 'obs', interp_method=interp_method)


            #< Mask observations according to added value input
            print('Mask observations to match added value input...')
            with xr.set_options(keep_attrs=True):
                var_obs_seas = var_obs_seas.where(~xr.ufuncs.isnan(arr_av))
            var_obs_seas = var_obs_seas.persist() #< Keep this in memory it will be used twice below



            #< Calculate realised added value
            print('Calculating realised added value...')
            with xr.set_options(keep_attrs=True):
                rav  = arr_av  * xr.ufuncs.fabs(arr_pav) / var_obs_seas
                ravs = arr_avs * xr.ufuncs.fabs(arr_pav) / xr.ufuncs.sqrt(var_obs_seas)

            if 'units' in rav.attrs:
                del rav.attrs['units']
                del ravs.attrs['units']


            #< Save output
            #< Save realised added value
            rav     = rav.to_dataset(name='rav')
            ofile_R = outpath + '/' + 'R.' + prefix + f'.q{qstr}.' + f'{season}' + f'.{yrStartPast}-{yrEndPast}to{yrStartFut}-{yrEndFut}' + f'.interp_{interp_method}' + '.nc' # Outfile for added value (squared error) map
            print(f'Save the realised added value (squared error) to {ofile_R}...')
            enc = {'rav':{'shuffle': True}, 'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
            lav.saver(client, ofile_R, rav, encoding=enc)
            #< Save normalised realised added value
            ravs = ravs.to_dataset(name='ravs')
            enc = {'ravs':{'shuffle': True}, 'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
            lav.saver(client, ofile_R, ravs, mode='a', encoding=enc)
            #< Save variance
            var_obs_seas = var_obs_seas.to_dataset(name='var')
            enc = {'var':{'shuffle': True}, 'lat':{'dtype':'float32'}, 'lon':{'dtype':'float32'}}
            lav.saver(client, ofile_R, var_obs_seas, mode='a', encoding=enc)


            #< clear memory
            client.cancel(arr_av); client.cancel(arr_pav); client.cancel(var_obs_seas)
            del arr_av; del arr_pav; del var_obs_seas
            gc.collect()




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
