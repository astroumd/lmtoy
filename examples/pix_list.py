#! /usr/bin/env python
#
#
import os
import sys

# in prep of the new lmtoy module
try:
    lmtoy = os.environ['LMTOY']
    sys.path.append(lmtoy + '/lmtoy')
    import runs
except:
    print("No LMTOY with runs.py")
    sys.exit(0)

    
if len(sys.argv) == 1:
    print("0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")
    sys.exit(0)

    
    
pl=sys.argv[1]

if pl == '-h' or pl == '--help':
    print("Construct a pix_list with beams taken out, e.g. use -4,5,6")
    print("which takes out beams 4,5 and 6 from the default 0..15 list")
    sys.exit(0)

pl = runs.pix_list(pl)
print(pl)
sys.exit(0)

    

bl = list(range(1,17))

if pl[0] == '-':
    # assume they're all < 0
    beams = pl.split(',')
    for b in beams:
        bl[abs(int(b))] = 0
    msg = ''
    for i in range(len(bl)):
        b = bl[i]
        if b > 0:
            if len(msg) > 0:
                msg = msg + ",%d" % i
            else:
                msg = "%d" % i
    print(msg)
else:
    print("need - as first character to negate the beams")
