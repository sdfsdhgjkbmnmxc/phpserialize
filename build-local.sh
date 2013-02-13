#!/bin/sh
cython -a phpserialize/_speedups.pyx
python setup.py build_ext --inplace
python tests/tests.py