"""
 Purpose: Write html page that contains that outputs of qc_utils.py

 python write_html.py <directory containing fig/ sanity/ stats/ - outputs of qc_util.py>
"""

import os, sys
import numpy as np
import glob

#
# Input
#
workdir = sys.argv[1]
#print(workdir)
# directory containing the fig files produced by qc_util.py
figdir = os.path.join(workdir, 'fig')
#print(figdir)
# output html file
html_outfile = os.path.join(workdir, 'index.html')
# output csv file
csv_outfile = os.path.join(workdir, 'summary.csv')

# figures
files = glob.glob(os.path.join(figdir, '*.png'))
#print(files)
files.sort()

file_container = {}
for file in files:
    bn = os.path.basename(file)
    toks = bn.split("_")
    group = toks[0]
    var = toks[1]
    if not group in file_container.keys():
        file_container[group] = []

    file_container[group].append(bn)

html_out = open(html_outfile,'w')
html_out.write("<html>\n<body>\n")
html_out.write("<a name=\"top\"></a>\n")
for group in file_container.keys():
    html_out.write("<h3><a href=\"#%s\">%s</a></h3>\n" % (group, group))
    html_out.write("<ol start=1>\n")
    for file in file_container[group]:
        toks = file.split("_")
        sanity_file = "sanity/sanity.%s_%s.log" % (toks[0], toks[1])
        stats_file = "stats/stats.%s_%s.log" % (toks[0], toks[1])
        sanity_file0 = os.path.join(workdir, sanity_file)
        sanity_filesize = os.path.getsize(sanity_file0)/1e6
        lines = open(sanity_file0, 'r')
        num_err = np.sum(['ERROR' in line for line in lines])
        if num_err == 0:
            html_out.write("<li><a href=\"#%s\">%s</a> (%3.2f Mb size, %d errors)</li>\n" % (file, file, sanity_filesize, num_err))
        else:
            html_out.write("<li><a href=\"#%s\">%s</a> <font color='red'>(%3.2f Mb size, %d errors)</font></li>\n" % (file, file, sanity_filesize, num_err))
    html_out.write("</ol>\n")

for group in file_container.keys():
    html_out.write("<a name=\"%s\"></a>\n" % group)
    
    for file in file_container[group]:
        toks = file.split("_")
        sanity_file = "sanity/sanity.%s_%s.log" % (toks[0], toks[1])
        stats_file = "stats/stats.%s_%s.log" % (toks[0], toks[1])
        sanity_file0 = os.path.join(workdir, sanity_file)
        sanity_filesize = os.path.getsize(sanity_file0)/1e6
        lines = open(sanity_file0, 'r')
        num_err = np.sum(['ERROR' in line for line in lines])
        html_out.write("<h3>%s</h3>\n" % file)
        html_out.write("<a name=\"%s\"></a>\n" % file)
        html_out.write("<a href=\"%s\" target=\"_blank\">Sanity Check</a> (%3.2f Mb size, %d errors) <br>\n" % (sanity_file, sanity_filesize, num_err))
        html_out.write("<a href=\"%s\" target=\"_blank\">Full statistics</a><br>\n" % (stats_file))
        html_out.write("<div class=\"figure\">\n")
        html_out.write("<img src=\"fig/%s\">\n" % file)
        html_out.write("</div>\n")
        html_out.write("<a href=\"#top\">Top</a>\n")

html_out.write("</body></html>\n")
html_out.close()
print("Written to {:}".format(html_outfile))


# Write to the a csv spreadsheet
csv_out = open(csv_outfile, 'w')
csv_out.write("group,variable,datacode,figfile,sanityfile,statsfile,num_error\n")
for group in file_container.keys():
    for file in file_container[group]:
        toks = file.split("_")
        variable = toks[1]
        sanity_file = "sanity.%s_%s.log" % (toks[0], toks[1])
        stats_file = "stats.%s_%s.log" % (toks[0], toks[1])
        sanity_file0 = os.path.join(workdir, 'sanity', sanity_file)
        sanity_filesize = os.path.getsize(sanity_file0)/1e6
        lines = open(sanity_file0, 'r')
        num_err = np.sum(['ERROR' in line for line in lines])
        if group == '15min':
            freq = '15m'
            suffix = 'n'
        elif group == '10min':
            freq = '10m'
            suffix = 'n'
        elif group == '1hr':
            freq = '1H'
            suffix = 'n'
            if variable in ['tasmean','pr','evspsbl','uasmean','vasmean','clt','rsds','rlds','prc','prsn','rsdsdir','rsus','rlus','rlut','rsdt','rsut','hfls','hfss','evspsblpot','clh','clm','cll','rsdscs','rldscs','rsuscs','rluscs','rsutcs','rlutcs']:
                suffix = 'm'
        elif group == '3hr':
            freq = '3H'
            suffix = 'n'
            if variable in ['mrros','mrro','snm','tauu','tauv']:
                suffix = 'm'
        elif group == '6hr':
            freq = '6H'
            suffix = 'n'
            if variable in ['mrros','mrro','snm','tauu','tauv']:
                suffix = 'm'
        elif group == 'day':
            freq = '1D'
            suffix = 'm'
            if variable == 'sund':
                suffix = 'a'
        elif group == 'mon':
            freq = '1M'
            suffix = 'm'
        if 'max' in variable:
            suffix = 'x'
        elif 'min' in variable:
            suffix = 'i'
        elif 'mean' in variable:
            suffix = 'm'

        datacode = '%s_%s%s' % (variable, freq, suffix) 
        csv_out.write("{:},{:},{:},{:},{:},{:},{:}\n".format(group, variable, datacode, file, sanity_file, stats_file, num_err))

csv_out.close()
print("Written to {:}".format(csv_outfile))

