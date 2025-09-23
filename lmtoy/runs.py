#   tools useful for the script generator (usually called mk_runs.py)
#
#   pix_list(pl)
#

"""
Useful tools for the LMTOY script generators (lmtoy_$PID)

   pix_list(pl, maxbeam=16)
   getpars(on)
   getargs(obsnum, pars4)
   mk_runs(project, on, pars1, pars2, pars3, argv=None)

"""

import os
import sys

_version = "23-sep-2025"

class IO(object):
    """
    class managing what Instrument/Obsmode a particular obsnum has
    Although the lmtinfo.py could be used, it is too slow, and it
    is better (?) to use a caching version in the script generator.
    It uses a file IO, which either has a single line with the IO,
    or many lines with  "IO obsnum" on a line

    An alternative is to read the local lmtinfo.txt where columns 2,3,5
    contain the info, e.g.
    2024-07-26T11:11:12   120096  SEQ        Science      Map(Az/C)   A262_2

    The slow alternative is to read the full $DATA_LMT/data_lmt.log
    """
    def __init__(self):
        try:
            fp = open("IO")
            lines = fp.readlines()
            for line in lines:
                if line[0] == '#': continue
                # hack: first line
                self.io = line.strip()
        except:
            # failing.... make it "TBD"
            print("Warning:  no IO file present with the Instrument/Obsgoal")
            self.io = "TBD"
    def getio(self, obsnum):
        # hack: all the same
        return self.io

def pix_list(pl):
    """ convert a strong like "-0,-1" to proper pixlist by removing
        0 and 1 from the 0..15 list.
        Note:   if the first character is a '-', all numbers are in removed list
                if not, the list is passed "as is",   so e.g.     "0,1,-2" would be wrong
    """
    if pl[1:].find('-') >= 0 or pl[1:].find('+') >= 0:
        print(f"Warning: only first sign in pix_list={pl} counts")
    if pl[0] == '-':
        bl = list(range(1,17))
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
        return msg
    else:
        # @todo there is no check if there are -beams in this list
        return pl


def getpars(on):
    """ get SLpipeline parameters from comments.txt after the '#' symbol
        [obsnum.args was deprecated in nov-2022]
    """
    pars4 = {}
    pars5 = {}
    if os.path.exists("obsnum.args"):
        print("ERROR: obsnum.args is deprecated, please use comments.txt now")
        sys.exit(1)

    if os.path.exists("comments.txt"):
        lines = open("comments.txt").readlines()
        for line in lines:
            if line[0] == '#': continue
            idx = line.find('QAFAIL')
            if idx > 0:
                extra='qagrade=-2'
            else:
                extra=''
            idx = line.find('#')
            w = line.split()
            if len(w) == 0: continue
            idx__bank = w[0].find('__')
            if idx__bank > 0:
                bank = int(w[0][idx__bank+2:])
                if w[0][0] == '-':    # only occurs in single obsnums, not combo
                    o = w[0][1:idx__bank]
                else:
                    o = w[0][:idx__bank]
                #print("# __bank=", bank, "obsnum=", o)
                if bank == 1:
                    pars = pars5
                else:
                    pars = pars4
            else:
                if w[0][0] == '-':
                    o = w[0][1:]
                else:
                    o = w[0]
                pars = pars4
            pars[o] = []
            # loop over args,  and replace PI parameters
            if idx > 0:
                for a in line[idx+1:].strip().split():
                    kv = a.split('=')
                    if kv[0] == 'pix_list':
                        a = 'pix_list=' + pix_list(kv[1])
                    pars[o].append(a)
            # append 'extra' (QAFAIL induced)
            if len(extra) > 0:
                pars[o].append(extra)

    #print("PARS4", pars4)
    #print("PARS5", pars5)

    return pars4,pars5


def getargs(obsnum, pars):
    """ search for <obsnum> and return the args
        obsnum   - must be a string, like "123456" or "123456_123467"
        pars     - a dict of {obsnum:[arg1,arg2,...]}
        returns the arguments in one string for that obsnum
              "arg1 arg2 .."
    """
    args = ""
    if obsnum in pars.keys():
        for a in pars[obsnum]:
            args = args + " " + a
    return args
    

def verify(runfile, debug=False):
    """ verify a runfile if the argument are good enough to be sent to the pipeline
    """
    if not os.path.exists(runfile):
        err = "Runfile %s does not exist" % runfile
        return err
    
    lines = open(runfile).readlines()
    for line in lines:
        if debug:
            print(line.strip())
        if line[0] == '#':
            continue
        w = line.split()
        if w[0] != 'SLpipeline.sh':
            err = "not an SLpipeline runfile:" + line
            return err
        if w[1][:7] != 'obsnum=':
            err = "not an SLpipeline runfile with obsnum=: " + w[1]
            return err
    return None

def mk_runs(project, on, pars1, pars2, pars3=None, argv=None):
    """ top level
       project    - PID, e.g. "2024-S1-MX-2"
       on         - dictionary of sources and their assocciated obsnums
                    obsnums are integers, negative one do not appear in combos
       pars1,2,3  - SLpipeline parameters for this tier-1,2,3 run (called a,b,c)
       argv       - optional for CLI
    """
    io = "TBD"
    o_min = -1
    o_max = -1

    # @todo if more than one I/O is present, this code won't work -- @todo fix multiple IO)
    io = IO()
    print("Note _io=%s assumed for all obsnums" % io.getio(0))

    if argv != None:
        if len(argv) > 1:
            obsnums=[]
            if argv[1] == '-h':
                print("mk_runs.py: Create runfiles by default (version %s)" % _version)
                print("  -h    this help")
                print("  -o    show all obsnums, sorted")
                print("  -c    produce a config/obsnum list [takes time]")
                print("  -b    show all failed obsnums")
                print("  -B    show all failed obsnums and add the word QAFAIL for comments.txt")
                sys.exit(0)
            elif argv[1] == '-o':
                for s in on.keys():
                    for o1 in on[s]:
                        obsnums.append(abs(o1))
                obsnums.sort()
                for o1 in obsnums:
                    print(o1)
                print("# found %d obsnums for %s" % (len(obsnums),project))
                return
            elif argv[1] == '-c':
                for s in on.keys():
                    for o1 in on[s]:
                        obsnums.append(abs(o1))
                obsnums.sort()
                for o1 in obsnums:
                    cmd = 'echo -n "%s "; lmtinfo.py %d | grep ^config=  | sed s/config=//' % (abs(o1),abs(o1))
                    print(cmd)
                    # os.system(cmd)
                return
            elif argv[1] == '-b' or argv[1] == '-B':
                for s in on.keys():
                    for o1 in on[s]:
                        if o1 < 0:
                            obsnums.append(abs(o1))
                obsnums.sort()
                if argv[1] == '-b':
                    for o1 in obsnums:
                        print(o1)
                else:
                    for o1 in obsnums:
                        print(o1,"QAFAIL")
                print("# found %d failed obsnums" % len(obsnums))                        
                return
            else:
                print("Unknown mode: ",argv)
                sys.exit(0)


    print("Creating run files")

    # @todo   fix this, it's hardcoded for a 3-tier system (a,b,c)
    run1a = '%s.run1a'   % project
    run1b = '%s.run1b'   % project
    run1c = '%s.run1c'   % project
    run1x = '%s.run1.sh' % project

    run2a = '%s.run2'    % project
    run2x = '%s.run2.sh' % project

    fp1 = list(range(4))  # run1a,b,c,sh
    fp2 = list(range(2))  # run2,sh

    fp1[0] = open(run1a, "w")
    fp1[1] = open(run1b, "w")
    fp1[2] = open(run1c, "w")
    fp1[3] = open(run1x, "w")
    
    fp2[0] = open(run2a, "w")
    fp2[1] = open(run2x, "w")    

    pars4,pars5 = getpars(on)

    # single obsnums
    n1 = 0
    for s in on.keys():     # loop over sources
        for o1 in on[s]:    # loop over obsnums
            cmd1 = ["" for i in range(4)]

            o = abs(o1)
            os = repr(o)
            _io = io.getio(o)
            if s in pars1:
                cmd1[0] = "SLpipeline.sh obsnum=%d _io=%s _s=%s %s restart=1 " % (o,_io,s,pars1[s])
            if s in pars2:
                cmd1[1] = "SLpipeline.sh obsnum=%d _io=%s _s=%s %s %s" % (o,_io,s,pars2[s], getargs(os,pars4))
            if pars3 != None and s in pars3:
                cmd1[2]  = "SLpipeline.sh obsnum=%d _io=%s _s=%s %s %s" % (o,_io,s, pars3[s], getargs(os,pars5))
            cmd1[3] = "SLpipeline.sh obsnum=%d _io=%s _s=%s archive=1" % (o,_io,s)
            for i in range(4):
                if len(cmd1[i]) > 0:  fp1[i].write("%s\n" % cmd1[i])
            n1 = n1 + 1

    # combination obsnums
    n2 = 0        
    for s in on.keys():         # loop over sources
        obsnums = ""
        n3 = 0
        for o1 in on[s]:        # loop over positive obsnums only
            o = abs(o1)
            if o1 < 0: continue
            n3 = n3 + 1
            if obsnums == "":
                obsnums = "%d" % o
                o_first = o_last = o
            else:
                obsnums = obsnums + ",%d" % o
                o_last = o
        print('%s[%d/%d] :' % (s,n3,len(on[s])), obsnums)
        o_o = '%s_%s' % (o_first,o_last)
        _io = io.getio(o_first)
        # print("Combo: %s" % o_o)
        cmd2 = ["" for i in range(2)]

        # only do admit, if _io is not RSR or TBD
        if _io.find('RSR') == 0 or _io.find('TBD') == 0:
            admit = 0
        else:
            admit = 1

        if s in pars1:
            cmd2[0] = "SLpipeline.sh obsnums=%s _io=%s _s=%s restart=1 admit=%d" % (obsnums, _io, s, admit)
        cmd2[1] = "SLpipeline.sh obsnums=%s _io=%s _s=%s archive=1" % (obsnums, _io, s)
        for i in range(2):
            if len(cmd2[i]) > 0:  fp2[i].write("%s\n" % cmd2[i])
        n2 = n2 + 1

    print("A proper re-run of %s should be in the following order: (note some of these may be empty)" % project)
    print(run1a)
    print(run1b)
    print(run1c)
    print(run2a)
    obsnums=[]
    for s in on.keys():
        for o1 in on[s]:
            obsnums.append(abs(o1))
    obsnums.sort()
    print("%s: obsnums %d - %d   with %d single obsnums and %d combinations" % (project, obsnums[0], obsnums[-1], n1, n2))
    print("Also note the archiving runs (run1.sh and run2.sh) when QA is done")
