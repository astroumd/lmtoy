#   tools useful for the script generator (usually called mk_runs.py)
#
#   pix_list(pl)
#

import os
import sys

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
    """ get SLpipeline parameters from obsnum.args (deprecated in nov-2022)
        nor comments.txt after the '#' symbol
    """
    pars4 = {}
    if os.path.exists("obsnum.args"):
        print("WARNING: obsnum.args is deprecated, please use comments.txt now")
        lines = open("obsnum.args").readlines()
        for line in lines:
            if line[0] == '#': continue
            w = line.split()
            pars4[int(w[0])] = w[1:]
            print('PJT4-deprecated',w[0],w[1:])

    if os.path.exists("comments.txt"):
        lines = open("comments.txt").readlines()
        for line in lines:
            if line[0] == '#': continue
            idx = line.find('#')
            w = line.split()
            # loop over args,  and replace PI parameters
            if idx > 0:
                pars4[int(w[0])] = []
                for a in line[idx+1:].strip().split():
                    kv = a.split('=')
                    if kv[0] == 'pix_list':
                        a = 'pix_list=' + pix_list(kv[1])
                    pars4[int(w[0])].append(a)

    return pars4


def getargs(obsnum, pars4):
    """ search for <obsnum> and return the args
    """
    args = ""
    if obsnum in pars4.keys():
        # print("PJT2:",obsnum,pars4[obsnum])
        for a in pars4[obsnum]:
            args = args + " " + a
    return args

#        helper function for populating obsnum dependant argument
def getargs_old(obsnum, flags=True):
    """ search for <obsnum>.args
        and in lmtoy.flags
        ** deprecated **
    """
    args = ""    
    if flags:
        f = 'lmtoy.flags'
        if os.path.exists(f):
            lines = open(f).readlines()
            for line in lines:
                if line[0] == '#': continue
                args = args + line.strip() + " "
        
    f = "%d.args" % obsnum
    if os.path.exists(f):
        lines = open(f).readlines()
        for line in lines:
            if line[0] == '#': continue
            args = args + line.strip() + " "
    return args

def mk_runs(project, on, pars1, pars2, argv=None):
    """ top level
    """

    if argv != None:
        if len(argv) > 0:
            obsnums=[]
            if argv[0] == '-h':
                print("mk_runs.py: Create runfiles by default")
                print("  -h    this help")
                print("  -o    show all obsnums, sorted")
                sys.exit(0)
            elif argv[0] == '-o':
                for s in on.keys():
                    for o1 in on[s]:
                        obsnums.append(abs(o1))
                obsnums.sort()
                for o1 in obsnums:
                    print(o1)
                return
            else:
                print("Unknown mode: ",argv)
                sys.exit(0)


    print("Creating run files")
    
    run1  = '%s.run1'  % project
    run1a = '%s.run1a' % project
    run1b = '%s.run1b' % project
    run2  = '%s.run2'  % project
    run2a = '%s.run2a' % project
    run2b = '%s.run2b' % project

    fp1  = open(run1,  "w")
    fp1a = open(run1a, "w")
    fp1b = open(run1b, "w")
    fp2  = open(run2,  "w")    
    fp2a = open(run2a, "w")
    fp2b = open(run2b, "w")


    pars4 = getpars(on)

    # single obsnums
    n1 = 0
    for s in on.keys():
        for o1 in on[s]:
            o = abs(o1)
            cmd1a = "SLpipeline.sh obsnum=%d _s=%s %s restart=1 " % (o,s,pars1[s])
            cmd1b = "SLpipeline.sh obsnum=%d _s=%s %s %s" % (o,s,pars2[s], getargs(o,pars4))
            cmd1  = "SLpipeline.sh obsnum=%d _s=%s %s %s %s" % (o,s,pars1[s], pars2[s], getargs(o,pars4))
            fp1a.write("%s\n" % cmd1a)
            fp1b.write("%s\n" % cmd1b)
            fp1.write("%s\n" % cmd1)
            n1 = n1 + 1

    #                           combination obsnums
    n2 = 0        
    for s in on.keys():
        obsnums = ""
        n3 = 0
        for o1 in on[s]:
            o = abs(o1)
            if o1 < 0: continue
            n3 = n3 + 1
            if obsnums == "":
                obsnums = "%d" % o
            else:
                obsnums = obsnums + ",%d" % o
        print('%s[%d/%d] :' % (s,n3,len(on[s])), obsnums)
        cmd2a = "SLpipeline.sh _s=%s admit=0 restart=1 obsnums=%s" % (s, obsnums)
        cmd2b = "SLpipeline.sh _s=%s admit=1 srdp=1    obsnums=%s" % (s, obsnums)
        fp2a.write("%s\n" % cmd2a)
        fp2b.write("%s\n" % cmd2b)
        n2 = n2 + 1

    print("A proper re-run of %s should be in the following order:" % project)
    print(run1a)
    print(run2a)
    print(run1b)
    print(run2b)
    print("Where there are %d single obsnum runs, and %d combination obsnums" % (n1,n2))
