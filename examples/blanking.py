#! /usr/bin/env python
#
#
# parses an ascii blanking file with obsvlist
#
# See also the --rfile in the rsr_driver.py, of which the format is
# very close to the one used here, but simpler:
#
#       obsnum  chassis  band
#
# whereas here we have
#
#       obsnum  chassis   band:[(f1,f2),(f3,f4]
#
#   

def blanking(filename, debug=False):
    """   Process a file with blanking information.
    
    Each (ascii) line can be of the following format:
    
    windows[N] = [(f1,f2),(f3,f4)]           sections for baselining
    obslist                                  inclusive list
    obslist    chassis                       blanking for this chassis
    obslist    chassis    bank_dict          blanking for this chassis/bank

    where obslist can be "a,b,c" or "a-b" (but not both)

    bank_dict is a (set of) dictionaries, e.g.
          {1: [(70.,100.)]}
          {4: [(95.,111.),]} {5: [(95.,111.),]}
          {4: [(95.,111.),] , 5: [(95.,111.),]}
    
    
    Note that windows, obslist and bank_dict are parsed with the python exec()
    function, so this may result in python syntax errors

    Returns:    (obslist, chassis, banks)

    @todo  could we do without the single obslist lines, and derive the obslist
           from the ones with chassis?
    
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
    for w in [0,1,2,3,4,5]:
        exec('windows[%d]=[]' % w, win)
    obslist = []
    blanks = []
    lines = open(filename)
    for line in lines:
        if line[0] == '#':
            continue
        line = line.strip()
        if line.find('windows[') == 0:           # parse a 'windows[N] = []' line
            exec(line, win)
            continue
        w = line.split()
        if len(w) == 0:                          # blank lines
            continue
        if len(w) == 1:                          # add obslist only line
            o = to_obslist(w[0], True)
            d = {}
            exec('x=%s' % o, d)
            obslist = obslist + d['x']
            continue
                                                 # add obslist,chassis,[band] line
        obsnum = w[0]
        chassis = int(w[1])
        dash = obsnum.find('-')
        if dash > 0:
            o1 = int(obsnum[:dash])
            o2 = int(obsnum[dash+1:])
            obsnums = 'range(%d,%d)' % (o1,o2)
        else:
            obsnums = '[%s]' % obsnum

        if len(w) == 2:
            bands = '{}'
        else:
            #  merge dicts and make one
            bands = ' '.join(w[2:]).replace(' ','').replace('}{',',')

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


#  a small testbed

if __name__ == '__main__':    
    import sys

    (obslist,blanks,windows) = blanking(sys.argv[1])

    if len(sys.argv) > 2:
        for b in blanks:
            print('B',b[0],b[1],b[2])

        for i in obslist:
            print('O',i)

        for w in windows.keys():
            print('W',w,windows[w])
