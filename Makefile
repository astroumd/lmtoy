
# use wget or wgetc (caching)
WGET = wgetc

help:
	@echo No help yet

.PHONY:  build dist doc



install_python:
	./install_anaconda3 wget=$(WGET)

install_lmtslr:
	git clone --branch teuben1 https://github.com/teuben/SpectralLineReduction
	(cd SpectralLineReduction; \
	python -m venv lmtoy_venv; \
	source lmtoy_venv/bin/activate; \
	awk -F= '{print $$1}'  requirements.txt > requirements_any.txt ;\
	pip install -r requirements_any.txt; \
	pip install -e .)


