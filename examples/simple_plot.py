#! /usr/bin/env python
#
#   a simple matplotlib plot - testing for pipelines
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
