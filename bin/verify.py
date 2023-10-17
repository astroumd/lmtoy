#! /usr/bin/env python
#

"""
Useful tools to verify pipeline parameters


"""

import os
import sys
import re

_version = "26-sep-2023"

_help = "This program is under development"


def read_rc(rcfile, debug=0):
    """ read an rc file, and make a dictionary, thus eliminating duplicates
        note all rc variables are treated as a string here since they come via bash
        returns the dictionary
    """
    rc = {}
    if debug > 1:
        print("# All keys")
    lines = open(rcfile).readlines()
    for line in lines:
        if line[0] == '#':
            continue
        # [string] = [string with spaces] # comment #> [string] [string]
        # spaces are not allowed in bash key=val
        m = re.match('^([^#]+)\s*=\s*([^#]+).*', line)
        if m:
            key = m.group(1).strip()
            val = m.group(2).strip()
            if len(val) > 0:
                if val[0] != "'" and val[0] != '"':
                    val = '"' + val + '"'
            else:
                val = "''"
            if debug > 1:
                cmd = '%s=%s' % (key,val)
                print(cmd)
                
            rc[key] = val
    if debug > 0:
        print("# Unique keys")
        for k in rc.keys():
            print("%s=%s" % (k,rc[k]))
    return rc

def read_run(runfile, debug=0):
    """ read a run file, and verify all arguments are ok
    """
    lines = open(runfile).readlines()
    for line in lines:
        if line[0] == '#':
            continue
        print(line.strip())
        w = line.split()
        if w[0] != 'SLpipeline.sh':
            print("not an SLpipeline runfile")
        if w[1][:7] != 'obsnum=':
            print("not an SLpipeline runfile with obsnum=")


#verify_listi(val, 0, 16)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print(_help)
        sys.exit(0)
    my_file = sys.argv[1]
    if True:
        read_run(my_file)
    else:
        debug = 0
        rc = read_rc(rcfile,debug)
        print('#', len(rc.keys()))
        if not "instrument" in rc.keys():
            print("not a valid lmtoy rc file?")
            sys.exit(1)
        # src, instrument, obspgm, restfreq
        exec("instrument=%s" % rc['instrument'])
        print(instrument)

