#! /usr/bin/env python
# 
# hardcoded badchannels
#
# this is like badlags.py - but now completely manually where you
# specificy both the bad Chassis/Board/Channel's, as well as
# the bad Chassis/Board on the command line
#
# Example use:
#       badlags2.py 12345  0/0/10 0/0/40 2/4/110  1/1 3/5   >  rsr.12345.badlags
#       rsr_badcb -r rsr.12345.badlags > rsr.12345.rfile 
#       rsr_badcb -b rsr.12345.badlags > rsr.12345.blanking
#

import os
import sys
import numpy as np
from docopt import docopt

if len(sys.argv) == 1:
    print("Usage: %s obsnum C/B/ch ...   C/B" % sys.argv[0])
    print("E.g.      badlags2.py 12345  0/0/10 0/0/40 2/4/110  1/1 3/5")
    sys.exit(0)

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
    
