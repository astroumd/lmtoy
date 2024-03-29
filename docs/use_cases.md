The spectral line reduction has two strong use cases for the DASHA
web-plotting: identifying bad data and setting limits on spectra
for baselines, or fitting lines.

# Use Case 1: identifying bad data

The traditional way to visually identify and isolate bad data is
to make a "waterfall" plot and then based in visual inspection find
regions with unusual signal or noise, and flagged them as bad based
on some combination of time, frequency, and beam. For example, for
SEQUOIA, we would display a 2-D waterfall image of the data for one beam with 
spectral channel running across the x-axis and time running down (or up)
the y-axis. 

The user would interact with this image by running a cursor over
the image to display time and spectral channel. Ideally the user
would be able to:

 A. use a cursor which reads out the current x and y coordinates

 B. draw a rectangle on the screen which would enclose a region to be
    designated bad.

In both interactions A and B, there would be an action associated
with the cursor or rectangle which would result in a writing of the
coordinate range to a python structure. This python structure would
then be used to generate a masking statement that is understood
by the pipeline, and would be utilized in a subsequent running of the
pipeline by the user.

Requirements: 

1. ability to display real coordinates of the cursor position and have
     an associated action which writes them to a python structure.
2. ability to create and manipulate a rectangle on the displayed image 
     and write the xmin,xmax,ymin,ymax of the rectangle back to a
     python structure.
3. ability to pan and zoom on the image to allow visual access to all
     spectral channels and time step with enough resolution to see
     and identify bad data at the level of 1 channel and 1 time step

# Use Case 2: 

The user needs to specify channel ranges for a line fit or for 
channel regions to fit and remove a baseline from the spectrum. The
user would specify 1 or more channel ranges by moving the cursor
on the image of the spectrum. In existing reduction programs, the
selection of a channel range is usually indicated by drawing a rectangle
which encloses the channel range on the screen.

Requirements:

1. ability to display a spectrum, possibly an average of many spectra
2. ability to use cursor to readout channel number
3. cursor action to allow designation of a start and stop channel for
     an interval and write those channel numbers to a python structure
4. ability to draw onto the image on the screen a box, or some other
     indicator of the selected regions.

 
# Use Case 3: Profile Fit

This is an advanced case where the initial conditions for a line fit
need to be given.
By drawing a box, the baseline level, the peak, mean velocity and width
are thus given. 
