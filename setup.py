from distutils.core import setup
from distutils.extension import Extension


setup(
    name='phpserialize',
    version='1.1',
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
        Extension("phpserialize._speedups", ["phpserialize/_speedups.c"])
    ],
)
