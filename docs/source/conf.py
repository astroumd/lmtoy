# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
sys.path.insert(0, os.path.abspath('../../lmtoy'))
sys.path.insert(0, os.path.abspath('../../SpectralLineReduction/lmtslr'))
sys.path.insert(0, os.path.abspath('../../dreampy3/dreampy3'))


# -- Project information -----------------------------------------------------

#import pdrtpy
#import sphinx_automodapi
from time import localtime

project = 'lmtoy'
# The full version, including alpha/beta/rc tags
# release = pdrtpy.VERSION
release = "1.0"
year = str(localtime().tm_year)
#author = pdrtpy.AUTHORS
author = "Peter Teuben"
copyright = year+" "+author


# https://github.com/miyakogi/m2r#sphinx-integration
#source_suffix = '.rst'
source_suffix = ['.rst', '.md', '.ipynb']
master_doc = 'index'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.doctest',
    'sphinx.ext.todo',
    'sphinx.ext.coverage',
    'sphinx.ext.mathjax',
    'sphinx.ext.viewcode',
    'sphinx.ext.intersphinx',
    'nbsphinx',
    'numpydoc',
    'm2r2',
    # 'm2r'         # does not work yet
]
numpydoc_show_class_members = True
#autosummary_generate = True

intersphinx_mapping = { 
    'python': ('https://docs.python.org/3', None),
    'numpy': ('http://docs.scipy.org/doc/numpy/', None),
    'scipy': ('http://docs.scipy.org/doc/scipy/reference/', None),
    'astropy': ('http://docs.astropy.org/en/stable/', None),
    'matplotib': ('http://matplotlib.org/',None)
}

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'bizstyle'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
#html_static_path = ['_static']
