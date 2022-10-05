#! /usr/bin/env python
#
#  Create the lmtmetadata.yaml (on stdout) for a given obsnum directory
#
#  

import sys
import dvpipe.utils as utils
from dvpipe.pipelines.lmtmetadatablock import LmtMetadataBlock

def header(rc, key):
    """
    input:
    rc     dictionary from the rc file
    key    keyword from the rc file
    
    returns:  the string value for the keyword
    
    """
    if key in rc:
        print("# PJT: header   ",key,rc[key])
        return rc[key]
    else:
        print("# PJT: unknown key ",key)

def get_rc(filename):
    """
    input:
    filename   name of the rc file
    returns:   the "rc" (string-string) dictionary 
    """
    rc = {}
    try:
        print("# PJT: opening  ",rcfile)
        fp = open(rcfile)
        lines = fp.readlines()
        fp.close()
        for line in lines:
            if line[0] == '#':  continue
            # can either exec() each line when the rc is clean, but it's not yet
            # until then, manually parse
            w = line.split('=')
            #   if w[1] starts with " or ', make it a string
            if w[1][0] == '"' or w[1][0] == "'":
                print("# PJT: stringify",line.strip())
                exec(line.strip())
                rc[w[0]] = locals()[w[0]]
            else:
                # non-strings only use the first word after =  (i.e. comments allowed)
                # but save it as string for potential conversion later on
                rc[w[0]] = w[1].strip().split()[0]
    except:
        print("Error processing %s " % rcfile)
        sys.exit(0)
    return rc
    

def example():
    """
    show a reminder lmtmetadata.yaml file 
    """
    # taken from dvpipe/pipelines/lmtmetadatablock.py

    print("# here is an example lmtmetadata.yaml file:")
    
    lmtdata = LmtMetadataBlock()
    #print(lmtdata.name,'\n',lmtdata.datasetFields)
    #print(type(lmtdata._datasetFields))
    #print(lmtdata.datasetFields['name'].values)
    lmtdata.add_metadata("projectID","2021-S1-US-3")

    
    lmtdata.add_metadata("PIName","Marc Pound")
    lmtdata.add_metadata("obsnum","12345,43210_43221")
    lmtdata.add_metadata("RA",123.456)
    lmtdata.add_metadata("DEC",-43.210)
    lmtdata.add_metadata("slBand",1)
    lmtdata.add_metadata("lineName",'CS2-1')
    lmtdata.add_metadata("frequencyCenter",97.981)
    lmtdata.add_metadata("bandwidth",2.5)
    lmtdata.add_metadata("intTime",30.0)
    lmtdata.add_metadata("projectTitle","Life, the Universe, and Everything")
    lmtdata.add_metadata("obsDate",utils.now())
    lmtdata.add_metadata("velocity",321.0)
    lmtdata.add_metadata("velDef","RADIO")
    lmtdata.add_metadata("velFrame","LSR")
    lmtdata.add_metadata("velType","FREQUENCY")
    lmtdata.add_metadata("z",0.001071)
    lmtdata.add_metadata("beam",20.0/3600.0)
    lmtdata.add_metadata("lineSens",0.072)
    lmtdata.add_metadata("facility","LMT")
    lmtdata.add_metadata("instrument","SEQUOIA")
    lmtdata.add_metadata("object","NGC 5948")
    if False:
    # If you try to add something that is not defined you get a ValueError
        try:
            lmtdata.add_metadata("foobar",12345)
        except KeyError as v:
            print("Caught as expected: ",v)
        print(lmtdata.controlledVocabulary)
        print(lmtdata.check_controlled("velFrame","Foobar"))
        print(lmtdata.check_controlled("velFrame","LSR"))
        print(lmtdata.check_controlled("foobar","uhno"))
        # If you try to add a value to a controlled variable that is not in
        # its controlled vocabulary (enum), you get a ValueError 
        try:
            lmtdata.add_metadata("velFrame","Foobar")
        except ValueError as v:
            print("Caught as expected: ",v)
    print(lmtdata.to_yaml())

if __name__ == "__main__":
    # simple CLI for now
    if len(sys.argv) < 2:
        print("Usage: %s ObsnumDirectory" % sys.argv[0])
        example()
        sys.exit(0)

    # find and read the rc file and construct the rc {} dictionary
    
    pdir = sys.argv[1]
    obsnum = pdir.split('/')[-1]
    rcfile = pdir + '/lmtoy_%s.rc' % obsnum
    rc = get_rc(rcfile)

    instrument = header(rc,"instrument")


    # process the rc file to make a header
    
    lmtdata = LmtMetadataBlock()
    lmtdata.add_metadata("obsDate", header(rc,"date_obs"))
    lmtdata.add_metadata("obsnum",  header(rc,"obsnum"))
    lmtdata.add_metadata("object",  header(rc,"src"))
    lmtdata.add_metadata("intTime", float(header(rc,"inttime")))
    #lmtdata.add_metadata("instrument", header(rc,"instrument"))
    print(lmtdata.to_yaml())
