/*
 *  compressing integers?

 wint junk2 100000 2000 4000,200 100000,10000  1000

 781264 502724 = 64%
 
 wint junk3 100000 2000 4000,200 100000,10000  1000
   -> 4928  =  0.6%

 wint junk4 100000 2000 4000,200 100000,10000 10
 465688  = 60%

 AMP = 500000 is more realistic
 wint junk5 100000 2000 4000,200 500000,50000 10
 543504 = 70%
 wint:     21.69user 5.96system 0:28.86elapsed 95%CPU
 gzip:    151.46user 2.73system 2:34.72elapsed 99%CPU
 gunzip:   16.47user 4.44system 0:24.34elapsed 85%CPU

*/

#include <nemo.h>

string defv[] = {
    "out=???\n           output binary data",		 
    "nscan=1\n           some help",
    "nchan=2048\n        some help",
    "wave=4096,100\n     wavelengths of components",
    "amp=100000,100\n    amps of the components",
    "noise=10\n          some help",
    "tab=f\n             ASCII table out?",
    "VERSION=0.0\n       21-Apr-2021 XYZ",
    NULL,
};

string usage="int I/O benchmark";

string cvsid="$Id:$";

#define MAXP  8

void nemo_main()
{
  real waves[MAXP], amps[MAXP];
  int i,j,k;
  real d;
  int     nscan = getiparam("nscan");
  int     nchan = getiparam("nchan");
  real    noise = getrparam("noise");
  int    nwaves = nemoinpr(getparam("wave"), waves, MAXP);
  int    namps  = nemoinpr(getparam("amp"), amps, MAXP);
  int     *data = (int *) allocate(nchan*sizeof(int));
  bool     Qtab = getbparam("tab");
  stream outstr = stropen(getparam("out"),"w");
  
  if (nwaves != namps) error("must have same wave/amp");
  
  for (k=0; k<nscan; k++) {
    for (j=0; j<nchan; j++) {
      for (i=0, d=0.0; i<nwaves; i++) 
	d += amps[i] * sin( 2.0*j*PI/waves[i]);
      d += grandom(0.0,noise);
      data[j] = (int) d;
    }
    if (Qtab) {
      for (j=0; j<nchan; j++)
	fprintf(outstr,"%d\n",data[j]);
    } else
      fwrite(data, nchan, sizeof(int), outstr);
  }
  strclose(outstr);
}
