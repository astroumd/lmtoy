#! /usr/bin/env python
#
#  phase2.py   - get LMTOY information about 

import sys
import pandas as pd

xlsx = 'LMT_2024-S1-MX-24_phase2.xlsx'

xlsx = sys.argv[1]
source = sys.argv[2]
df1 = pd.read_excel(xlsx,sheet_name='Targets')

keys = ['Source Name',                     # 
        'SOURCE VELOCITY',                 # vlsr
        'INSTRUMENT',                      # instrument
        'Obs. Mode',                       # 'OTF'   'PS'
        'Line Rest Frequency',             # restfreq
        'Line Width',                      # dv
        'Line Spectrometer Mode',          # 200MHz  (later: bandwidth in GHz)
        'Spectrometer Mode',               # WIDE, ...
        '2nd Line Frequency',
        '2nd Line Width',
        '2nd Line Spectrometer Mode',      # is this always the same as 1st
        'X MAP LENGTH',                    # x_extent
        'Y MAP LENGTH',                    # y_extent
        'SCAN COORDS']                     # map_coord

for k in keys:
    print(df1[k][1:])
