#
#   exploring LMT masking
#
#   Masking is based on describing the data as
#           data[ntime,nbeam,npol,nband,nchan]
#   matching te SDFITS
#           data[nrows,nchan]
#   where
#           nrows = ntime*nbeam*npol*nband
#
#
#   Initially during the filler from raw to sdfits a filtering operation is
#   allowed to narrow down the data in the SDFITS file. Of course they can
#   also be masking while working with the SDFITS file, when these effectively
#   become a mask!
#
#   We only allow for the following filters:
#      - beams can be removed (for WARES only)
#      - time ranges can be removed
#      - channel ranges as long as there are no gaps, so just a simple min-max
#        (e.g. dropped N end-channels at both ends works just as well)
#
#   We currently don't allow any down-filtering in the Pol and Band dimension.
#
#

import sys
import numpy as np
import numpy.ma as ma


class Masking(object):
    def __init__(self, filename = None, raw = False ):
        self.mask = []
        self.nifproc = 0
        self.name = "mask"
        if filename != None:
            printf("Opening %s as masking file" % filename)
            if raw:
                # @todo PI and OBS parameters are initialized here
                print("WARNING: no support for RAW (ifproc) yet");
                return
            self.append(filename)

    def __len__(self):
        return len(self.mask)

    def __str__(self):
        line = ""
        for m in self.mask:
            line = line + "%s\n" % m
        return line

    def setmask(self, mask):
        print("SETMASK: found %d masked" % mask.sum())
        self.mask = mask

    def print(self, header=None):
        if header != None:
            print(header)
        print("===== Found %d masks: " % len(self.mask))
        for m in self.mask:
            print(m)

    def append(self, filename, report=True):
        if report: print("Append: ",filename)
        lines = open(filename).readlines()
        for line in lines:
            self.mask.append(line.strip())

    def load(self, filename):
        self.read(filename)
        
    def read(self, filename):
        print("Read: ",filename)        
        self.mask = []
        self.append(filename, report=False)

    def save(self, filename):
        self.write(filename)

    def write(self, filename):
        fp = open(filename,"w")
        for line in self.mask:
            fp.write("%s\n" % line)
        fp.close()

    def undo(self, nundo=1):
        # this needs to protect it doesn't bump beyond the ifproc number
        print("UNDO ",nundo)
        nmask = len(self.mask)
        if nundo > nmask:
            print("Cannot undo %d, there are only %d left" % (nundo,nmask))
            return
        for i in range(nundo):
            self.mask.pop()
        # @todo    when a legal undo was done, masking file needs to be remade
        # @todo    when ifproc ones are undone, sdfits needs to be remade

    def raw(self, flag, name=None, value=True):
        """ allow raw python 5D flagging. The directive in the masking file is
            #RAW   [:,1,:,:,:]
        """
        if flag[:4] == "#RAW":
            p0 = flag.find("[")
            p1 = flag.find("]")
            # ensure p0 and p1 > 0
            cmd = "%s%s = %s" % (self.name, flag[p0:p1+1],repr(value))
            print("RAW flagging cmd: ", cmd)
            exec(cmd)
        else:
            print("Warning: not a #RAW directive:",flag)


if __name__ == "__main__":
    a = Masking()
    print(len(a))
    a.append("a.mask")
    print(len(a))
    
    a.print('1 -------------------------------------')
    print(len(a))

    a.append("a.mask")    
    a.print('2 -------------------------------------')
    print(len(a))
    a.write("aa.mask")
    
    a.undo(3)
    a.print('3 -------------------------------------')
    a.undo(10)


    data = np.arange(2*2*2).reshape(2,2,1,1,2)
    mask = np.isnan(data)
    a.setmask(mask)
    a.raw("#RAW  [:,1,:,:,:]")
    print("Set mask on %d" % mask.sum())    
