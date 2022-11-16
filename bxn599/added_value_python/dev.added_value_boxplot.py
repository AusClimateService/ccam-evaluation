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


def addedValueStatMSE(X_dict):

    ress = ['LR', 'HRd']
    av = av_norm = 0
    for res in ress:
        av       += lav.AVmse(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
        av_norm  += lav.AVmse_norm(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
    avs = (av/av_norm)
    return avs


def addedValueStatCorr(X_dict):

    ress = ['LR', 'HRd']
    av = av_norm = 0
    for res in ress:
        av       += lav.AVcorr(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
        av_norm  += lav.AVcorr_norm(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
    avs = (av/av_norm)
    return avs

def addedValueStatBias(X_dict):

    ress = ['LR', 'HRd']
    av = av_norm = 0
    for res in ress:
        av       += lav.AVbias(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
        av_norm  += lav.AVbias_norm(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
    avs = (av/av_norm)
    return avs

def addedValueStatStd(X_dict):

    ress = ['LR', 'HRd']
    av = av_norm = 0
    for res in ress:
        av       += lav.AVstd(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
        av_norm  += lav.AVstd_norm(X_dict['obs{}'.format(res)], X_dict['gdd{}'.format(res)], X_dict['rcm{}'.format(res)])
    avs = (av/av_norm)
    return avs

def corrCommonBias(X_dict):

    ress = ['LR'] #, 'HRd']
    Xgdd = Xrcm = Xobs = 0
    for res in ress:
        Xgdd += X_dict['gdd{}'.format(res)]
        Xrcm += X_dict['rcm{}'.format(res)]
        Xobs += X_dict['obs{}'.format(res)]

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
    plt.ylim([-0.5, 1])
    plt.yticks([-0.5, 0, 0.5, 1], weight='bold')
    plt.gca().axhline(c='grey', lw=2, linestyle='--')

    #< legend
    xx = 0
    locs, labels = plt.yticks()            # Get locations and labels
    dloc = locs[1]-locs[0]
    for i, dummy in enumerate(arrList):
        x, y  = zip(*sorted(dummy.items()))
        if len(y) > 1:
            leg.append(plt.gca().legend(lss[xx], x, loc='upper center', bbox_to_anchor=(xx-0.25,locs[0]-0.75*dloc, 0.5, 0.1), bbox_transform=plt.gca().transData))
            xx += 1
    ax = plt.gca()
    [ax.add_artist(l) for l in leg]
    ax.set_title(title, size='large', weight='bold')
    ax.set_ylabel(ylabel, weight='bold')

    plt.savefig(ofile, bbox_inches='tight')


# Parse input arguments
def parse_args(parser):
    parser.add_argument("--ipath", dest='ipath', type=str, help="Path to input data.")
    parser.add_argument("-o", "--outpath", default='', type=str, help="Comma-separated list of input files. (The first file will be the reference)")
    parser.add_argument("--op", default='mse', type=str, help="What statistic should be used to summarise the added value (mse, corr, bias, var, commbias)")
    parser.add_argument("--gdds", nargs='?', help="Comma-separated list of input driving models (e.g. ACCESS1-0)")
    parser.add_argument("--varnames", nargs='?', help="Comma-separated list of input variable names (in the order of gdd, rcm, obs)")
    parser.add_argument("--yrStart", type=int, help="Year to start processing.")
    parser.add_argument("--yrEnd", type=int, help="Year to end processing.")
    parser.add_argument("--quantiles", dest='quantiles', type=str, nargs='?', help="Quantiles to calculate added value for.")
    parser.add_argument("--seasons", nargs='?', default='annual', help="Comma-separated list of seasons (annual, DJF, etc.)")
    parser.add_argument("--interp_method", dest='interp_method', type=str, default="nearest", help="Interpolation method used to interpolate to high-res")
    parser.add_argument("--resolution", dest='resolution', type=str, default='', help="Resolution (i.e. 0p05deg or 0p11deg)")
    parser.add_argument("--prefix", dest='prefix', type=str, default='', help="Prefix for output files")
    parser.add_argument("--project", dest='project', type=str, default='', help="Project (e.g. barpa, narclim) used for filename")
    parser.add_argument("--regions", dest='regions', type=str, default='', help="Regions input file.")
    parser.add_argument("--debug", dest='debug', type=lav.str2bool, const=True, nargs='?', default=False, help="Debugging plots")
    return parser.parse_args()


def main():

        #< Increase garbage threshold
        g0, g1, g2 = gc.get_threshold()
        gc.set_threshold(g0 * 3, g1 * 3, g2 * 3)

        # User argument input
        parser    = argparse.ArgumentParser(description='Plot some overview plots of the added value analysis.')
        args      = parse_args(parser)
        ipath     = args.ipath
        gdds      = list(filter(None, args.gdds.split(",")))
        varnames  = list(filter(None, args.varnames.split(",")))
        outpath   = args.outpath
        op        = args.op
        yrStart   = args.yrStart
        yrEnd     = args.yrEnd
        quantiles = [i for i in list(filter(None, args.quantiles.split(",")))]
        seasons   = list(filter(None,args.seasons.split(",")))
        interp_method = args.interp_method
        res         = args.resolution
        prefix    = args.prefix
        project   = args.project
        ifile_regions = args.regions
        l_debug_first = args.debug

        ifiles_dummy = ipath + '/' + 'X.{}_{}.{}.0p11deg.q{}.{}.{}-{}.interp_{}.nc'
        oplot  = outpath + '/' + prefix + '.boxplot.added_value.{}.{}.q{}.EASTAUS.{}.{}.png'


        #< Read the regions files
        print('Read in the added value regions definition...')
        print(ifile_regions)
        regions = xr.load_dataset(ifile_regions)['regions']
        regions['lat'] = regions['lat'].astype('float32')
        regions['lon'] = regions['lon'].astype('float32')


        qDummy  = {}
        for gdd in gdds:
            varDummy  = {}
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

                seasonDummy  = {}
                for var in varnames:


                    #< read data
                    ifiles      = ifiles_dummy.format(project, gdd, var, qstr, '{}', yrStart, yrEnd, interp_method)
                    print(ifiles)
                    X           = {}
                    regionDummy = {}
                    for season in seasons:
                        avs     = {}
                        for region in ['coast', 'topo', 'flat']:
                            if region == 'coast':
                                iregion = 1
                            elif region == 'topo':
                                iregion = 2
                            elif region == 'flat':
                                iregion = 3

                            for model in ['obs', 'gdd', 'rcm']:
                                for res in ['LR', 'HRd']:
                                    ifile = ifiles.format(season)
                                    X[model, res] = xr.open_dataset(ifile)['{}{}'.format(model,res)]

                            # #< Just for testing the script!!!!
                            # ##################################
                            # # RCM = GDD -> AV = 0
                            # # X['rcm', 'LR']  = X['gdd', 'LR']
                            # # X['rcm', 'HRd'] = X['gdd', 'HRd']
                            # # RCM = OBS -> AV = 1
                            # # X['rcm', 'LR']  = X['obs', 'LR']
                            # # X['rcm', 'HRd'] = X['obs', 'HRd']
                            # # RCM = (GCM + OBS) / 2 -> AV = 0.6
                            # X['rcm', 'LR']  = (X['obs', 'LR'] + X['gdd', 'LR']) / 2.
                            # X['rcm', 'HRd'] = (X['obs', 'HRd'] + X['gdd', 'HRd']) / 2.
                            # ##################################

                            #< Cut overlap
                            regions, X['obs', 'LR'], X['obs', 'HRd'], X['gdd', 'LR'], X['gdd', 'HRd'], X['rcm', 'LR'], X['rcm', 'HRd'] = lav.cut_overlap(regions, X['obs', 'LR'], X['obs', 'HRd'], X['gdd', 'LR'], X['gdd', 'HRd'], X['rcm', 'LR'], X['rcm', 'HRd'], dims=['lat', 'lon'])

                            #< Group by region
                            lav.check_coordinates_match(regions, X['obs', 'LR'], X['obs', 'HRd'], X['gdd', 'LR'], X['gdd', 'HRd'], X['rcm', 'LR'], X['rcm', 'HRd'], dims=['lat','lon'])
                            X_dict = {'obsLR': X['obs', 'LR'].where(regions==iregion),   'gddLR': X['gdd', 'LR'].where(regions==iregion),   'rcmLR': X['rcm', 'LR'].where(regions==iregion),
                                      'obsHRd': X['obs', 'HRd'].where(regions==iregion), 'gddHRd': X['gdd', 'HRd'].where(regions==iregion), 'rcmHRd': X['rcm', 'HRd'].where(regions==iregion)}

                            if l_debug_first:
                                plt.figure()
                                X_dict['obsLR'].plot.pcolormesh()
                                plt.figure()
                                X_dict['obsHRd'].plot.pcolormesh()
                                plt.figure()
                                X_dict['gddLR'].plot.pcolormesh()
                                plt.figure()
                                X_dict['gddHRd'].plot.pcolormesh()
                                plt.figure()
                                X_dict['rcmLR'].plot.pcolormesh()
                                plt.figure()
                                X_dict['rcmHRd'].plot.pcolormesh()
                                plt.show()


                            #< Select the operation in which added value is measured
                            if op == 'mse':
                                avs[region] = addedValueStatMSE(X_dict)
                            elif op == 'corr':
                                avs[region] = addedValueStatCorr(X_dict)
                            elif op == 'bias':
                                avs[region] = addedValueStatBias(X_dict)
                            elif op == 'var':
                                avs[region] = addedValueStatStd(X_dict)
                            elif op == 'commbias':
                                avs[region] = corrCommonBias(X_dict)

                            print(q, var, season, region)
                            print(avs[region].values)
                        l_debug_first = False



            #< Combine the added values in dictionaries and convert to xarray in the end
                        regionDummy[season] = xr.concat([avs[key] for key in avs], dim=pd.Index(avs.keys(), name='region'), coords='minimal')
                    seasonDummy[var] = xr.concat([regionDummy[key] for key in regionDummy], dim=pd.Index(regionDummy.keys(), name='season'), coords='minimal')
                varDummy[q] = xr.concat([seasonDummy[key] for key in seasonDummy], dim=pd.Index(seasonDummy.keys(), name='var'), coords='minimal')
            qDummy[gdd] = xr.concat([varDummy[key] for key in varDummy], dim=pd.Index([str(k) for k in varDummy.keys()], name='q'), coords='minimal')
        avs = xr.concat([qDummy[key] for key in qDummy], dim=pd.Index(qDummy.keys(), name='gdd'), coords='minimal')


        #< Calculate mean over every other dimension
        avsregion = avs.mean(['var', 'q', 'season', 'gdd']).to_dict()
        avsseason = avs.mean(['var', 'q', 'region', 'gdd']).to_dict()
        avsvar    = avs.mean(['region', 'q', 'season', 'gdd']).to_dict()
        avsq      = avs.mean(['var', 'region', 'season', 'gdd']).to_dict()
        avsgdd    = avs.mean(['var', 'region', 'season', 'q']).to_dict()

        #< Combine in dict
        regionDummy = dict(zip(avsregion['coords']['region']['data'], avsregion['data']))
        seasonDummy = dict(zip(avsseason['coords']['season']['data'], avsseason['data']))
        varDummy    = dict(zip(avsvar['coords']['var']['data'], avsvar['data']))
        qDummy      = dict(zip(avsq['coords']['q']['data'], avsq['data']))
        gddDummy    = dict(zip(avsgdd['coords']['gdd']['data'], avsgdd['data']))


        #< Select the operation in which added value is measured
        if op == 'mse':
            title  = 'Added value (MSE) summary'
            ofile  = oplot.format('av.mse.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'AV'
        elif op == 'corr':
            title  = 'Added value (Corr) summary'
            ofile  = oplot.format('av.corr.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'AV'
        elif op == 'bias':
            title  = 'Added value (Bias) summary'
            ofile  = oplot.format('av.bias.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'AV'
        elif op == 'var':
            title  = 'Added value (Standard deviation) summary'
            ofile  = oplot.format('av.variance.summary', '{}', '{}', '{}', '{}').replace('.{}','').replace('.q{}','')
            ylabel = 'AV'
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
