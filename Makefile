
# use wget or wgetc (caching)
WGET = wgetc

help:
	@echo No help yet

.PHONY:  build dist doc



install_python:
	./install_anaconda3 wget=$(WGET)

SpectralLineReduction:
	git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction

dreampy3:
	git clone https://github.com/lmt-heterodyne/dreampy3

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

install_dreampy3: dreampy3
	@echo python dreampy3
	(cd dreampy3; \
	python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip install -r requirements_lmtoy.txt; \
	pip install -e .)


# in top level !!!
common:
	(python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	pip install -r SpectralLineReduction/requirements_lmtoy.txt; \
	pip install -r dreampy3/requirements_lmtoy.txt; \
	pip install -e SpectralLineReduction; \
	pip install -e dreampy3)
