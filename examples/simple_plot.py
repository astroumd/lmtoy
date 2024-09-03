#! /usr/bin/env python
#
#   a simple matplotlib plot - testing for pipelines
#
_version = "3-sep-2023"

import os
import sys

import numpy as np
import matplotlib.pyplot as plt


if __name__ == "__main__":
    x = np.arange(0,2,0.1)
    y = np.sqrt(x)

    plt.figure()
    plt.plot(x,y, label="test");
    plt.legend()
    plt.show()
    fn = 'simple_plot.png'
    plt.savefig(fn)
