# Examples of LMT processings

These amend the examples given in SpectralLineReduction.

                    M51          M31        IRC+10216

      obs          7000"        1500"        700"   
      CPU           300"         200"         70"
      data size    13.3 GB       2.8 GB      1.6 GB
      memory       10.5 GB       4.0 GB      1.7 GB
      I/O speed      40 MB/s      20 MB/s     20 MB/s
      nspectra      400k         300k         92k
      nchan        2048         2048        2048
      #obsnum         1            3           1

## IRC+10216:   IRC_data

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


## M31:   M31_data

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


## M51:   M51_data

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

