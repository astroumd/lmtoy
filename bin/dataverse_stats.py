#!/usr/bin/env python
# Script to plot LMT dataverse statistics
import argparse
import requests
import sys
import matplotlib.pyplot as plt
import numpy as np

headers = { 'Accept': 'application/json'} 
url = "https://dp.lmtgtm.org/api/info/metrics"
parser = argparse.ArgumentParser(prog=sys.argv[0])
parser.add_argument("--plot",    "-p", action="store_true",  help="Plot the results")
parser.add_argument("--debug",   "-d", action="store_true",  help="debug mode")
args=parser.parse_args()

# cumulative monthly downloads
# number of objects in collection per month
# number of files in collection per month
keys = ["downloads", "datasets", "files"]
results = dict.fromkeys(keys)

headers = {"Accept":"application/json"}
for k in keys:
    r= requests.get(f"{url}/{k}/monthly",headers=headers)
    if r.status_code != 200:
        raise Exception(f"Didn't get acceptable response for {k}: {r}")

    results[k] = r.json()
    if args.debug: 
        print(f"{results[k]=}")

args.plot=True
if args.plot:
    figure,ax=plt.subplots(figsize=(8,6))
    width=0.25
    multiplier=0
    xaxis = None
    for key in results:
        ary = results[key]
        date = [ary['data'][x]['date'] for x in range(len(ary['data']))]
        if xaxis is None:
            xaxis=np.arange(len(date))
        count = [ary['data'][x]['count'] for x in range(len(ary['data']))]
        rect=ax.bar(xaxis+width*multiplier,count,width=width,label=key)
        multiplier=multiplier+1
        #ax.bar_label(rect,date,padding=3)
    ax.set_xticks(xaxis+width,date)
    ax.legend()
    plt.title("Cumulative statistics for LMT dataverse")
#