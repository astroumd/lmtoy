# Examples of LMT data processing

There are several processing paths for Sequoia data:  OTF, MAP, BS and PS.

See the Makefile of examples how to run a number of regressions/tests/benchmarks

## lmtoy_reduce.sh

See [lmtoy_reduce.md](lmtoy_reduce.md) on using the new experimental pipeline

## A typical OTF run

1. Convert the raw (spectra) data to a calibrated spectrum file.   Some selections, e.g. by pixel,
   Cannot select by time yet. Although all spectra are read (this costs memory), the output can
   be trimmed by whatever slice is selected

2. Plot the spectra of all or one pixel. View coverage, etc

3. Grid the spectrum file into a FITS cube. This is where one can select on RMS etc.  This will also
   produce a waterfall fits cube, which may be a little easier to understand than the plots from
   step 2.

4. Plot the cube, by picking a point to view a spectrum, slices, and a TMAX or TINT.  Or take your cube
   to your	favorite fits cube viewer (ds9, casaviewer, carta, qfitsview, ...)

5. If you have many OBSNUM's to process, the lmt_combine.sh script combines them, much like step 3. You
   can also use 3rd party tools to combine the cubes.


## Overview of three datasets


These amend the examples given in SpectralLineReduction.

      src             M51          M31        IRC
		    
      skytime        6934"        1471"        686"
      inttime        4984"        1297"        528"
      data size      13.3 GB       2.8 GB      1.6 GB
      data rate       1.9 MB/s     1.9 MB/s    2.3 MB/s
      CPU             300"         200"         70"
      processing rate  40 MB/s      20 MB/s     20 MB/s
      memory         10.5 GB       4.0 GB      1.7 GB
                  ?? 12.1 ??
      ntime           834k         231k       101k
      nspectra        340k         228k        92k
      nchan          2048         2048        2048
      size           8x12'         6x6'        8x8'
      noise           135mK        108mK       181mK

      #obsnum           1            3           1
      bad_pixels      0,5            3           - (1?)

      Cube size (MP) 12.8          5.7         8.5
      ADMIT CPU        70"          90"         90"



## IRC+10216:

        284 ./ifproc/ifproc_2018-11-16_079447_00_0001.nc
      27872 ./ifproc/ifproc_2018-11-16_079448_01_0000.nc
       3864 ./spectrometer/roach0/roach0_79447_0_1_IRC+10216_2018-11-16_114830.nc
     404540 ./spectrometer/roach0/roach0_79448_1_0_IRC+10216_2018-11-16_114845.nc
       3868 ./spectrometer/roach1/roach1_79447_0_1_IRC+10216_2018-11-16_114830.nc
     404632 ./spectrometer/roach1/roach1_79448_1_0_IRC+10216_2018-11-16_114845.nc
       3932 ./spectrometer/roach2/roach2_79447_0_1_IRC+10216_2018-11-16_114830.nc
     405116 ./spectrometer/roach2/roach2_79448_1_0_IRC+10216_2018-11-16_114845.nc
       3996 ./spectrometer/roach3/roach3_79447_0_1_IRC+10216_2018-11-16_114830.nc
     405252 ./spectrometer/roach3/roach3_79448_1_0_IRC+10216_2018-11-16_114845.nc

The 79447 obsnum refers to the "Cal", and 79448 to an OTF map of the source (IRC+10216).
Via the Makefile you can run **make bench** which should report

      QAC_STATS: IRC_79448.fits.ccd 0.0153953 0.503169 -66.2138 75.2123  0 0.0720699

as well as a CPU time output. Here are some examples how long the benchmark takes

      205.84user 7.96system 3:42.94elapsed 95%CPU    "chara", Xeon E3-1280 @ 3.50GHz 
      179.97user 4.61system 3:09.17elapsed 97%CPU    "cln" @UMass; Xeon E5-1630 v3 @ 3.70GHz
      151.71user 2.12system 2:34.57elapsed 99%CPU    "lma" @UMD; AMD EPYC 7302 16-Core Processor
      110.78user 2.03system 1:52.83elapsed 99%CPU    "xps13", Peter's i5-1135G7 based laptop
      
## M31:

        284 ./ifproc/ifproc_2019-10-31_085775_00_0001.nc
      64324 ./ifproc/ifproc_2019-10-31_085776_00_0001.nc
        284 ./ifproc/ifproc_2019-10-31_085777_00_0001.nc
      64768 ./ifproc/ifproc_2019-10-31_085778_00_0001.nc
        284 ./ifproc/ifproc_2019-11-01_085823_00_0001.nc
      64964 ./ifproc/ifproc_2019-11-01_085824_00_0001.nc
       3796 ./spectrometer/roach0/roach0_85775_0_1_Region_J-K_2019-10-31_070131.nc
     931520 ./spectrometer/roach0/roach0_85776_0_1_Region_J-K_2019-10-31_070149.nc
       3796 ./spectrometer/roach0/roach0_85777_0_1_Region_J-K_2019-10-31_073103.nc
     937968 ./spectrometer/roach0/roach0_85778_0_1_Region_J-K_2019-10-31_073122.nc
       3732 ./spectrometer/roach0/roach0_85823_0_1_Region_J-K_2019-11-01_070920.nc
     940760 ./spectrometer/roach0/roach0_85824_0_1_Region_J-K_2019-11-01_070938.nc
       3796 ./spectrometer/roach1/roach1_85775_0_1_Region_J-K_2019-10-31_070131.nc
     931648 ./spectrometer/roach1/roach1_85776_0_1_Region_J-K_2019-10-31_070149.nc
       3796 ./spectrometer/roach1/roach1_85777_0_1_Region_J-K_2019-10-31_073104.nc
     938096 ./spectrometer/roach1/roach1_85778_0_1_Region_J-K_2019-10-31_073122.nc
       3796 ./spectrometer/roach1/roach1_85823_0_1_Region_J-K_2019-11-01_070920.nc
     941016 ./spectrometer/roach1/roach1_85824_0_1_Region_J-K_2019-11-01_070938.nc
       3928 ./spectrometer/roach2/roach2_85775_0_1_Region_J-K_2019-10-31_070131.nc
     931968 ./spectrometer/roach2/roach2_85776_0_1_Region_J-K_2019-10-31_070149.nc
       3928 ./spectrometer/roach2/roach2_85777_0_1_Region_J-K_2019-10-31_073104.nc
     938352 ./spectrometer/roach2/roach2_85778_0_1_Region_J-K_2019-10-31_073122.nc
       3864 ./spectrometer/roach2/roach2_85823_0_1_Region_J-K_2019-11-01_070920.nc
     941144 ./spectrometer/roach2/roach2_85824_0_1_Region_J-K_2019-11-01_070938.nc
       3928 ./spectrometer/roach3/roach3_85775_0_1_Region_J-K_2019-10-31_070131.nc
     932128 ./spectrometer/roach3/roach3_85776_0_1_Region_J-K_2019-10-31_070149.nc
       3928 ./spectrometer/roach3/roach3_85777_0_1_Region_J-K_2019-10-31_073104.nc
     938544 ./spectrometer/roach3/roach3_85778_0_1_Region_J-K_2019-10-31_073122.nc
       3928 ./spectrometer/roach3/roach3_85823_0_1_Region_J-K_2019-11-01_070920.nc
     941468 ./spectrometer/roach3/roach3_85824_0_1_Region_J-K_2019-11-01_070938.nc


## M51:

         304 ./ifproc/ifproc_2020-02-20_091111_00_0001.nc
      247476 ./ifproc/ifproc_2020-02-20_091112_00_0001.nc
        3732 ./spectrometer/roach0/roach0_91111_0_1_NGC5194_2020-02-20_060329.nc
     3343900 ./spectrometer/roach0/roach0_91112_0_1_NGC5194_2020-02-20_060348.nc
        3796 ./spectrometer/roach1/roach1_91111_0_1_NGC5194_2020-02-20_060329.nc
     3352484 ./spectrometer/roach1/roach1_91112_0_1_NGC5194_2020-02-20_060348.nc
        3864 ./spectrometer/roach2/roach2_91111_0_1_NGC5194_2020-02-20_060329.nc
     3363052 ./spectrometer/roach2/roach2_91112_0_1_NGC5194_2020-02-20_060348.nc
        3928 ./spectrometer/roach3/roach3_91111_0_1_NGC5194_2020-02-20_060330.nc
     3370720 ./spectrometer/roach3/roach3_91112_0_1_NGC5194_2020-02-20_060348.nc

## Filenames:   (ObsNum,SubObsNum,ScanNum)

A keen observer may have noticed some oddities in the filenames, for example for the IFPROC the obsnum has 6 digits,
for the ROACH files they have 5. The **ObsNum** is followed by two other integers, the **SubObsNum** and the
**ScanNum**

For IRC we have **079447_00_0001** and **079448_01_0000** (this is a mistake in the 2nd, Map, data)
but for M51/M31 we have **091111_00_0001** and **091112_00_0001**, which is the expected pattern.

Kamal says the ScanNum starts at 0 for Ps and at 1 for OTF.  The
ObsPgms increment the SubObsNum if they are in SubObsMode.

Examples of RSR: 010185_00_0001, but we do have 092085_00_0000 and 092087_00_0001 that don't fits the 0,1 pattern.
