# LMT SLpipeline Directory structure - current status (v0.3)

    W = WORK_LMT      - root of all pipeline results, working and PI accessible
    P = ProjectId     - e.g. 2018-S1-MU-8 (this is where .htaccess is)
    O = ObsNum        - (O can be O1, O1_O2, etc.)
    S = SourceName    - 
    B = BandName      - need to cover (not implented yet)
    L = LMT TAP shadow tree

#  sequoia

## Current Structure

     W/P/O/                    directory (currently 50-ish files)
         O/S_O.fits            1. flux flat 3d fits
         O/S_O.wt.fits         2. weight (2d)
         O/S_O.nf.fits         3. noise flat 3d fits 
         O/S_O.nfs.fits        4. noise flat smoothed 3d fits
         O/S_O.wf.fits         5. waterfall 3d fits (time,freq,beam)
         ...
         O/index.html         99. PI summary (only advertise #1,#2,#5)
         .
         O/S_O.nf.admit/     101. admit native resolution results
         O/S_O.nfs.admit/    102. admit smoothed results
         .
         .
         O_RAW.tar              - by request only
         O_TAP.tar              - TAP
         O_SRDP.tar             - SRDP
		 
	 W/P/L/O1                   - LMT TAP shadow lightweight tree
	       O1/index.html          ... only single obsnum's
		   O1_TAP.tar           - ??? should we keep that here ???


## Grouping:
     1. by radec        (e.g. M31, one per obsnum) - RSR 
     2. by (rest)freq   (e.g. M83, one per obsnum)
     3. by restfreq     IRC+1021 has two lines (PI parameter, or ADMIT ?)
     4. by band         when we have the 4 new roach boards
 
**note:**   forced combining by different sourcenames (M51_north, M51, M51_south)


# Grant_Data_Product_Filenames.pdf

**single:**  *Instrument_ProjectID_ArrayName_ObsGoal_ObsNum_SourceName_ReductionTime.fits*

**combine:** *Instrument_ProjectID_ArrayName_SourceName_ReductionTime.fits*

e.g.     **SEQUOIA_2018-S1-MU-8_A1100_Science_91112_NGC5194_2022-01-11T13:55:42.fits**

- note that most components have a corresponding FITS keyword
- ReductionTime  ?=    date -u +%Y-%m-%dT%H:%M:%S  e.g.  2022-01-11T13:55:42
- note that a : in a filename does not play nice on windows filesystem
- This ignores Band number (future SL expansion we will need, like spwNN in ALMA)
- for SEQUOIA the ArrayName makes little sense
