The spectral line reduction has two strong use cases for the DASHA
web-plotting: identifying bad data and setting limits on spectra
for baselines, or fitting lines.

# Use Case 1: identifying bad data

The traditional way to visually identify and isolate bad data is
to make a "waterfall" plot and then based in visual inspection find
regions with unusual signal or noise, and flagged them as bad based
on some combination of time, frequency, and beam. For example, for
SEQUOIA, we would display a 2-D image ofthe data for one beam with 
spectral channel running across the x-axis and time running down 
the y-axis. 

The user would interact with this image by running a cursor over
the image to display time and spectral channel. Ideally the user
would be able to:
A. use a cursor which reads out the current x and y coordinates
B. draw a rectangle on the screen which would enclose a region to be
    designated bad.

In both interactions A and B, there would be an action associated
with the cursor or rectange which would result in a writing of the
coordinate range to a python structure. This pyton structure would
then be used to generate a masking statement that is understood
by the pipeline, and would be utilized in a new running of the
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

## dasha/plotly/matplotlib:   range selector

In an X-Y plot we need to select an Xmin and Xmax. For example
for setting where the fit the baseline.  Or to mask a region
where a birdy is in the spectrum.



## dasha/plotly/matplotlib:   box selector

In an X-Y image, for example a waterfall image for a given Sequoia pixel,
we need to be able to set a box, where data is bad.
It should also be able to set one of the two dimensions to the max dimension
in that image (i.e. for all times in a freq range (birdy?), or for all frequencies
in a time-range. 
