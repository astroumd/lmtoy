#! /usr/bin/env python
#
#   a simple matplotlib plot - testing for pipelines
#
#   setting the backend:
#     1.  rcParams["backend"] parameter in your matplotlibrc file
#     2.  The MPLBACKEND environment variable
#     3.  The function matplotlib.use()
#
_version = "3-sep-2023"

import os
import sys
import numpy as np

if len(sys.argv) > 1:
    _mode = int(sys.argv[1])
    plotfile = 'simple_plot.png'
else:
    _mode = 0
    plotfile = None

import matplotlib
if 'MPLBACKEND' in os.environ:
    print('$MPLBACKEND :',os.environ['MPLBACKEND'])
    matplotlib.use(os.environ['MPLBACKEND'])          # isn't this redundant?
else:
    print("no $MPLBACKEND used")
    if _mode == 0:
        matplotlib.use('qt5agg')
    else:
        matplotlib.use('agg')
        
import matplotlib.pyplot as plt
print('mpl backend :',matplotlib.get_backend())
        
x = np.arange(0,2,0.1)
y = np.sqrt(x)

plt.figure()
plt.plot(x,y, label="test");
plt.legend()
if plotfile == None:
    plt.show()
else:
    plt.savefig(plotfile)
    print("Wrote",plotfile)
