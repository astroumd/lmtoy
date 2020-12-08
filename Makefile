# See the INSTALL.md notes on how to use this Makefile


# use wget or (caching) wgetc 
WGET = wget

help:
	@echo No help yet


git:  SpectralLineReduction dreampy3

SpectralLineReduction:
	git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction

dreampy3:
	git clone https://github.com/lmt-heterodyne/dreampy3


.PHONY:  build


# step 1 (or skip and use another python)
#        after this install, the start_python.sh should be sourced in the shell
install_python:
	./install_anaconda3 wget=$(WGET)

# step 2
install_lmtslr: SpectralLineReduction
	@echo python SLR
	(cd SpectralLineReduction; \
	python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip install -r requirements_lmtoy.txt; \
	pip install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make; cp spec_driver_fits	../bin)

# step 3
install_dreampy3: dreampy3
	@echo python dreampy3
	(cd dreampy3; \
	python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip install -r requirements_lmtoy.txt; \
	pip install -e .)


# Optional hack:  once we agree on a common ste of requirements, we can make a common step
#                 note the current step2 and step3 mean you can only run one of the two
common:
	(python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	pip install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip install -r dreampy3/requirements_lmtoy.txt; \
	pip install -e SpectralLineReduction; \
	pip install -e dreampy3)
