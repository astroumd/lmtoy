#! /usr/bin/env python
#
#  Create the lmtmetadata.yaml (on stdout) for a given obsnum directory
#
#  projectTitle
#  PIName
#  lineName  - "search for"
#
import os
import sys
import dvpipe.utils as utils
from dvpipe.pipelines.metadatagroup import LmtMetadataGroup, example

_version = "27-feb-2023"

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
        print("line: ",line, "w:",w)
        print("Error processing %s " % rcfile)
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

    debug = False
    
    # simple CLI for now
    if len(sys.argv) < 2:
        print("Usage: %s ObsnumDirectory" % sys.argv[0])
        print("version: %s" % _version)
        example()
        sys.exit(0)

    print("# Warning: mk_metadata does not produce fully certified data yet")

    # find and read the rc file and construct the rc {} dictionary
    
    pdir = sys.argv[1]
    obsnum = pdir.split('/')[-1]
    rcfile = pdir + '/lmtoy_%s.rc' % obsnum
    rc = get_rc(rcfile, debug)

    # get version, as comment (or metadata?)
    print("# LMTOY version %s" % get_version())
    

    # deal with the enum's we use for instrument on the DV side
    # valid names:  TolTEC, MSIP1mm, SEQUOIA, RSR, OMAYA
    
    instrument = header(rc,"instrument", debug)
    if instrument == "SEQ":
        instrument = "SEQUOIA"

    # open the LMB and write some common metadata
    lmtdata = LmtMetadataGroup('foobar')
    lmtdata.add_metadata("observatory",  "LMT")
    lmtdata.add_metadata("LMTInstrument",instrument)
    lmtdata.add_metadata("projectID",    header(rc,"ProjectId",debug))
    lmtdata.add_metadata("projectTitle", header(rc,"projectTitle",debug))
    lmtdata.add_metadata("PIName",       header(rc,"PIName",debug))
    lmtdata.add_metadata("obsnum",       header(rc,"obsnum",debug))
    lmtdata.add_metadata("obsDate",      header(rc,"date_obs",debug))
    lmtdata.add_metadata("targetName",   header(rc,"src",debug))
    lmtdata.add_metadata("intTime",float(header(rc,"inttime",debug)))

    if instrument == "SEQUOIA":
        #lmtdata.add_metadata("origin",  "lmtoy v0.6")
        #
        #  below here to be deciphered
        #
        lmtdata.add_metadata("RA",123.456)
        lmtdata.add_metadata("DEC",-43.210)
        lmtdata.add_metadata("velocity",321.0)          # vlsr
        lmtdata.add_metadata("velDef","RADIO")          
        lmtdata.add_metadata("velFrame","LSR")
        lmtdata.add_metadata("velType","FREQUENCY")
        lmtdata.add_metadata("z",0.001071)              # <-vlsr
        
        #lmtdata.add_metadata("slBand",1)
        #lmtdata.add_metadata("lineName",'CS2-1')
        #lmtdata.add_metadata("frequencyCenter",97.981)
        #lmtdata.add_metadata("bandwidth",2.5)
        #lmtdata.add_metadata("beam",20.0/3600.0)
        #lmtdata.add_metadata("lineSens",0.072)

        band = dict()
        band["slBand"] = 1
        band["lineName"]='CS2-1'
        #   for multiple lines:
        #band["lineName"] = 'CS2-1,CO1-0,H2CS'
        band["frequencyCenter"] = 97.981
        band["bandwidth"] = 2.5
        band["beam"] = 20.0/3600.0
        band["lineSens"] = 0.072
        band["qaGrade"] = "A+++"
        lmtdata.add_metadata("band",band)

    elif instrument == "RSR":
        print("instrument=%s " % instrument)
    else:
        print("instrument=%s not implemented yet" % instrument)


    
    print(lmtdata.to_yaml())
