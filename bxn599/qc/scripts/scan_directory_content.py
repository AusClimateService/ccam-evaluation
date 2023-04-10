"""
 Plots the content of DRS L1 data.
 Usage:
 scan_directory_content.py --path /g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/<gcm>/evaluation/r1i1p1f1/BOM-BARPA-R/v1/<freq>/<variable> --figure_prefix bom_barpa --verbose

 scan_directory_content.py --path /g/data/ia39/australian-climate-service/test-data/CORDEX-CMIP6/output/AUS-15/BOM/<gcm>/<experiment>/r1i1p1f1/BOM-BARPA-R/v1/15min/<variable> --figure_prefix barpa_15min

 Chun-Hsu Su, August 2022
"""

import os, sys
import numpy as np
import glob
from datetime import datetime as dt
from datetime import timedelta as delt
import pandas as pd
from netCDF4 import Dataset, num2date, date2num
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import nc_time_axis
import argparse

# interval as per how the files are organised.
# For BARPA, it is always monthly, all set to monthly
_INTERVAL_MAX = {'mon': 31*24,
        'day': 31*24, #1*24,
        '3hr': 31*24,
        '6hr': 31*24, #0.25*24,
        '1hr': 31*24, #1,
        '15min': 31*24, #0.25,
        '10min': 31*24} #0.17}
# Group all the variables into one plot
_DEFAULT_GROUP = 1
# Line color
_DEFAULT_COLOR = 'k'
_ERROR_COLOR = 'r'
_LINESTYLE = 'o-'

# Methods
def get_file_times(files):
    """
    Returns the values of the time stamps in all the files.
    It reads in the "time" variable in the netcdf files.
    """
    file_starts = []
    file_ends = []

    freq = None
    for file in files:
        if freq is None:
            freq = os.path.basename(file).split("_")[-2]

        fid = Dataset(file, 'r')
        tstart = num2date(fid.variables['time'][0], fid.variables['time'].units)
        tend = num2date(fid.variables['time'][-1], fid.variables['time'].units)
        fid.close()
        
        file_starts.append(tstart)
        file_ends.append(tend)

    return file_starts, file_ends, freq

def get_file_times_fast(files):
    """
    Returns the values of the time stamps in all the files.

    This implementation is based on the timestamp in the
    filename. It is a faster implementation than looking
    at the "time" values in the individual files.
    """
    file_starts = []
    file_ends = []

    freq = None
    for file in files:
        if freq is None:
            freq = os.path.basename(file).split("_")[-2]

        bn = os.path.basename(file)
        toks = os.path.splitext(bn)[0].split("_")
        tstart = toks[-1].split("-")[0]
        tend = toks[-1].split("-")[1]
        assert len(tstart) <= 10, "Time format in filename must be either %Y%m(%d%H)"
        if len(tstart) == 6:
            timeformat = "%Y%m"
        elif len(tstart) == 8:
            timeformat = "%Y%m%d"
        elif len(tstart) == 10:
            timeformat = "%Y%m%d%H"
        tstart = dt.strptime(tstart, timeformat)
        tend = dt.strptime(tend, timeformat)

        file_starts.append(tstart)
        file_ends.append(tend)

    return file_starts, file_ends, freq

def get_continuous_timespans(file_starts, file_ends, freq):
    """
    Identify continuous periods in the time array.
    """
    tdiff_thres = _INTERVAL_MAX[freq]
    time_start_spans = [file_starts[0]]
    time_end_spans = []
    N = len(file_starts)
    for i in range(1,N):
        # if the time gap between the current file and the last file is more than
        # what is sensible, we have a break
        tdiff = (file_starts[i] - file_ends[i-1]).days * 24
        if tdiff > tdiff_thres:
            time_end_spans.append(file_ends[i-1])
            time_start_spans.append(file_starts[i])

    time_end_spans.append(file_ends[-1])

    return time_start_spans, time_end_spans

def printmsg(text, verbose=True):
    if verbose:
        print(text)
    return

#-----------------
# Main
#-----------------
if __name__ == "__main__":

    # Get the input arguments
    parser =  argparse.ArgumentParser(description='Scan through the filesystem and plots the time range of each set of Level 1 DRS files')
    parser.add_argument("--path", nargs='?', required=True, help='Path to the target directory. Use <...> in the path to identify multiple subdirectories to scan through')
    parser.add_argument("--figure_prefix", nargs='?', required=True, help='Prefix to the output figure files')
    parser.add_argument("--outdir", nargs="?", required=True, help="Output directory for the figures and html")
    parser.add_argument("--html", nargs="?", help='Path to the new html page to display the figure')
    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()
    path = args.path
    outpng_prefix = args.figure_prefix

    # Create outpu directory
    if not os.path.exists(os.path.join(args.outdir, 'fig')):
        os.makedirs(os.path.join(args.outdir, 'fig'))

    # Identify the levels for branching the levels
    toks = path.split("/")
    _BRANCH_INDICES = [i for i in range(len(toks)) if '<' in toks[i] and '>' in toks[i]]
    _BRANCH_LABELS = [toks[i] for i in _BRANCH_INDICES]
    toks_wild = toks
    for index in _BRANCH_INDICES:
        toks_wild[index] = "*"
    path_wild = "/".join(toks_wild)

    _BRANCH_TOPLABEL = "/".join(_BRANCH_LABELS[:-_DEFAULT_GROUP])
    _BRANCH_SUBLABEL = "/".join(_BRANCH_LABELS[-_DEFAULT_GROUP:])
    
    # Get all the matching files
    files = glob.glob(os.path.join(path_wild, '*.nc'))
    printmsg("Number of files found: {:}".format(len(files)), args.verbose)

    # Gather the LISTING of the files, add to the LISTING dictionary
    nlevel = len(_BRANCH_INDICES)
    LISTING = {}
    for file in files:
        toks = file.split("/")
        levels = []
        for ilevel in range(nlevel):
            levels.append(toks[_BRANCH_INDICES[ilevel]])
        levelname = "/".join(levels)
        if not levelname in LISTING.keys():
            LISTING[levelname] = {'files': []}
        LISTING[levelname]['files'].append(file)

    # Sort the file and work out periods of continuous data
    for levelname in LISTING.keys():
        printmsg("Doing {:}".format(levelname), args.verbose)
        LISTING[levelname]['files'].sort()
        files = LISTING[levelname]['files']

        # Get the time range for each group of files
        file_starts, file_ends, freq = get_file_times_fast(files)
        # Work out all the periods of continuous data and thus
        # identify any gaps in the data
        span_starts, span_ends = get_continuous_timespans(file_starts, file_ends, freq)
        LISTING[levelname]['span_starts'] = span_starts
        LISTING[levelname]['span_ends'] = span_ends

    # Group the listing, each group will be plotted on the same figure
    PLOT_GROUP = {}
    for levelname in LISTING.keys():
        toks = levelname.split("/")
        key = "/".join(toks[:-_DEFAULT_GROUP])
        if not key in PLOT_GROUP.keys():
            PLOT_GROUP[key] = []
        PLOT_GROUP[key].append(levelname)

    for key in PLOT_GROUP.keys():
        PLOT_GROUP[key].sort()

    # Start plotting
    FIGURES = {}
    for key in PLOT_GROUP.keys():
        N = len(PLOT_GROUP[key])

        # Plotting one figure per group
        fig = plt.figure(figsize=(10,int(N/3)))
        ax = plt.subplot()
        ax.xaxis.set_minor_locator(mdates.YearLocator(base=1))
        ax.xaxis.set_major_locator(mdates.YearLocator(base=2))
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y'))
        ax.set_title("{:} = {:}".format(_BRANCH_TOPLABEL, key))
        ax.set_ylabel(_BRANCH_SUBLABEL)
        names = []
        for i, levelname in enumerate(PLOT_GROUP[key]):
            toks = levelname.split("/")
            name = "/".join(toks[-_DEFAULT_GROUP:])
            names.append(name)
            M = len(LISTING[levelname]['span_starts'])
            color = (_DEFAULT_COLOR if M == 1 else _ERROR_COLOR)
            for start, end in zip(LISTING[levelname]['span_starts'], LISTING[levelname]['span_ends']):
                ax.plot([start, end], [i,i], _LINESTYLE, color=color)
                printmsg("{:}: periods: {:} to {:}".format(levelname, start, end), args.verbose)

        #xticklabels = ax.get_xticklabels()
        #ax.set_xticklabels(xticklabels, rotation=45)
        ax.set_yticks(range(N))
        ax.set_yticklabels(names) #, fontdict={'horizontalalignment': 'left'})
        ax.set_ylim([-1, N])
        ax.invert_yaxis()
        ax.grid(True)
        plt.tight_layout()
        outpng_basename = "%s.%s.png" % (outpng_prefix, key.replace("/","_"))
        outpng = os.path.join(args.outdir, 'fig', outpng_basename)
        plt.savefig(outpng)
        plt.close()
        printmsg("Written to {:}".format(outpng), args.verbose)
        FIGURES[key] = outpng_basename

if args.html is not None:
    html_outfile = os.path.join(args.outdir, args.html)
    html_out = open(html_outfile, "w")
    html_out.write("<html>\n<body>\n")
    html_out.write("<h1>Content of %s</h1>\n" % args.path.replace("<", "&lt").replace(">","&gt"))
    html_out.write("<h5>Last update: {:}</h5>\n".format(dt.now()))
    html_out.write("<a name=\"top\"></a>\n")
    html_out.write("<ol start=1>\n")
    for key in FIGURES.keys():
        outpng = FIGURES[key]
        html_out.write("<li><a href=\"#%s\">%s</a>\n" % (outpng, key.replace("/", " > ")))
    html_out.write("</ol>\n")

    for key in FIGURES.keys():
        outpng = FIGURES[key]
        html_out.write("<h3>%s</h3>\n" % key.replace("/", " > "))
        html_out.write("<a name=\"%s\"></a>\n" % outpng)
        html_out.write("<div class=\"figure\">\n")
        html_out.write("<img src=\"fig/%s\">\n" % outpng)
        html_out.write("</div>\n")
        html_out.write("<a href=\"#top\">Top</a>\n")


html_out.write("</body></html>\n")
html_out.close()
print("Written to {:}".format(html_outfile))



