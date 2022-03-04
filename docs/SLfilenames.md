# LMT SLpipeline Directory structure - current status (v0.4)

    D = DATA_LMT      - root of the (read-only) RAW data 
    W = WORK_LMT      - root of all pipeline results, working and PI accessible
    P = ProjectId     - e.g. 2018-S1-MU-8 (this is where .htaccess is)
    S = SourceName    - PI provided
    O = ObsNum        - (O can be O1, O1_O2, etc.)
    B = BandName      - (0,1 currently)
    L = LMT           - TAP shadow tree
	

#  SLR (SEQUOIA, 1MM, OMAYA)

## Current Structure

     W/P/O/                    directory (currently 50-ish files)
	     O/S_O_B.nc              0. specfile
         O/S_O_B.fits            1. flux flat 3d fits
         O/S_O_B.wt.fits         2. weight (2d)
         O/S_O_B.nf.fits         3. noise flat 3d fits 
         O/S_O_B.nfs.fits        4. noise flat smoothed 3d fits
         O/S_O_B.wf.fits         5. waterfall 3d fits (time,freq,beam)
         ...
         O/index.html           99. PI summary (only advertise #1,#2,#5)
         .
         O/S_O_B.nf.admit/     101. admit native resolution results
         O/S_O_B.nfs.admit/    102. admit smoothed results
         .
         .
         O_RAW.tar              - by request only
         O_TAP.tar              - TAP
         O_SRDP.tar             - SRDP
		 
	 W/P/L/O1                   - LMT TAP shadow lightweight tree
	       O1/...                 only single obsnum's
	       O1/index.html          PI summary
		   O1_TAP.tar           - probably no need to keep this


## Grouping:
     1. by radec        (e.g. M31, one per obsnum) - RSR 
     2. by (rest)freq   (e.g. M83, one per obsnum)
     3. by restfreq     IRC+1021 has two lines (PI parameter, or ADMIT ?)
     4. by band         when we have the new roach boards, B=0,1 will be needed
	                    this will result in filenames such as S_O_B.fits
						For RSR the 6 bands will normally be bandmerged
						to S_O.fits
 
**note:**   forced combining by different sourcenames (M51_north, M51, M51_south)

# RSR

To be written, the current filenames are based on the two different scripts
and only produce a text based spectrum, viz.

      rsr.33551.blanking.sum.txt
	  rsr.33551.driver.sum.txt
	  
which should become

      I10565_33551.txt
      I10565_33551.fits
	  
following the SLR convention.

# Grant_Data_Product_Filenames.pdf

**single:**  *Instrument_ProjectID_ArrayName_ObsGoal_ObsNum_SourceName_ReductionTime.fits*

**combine:** *Instrument_ProjectID_ArrayName_SourceName_ReductionTime.fits*

e.g.     **SEQUOIA_2018-S1-MU-8_A1100_Science_91112_NGC5194_2022-01-11T13:55:42.fits**

- note that most components have a corresponding FITS keyword
- ReductionTime  ?=    date -u +%Y-%m-%dT%H:%M:%S  e.g.  2022-01-11T13:55:42
- note that a : in a filename does not play nice on windows filesystem
- This ignores Band number (future SL expansion we will need, like spwNN in ALMA)
- for SEQUOIA the ArrayName makes little sense

# LMT SL RAW data

some examples

	ifproc/ifproc_2020-02-20_091112_00_0001.nc
	spectrometer/roach0/roach0_91112_0_1_NGC5194_2020-02-20_060348.nc
	spectrometer/roach1/roach1_91112_0_1_NGC5194_2020-02-20_060348.nc
	spectrometer/roach2/roach2_91112_0_1_NGC5194_2020-02-20_060348.nc
	spectrometer/roach3/roach3_91112_0_1_NGC5194_2020-02-20_060348.nc

	RedshiftChassis0/RedshiftChassis0_2015-01-22_033551_00_0001.nc
	RedshiftChassis1/RedshiftChassis1_2015-01-22_033551_00_0001.nc
	RedshiftChassis2/RedshiftChassis2_2015-01-22_033551_00_0001.nc
	RedshiftChassis3/RedshiftChassis3_2015-01-22_033551_00_0001.nc

# ALMA 

As another extreme, here is an example of the ALMA SOUS/GOUS/MOUS archive hierarchy:

	2016.2.00005.S/
		science_goal.uid___A001_X1234_X1f6/
			group.uid___A001_X1234_X1f7/
				member.uid___A001_X1234_X1f8/calibration
				member.uid___A001_X1234_X1f8/log
				member.uid___A001_X1234_X1f8/qa
				member.uid___A001_X1234_X1f8/raw
				member.uid___A001_X1234_X1f8/script
				member.uid___A001_X1234_X1f8/product/
					uid___A001_X1234_X1f8.J1922+1530_ph.spw16.mfs.I.pbcor.fits
					uid___A001_X1234_X1f8.J1922+1530_ph.spw16.mfs.I.pb.fits.gz
					uid___A001_X1234_X1f8.W51_sci.spw16_18_20_22.cont.I.alpha.fits
					uid___A001_X1234_X1f8.W51_sci.spw16.cube.I.pbcor.fits
					uid___A001_X1234_X1f8.W51_sci.spw16.cube.I.pb.fits.gz
					....

