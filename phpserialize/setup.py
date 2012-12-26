# -*- coding: utf-8 -*-
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext #@UnresolvedImport

setup(
    cmdclass={'build_ext': build_ext},
    ext_modules=[Extension("_speedups", ["_speedups.pyx"])]
)
