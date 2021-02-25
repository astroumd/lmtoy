#! /usr/bin/env python
#
#

import sys

def blanking(filename):
    """   blanking rules       obsnum,chassis,bank
    """
    def to_obslist(obsnums, to_list=False):
        """  convert  a,b,c  or a-b to a python string for exec()
        """
        dash = obsnums.find('-')
        if dash > 0:
            o1 = int(obsnums[:dash])
            o2 = int(obsnums[dash+1:])+1
            if to_list:
                obslist = 'list(range(%d,%d))' % (o1,o2)
            else:
                obslist = 'range(%d,%d)' % (o1,o2)
        else:
            obslist = '[%s]' % obsnums
        return obslist

    win = {}
    exec('windows={}', win)
    obslist = []
    blanks = []
    lines = open(filename)
    for line in lines:
        if line[0] == '#':
            continue
        line = line.strip()
        if line.find('windows[') == 0:
            exec(line, win)
            continue
        w = line.split()
        if len(w) == 0:
            continue
        if len(w) == 1:
            # accumulate obslist
            o = to_obslist(w[0], True)
            d = {}
            exec('x=%s' % o, d)
            # print("OBSLIST",d['x'])
            obslist = obslist + d['x']
            continue
        #print("B:",line)
        obsnum = w[0]
        chassis = int(w[1])
        #print("CHASSIS: ",chassis)
        dash = obsnum.find('-')
        if dash > 0:
            o1 = int(obsnum[:dash])
            o2 = int(obsnum[dash+1:])
            obsnums = 'range(%d,%d)' % (o1,o2)
        else:
            obsnums = '[%s]' % obsnum
        #print("OBSNUMS: " , obsnums)

        if len(w) == 2:
            bands = '{}'
        else:
            bands = ' '.join(w[2:]).replace(' ','').replace('}{',',')
        #print("BANDS: ", bands)

        d = {}
        exec('x=%d' % chassis, d)
        exec('y=%s' % obsnums, d)
        exec('z=%s' % bands,   d)
        print('BLANK',d['x'], d['y'], d['z'])
        blanks.append([d['x'], d['y'], d['z']])

    windows = win['windows']        

    print("Found %d blanking lines" % len(blanks))
    print("Found %d obsnums" % len(obslist))
    print("Found %d windows for baselining" % len(windows))

    return (obslist,blanks,windows)


if __name__ == '__main__':    

    (obslist,blanks,windows) = blanking(sys.argv[1])

    if len(sys.argv) > 2:
        for b in blanks:
            print('B',b[0],b[1],b[2])

        for i in obslist:
            print('O',i)

        for w in windows.keys():
            print('W',w,windows[w])
