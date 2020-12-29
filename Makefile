# See the INSTALL.md notes on how to use this Makefile
# what is shown here to install, is just one of many paths

#
SHELL = /bin/bash

# use standard wget or Peter's caching wgetc 
WGET = wget

URL1  = https://github.com/teuben/SpectralLineReduction
URL1a = https://github.com/teuben/SpectralLineReduction
URL2  = https://github.com/lmt-heterodyne/dreampy3
URL3  = https://github.com/lmt-heterodyne/SpectralLineConfigFiles
URL4  = https://github.com/Caltech-IPAC/Montage
URL5  = https://github.com/teuben/nemo

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

config:
	./configure


git:  SpectralLineReduction SpectralLineConfigFiles dreampy3

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

# step 1 (or skip and use another python)
#        after this install, the start_python.sh should be sourced in the shell
install_python:
	./install_anaconda3 wget=$(WGET)

lmtoy_venv:
	python3 -m venv lmtoy_venv


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
	(cd SpectralLineReduction/C ; make install)

# step 2b
install_lmtslr:  SpectralLineReduction
	(cd SpectralLineReduction; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install --upgrade pip ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make install)

# step 3
install_dreampy3: dreampy3 lmtoy_venv
	@echo python3 dreampy3
	(cd dreampy3; \
	source ../lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)

# step 4 (optional)
install_montage:  Montage
	(cd Montage; make)
	# @todo: install the (2?) python interfaces

# step 5 (optional)
install_nemo:  nemo
	(cd nemo; ./configure; make build MAKELIBS=corelibs)

# Optional hack:  once we agree on a common ste of requirements, we can make a common step
#                 note the current step2 and step3 mean you can only run one of the two
common: lmtoy_venv
	(source lmtoy_venv/bin/activate; \
	pip install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip install -r dreampy3/requirements_lmtoy.txt; \
	pip install -e SpectralLineReduction; \
	pip install -e dreampy3)


# git pull on all repos we use here
DIRS = SpectralLineReduction nemo Montage
pull:
	@echo -n "lmtoy: "; git pull
	-@for dir in $(DIRS); do\
	(echo -n "$$dir: " ;cd $$dir; git pull); done
