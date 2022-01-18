# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)


PJT = ursa.astro.umd.edu:public_html/LMT/lmtoy

pjt: nbs lastmod html
	rsync -av build/html $(PJT)
	echo See also: https://www.astro.umd.edu/~teuben/LMT/lmtoy/html

lastmod:
	echo "Last modified `date` on `hostname`" > source/lastmod.rst

nbs:
	(cd source; make all)

# https://github.com/spatialaudio/nbsphinx/issues/170
#   Include notebooks from outside the root directory
# https://github.com/sphinx-doc/sphinx/issues/701
#   relative links in toctree 
