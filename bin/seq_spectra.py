#! /usr/bin/env python
#  template script written by NEMO::pytable
#
_version = "1-aug-2023"

_help = """Usage: seq_spectra.py [options] TABLE [TABLE ...]

Options:
  -y PLOTFILE             Save plotfile instead of interactive. Optional
  -h --help               This help
  -d --debug              Add debugging
  -v --version            The script version

Multiple tables can be given.

"""


import sys
import numpy as np
from docopt import docopt

av = docopt(_help, options_first=True, version='seq_spectra.py %s' % _version)
if av['--debug']:
    print(av)


plotfile = av['-y']    
tables = av['TABLE']
n = 0

#import matplotlib
#matplotlib.use('svg')
import matplotlib.pyplot as plt

plt.figure()

for f in tables:
    n = n + 1
    data1 = np.loadtxt(f).T
    plt.step(data1[0],data1[1],label=f, where='mid')

if n==0:
    sys.exit(0)
plt.xlabel('VLSR (km/s)')
plt.ylabel('Ta (K)')
#plt.ylim([0,1])
#  @todo plot between +/- 5 sigma or so
#plt.ylim([-0.01,0.01])
plt.title('SEQ Bs spectra')
plt.legend()
if plotfile == None:
    plt.show()
else:
    plt.savefig(plotfile)
    print("%s writtten" % plotfile)
