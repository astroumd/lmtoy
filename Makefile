# See the INSTALL.md notes on how to use this Makefile

#
SHELL = /bin/bash

#
TIME = /usr/bin/time

# use standard wget or Peter's caching wgetc 
WGET = wget

# use python3 or anaconda3
PYTHON = anaconda3

# git directories we should have here

GIT_DIRS = SpectralLineReduction dreampy3 maskmoment RSR_driver nemo b4r \
           RedshiftPointing LinePointing dvpipe \
	   lmt_web lmtoy_dispatch pipeline_web

# URLs that we'll need

URL1  = https://github.com/lmt-heterodyne/SpectralLineReduction
URL1a = https://github.com/teuben/SpectralLineReduction
URL2  = https://github.com/lmt-heterodyne/dreampy3
URL3  = https://github.com/lmt-heterodyne/SpectralLineConfigFiles
URL4  = https://github.com/Caltech-IPAC/Montage
URL5  = https://github.com/teuben/nemo
URL6  = https://github.com/teuben/maskmoment
URL7  = https://github.com/gopastro/sculpt
URL8  = https://github.com/LMTdevs/RSR_driver
URL8a = https://github.com/teuben/RSR_driver
URL9a = https://github.com/toltec-astro/dasha
URL9b = https://github.com/toltec-astro/tollan
URL9c = https://github.com/toltec-astro/tolteca
URL10a= https://github.com/astropy/specutils
URL10b= https://github.com/pyspeckit/pyspeckit
URL11 = https://github.com/astroumd/admit
URL11a= https://casa.nrao.edu/download/distro/casa/release/el7/casa-release-5.8.0-109.el7.tar.gz
URL12a= https://github.com/b4r-dev/pipeline
URL12b= https://github.com/b4r-dev/notebooks
URL12c= https://github.com/b4r-dev/devtools
URL12d= https://github.com/b4r-dev/b4rpipe
URL13a= https://github.com/gopastro/cubevis
URL13b= https://github.com/gopastro/sculpt
URL14 = https://github.com/GreenBankObservatory/gbtgridder 
URL14a = https://github.com/teuben/gbtgridder
URL15 = https://github.com/lmt-heterodyne/RedshiftPointing
URL16 = https://github.com/lmt-heterodyne/LinePointing
URL17 = https://github.com/teuben/aplpy
URL18 = https://github.com/toltec-astro/dvpipe
URL19 = https://github.com/lmtoy/lmtoy_run
URL20 = https://github.com/lmtmc/lmt_web
URL21 = https://github.com/lmtmc/lmtoy_dispatch
URL22 = https://github.com/lmtmc/pipeline_web
URL23 = https://github.com/GreenBankObservatory/dysh


.PHONY:  help install build


install:
	@echo "The installation has a few manual steps, it is best to consult the docs/install_lmtoy script for an example"
	@echo "1. install python (or skip it if you have it)"
	@echo "  make install_python"
	@echo "  source python_start.sh"
	@echo "2. install LMTSLR and friends: (venv versions also exist)"
	@echo "  make install_lmtslr install_dreampy install_dvpipe install_maskmoment"
	@echo "3. Configure LMTOY for others to use it"
	@echo "  make config"
	@echo "  source lmtoy_start.sh"
	@echo "Users will then see an environment variable LMTOY: $(LMTOY)"
	@echo ""
	@echo "Other useful targets:"
	@echo "    make pull                  update all git repos"
	@echo "    make status                view git status in all repos"
	@echo "    make update                recompile updated repos"
	@echo "    make help                  a full list of all documented help"
	@echo "For a full list, type:  'make help'"
	@echo ""

help:
## help:      This Help
help : Makefile
	@sed -n 's/^##//p' $<


## git:       Get all git repos for this install
git:  $(GIT_DIRS)
	@echo Last git: `date` >> git.log

## pull:      Update all git repos
pull:
	@echo -n "lmtoy: "; git pull
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git pull); done
	@echo Last pull: `date` >> git.log

status:
	@echo -n "lmtoy: "; git status -uno
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git status -uno); done

branch:
	@echo -n "lmtoy: "; git branch --show-current
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git branch --show-current); done


config:  lmtoy_local.sh lmtoy_local.csh
	./configure

# local variations that override the lmtoy_start version
lmtoy_local.sh:
	@echo '# local LMTOY settings can go here'         > lmtoy_local.sh
	@echo '# export DATA_LMT=/data_lmt'               >> lmtoy_local.sh
	@echo '# export CORR_CAL_DIR=$$DATA_LMT/rsr/cal'  >> lmtoy_local.sh
	@echo '# export HDF5_DISABLE_VERSION_CHECK=2'     >> lmtoy_local.sh

lmtoy_local.csh:
	@echo '# local LMTOY settings can go here'         > lmtoy_local.csh
	@echo '# setenv DATA_LMT /data_lmt'               >> lmtoy_local.csh
	@echo '# setenv CORR_CAL_DIR $$DATA_LMT/rsr/cal'  >> lmtoy_local.csh
	@echo '# setenv HDF5_DISABLE_VERSION_CHECK 2'     >> lmtoy_local.csh


#  deprecated, this is where development took place Nov 2020 - March 2022
SpectralLineReduction_teuben1:
	git clone --branch teuben1 $(URL1a) SpectralLineReduction_teuben1
	(cd SpectralLineReduction_teuben1; git remote add upstream $(URL1) )

# March-2022 update
update1: SpectralLineReduction
	@echo "Swapping out an old SpectralLineReduction repo"
	mv SpectralLineReduction SpectralLineReduction_`date +%Y-%m-%d-%H%M%S`
	$(MAKE) SpectralLineReduction
	@echo "Depending on your python environment you should now do one of:"
	@echo "   make install_lmtslr"
	@echo "   make install_lmtslr_venv"

## update:    recompile what needs to be recompiled
update: update_lmtslr update_nemo
	(cd $(NEMO); make check)

SpectralLineReduction:
	git clone $(URL1)

SpectralLineConfigFiles:
	git clone $(URL3)

dreampy3:
	git clone $(URL2)

Montage:
	git clone $(URL4)

nemo:
	git clone $(URL5)

maskmoment:
	git clone --branch teuben2 $(URL6)

sculpt:
	git clone $(URL7)

RSR_driver:
	git clone --branch teuben1 $(URL8a)
	(cd RSR_driver; git remote add upstream https://github.com/LMTdevs/RSR_driver)

aplpy:
	git clone --branch fix_block_reduce $(URL17)
	@echo Only apply this if your aplpy is broken due to astropy5
	@echo pip install -e aplpy

dasha:
	git clone $(URL9a)

tollan:
	git clone $(URL9b)

tolteca:
	git clone $(URL9c)

specutils:
	git clone $(URL10a)

pyspeckit:
	git clone $(URL10b)

gbtgridder:
	git clone -b release_3.0 $(URL14)

gbtgridder_pjt:
	git clone -b python3 $(URL14a)

RedshiftPointing:
	git clone $(URL15)

LinePointing:
	git clone $(URL16)

dvpipe:
	git clone $(URL18)


lmtoy_run:	$(WORK_LMT)/lmtoy_run  lmtoy_run_git

$(WORK_LMT)/lmtoy_run:
	(cd $(WORK_LMT); git clone $(URL19); cd lmtoy_run; make git pull)


lmtoy_run_git:
	(cd $(WORK_LMT)/lmtoy_run; make git pull)
	@echo "Make sure you regularly 'make lmtoy_run' to update the script generators"

webrun:	lmt_web

lmt_web:
	git clone $(URL20)

lmtoy_dispatch:
	git clone $(URL21)

pipeline_web:
	git clone $(URL22)

dysh:
	git clone $(URL23)

# hack for Linux  (@todo Mac)
admit:
	git clone $(URL11)
	(cd admit; git checkout python3; autoconf)
	(cd admit; wget -O - $(URL11a) | tar zxf -)
	(cd admit; ln -s casa-release-5.8.0-109.el7 casa)
	(cd admit; ./configure --with-casa-root=`pwd`/casa)

# to test admit:
#     source admit_start.sh; make testdata; cd testdata; runa1 test0.fits

b4r:
	mkdir -p b4r
	(cd b4r; git clone $(URL12a))
	(cd b4r; git clone $(URL12b))
	(cd b4r; git clone $(URL12c))
	(cd b4r; git clone $(URL12d))
	@echo "All subdirectories here are independent B4R tools" > b4r/README
	@echo "See also https://github.com/b4r-dev"              >> b4r/README
	@echo "See also https://github.com/b4r-dev"


# step 1 (or skip and use another python)
#        after this install, the start_python.sh should be sourced in the shell
install_python:
	./install_$(PYTHON) wget=$(WGET)

lmtoy_venv:
	python3 -m venv lmtoy_venv

## basic:     pip install all the basic but essential ones
basic:
	make pip install_lmtslr install_dreampy3 install_dvpipe install_maskmoment

## pip:       basic requirement and lmtoy itself
pip:
	pip3 install -r requirements.txt
	pip3 install -e .

# I find venv not working for me during development.

# step 2a
install_lmtslr_venv: SpectralLineReduction lmtoy_venv
	@echo python3 SLR
	(cd SpectralLineReduction; \
	source ../lmtoy_venv/bin/activate; \
	pip3 install --upgrade pip ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make clean install; ./spec_driver_fits)

# step 2b
install_lmtslr:  SpectralLineReduction
	(cd SpectralLineReduction; \
	pip3 install --upgrade pip ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make clean install; ./spec_driver_fits)

update_lmtslr:  SpectralLineReduction
	@echo C
	(cd SpectralLineReduction/C ; make clean install; ./spec_driver_fits)

# step 3
install_dreampy3_venv: dreampy3 RSR_driver lmtoy_venv
	@echo python3 dreampy3
	(cd dreampy3; \
	source ../lmtoy_venv/bin/activate; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)

install_dreampy3: dreampy3 RSR_driver
	@echo python3 dreampy3
	(cd dreampy3; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)

install_dasha: dasha tollan
	@echo python3 dasha
	(cd tollan; pip3 install -e .)
	(cd dasha; pip3 install -e .)

install_astropy: specutils pyspeckit
	@echo specutils pyspeckit
	(cd specutils; pip3 install -e .)
	(cd pyspeckit; pip3 install -e .)

install_dvpipe:  dvpipe
	@echo dvpipe
	pip3 install -e dvpipe 

# step 4 (optional)
install_montage:  Montage
	(cd Montage; make)
	@echo  @todo: install the python interface for Montage

# step 5 (optional; pick YAPP=ps or YAPP=pgplot)
YAPP = ps
MKNEMOS = "pgplot cfitsio hdf5 netcdf4"
# install_mknemos:    install all NEMO 3rd party libraries from source (pgplot cfitsio hdf5 netcdf)
install_mknemos: nemo
	(cd nemo; ./configure; make build1 ; source nemo_start.sh; make mknemos MKNEMOS="$(MKNEMOS)")

## install_nemo:           formal NEMO install using YAPP=
install_nemo:  nemo
	(cd nemo; ./configure --with-yapp=$(YAPP); make build1 build2 build3 MAKELIBS=corelibs)

## install_nemo_pglocal:   install a NEMO with PGPLOT from source (mknemo pgplot)
install_nemo_pglocal:  nemo
	(cd nemo; source nemo_start.sh; ./configure --with-yapp=pgplot --enable-png --with-pgplot-prefix=$(NEMOLIB); make build1 build2 build3 MAKELIBS=corelibs)

## update_nemo:            quick update of what we need from NEMO
update_nemo:	nemo
	(cd nemo; make build2a build3 MAKELIBS=corelibs)

install_maskmoment: maskmoment
	(cd maskmoment; pip install -e .)

## fix_pdf:                on some systems ImageMagick won't convert PDF to PNG

fix_pdf: $(HOME)/.config/ImageMagick/policy.xml

$(HOME)/.config/ImageMagick/policy.xml:
	mkdir -p $(HOME)/.config/ImageMagick && cp etc/policy.xml  $(HOME)/.config/ImageMagick/policy.xml

# Optional hack:  once we agree on a common set of requirements, we can make a common step
#                 note the current step2 and step3 mean you can only run one of the two
common: lmtoy_venv
	(source lmtoy_venv/bin/activate; \
	pip3 install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip3 install -r dreampy3/requirements_lmtoy.txt; \
	pip3 install -e SpectralLineReduction; \
	pip3 install -e dreampy3)


# ---------------------------- benchmarks -------------------------------------------------------------------------------------------

META  = 1
ADMIT = 0
bench:  bench1 bench5 bench2 bench3 

## bench1:   RSR 30m benchmark: obsnum=33551
bench1:
	@echo sbatch_lmtoy.sh etc/bench1.run
	$(TIME) SLpipeline.sh obsnum=33551 restart=1 linecheck=1 public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench1.txt'
	@echo "================================================================================================================="
	@echo xdg-open  $(WORK_LMT)/2014ARSRCommissioning/33551/README.html

## bench5:   RSR 50m benchmark: obsnum=110670
bench5:
	$(TIME) SLpipeline.sh obsnum=110670 restart=1 linecheck=1 public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench5.txt'
	@echo "================================================================================================================="
	@echo xdg-open  $(WORK_LMT)/2024ARSRCommissioning/110670/README.html

## bench1a:  RSR benchmark with a combination
bench1a:
	$(TIME) SLpipeline.sh obsnum=33552 restart=1 linecheck=1 public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	$(TIME) SLpipeline.sh obsnums=33551,33552 restart=1 admit=$(ADMIT) meta=$(META)
	$(TIME) SLpipeline.sh obsnums=33552,33551 restart=1 admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench1a.txt'
	@echo "================================================================================================================="
	@echo xdg-open  $(WORK_LMT)/2014ARSRCommissioning/33551_33552/README.html

## bench1b:  RSR dryrun archive submission using dvpipe (needs bench1)
bench1b:
	(cd $(WORK_LMT)/2014ARSRCommissioning/dir4dv/33551; upload_project.sh in=. out=/tmp/dvout publish=0 verbose=1 overwrite=1)

## bench2:   SEQ benchmark: obsnum=79448
bench2:
	@echo sbatch_lmtoy.sh etc/bench2.run
	$(TIME) SLpipeline.sh obsnum=79448 restart=1 map_coord_use=1 public=2020-12-31 qagrade=3 maskmoment=$(ADMIT) admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench2.txt'
	@echo "========================================================================================"
	@echo xdg-open  $(WORK_LMT)/2018S1SEQUOIACommissioning/79448/README.html

## bench2a:  SEQ benchmark with identical combination
bench2a:
	$(TIME) SLpipeline.sh obsnums=79448,79448 restart=1 admit=$(ADMIT) meta=$(META)

## bench3:   SEQ dual IF benchmark (about 1.5 min)
bench3:
	@echo sbatch_lmtoy.sh etc/bench3.run
	$(TIME) SLpipeline.sh obsnum=110399 restart=1 extent=120 maskmoment=$(ADMIT) public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench3.txt'
	@echo "========================================================================================"
	@echo xdg-open  $(WORK_LMT)/2024S1SEQUOIACommissioning/110399/README.html

## bench4:   SEQ/Ps benchmark
bench4:
	$(TIME) SLpipeline.sh _s=VX-Sgr/PS obsnum=108764 restart=1 public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	$(TIME) SLpipeline.sh _s=VX-Sgr/BS obsnum=108766 restart=1 public=2020-12-31 qagrade=3 admit=$(ADMIT) meta=$(META)
	@bash -c 'source lmtoy_functions.sh ; printf_green_file etc/bench4.txt'
	@echo xdg-open  $(WORK_LMT)/2023S1SEQUOIACommissioning/108764/README.html
	@echo xdg-open  $(WORK_LMT)/2023S1SEQUOIACommissioning/108766/README.html

## nemo5:     NEMO bench5
nemo5:
	(cd $(NEMO); $(TIME) make bench5)

## bench99:  to be documented and regressed
bench99:
	@echo 1MM PS/Gaincurve
	SLpipeline.sh obsnum=93562 restart=1
	@echo beam-map for 1mm
	SLpipeline.sh obsnum=93560 restart=1 goal=Pointing
	@echo beam-map for seq
	SLpipeline.sh obsnum=92984 restart=1 goal=Pointing 
