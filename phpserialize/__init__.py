"""
php serialize / unserialize implementation in Python
http://github.com/sdfsdhgjkbmnmxc/phpserialize
"""
try:
    from phpserialize_speedups import serialize, unserialize
# except (ImportError, AttributeError):
except ImportError:
    from core import serialize, unserialize
from core import PHP_Class
