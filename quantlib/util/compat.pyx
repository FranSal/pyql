""" Compatibility layer for Py2/Py3 support. """

from cpython cimport PyBytes_AsString, PY_MAJOR_VERSION
from libcpp.string cimport string

cdef string py_compat_str_as_utf8_string(text):
    """
    Returns the result of calling string(PyBytes_AsString(text)) to return a
    C++ string after handling encoding of text to bytes (as UTF-8) if
    necessary. Compatible with both unicode strings on Py2 and Py3 and
    byte-strings on Py2.

    See https://github.com/cython/cython/wiki/FAQ#how-do-i-pass-a-python-string-parameter-on-to-a-c-library
    """
    if isinstance(text, unicode):
        utf8_data = text.encode('UTF-8')
    elif (PY_MAJOR_VERSION < 3) and isinstance(text, str):
        text.decode('UTF-8')    # ensure it's UTF-8 encoded if there are high-bit chars
        utf8_data = text
    else:
        raise ValueError("requires text input, got %s" % type(text))
    return string(PyBytes_AsString(utf8_data))

cdef utf8_char_array_to_py_compat_str(const char* char_array):
    """
    Converts the given char* to a native Python string (bytes on Py2, unicode on Py3)
    """
    if PY_MAJOR_VERSION < 3:
        return char_array
    else:
        return char_array.decode('UTF-8')

