from cpython cimport bool
from decimal import Decimal
from phpserialize.core import PHP_Class
from phpserialize.errors import PhpUnserializationError, PhpSerializationError, \
    _PhpUnserializationError

DEFAULT_UNICODE_ENCODING = 'utf-8'


cdef extern from "Python.h":
    ctypedef void PyObject
    ctypedef struct PyTypeObject
    int PyObject_TypeCheck(object, PyTypeObject*)


cdef inline bint typecheck(object ob, object tp):
    return PyObject_TypeCheck(ob, <PyTypeObject*>tp)


def unserialize(s):
    """
    Unserialize python struct from php serialization format
    """
    if not isinstance(s, basestring) or s == '':
        raise ValueError('Unserialize argument must be non-empty string')

    try:
        return Unserializator(s).unserialize()
    except _PhpUnserializationError, e:
        char = len(str(s)) - len(e.rest)
        delta = 50
        try:
            sample = u'...%s --> %s <-- %s...' % (
                s[(char > delta and char - delta or 0):char],
                s[char],
                s[char + 1:char + delta]
            )
            message = u'%s in %s' % (e.message, sample)
        except Exception, e:
            print e
            raise
        print message
        raise PhpUnserializationError(message)

def serialize(struct, typecast=None):
    return do_serialize(struct, typecast)

cdef str do_serialize(object struct, object typecast=None):
    """
    Serialize python struct into php serialization format
    """
    if typecast:
        struct = typecast(struct)

    # N;
    if struct is None:
        return 'N;'

    struct_type = type(struct)
    # d:<float>;
    if struct_type is float:
        return 'd:%.20f;' % struct  # 20 digits after comma

    # d:<float>;
    if struct_type is Decimal:
        return 'd:%.20f;' % struct  # 20 digits after comma

    # b:<0 or 1>;
    if struct_type is bool:
        return 'b:%d;' % int(struct)

    # i:<integer>;
    if struct_type is int or struct_type is long:
        return 'i:%d;' % struct

    # s:<string_length>:"<string>";
    if struct_type is str:
        return 's:%d:"%s";' % (len(struct), struct)

    if struct_type is unicode:
        return do_serialize(struct.encode(DEFAULT_UNICODE_ENCODING), typecast)

    # a:<hash_length>:{<key><value><key2><value2>...<keyN><valueN>}
    if struct_type is dict:
        core = ''.join([do_serialize(k, typecast) + do_serialize(v, typecast) for k, v in struct.items()])
        return 'a:%d:{%s}' % (len(struct), core)

    if struct_type is tuple or struct_type is list:
        return do_serialize(dict(enumerate(struct)), typecast)

    if isinstance(struct, PHP_Class):
        return 'O:%d:"%s":%d:{%s}' % (
            len(struct.name),
            struct.name,
            len(struct),
            ''.join([do_serialize(x.php_name, typecast) + do_serialize(x.value, typecast) for x in struct]),
        )

    raise PhpSerializationError('PHP serialize: cannot encode %r' % struct)


cdef class Unserializator(object):
    cdef bool _is_unicode
    cdef int _position
    cdef str _str

    def __init__(self, object s):
        self._position = 0
        if isinstance(s, unicode):
            self._str = s.encode(DEFAULT_UNICODE_ENCODING)
            self._is_unicode = True
        else:
            self._str = s
            self._is_unicode = False

    cdef inline void await(self, str symbol, int n=1):
        result = self.take(n)
        if result != symbol:
            raise _PhpUnserializationError('Next is `%s` not `%s`' % (result, symbol), self.get_rest())

    cdef inline str take(self, int n=1):
        result = self._str[self._position:self._position + n]
        self._position += n
        return result

    cdef str take_while_not(self, str stopsymbol):
        try:
            stopsymbol_position = self._str.index(stopsymbol, self._position)
        except ValueError:
            raise _PhpUnserializationError('No `%s`' % stopsymbol, self.get_rest())
        result = self._str[self._position:stopsymbol_position]
        self._position = stopsymbol_position + 1
        return result

    cdef str get_rest(self):
        return self._str[self._position:]

    cdef dict parse_hash_core(self, int size):
        result = {}
        self.await('{')
        for i in range(size):
            k = self.unserialize()
            v = self.unserialize()
            result[k] = v
        self.await('}')
        return result

    cdef object unserialize(self):
        t = self.take()

        if t == 'N':
            self.await(';')
            return None

        self.await(':')

        if t == 'i':
            return int(self.take_while_not(';'))

        if t == 'd':
            return float(self.take_while_not(';'))

        if t == 'b':
            return bool(int(self.take_while_not(';')))

        if t == 's':
            size = int(self.take_while_not(':'))
            self.await('"')
            result = self.take(size)
            self.await('"')
            self.await(';')
            if self._is_unicode:
                return result.decode(DEFAULT_UNICODE_ENCODING)
            return result

        if t == 'a':
            size = int(self.take_while_not(':'))
            result = self.parse_hash_core(size)
            if result.keys() == range(size):
                return result.values()
            else:
                return result

        if t == 'O':
            object_name_size = int(self.take_while_not(':'))
            self.await('"')
            object_name = self.take(object_name_size)
            self.await('"')
            self.await(':')
            object_length = int(self.take_while_not(':'))
            php_class = PHP_Class(object_name)
            members = self.parse_hash_core(object_length)
            if members:
                for php_name, value in members.items():
                    php_class.set_item(php_name, value)
            return php_class

        raise _PhpUnserializationError('Unknown type `%s`' % t, self.get_rest())
