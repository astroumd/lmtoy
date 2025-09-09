#!/usr/bin/env python
# Script to plot LMT dataverse statistics
import argparse
import requests
import sys
import matplotlib.pyplot as plt
import numpy as np
from astropy.table import Table

headers = { 'Accept': 'application/json'} 
url = "https://dp.lmtgtm.org/api/info/metrics"
parser = argparse.ArgumentParser(prog=sys.argv[0])
parser.add_argument("--plot",    "-p", action="store_true",  help="Plot the results")
parser.add_argument("--debug",   "-d", action="store_true",  help="debug mode")
parser.add_argument("--monthly",   "-m", action="store_true",  help="compute monthly (differential) stats.")
parser.add_argument("--file",   "-f", action="store",  help="output file")
args=parser.parse_args()

# cumulative monthly downloads
# number of objects in collection per month
# number of files in collection per month
keys = ["downloads", "datasets", "files"]
results = dict.fromkeys(keys)
diff = dict.fromkeys(keys)
date = dict.fromkeys(keys)
count = dict.fromkeys(keys)

headers = {"Accept":"application/json"}
for k in keys:
    r= requests.get(f"{url}/{k}/monthly",headers=headers)
    if r.status_code != 200:
        raise Exception(f"Didn't get acceptable response for {k}: {r}")

    results[k] = r.json()
    #if args.monthly:
    ary = results[k]
    date[k] = [ary['data'][x]['date'] for x in range(len(ary['data']))]
    count[k] = np.array([ary['data'][x]['count'] for x in range(len(ary['data']))])
    diff[k] = count[k][1:]-count[k][:-1]
    # first entry in diffs should be count[0]-0 = count[0]
    diff[k] = np.insert(diff[k],0,count[k][0])
    if args.debug: 
        print(f"{results[k]=}")
        print(f"{date[k]=}")
        print(f"{count[k]=}")
        print(f"{diff[k]=}")
if args.file:
    dv = [list(date.values()) for k in date]
    cv = [list(count.values()) for k in count]
    fv = [list(diff.values()) for k in diff]
    cols = []
    for i in range(len(dv)):
        cols.extend([dv[i],cv[i],fv[i]])
    if args.debug:
       print(f"{cols=}")


if args.plot:
    figure,ax=plt.subplots(figsize=(8,6))
    width=0.25
    multiplier=0
    xaxis = None
    for key in results:
        if xaxis is None:
            xaxis=np.arange(len(date[k]))
        #rect=ax.bar(xaxis+width*multiplier,count[key],width=width,label=key)
        ax.plot(xaxis,count[key],label=f"{key} cumulative")
        if args.monthly:
            rect2=ax.bar(xaxis+width*multiplier,diff[key],width=width,label=f"{key} monthly")
        multiplier=multiplier+1
        #ax.bar_label(rect,date,padding=3)
    ax.set_xticks(xaxis+width,date[k])
    ax.legend()
    plt.title("Download statistics for LMT dataverse")
    plt.show()
#
