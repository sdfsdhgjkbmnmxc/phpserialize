from distutils.core import setup
from distutils.extension import Extension

setup(
    name='phpserialize',
    version='1.0',
    url='http://github.com/sdfsdhgjkbmnmxc/phpserialize',
    author='Maxim Oransky',
    author_email='maxim.oransky@gmail.com',
    description='Php serialization/deserialization implementation on Python',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Topic :: Software Development :: Libraries :: Python Modules',
    ],
    packages=[
        'phpserialize',
    ],
    ext_modules=[
        Extension("phpserialize_speedups", ["phpserialize_speedups.c"])
    ]
)
