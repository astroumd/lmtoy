#! /usr/bin/env python
#

"""Usage: mk_metadata.py [options] [OBSNUM]

Options:

-d          add more debugging
-y YAMLFILE Output yaml file. Optional.
-f DBFILE   Output sqlite database filename. Optional.

-o          Overwrite row for all possible rows with OBSNUM.
            Only affects if a database was used.
            (NOT IMPLEMENTED)
--delete N  delete row N (alma_id) from table
            (NOT IMPLEMENTED)

--version   Show version
-h --help   This help

For a given OBSNUM the script will create the metadata for DataVerse
in either yaml and/or sqlite format. If no obsnum is given, a
generic example is given.

"""

import os
import sys
import math
import yaml
from docopt import docopt
import astropy.units as u
from astropy.coordinates import SkyCoord
import dvpipe.utils as utils
from dvpipe.pipelines.metadatagroup import LmtMetadataGroup, example
from dvpipe.pipelines.metadatablock import MetadataBlock
from lmtoy import data_prod_id
from datetime import date
from dateutil.relativedelta import relativedelta

_version = "15-jul-2024"

def header(rc, key, debug=False):
    """
    input:
    rc     dictionary from the rc file
    key    keyword from the rc file
    
    returns:  the string value for the keyword
    
    """
    if key in rc:
        if debug:
            print("# PJT: header   ",key,rc[key])
        if rc[key].find(',') < 0:
            return rc[key]
        else:
            print("# PJT: header %s not single valued: %s, using first" % (key,rc[key]))
            # return first
            return rc[key].split(',')[0]
    else:
        if debug:
            print("# PJT: unknown key ",key)
            print(rc)

def rc_file(pdir, bank = None):
    """ find an rc file
        lmtoy_OBSNUM.rc or lmtoy_OBSNUM__BANK.rc
    """
    if pdir.rfind('/') > 0:
        #print("PJT - dir")
        obsnum = pdir.split('/')[-1]
        if bank==None:
            rcfile = pdir + '/lmtoy_%s.rc' % obsnum
        else:
            rcfile = pdir + '/lmtoy_%s__%d.rc' % (obsnum,bank)
    else:
        #print("PJT - obsnum")        
        obsnum = pdir
        if bank==None:
            rcfile =  '%s/lmtoy_%s.rc' % (obsnum,obsnum)
        else:
            rcfile =  '%s/lmtoy_%s__%d.rc' % (obsnum,obsnum,bank)
    if not os.path.exists(rcfile):
        print("File %s does not exist" % rcfile)
        sys.exit(0)
    #print("PJT rc_file",rcfile)
    return rcfile

def get_rc(rcfile, rc=None, debug=False):
    """
    input:
    rcfile     name of the rc file
    rc         optional existing rc dictionary to use
    returns:   the "rc" (string-string) dictionary 
    """
    if rc==None:
        rc = {}
    else:
        print("DEBUG rc:",rc)
        
    try:
        print("# opening  ",rcfile)
        fp = open(rcfile)
        lines = fp.readlines()
        fp.close()
        for line in lines:
            if line[0] == '#':  continue
            line = line.strip()
            # can either exec() each line when the rc is clean, but it's not yet
            # until then, manually parse
            w = line.split('=')
            #   if w[1] starts with " or ', make it a string
            if len(w[1])==0:
                # empty string
                exec('%s=""' % w[0])
                rc[w[0]] = locals()[w[0]]                
            elif w[1][0] == '"' or w[1][0] == "'":
                if debug:
                    print("# PJT: stringify",line.strip())
                exec(line.strip())
                rc[w[0]] = locals()[w[0]]
            else:
                # non-strings only use the first word after =  (i.e. comments allowed)
                # but save it as string for potential conversion later on
                rc[w[0]] = w[1].strip().split()[0]
    except:
        print("Error processing %s " % rcfile)
        print("line: ",line, "w:",w)
        sys.exit(0)
    return rc
    
def get_version():
    """
    return the version of LMTOY (from $LMTOY/VERSION)
    """
    fp = open("%s/VERSION" % os.environ['LMTOY'])
    lines = fp.readlines()
    fp.close()
    return lines[0].strip()

def get_publicDate(rc, debug=False):
    """
    return the date the data will go public. ISO format  yyyy-mm-dd
    should be a year after "now", unless one was present in the RC file
    (e.g. when passed as public=yyyy-mm-dd to SLpipeline.sh)
    """
    public = header(rc,"date_public",debug)
    if public != None:
        return public
    public_date = date.today() + relativedelta(years=1)
    return public_date.isoformat()

# constants
_c  = 299792.458
_pi = math.pi
        


def lmt_beam(freq, dish=50.0, factor=1.15):
    """ compute FWHM beam for the LMT
    """
    beam = factor*_c/(freq*dish)*(180/_pi)/1e6    # now in degrees
    return beam

_lines = []

def guess_line(restfreq, debug=False):
    """ guess the  form and trans for given restfreq
    All we have is a common table... since this is not in the header
    $LMTOY/etc/lines.list   has     (restfreq,form,trans)
    """
    if len(_lines) == 0:
        lfile = os.environ['LMTOY'] + '/etc/lines.list'
        fp = open(lfile)
        lines = fp.readlines()
        fp.close()
        for line in lines:
            if line[0] == '#': continue
            w = line.split()
            if len(w) == 3:
                rf = float(w[0])
                lf = w[1]
                tf = w[2]
                _lines.append((rf,lf,tf))
        if debug:
            print("Found %d in lines.list" % len(_lines))
    #  example line:   110.2013543 13co 1-0
    #  if the transition is a '?' , return a space ' ' instead
    for l in _lines:
        d = abs(l[0]-restfreq)
        if d < 0.001:
            if debug:
                print("Found",l[1],l[2])
            if l[2] == '?':
                return (l[1],' ')
            return (l[1],l[2])
    return ("Unknown","Unknown")

def get_qagrade(rc, debug=False):
    """
    processingLevel = 1:     -1,0     are allowed (single obsnum)
    processingLevel = 2:     -2,1,2,3 are allowed (single obsnum)
    processingLevel = 3:     -2,1,2,3 are allowed (combinations)
    """
    qagrade = header(rc,"qagrade",debug)
    if qagrade == None:
        qagrade = 0
    else:
        qagrade = int(qagrade)
    return qagrade


    
if __name__ == "__main__":

    av = docopt(__doc__,options_first=True, version=_version)
    debug = av['-d']
    
    if debug:
        print(av)

    dbfile = av['-f']
    yamlfile = av['-y']
   
    if av['OBSNUM'] == None:
        lmtdata = example(dbfile,yamlfile)
        lmtdata.write_to_db()
        lmtdata.write_to_yaml()        
        sys.exit(0)

    # find and read the rc file and construct the rc {} dictionary
    # OBSNUM can be an actual OBSNUM or the OBSNUM directory 
    pdir = av['OBSNUM']
    rcfile = rc_file(pdir)
    rc = get_rc(rcfile, debug=debug)

    # get version, as comment (or metadata?)
    print("# LMTOY version %s" % get_version())
    
    # deal with the enum's we use for instrument on the DV side
    # valid names:  TolTEC, MSIP1mm, SEQUOIA, RSR, OMAYA
    instrument = header(rc,"instrument", debug)
    if instrument == "SEQ":
        instrument = "SEQUOIA"
    if instrument == "1MM":
        instrument = "MSIP1MM"

    # open the LMG and write some common metadata
    # -- see also example() in lmtmetadatagroup.py
    lmtdata = LmtMetadataGroup('SLpipeline', dbfile=dbfile, yamlfile=yamlfile)
    lmtdata.add_metadata("observatory",  "LMT")
    lmtdata.add_metadata("LMTInstrument",instrument)
    lmtdata.add_metadata("projectID",    header(rc,"ProjectId",debug))
    lmtdata.add_metadata("projectTitle", header(rc,"projectTitle",debug))
    lmtdata.add_metadata("PIName",       header(rc,"PIName",debug))
    lmtdata.add_metadata("publicDate",   get_publicDate(rc,debug))
    lmtdata.add_metadata("isPolarimetry",      False)    # or True if HWP mode not ABSENT
    lmtdata.add_metadata("halfWavePlateMode", "ABSENT")  # or FIXED or ROTATING

    # isCombined - bool, True if more than one obsnum/combined data
    obsnum = header(rc,"obsnum")
    if obsnum.find("_") > 0:
        isCombined = True
        obsnums = header(rc,"obsnum_list")
    else:
        isCombined = False
        obsnums = ""
    lmtdata.add_metadata("isCombined", isCombined)

    # NEW:  obsInfo dict - one per true obsnum
    #     obsNum - int (must now be an number!)
    #     subobsnum - int   
    #     scannum - int 
    #     intTime - float in time units
    #     obsGoal - SCIENCE or OTHER
    #     obsComment - comment string
    #     opacity225 - opacity at 225 GHz (can be 0)

    if isCombined:
        # assemble all obsinfo's for all obsnum's in the combo 
        for o in obsnums.split(','):
            fn = '../%s/%s_lmtmetadata.yaml' % (o,o)
            print("YAML Reading",fn)
            fp = open(fn)
            if True:
                # native yaml
                y = yaml.safe_load(fp)
                o = y['obsInfo'][0]
            else:
                # directly using out dvpipe  @todo  this doesn't work
                y = MetadataBlock(yamlfile=fn,load_data=True)
                o = y.metadata['obsInfo'][0]
            lmtdata.add_metadata("obsInfo",o)
        ref_id = data_prod_id.make_lmtoy_data_prod_id(obsnums.split(','))
    else:
        obsinfo = dict()
        obsinfo["obsNum"]      = int(obsnum)
        obsinfo["subObsNum"]   = int(header(rc,"subobsnum",debug))      # normally 0 for us
        obsinfo["scanNum"]     = int(header(rc,"scannum",debug))        # normally 1 for us
        obsinfo["intTime"]     = float(header(rc,"inttime",debug))
        obsinfo["obsGoal"]     = "SCIENCE"
        if isCombined:
            obsinfo["obsComment"]  = "Combining %s" % obsnums
        else:
            obsinfo["obsComment"]  = "None"                        # @todo ???
        opacity225 = float(header(rc,"tau",debug))
        if opacity225 == 0.0:
            obsinfo["opacity225"]  = -1.0
        else:
            obsinfo["opacity225"]  = opacity225
        obsinfo["obsDate"]     = header(rc,"date_obs",debug)    
        lmtdata.add_metadata("obsInfo",obsinfo)
        ref_id = obsnum

    # ref_id - string identifier. 
    lmtdata.add_metadata("referenceID", ref_id)
    inttime = float(header(rc,"inttime",debug))

    ra_deg  = float(header(rc,"ra", debug))
    dec_deg = float(header(rc,"dec",debug))
    cs = SkyCoord(ra=ra_deg*u.degree, dec=dec_deg*u.degree, frame='icrs')
    glon = cs.galactic.l.value
    glat = cs.galactic.b.value
    
    lmtdata.add_metadata("targetName",       header(rc,"src",debug))
    lmtdata.add_metadata("RA",               ra_deg)
    lmtdata.add_metadata("DEC",              dec_deg)
    lmtdata.add_metadata("calibrationLevel", 1)       # @todo hardcoded now
    lmtdata.add_metadata('galLon',           glon)
    lmtdata.add_metadata('galLat',           glat)
    lmtdata.add_metadata('pipeVersion',      header(rc,"lmtoy_version"), debug)

    
    if instrument == "SEQUOIA" or instrument == "MSIP1MM":     # @todo this is only for mapping so far
   
        # @todo deal with other obspgm's, this is still Map only

        rcfile = rc_file(pdir, 0)     # get bank=0, should always be present
        rc = get_rc(rcfile, debug=debug)

        vlsr = float(header(rc,"vlsr",debug))
        lmtdata.add_metadata("velocity",vlsr)           # vlsr
        lmtdata.add_metadata("velDef","RADIO")          
        lmtdata.add_metadata("velFrame","LSR")
        lmtdata.add_metadata("velType","FREQUENCY")
        lmtdata.add_metadata("z",vlsr/_c)               # @todo

        numbands = int(header(rc,"numbands",debug))

        # process bank=0

        skyfreq = float(header(rc,"skyfreq",debug))
        restfreq = float(header(rc,"restfreq",debug))
        (line_form, line_trans) = guess_line(restfreq)
        rms = float(header(rc,"rms",debug))
        nchan = int(header(rc,"nchan"))             # can differ per bank
        nchan0 = int(header(rc,"nchan0"))           # same for each bank
        bw = float(header(rc,"bandwidth",debug))    # same for each bank
        
        inttime = float(header(rc,"inttime",debug))   # oddity, SEQ has this in the bank based rc
         
        band = dict()
        band["bandNum"] = 1
        band["formula"]=line_form
        band["transition"]=line_trans
        band["frequencyCenter"] = restfreq*u.Unit("GHz")
        band["velocityCenter"] = vlsr
        band["bandwidth"] = bw*nchan/nchan0*u.Unit("GHz")
        band["beam"] = lmt_beam(skyfreq)
        band["winrms"] = rms*u.Unit("mK")
        band["qaGrade"] = qagrade = get_qagrade(rc, debug)   # -2 .. 3 (-1,0 means not graded)

        band["nchan"] =  nchan
        band["bandName"] = "OTHER"    # we don't have special names for the spectral line bands
        lmtdata.add_metadata("band",band)

        if numbands > 1:
            # process bank=1

            rcfile = rc_file(pdir, 1)     # get bank=1; we only have 2 banks now
            rc = get_rc(rcfile, debug=debug)

            skyfreq = float(header(rc,"skyfreq",debug))
            restfreq = float(header(rc,"restfreq",debug))
            bw = float(header(rc,"bandwidth",debug))
            (line_form, line_trans) = guess_line(restfreq)            
            rms = float(header(rc,"rms",debug))

            band = dict()
            nchan = int(header(rc,"nchan"))
            band["bandNum"] = 2
            band["formula"]=line_form
            band["transition"]=line_trans
            band["frequencyCenter"] = restfreq*u.Unit("GHz")
            band["velocityCenter"] = vlsr
            band["bandwidth"] = bw*nchan/nchan0*u.Unit("GHz")
            band["beam"] = lmt_beam(skyfreq)
            band["winrms"] = rms*u.Unit("mK")
            band["qaGrade"] = qagrade = get_qagrade(rc, debug)   # -2 .. 3 (-1,0 means not graded)
            band["nchan"] = nchan
            band["bandwidth"] = bw*u.Unit("GHz")
            
            band["bandName"] = "OTHER"    # we don't have special names for the spectral line bands
            lmtdata.add_metadata("band",band)

            # @todo   should the qagrade be the min() or max() of the bands?
            

    elif instrument == "RSR":
        print("instrument=%s " % instrument)

        lmtdata.add_metadata("velocity",0.0)          # vlsr
        lmtdata.add_metadata("velDef","RADIO")          
        lmtdata.add_metadata("velFrame","SRC")
        lmtdata.add_metadata("velType","FREQUENCY")
        lmtdata.add_metadata("z",0.0)                 # <-vlsr

        # @todo data before feb-2018 were using a 32m dish
        dish = 50     # dish diameter in m
        freq = 90.0   # center-freq in GHz
        beam = lmt_beam(freq, dish)

        band = dict()
        band["bandNum"] = int(1)
        band["frequencyCenter"] = freq*u.Unit("GHz")
        band["bandwidth"] = 40.0*u.Unit("GHz")
        band["velocityCenter"] = 0.0
        band["beam"] = beam
        rms = header(rc,"rms",debug)
        if len(rms) == 0:
           band["winrms"] = -1.0
        else:
           band["winrms"] = float(header(rc,"rms",debug))*u.Unit("K")
        band["qaGrade"] = qagrade = get_qagrade(rc, debug)   # -2 .. 3 (-1,0 means not graded)        <
        band["nchan"] = int(header(rc,"nchan",debug))
        band["formula"] = ""        # not applicable for RSR
        band["transition"] = ""     # not applicable for RSR
        band["bandName"] = "OTHER"  # we don't have special names for the spectral line bands
        lmtdata.add_metadata("band",band)
        
    else:
        print("instrument=%s not implemented yet" % instrument)

    # 0 = unprocessed (never happens), 1 = pipeline processed, 2 = DA improvement
    # toltec has different definitions and includes level 3.
    # @todo   qagrade can differ per band for SEQ, currently last one survives
    if qagrade==0 or qagrade==-1:
        lmtdata.add_metadata("processingLevel", 1)
    elif isCombined:
        lmtdata.add_metadata("processingLevel", 3)
    else:
        lmtdata.add_metadata("processingLevel", 2)
        

    lmtdata.add_metadata("totalIntTime", inttime)        

    # validate=True is now default
    if yamlfile != None:
        lmtdata.write_to_yaml()
    if dbfile != None:
        lmtdata.write_to_db()   

