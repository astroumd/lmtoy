#! /usr/bin/env python
#
#   a simple matplotlib plot - testing for pipelines
#
#   parent shell can optionally do:
#       export MPLBACKEND=agg
#
_version = "3-sep-2023"
_mode = 0

import os
import sys

import numpy as np
import matplotlib.pyplot as plt


if __name__ == "__main__":
    if len(sys.argv) > 1:
        _mode = int(sys.argv[1])
        plotfile = 'simple_plot.png'
    else:
        _mode = 0
        plotfile = None

    import matplotlib
    if _mode == 0:
        matplotlib.use('qt5agg')
    else:
        matplotlib.use('agg')
    import matplotlib.pyplot as plt
    print('mpl backend spectra',matplotlib.get_backend())
        
    x = np.arange(0,2,0.1)
    y = np.sqrt(x)

    plt.figure()
    plt.plot(x,y, label="test");
    plt.legend()
    if plotfile == None:
        plt.show()
    else:
        plt.savefig(plotfile)
        print("Wrote ",plotfile)
