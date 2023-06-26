#! /usr/bin/env bash
#
#   this reports the matplotlib backend with and without $DISPLY

echo "DISPLAY: $DISPLAY"
python -c 'import matplotlib; print(matplotlib.get_backend())'
unset DISPLAY
python -c 'import matplotlib; print(matplotlib.get_backend())'
