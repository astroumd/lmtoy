# An LMT glossary (now supersesed by glossary.rst)

There are some overloaded and confusing terms in here.
E.g. *pixel/cell/beam* and *board/band/chassis* are notorious. Currently
*Resolution/FWHM* can be confusing too.



* **band**:  coherent section in frequency space. For **RSR** there are 6 bands, sometimes the word **board** is used as well.
LSR also uses this keyword.  

* **bank**:  OTF uses this, it's always 0.  There are 2 slots (bank 0 and 1) in the data file, but only 0 is used.

* **beam**:   in the 4x4 multi-beam. Not to be confused with the **FWHM**.  At 115 GHz the **FWHM** is about 16", at 86 GHz about 21".
The beam separation is 27.8"

* **board**:   for LSR these are the roach boards (4). For RSR they are called **chassis** (4). But in **RSR**
board has also been used where **band** is meant.

* **cell**: (most people would call this a pixel, but at LMT **pixel** is an overloaded word for the beams. In the gridder
we use --cell=

* **chassis**:  for RSR there are 4 chassis boards, similar to the roach boards.

* **ECSV**: (Enhanced Character Separated Values) a popular self-describing ascii table format popularized by astropy

* **FITS**: (Flexible Image Transport System): the export format for data-cube, although there is also a
waterfall cube (time-freq-pixel) cube available.   Unclear what we will use for pure spectra.
**SDFITS** seems overly complex. CLASS needs to be supported. Currently **RSR** exports ASCII tables, not even **ECSV**

* **FWHM**: (Full Width Half Max): the effective resolution of the beam if normally given in **FITS** keywords BMAJ,BMIN,BPA.
The term **resolution**

* **LSR**: (Spectral Line Reduction):  the software reduction Sequoia (3mm) data, and presumably in the future, Omaya (1mm)

* **pixel**: synonym for **beam** as in multi-beam. The keyword --pix_list= is used to select pixels (0..15) for processing.

* **ramp**: The ramp is the area where not all beams have been. Within the ramp there is thus a uniform coverage.
The ramp covers 3 beams (not FWHM, but pixel), so about 85".   For any maps smaller than about 200"
there is no good area of uniform coverage. Should have a plot of that here, and maybe compare that to a large
M51 area?

* **resolution**:   this term is used in the gridder, but it's not **FWHM**, it's lambda/D.  Keyword --resolution= is used
If selected this way, FWHM is set as 1.15 * resolution. But if resolution is chosen larger, what is the effective
FWHM?   It would be better to have a dimensionless term for **resolution/pixel** and a different name for resolution alltogether.

* **RSR**: (Redshift-Search-Receiver):  The single **pixel** receiver operating between 70 and 110 GHz in 6 separate
bands of 256 channels each.  Typical resolution: 100 km/s.  Each pixel is really dual-beam dual-pol.

* **SDFITS**: Single Dish **FITS** format, normally used to store raw or even calibrated spectra in a FITS BINTABLE format.
Each row in a BINTABLE has an attached RA,DEC (and other meta-data), plus the whole spectrum.

* **SFL**: Sanson-Flamsteed projection, used in LMT **FITS** files (the GLS - GLobal Sinusoidal is similar to SFL).




