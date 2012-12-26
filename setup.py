from distutils.core import setup
from distutils.extension import Extension
import os
import sys

cmdclasses = {}
try:
    from Cython.Distutils import build_ext #@UnresolvedImport
except ImportError:
    pass
else:
    cmdclasses['build_ext'] = build_ext

setup(
    name='php-serialize',
    version='1.0',
    url='http://code.google.com/p/php-serizlize/',
    author='Maxim Oransky',
    author_email='maxim.oransky@gmail.com',
    description='Php serialization/deserialization implementation on Python',
#    packages=packages,
    cmdclass=cmdclasses,
    classifiers=[
        'Development Status :: 4 - Beta',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    ext_modules=[
        Extension("phpserialize_speedups", ["phpserialize_speedups.pyx"])
    ]
)



