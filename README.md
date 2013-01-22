phpserialize
============

Php serialize / unserialize implementation in Python:

 * fast as possible (php built-in implementation is ~10x faster)
 * php objects support

Usage:

```
>>> import phpserialize
>>> print phpserialize.unserialize('a:1:{s:5:"Admin";i:0;}')
{'Admin': 0}
>>> print phpserialize.serialize([1, 2, "aaaa", {'k': 'v'}])
a:4:{i:0;i:1;i:1;i:2;i:2;s:4:"aaaa";i:3;a:1:{s:1:"k";s:1:"v";}}
```