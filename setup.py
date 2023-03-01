#!/usr/bin/env python
#

import os
import sys

# from setuptools import setup

from setuptools import setup, find_packages

modcontents = open('lmtoy/__init__.py').read()

setup(
    name = 'lmtoy',
    version = open('VERSION').read().strip(),
    author = 'Peter Teuben',
    author_email = 'teuben@umd.edu',
    description = 'tools to assemble an LMT spectral line pipeline',
    license = 'MIT',
    keywords = 'astronomy',
    url = 'https://github.com/astroumd/lmtoy',
    packages = find_packages(),
    install_requires = ['numpy'],
)

