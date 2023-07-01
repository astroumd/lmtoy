#! /usr/bin/env python
#
#  Recursive data (file) finder
#
#  command line usage:
#
#      fdr [-r] [-m MAXFILES] file [path1 path2 ...]
#
#  Shell alternative:
#
#  find . -name \*$a\* -print


import os
import sys
import glob

_debug = True



def fdr(filename, path=None, recursive=False, wildcard=False, maxfiles=None):
    """
    Input:
        filename - can be wildcard
        path - optional. can be : separated, can start with $ if envvar
        recursive - recursively search: Default: False
        wildcard - automatically wildcard the filename
        maxfiles - maximum number of files to be returns. Default: All

    Returns:
        list of found filenames,  with maxfiles entry if applicable.
        Note list could be empty.

    See also?
        astropy's getdata ???  
        pdrptry.pdrutils.get_testdata()
        astropy.utils.data.get_pkg_data_filenames
    
    Examples:

        fdr('ngc1234.fits')    - this exact file!
        fdr('*.fits')          - all fits file in this directory
        fdr('ngc1234.fits','/tmp')  - this file in /tmp
        fdr('*.fits','/tmp')        - all fits files in /tmp
        fdr('ngc1234.fits','$DYSH_DATA_PATH')
        fdr('ngc1234.fits','$DYSH_DATA_PATH', True)
        fdr('ngc1234.fits','$DYSH_DATA_PATH:/data/gbt')
    """
    if os.path.exists(filename):
        return [filename]

    if path == None:
        if wildcard:
            fname = '*' + filename + '*'
        else:
            fname = filename
        if _debug:
            print('# FNAME:',fname)

        if recursive:
            fn = glob.glob('**/' + fname, recursive=recursive)        
        else:
            fn = glob.glob(fname, recursive=recursive)

        if maxfiles == None:
            return fn
        else:
            return fn[:maxfiles]
    else:
        print("# Warning: -p not yet implemented")
        all=[]
        for p in path.split(':'):
            if _debug:
                print('# DATA1',p)
            if p[0] == '$':
                if p[1:] in os.environ:
                    p = os.environ[p[1:]]
                else:
                    print("# Warning: %s not in the environment" % p)
            if not os.path.exists(p):
                print("# Warning: directory %s does not exist" % p)
            if _debug:
                print('# DATA2',p)            
        return all


import argparse

my_help = """
This script searches for files, optionally hierarchically,
much like the Unix 'find' program.
A difference is handling the --path directive, as multiple
colon separated paths can be given, much like the $PATH
environment variable in Unix.
The path variable can also expand $-environment variables.
          
"""

p = argparse.ArgumentParser(description=my_help, epilog='And so the search goes on....')
p.add_argument('-m', '--maxfiles', type = int, default = None, help='Maximum number of files to return [Default: all]')
p.add_argument('-c', '--count', action='store_true',           help='add counter to filenames?')
p.add_argument('-w', '--wildcard', action='store_true',        help='fully wildcard the filename embedded')
p.add_argument('-r', '--recursive', action='store_true',       help='resursive?')
p.add_argument('-p', '--path', type = str, default = None,     help='optional (colon separated) path(s)')
p.add_argument('filename', nargs='+',                          help='Filename(s) to search for')


args = p.parse_args()
if _debug:
    print('#', args)
 
filename = args.filename
maxfiles = args.maxfiles
recursive = args.recursive
wildcard = args.wildcard
path = args.path
count = args.count

r = []
for f in filename:
    r.append(fdr(f, path, recursive, wildcard, maxfiles))
r.sort()    

if _debug:
    print("Results:")
if count:
    n=1
    for f in r:
        print(n,f)
        n=n+1
else:
    for f in r:
        print(f)
