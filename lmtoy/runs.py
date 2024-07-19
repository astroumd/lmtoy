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

_version = "19-jul-2024"

def pix_list(pl):
    """ convert a strong like "-0,-1" to proper pixlist by removing
        0 and 1 from the 0..15 list.
        Note:   if the first character is a '-', all numbers are in removed list
                if not, the list is passed "as is",   so e.g.     "0,1,-2" would be bad
    """
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

    print("PARS4", pars4)
    print("PARS5", pars5)

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
    run1a = '%s.run1a' % project
    run1b = '%s.run1b' % project
    run1c = '%s.run1c' % project

    run2a = '%s.run2a' % project
    run2b = '%s.run2b' % project
    run2c = '%s.run2c' % project

    fp1 = list(range(3))
    fp2 = list(range(3))

    fp1[0] = open(run1a, "w")
    fp1[1] = open(run1b, "w")
    fp1[2] = open(run1c, "w")
    
    fp2[0] = open(run2a, "w")
    fp2[1] = open(run2b, "w")
    fp2[2] = open(run2c, "w")

    pars4,pars5 = getpars(on)

    # single obsnums
    n1 = 0
    for s in on.keys():     # loop over sources
        for o1 in on[s]:    # loop over obsnums
            cmd1 = ["" for i in range(3)]
            cmd2 = ["" for i in range(3)]

            o = abs(o1)
            os = repr(o)
            if s in pars1:
                cmd1[0] = "SLpipeline.sh obsnum=%d _s=%s %s restart=1 " % (o,s,pars1[s])
            if s in pars2:
                cmd1[1] = "SLpipeline.sh obsnum=%d _s=%s %s %s" % (o,s,pars2[s], getargs(os,pars4))
            if pars3 != None and s in pars3:
                cmd1[2]  = "SLpipeline.sh obsnum=%d _s=%s %s %s" % (o,s, pars3[s], getargs(os,pars5))
            for i in range(3):
                if len(cmd1[i]) > 0:  fp1[i].write("%s\n" % cmd1[i])
            n1 = n1 + 1

    #                           combination obsnums
    n2 = 0        
    for s in on.keys():         # loop over sources
        obsnums = ""
        n3 = 0
        for o1 in on[s]:        # loop over positive obsnums
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
        print("Combo: %s" % o_o)
        cmd1 = ["" for i in range(3)]
        cmd2 = ["" for i in range(3)]
        
        if s in pars1:
            cmd2[0] = "SLpipeline.sh _s=%s admit=0 restart=1 obsnums=%s" % (s, obsnums)
        if s in pars2:
            cmd2[1] = "SLpipeline.sh _s=%s admit=1 srdp=1    obsnums=%s %s" % (s, obsnums, getargs(o_o,pars4))
        if pars3 != None and s in pars3:
            cmd2[2] = "SLpipeline.sh _s=%s admit=1 srdp=1    obsnums=%s %s" % (s, obsnums, getargs(o_o,pars5))
        for i in range(3):
            if len(cmd2[i]) > 0:  fp2[i].write("%s\n" % cmd2[i])
        n2 = n2 + 1

    print("A proper re-run of %s should be in the following order: (note some of these may be empty)" % project)
    print(run1a)
    print(run2a)
    print(run1b)
    print(run2b)
    print(run1c)
    print(run2c)
    print("Where there are %d single obsnum runs, and %d combination obsnums" % (n1,n2))
