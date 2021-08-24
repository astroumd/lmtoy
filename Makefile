# See the INSTALL.md notes on how to use this Makefile
# what is shown here to install, is just one of many paths

#
SHELL = /bin/bash

# use standard wget or Peter's caching wgetc 
WGET = wget

# use python3 or anaconda3
PYTHON = anaconda3

URL1  = https://github.com/teuben/SpectralLineReduction
URL1a = https://github.com/teuben/SpectralLineReduction
URL2  = https://github.com/lmt-heterodyne/dreampy3
URL3  = https://github.com/lmt-heterodyne/SpectralLineConfigFiles
URL4  = https://github.com/Caltech-IPAC/Montage
URL5  = https://github.com/teuben/nemo
URL6  = https://github.com/teuben/maskmoment
URL7  = https://github.com/gopastro/sculpt
URL8  = https://github.com/LMTdevs/RSR_driver
URL9a = https://github.com/toltec-astro/dasha
URL9b = https://github.com/toltec-astro/tollan
URL9c = https://github.com/toltec-astro/tolteca
URL10a= https://github.com/astropy/specutils
URL10b= https://github.com/pyspeckit/pyspeckit
URL11 = https://github.com/astroumd/admit
URL12a= https://github.com/b4r-dev/pipeline
URL12b= https://github.com/b4r-dev/notebooks
URL12c= https://github.com/b4r-dev/devtools
URL13a= https://github.com/gopastro/cubevis
URL13b= https://github.com/gopastro/sculpt

.PHONY:  help install build


help install:
	@echo "The installation has a few manual steps:"
	@echo "1. install python (or skip it if you have it)"
	@echo "  make install_python"
	@echo "  source python_start.sh"
	@echo "2. install LMTSLR"
	@echo "  make install_lmtslr"
	@echo "3. Configure LMTOY for others to use it"
	@echo "  make config"
	@echo "  source lmtoy_start.sh"
	@echo "Users will then see an environment variable LMTOY: $(LMTOY)"
	@echo ""
	@echo "Other useful targets:"
	@echo "    make pull                  update all git repos"
	@echo "    make status                view git status in all repos"
	@echo ""

# git directories we should have here

GIT_DIRS = SpectralLineReduction dreampy3 maskmoment RSR_driver nemo Montage b4r

git:  $(GIT_DIRS)
	@echo Last git: `date` >> git.log

pull:
	@echo -n "lmtoy: "; git pull
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git pull); done
	@echo Last pull: `date` >> git.log

status:
	@echo -n "lmtoy: "; git status -uno
	-@for dir in $(GIT_DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git status -uno); done


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


SpectralLineReduction:
	git clone --branch teuben1 $(URL1a)
	(cd SpectralLineReduction; git remote add upstream $(URL1) )

SpectralLineReduction_upstream:
	git clone $(URL1a) SpectralLineReduction_upstream

SpectralLineConfigFiles:
	git clone $(URL3)

dreampy3:
	git clone $(URL2)

Montage:
	git clone $(URL4)

nemo:
	git clone $(URL5)

maskmoment:
	git clone --branch teuben1 $(URL6)

sculpt:
	git clone $(URL7)

RSR_driver:
	git clone $(URL8)

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

admit:
	git clone $(URL11)
	(cd admit; git checkout python3)

b4r:
	mkdir -p b4r
	(cd b4r; git clone $(URL12a))
	(cd b4r; git clone $(URL12b))
	(cd b4r; git clone $(URL12c))


# step 1 (or skip and use another python)
#        after this install, the start_python.sh should be sourced in the shell
install_python:
	./install_$(PYTHON) wget=$(WGET)

lmtoy_venv:
	python3 -m venv lmtoy_venv

pip:
	pip install -r requirements.txt


# I find venv not working for me during development.

# step 2a
install_lmtslr_venv: SpectralLineReduction lmtoy_venv
	@echo python3 SLR
	(cd SpectralLineReduction; \
	source ../lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install --upgrade pip ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make clean install; ./spec_driver_fits)

# step 2b
install_lmtslr:  SpectralLineReduction
	(cd SpectralLineReduction; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
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
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)

install_dreampy3: dreampy3 RSR_driver
	@echo python3 dreampy3
	(cd dreampy3; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
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

# step 4 (optional)
install_montage:  Montage
	(cd Montage; make)
	@echo  @todo: install the python interface for Montage

# step 5 (optional; pick YAPP=ps or YAPP=pgplot)
YAPP = ps
install_nemo:  nemo
	(cd nemo; ./configure --with-yapp=$(YAPP); make build1 build2 build3 MAKELIBS=corelibs)

install_nemo_pgplot:  nemo
	(cd nemo; ./configure --with-yapp=pgplot; make build1 build2 build3 MAKELIBS=corelibs)

update_nemo:	nemo
	(cd nemo; make build2a build3 MAKELIBS=corelibs)

install_maskmoment: maskmoment
	(cd maskmoment; pip install -e .)

# Optional hack:  once we agree on a common ste of requirements, we can make a common step
#                 note the current step2 and step3 mean you can only run one of the two
common: lmtoy_venv
	(source lmtoy_venv/bin/activate; \
	pip install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip install -r dreampy3/requirements_lmtoy.txt; \
	pip install -e SpectralLineReduction; \
	pip install -e dreampy3)


