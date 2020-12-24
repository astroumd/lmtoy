# See the INSTALL.md notes on how to use this Makefile
# what is shown here to install, is just one of many paths

# use standard wget or Peter's caching wgetc 
WGET = wget

URL1  = https://github.com/teuben/SpectralLineReduction
URL1a = https://github.com/teuben/SpectralLineReduction
URL2  = https://github.com/lmt-heterodyne/dreampy3
URL3  = https://github.com/lmt-heterodyne/SpectralLineConfigFiles

.PHONY:  help install build



help install:
	@echo "The installation has a few manual steps:"
	@echo "1. install python (or skip it if you have it)"
	@echo "  make install_python"
	@echo "  source python_start.sh"
	@echo "2. install LMTSLR (in your python virtual environment)" 
	@echo "  make install_lmtslr"
	@echo "3. Configure LMTOY for others to use it"
	@echo "  ./configure"
	@echo "  source lmtoy_start.sh"
	@echo "Users will then see an environment variable LMTOY: $(LMTOY)"


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
	git clone https://github.com/Caltech-IPAC/Montage

# step 1 (or skip and use another python)
#        after this install, the start_python.sh should be sourced in the shell
install_python:
	./install_anaconda3 wget=$(WGET)

lmtoy_venv:
	python3 -m venv lmtoy_venv

# step 2
install_lmtslr: SpectralLineReduction lmtoy_venv
	@echo python3 SLR
	(cd SpectralLineReduction; \
	source ../lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make; cp spec_driver_fits	../bin)

# step 3
install_dreampy3: dreampy3 lmtoy_venv
	@echo python3 dreampy3
	(cd dreampy3; \
	source ../lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip3 install -r requirements_lmtoy.txt; \
	pip3 install -e .)


# Optional hack:  once we agree on a common ste of requirements, we can make a common step
#                 note the current step2 and step3 mean you can only run one of the two
common: lmtoy_venv
	(source lmtoy_venv/bin/activate; \
	pip install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip install -r dreampy3/requirements_lmtoy.txt; \
	pip install -e SpectralLineReduction; \
	pip install -e dreampy3)

