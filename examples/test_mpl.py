#! /usr/bin/env bash
#
#   this reports the matplotlib backend with and without $DISPLY

python -c 'import matplotlib; print(matplotlib.matplotlib_fname())'
echo "DISPLAY: $DISPLAY"
python -c 'import matplotlib; print(matplotlib.get_backend())'
unset DISPLAY
python -c 'import matplotlib; print(matplotlib.get_backend())'

