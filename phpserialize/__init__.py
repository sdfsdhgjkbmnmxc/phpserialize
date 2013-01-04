"""
php serialize / unserialize implementation in Python
http://github.com/sdfsdhgjkbmnmxc/phpserialize
"""
try:
    from phpserialize_speedups import serialize, unserialize, PHP_Class
# except (ImportError, AttributeError):
except ImportError:
    from core import serialize, unserialize, PHP_Class
