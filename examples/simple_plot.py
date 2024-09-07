#! /usr/bin/env python
#
#   a simple matplotlib plot:  testing for MPL capabilities
#
#
_version = "7-sep-2023"

_help = """Usage: simple_plot.py [options]

-p --plotfile PLOTFILE  Plot filename, extension is important. Optional.
                        It none given, output should appear on screen.
-b --backend BACKEND    Optional MPLBACKEND to use
-s --show               Show available backends
-d --debug              More debugging output?
-h --help               This help
-v --version            Script version

This script allows you to easily test for matplotlib's
capabilities in terms of picking interactive plotting
vs. creating a plotfile, and selecting a backend
if the default is not sufficient.

By default the script should bring up an interactive plot
and report in the title what backend was used.

One can also set a default backend via an environment variable
      export MPLBACKEND=agg
or your matplotlibrc file (location varies per platform).
Use --debug to see which one you should use.


"""

import os
import sys
import numpy as np
from docopt import docopt


# 1. Grab the command line arguments
av = docopt(_help, options_first=True, version=_version)
_debug = av['--debug']
if _debug:
    print(av)

plotfile = av['--plotfile']
backend = av['--backend']
_mode = -1
    

# 2. MATPLOTLIB settings
import matplotlib
if av['--show']:
    gui_env = [i for i in matplotlib.rcsetup.interactive_bk]
    non_gui_backends = matplotlib.rcsetup.non_interactive_bk
    print ("Non Gui backends are:", non_gui_backends)
    print ("Gui backends I will test for", gui_env)
    sys.exit(0)

if plotfile is not None:
    matplotlib.use('agg')     # use common plotfile capable backend
if backend is not None:
    matplotlib.use(backend)   # unless forced otherwise with --backend
    
import matplotlib.pyplot as plt

if _debug:
    print("Your matplotlibrc file:",matplotlib.matplotlib_fname())
    if 'MPLBACKEND' in os.environ:
        print('$MPLBACKEND :',os.environ['MPLBACKEND'])
    else:
        print("no $MPLBACKEND used")
        
backend = matplotlib.get_backend()
if _debug:
    print('mpl backend :',backend)

    
# 3. Compute and plot        
x = np.arange(0,2,0.1)
y = np.sqrt(x)

plt.figure()
plt.plot(x,y, label="test");
plt.legend()
msg = f"plotfile={plotfile} mode={_mode} backend={backend}"
plt.title(msg)
if plotfile == None:
    plt.show()
else:
    plt.savefig(plotfile)
    print("Wrote",plotfile)
