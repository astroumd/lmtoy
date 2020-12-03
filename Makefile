
# use wget or wgetc (caching)
WGET = wgetc

help:
	@echo No help yet

.PHONY:  build dist doc



install_python:
	./install_anaconda3 wget=$(WGET)

SpectralLineReduction:
	git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction

install_lmtslr: SpectralLineReduction
	@echo python
	(cd SpectralLineReduction; \
	python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_lmtoy.txt ; \
	pip install -r requirements_lmtoy.txt; \
	pip install -e .)
	@echo C
	(cd SpectralLineReduction/C ; make; cp spec_driver_fits	../bin)


