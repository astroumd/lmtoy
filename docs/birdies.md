# Birdies

Predominantly appear in the lower bandwidth modes, 400MHz and 200MHz data, but some have been seen in 800MHz as well.

In 400MHz 3 channels to the side-lobe = 300 kHz

In 200MGz 6 channels = 300 kHz

Two types of birdies?

1.  Tsys birdies
2.  Data birdies (using constant Tsys they still show up in data)

## Data with birdies

### Commisioning Data

Usually the respective README.md files in the script generators have more information. Sometimes
there appears to be a relationship between birdies and bad ("wavy") beams, but just to clarify:
birdies do not appear in all beams.

Here's a summary of the birdies

* 2022 94050 400MHz 86.243442 - R-Cas - very odd alias of the SiO line in bad beams 12,13 +birdies

* 2023 109941 400MHz 86.2434,88.6318 - R-Leo - also aliased SiO line in beams 12,13, but larger delta-freq
* 2023 108768 800MHz 115.27120,110.20135
* 2023 107996 800MHz 86.243442,88.631847       no birdies
* 2023 107666 800MHz 115.271204 - no birdies

* 2024 111082 800MHz no birdies
* 2024 110407 200MHz 115.2712 MonR2 many messy beams, with birdies

### Science Data

* 2024-S1-MX-37 400MHz L1157-B1  87.88,95.936     0:0,1,4,5,10,11,12   1:2,3,8,9,13,14  (some later ones practically all beams)119728
* 2021-S1-MX-14 800MHz L1157-B1  87.848 - 0:2,6    tsys all beams, data only in 0:2,6
* 2018-S1-MU-45 800MHz L1157-B1  95.955 - but no birdies
* 2023-S1-MX-49 400MHz L1157-B1  87.88,95.936  109989   0:5,12,13  1:2,4,5,8,9,14,15


* 2018-S1-MU-46 ?
* 2018-S1-MU-65 200MHz  IRAS04166+2706_B  
* 2018-S1-MU-8 M51/N6??  - birdies in Tsys, but only 1 in data - only at 88.631847 GHz
     * 90139-90286 (jan 29/30) bad
     * 90381-90462 (feb 10/11)  are ok
* 2021-S1-MX-3 800MHz [only in Arp143] - 97955 weak in spectra, strong in Tsys
* 2023-S1-UM-15 200MHz HB114_13CO - 1 bank mistake -  200MHz - w/ birdies

* 2024-S1-MX-2   400MHz G1/G358     115.271202,110.201354   112139/   0:0,1,4,5,10,11,12  1:2,3,8,9
     * For G358 the birdies are present
     * For G1 no birdies
* 2023-S1-UM-16  400MHz G1         115.271202,110.201354      - no birdies, as in MX-2




redo 2018-S1-MU-65
0-14
i.e.  vlsr=6.9   dv=10  dw=20

redo 2023-S1-UM-16



for o in $(lmtinfo.py grep 2022S1SEQUOIACommissioning Pointing | tabcols - 2); do echo -n "$o ";lmtinfo.py $o | grep bandwidth; done
for o in $(lmtinfo.py grep 2023S1SEQUOIACommissioning Pointing | tabcols - 2); do echo -n "$o ";lmtinfo.py $o | grep bandwidth; done
for o in $(lmtinfo.py grep 2024S1SEQUOIACommissioning Pointing | tabcols - 2); do echo -n "$o ";lmtinfo.py $o | grep bandwidth; done
110045 bandwidth=0.8,0.8   # Ghz
