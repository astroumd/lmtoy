#! /usr/bin/env python
# 
# hardcoded badchannels
#

import os
import sys
import numpy as np
from docopt import docopt

obsnum = sys.argv[1]
print("# c b ch obsnum metric")
print("#  hardcoded badlags2 for obsnum=%s" % obsnum)

# c/b/ch1,ch2,ch3,....
for arg in sys.argv[2:]:
    cbl = arg.split('/')
    if len(cbl) == 3:
        c = cbl[0]
        b = cbl[1]
        channels = cbl[2].split(',')
        for ch in channels:
            print("%s %s %s %s 99.9" % (c,b,ch,obsnum))
    elif len(cbl) == 2:
        c = cbl[0]
        b = cbl[1]
        print("#BADCB %s %s %c 0" % (obsnum,c,b))
    
