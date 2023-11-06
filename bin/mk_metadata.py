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
from docopt import docopt
import astropy.units as u
import dvpipe.utils as utils
from dvpipe.pipelines.metadatagroup import LmtMetadataGroup, example

_version = "7-nov-2023"

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
        return rc[key]
    else:
        if debug:
            print("# PJT: unknown key ",key)

def get_rc(filename, debug=False):
    """
    input:
    filename   name of the rc file
    returns:   the "rc" (string-string) dictionary 
    """
    rc = {}
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
    if pdir.rfind('/') > 0:
        obsnum = pdir.split('/')[-1]
        rcfile = pdir + '/lmtoy_%s.rc' % obsnum
    else:
        obsnum = pdir        
        rcfile =  '%s/lmtoy_%s.rc' % (obsnum,obsnum)
    if not os.path.exists(rcfile):
        print("File %s does not exist" % rcfile)
        sys.exit(0)
    rc = get_rc(rcfile, debug)

    # get version, as comment (or metadata?)
    print("# LMTOY version %s" % get_version())
    

    # deal with the enum's we use for instrument on the DV side
    # valid names:  TolTEC, MSIP1mm, SEQUOIA, RSR, OMAYA
    instrument = header(rc,"instrument", debug)
    if instrument == "SEQ":
        instrument = "SEQUOIA"

    # open the LMG and write some common metadata
    # -- see also example() in lmtmetadatagroup.py
    lmtdata = LmtMetadataGroup('SLpipeline', dbfile=dbfile, yamlfile=yamlfile)
    lmtdata.add_metadata("observatory",  "LMT")
    lmtdata.add_metadata("LMTInstrument",instrument)
    lmtdata.add_metadata("projectID",    header(rc,"ProjectId",debug))
    lmtdata.add_metadata("projectTitle", header(rc,"projectTitle",debug))
    lmtdata.add_metadata("PIName",       header(rc,"PIName",debug))
    lmtdata.add_metadata("publicDate",   "2099-12-31")   # @todo

    #lmtdata.add_metadata("obsnum",       header(rc,"obsnum",debug))
    #lmtdata.add_metadata("subobsnum",    header(rc,"subobsnum",debug))
    #lmtdata.add_metadata("scannum",      header(rc,"scannum",debug))
    #lmtdata.add_metadata("obsnumList",   header(rc,"obsnum_list",debug))


    # NEW:  obsInfo dict - one per true obsnum
    #     obsNum - int (must now be an number!)
    #     subobsnum - int   
    #     scannum - int 
    #     intTime - float in time units
    #     obsGoal - SCIENCE or OTHER
    #     obsComment - comment string
    #     opacity225 - opacity at 225 GHz
    obsinfo = dict()
    obsinfo["obsNum"]      = header(rc,"obsnum",debug)
    obsinfo["subObsNum"]   = header(rc,"subobsnum",debug)
    obsinfo["scanNum"]     = header(rc,"scannum",debug)
    obsinfo["intTime"]     = float(header(rc,"inttime",debug))
    obsinfo["obsGoal"]     = "SCIENCE"
    obsinfo["obsComment"]  = "This is an observation comment"
    obsinfo["opacity225"]  = float(header(rc,"tau",debug))
    obsinfo["obsDate"]     = header(rc,"date_obs",debug)    
    lmtdata.add_metadata("obsInfo",obsinfo)
    
    # ref_id - string identifier. Following Toltec convention:
    #    * Single obsnum:  {obsnum}_{reduction_id} 
    #    * Combined obsnums: {minimum_obsnum}c{number_of_obsnums}_{reduction_id}
    #    Where reduction_id is a sequential ID generated by the pipeline run.
    #    For example. For a combined reduction of 3 obsnums 100001, 
    #    100002, and 100003, the ref id is 100001c3_0.
    #lmtdata.add_metadata("referenceID", header(rc,"referenceId",debug))
    lmtdata.add_metadata("referenceID", "blabla")

    lmtdata.add_metadata("totalIntTime", 100.0)    # seconds or astropy units
    

    # isCombined - bool, True if more than one obsnum/combined data
    if obsinfo["obsNum"].find("_") > 0:
        lmtdata.add_metadata("isCombined", True)
    else:
        lmtdata.add_metadata("isCombined", False)

    # obsnumlist is deprecated
    #lmtdata.add_metadata("obsnumList",   header(rc,"obsnum_list",debug))

    lmtdata.add_metadata("targetName",   header(rc,"src",debug))
    lmtdata.add_metadata("RA",     float(header(rc,"ra",debug)))
    lmtdata.add_metadata("DEC",    float(header(rc,"dec",debug)))
    lmtdata.add_metadata("calibrationLevel",1)
    lmtdata.add_metadata('galLon',    0.0)
    lmtdata.add_metadata('galLat',    0.0)
    # lmtdata.add_metadata('boundingBox', 60.0)     deprecated
    lmtdata.add_metadata('pipeVersion', "1.0")

    
    if instrument == "SEQUOIA":
        #lmtdata.add_metadata("origin",  "lmtoy v0.6")
        #
        #  below here to be deciphered
        #
        lmtdata.add_metadata("velocity",321.0)          # vlsr
        lmtdata.add_metadata("velDef","RADIO")          
        lmtdata.add_metadata("velFrame","LSR")
        lmtdata.add_metadata("velType","FREQUENCY")
        lmtdata.add_metadata("z",0.001071)              # <-vlsr

        numbands = int(header(rc,"numbands",debug))
        
        
        band = dict()
        band["slBand"] = 1
        band["formula"]='CO'               #   multiple lines not resolved yet
        band["transition"]='1-0'
        band["frequencyCenter"] = 97.981*u.Unit("GHz")
        band["velocityCenter"] = 0.0
        band["bandwidth"] = 2.5
        band["beam"] = 20.0/3600.0
        # lineSens changed to winrms, contSens deprecated.
        band["winrms"] = 0.072*u.Unit("K")
        band["qaGrade"] = "A+++"
        band["nchan"] = 1024
        lmtdata.add_metadata("band",band)

        if numbands > 1:
            band["slBand"] = 2
            band["formula"]='HCN'               #   multiple lines not resolved yet
            band["transition"]='1-0'
            band["frequencyCenter"] = 97.981*u.Unit("GHz")
            band["velocityCenter"] = 0.0
            band["bandwidth"] = 2.5
            band["beam"] = 20.0/3600.0
            band["winrms"] = 0.072*u.Unit("K")
            band["qaGrade"] = "A+++"
            band["nchan"] = 1024
            lmtdata.add_metadata("band",band)
            

    elif instrument == "RSR":
        print("instrument=%s " % instrument)

        lmtdata.add_metadata("velocity",0.0)          # vlsr
        lmtdata.add_metadata("velDef","RADIO")          
        lmtdata.add_metadata("velFrame","SRC")
        lmtdata.add_metadata("velType","FREQUENCY")
        lmtdata.add_metadata("z",0.0)                 # <-vlsr
        

        band = dict()
        band["slBand"] = 1
        band["frequencyCenter"] = 92.5*u.Unit("GHz")
        band["bandwidth"] = 40.0*u.Unit("GHz")
        band["velocityCenter"] = 0.0
        band["beam"] = 20.0/3600.0
        band["winrms"] = 1*u.Unit("mK")
        band["qaGrade"] = "A+++"
        band["nchan"] = 1300
        band["formula"] = ""
        band["transition"] = ""
        
        lmtdata.add_metadata("band",band)
        
    else:
        print("instrument=%s not implemented yet" % instrument)

    # validate=True is now default
    if yamlfile != None:
        lmtdata.write_to_yaml()
    if dbfile != None:
        lmtdata.write_to_db()   

