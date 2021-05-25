# Use Cases

Here we cover some basic use cases the codes will need to do.


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
