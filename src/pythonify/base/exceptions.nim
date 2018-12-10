type
    #PyValueError* = object of Exception
    PySystemExit* = object of Exception
    PyKeyboardInterrupt* = object of Exception
    PyGeneratorExit* = object of Exception
    PyException* = object of Exception
    PyStopIteration* = object of Exception
    PyStandardError* = object of Exception
    PyBufferError* = object of Exception
    PyArithmeticError* = object of Exception
    PyFloatingPointError* = object of Exception
    PyOverflowError* = object of Exception
    PyZeroDivisionError* = object of Exception
    PyAssertionError* = object of Exception
    PyAttributeError* = object of Exception
    PyEnvironmentError* = object of Exception
    PyIOError* = object of Exception
    PyOSError* = object of Exception
    PyWindowsError* = object of Exception
    PyVMSError* = object of Exception
    PyEOFError* = object of Exception
    PyImportError* = object of Exception
    PyLookupError* = object of Exception
    PyIndexError* = object of Exception
    PyKeyError* = object of Exception
    PyMemoryError* = object of Exception
    PyNameError* = object of Exception
    PyUnboundLocalError* = object of Exception
    PyReferenceError* = object of Exception
    PyRuntimeError* = object of Exception
    PyNotImplementedError* = object of Exception
    PySyntaxError* = object of Exception
    PyIndentationError* = object of Exception
    PyTabError* = object of Exception
    PySystemError* = object of Exception
    PyTypeError* = object of Exception
    PyValueError* = object of Exception
    PyUnicodeError* = object of Exception
    PyUnicodeDecodeError* = object of Exception
    PyUnicodeEncodeError* = object of Exception
    PyUnicodeTranslateError* = object of Exception
    PyWarning* = object of Exception
    PyDeprecationWarning* = object of Exception
    PyPendingDeprecationWarning* = object of Exception
    PyRuntimeWarning* = object of Exception
    PySyntaxWarning* = object of Exception
    PyUserWarning* = object of Exception
    PyFutureWarning* = object of Exception
    PyImportWarning* = object of Exception
    PyUnicodeWarning* = object of Exception
    PyBytesWarning* = object of Exception

# raise Foo
template SystemExit*(): auto = newException(PySystemExit, "")
template KeyboardInterrupt*(): auto = newException(PyKeyboardInterrupt, "")
template GeneratorExit*(): auto = newException(PyGeneratorExit, "")
template Exception*(): auto = newException(PyException, "")
template StopIteration*(): auto = newException(PyStopIteration, "")
template StandardError*(): auto = newException(PyStandardError, "")
template BufferError*(): auto = newException(PyBufferError, "")
template ArithmeticError*(): auto = newException(PyArithmeticError, "")
template OverflowError*(): auto = newException(PyOverflowError, "")
template ZeroDivisionError*(): auto = newException(PyZeroDivisionError, "")
template AssertionError*(): auto = newException(PyAssertionError, "")
template AttributeError*(): auto = newException(PyAttributeError, "")
template EnvironmentError*(): auto = newException(PyEnvironmentError, "")
template WindowsError*(): auto = newException(PyWindowsError, "")
template VMSError*(): auto = newException(PyVMSError, "")
template ImportError*(): auto = newException(PyImportError, "")
template LookupError*(): auto = newException(PyLookupError, "")
template MemoryError*(): auto = newException(PyMemoryError, "")
template NameError*(): auto = newException(PyNameError, "")
template UnboundLocalError*(): auto = newException(PyUnboundLocalError, "")
template ReferenceError*(): auto = newException(PyReferenceError, "")
template RuntimeError*(): auto = newException(PyRuntimeError, "")
template NotImplementedError*(): auto = newException(PyNotImplementedError, "")
template SyntaxError*(): auto = newException(PySyntaxError, "")
template IndentationError*(): auto = newException(PyIndentationError, "")
template TabError*(): auto = newException(PyTabError, "")
template SystemError*(): auto = newException(PySystemError, "")
template TypeError*(): auto = newException(PyTypeError, "")
template UnicodeError*(): auto = newException(PyUnicodeError, "")
template UnicodeDecodeError*(): auto = newException(PyUnicodeDecodeError, "")
template UnicodeEncodeError*(): auto = newException(PyUnicodeEncodeError, "")
template UnicodeTranslateError*(): auto = newException(PyUnicodeTranslateError, "")
template Warning*(): auto = newException(PyWarning, "")
template DeprecationWarning*(): auto = newException(PyDeprecationWarning, "")
template PendingDeprecationWarning*(): auto = newException(PyPendingDeprecationWarning, "")
template RuntimeWarning*(): auto = newException(PyRuntimeWarning, "")
template SyntaxWarning*(): auto = newException(PySyntaxWarning, "")
template UserWarning*(): auto = newException(PyUserWarning, "")
template FutureWarning*(): auto = newException(PyFutureWarning, "")
template ImportWarning*(): auto = newException(PyImportWarning, "")
template UnicodeWarning*(): auto = newException(PyUnicodeWarning, "")
template BytesWarning*(): auto = newException(PyBytesWarning, "")

# nimにもあるもの
# avoid overdefinition
template pyValueError*(): auto = newException(PyValueError, "")
template pyEOFError*(): auto = newException(PyEOFError, "")
template pyOSError*(): auto = newException(PyOSError, "")
template pyIOError*(): auto = newException(PyIOError, "")
template pyIndexError*(): auto = newException(PyIndexError, "")
template pyKeyError*(): auto = newException(PyKeyError, "")
template pyFloatingPointError*(): auto = newException(PyFloatingPointError, "")


# raise Foo("bar")
proc SystemExit*(msg=""): auto = newException(PySystemExit, msg)
proc KeyboardInterrupt*(msg=""): auto = newException(PyKeyboardInterrupt, msg)
proc GeneratorExit*(msg=""): auto = newException(PyGeneratorExit, msg)
proc Exception*(msg=""): auto = newException(PyException, msg)
proc StopIteration*(msg=""): auto = newException(PyStopIteration, msg)
proc StandardError*(msg=""): auto = newException(PyStandardError, msg)
proc BufferError*(msg=""): auto = newException(PyBufferError, msg)
proc ArithmeticError*(msg=""): auto = newException(PyArithmeticError, msg)
proc OverflowError*(msg=""): auto = newException(PyOverflowError, msg)
proc ZeroDivisionError*(msg=""): auto = newException(PyZeroDivisionError, msg)
proc AssertionError*(msg=""): auto = newException(PyAssertionError, msg)
proc AttributeError*(msg=""): auto = newException(PyAttributeError, msg)
proc EnvironmentError*(msg=""): auto = newException(PyEnvironmentError, msg)
proc WindowsError*(msg=""): auto = newException(PyWindowsError, msg)
proc VMSError*(msg=""): auto = newException(PyVMSError, msg)
proc ImportError*(msg=""): auto = newException(PyImportError, msg)
proc LookupError*(msg=""): auto = newException(PyLookupError, msg)
proc MemoryError*(msg=""): auto = newException(PyMemoryError, msg)
proc NameError*(msg=""): auto = newException(PyNameError, msg)
proc UnboundLocalError*(msg=""): auto = newException(PyUnboundLocalError, msg)
proc ReferenceError*(msg=""): auto = newException(PyReferenceError, msg)
proc RuntimeError*(msg=""): auto = newException(PyRuntimeError, msg)
proc NotImplementedError*(msg=""): auto = newException(PyNotImplementedError, msg)
proc SyntaxError*(msg=""): auto = newException(PySyntaxError, msg)
proc IndentationError*(msg=""): auto = newException(PyIndentationError, msg)
proc TabError*(msg=""): auto = newException(PyTabError, msg)
proc SystemError*(msg=""): auto = newException(PySystemError, msg)
proc TypeError*(msg=""): auto = newException(PyTypeError, msg)
proc UnicodeError*(msg=""): auto = newException(PyUnicodeError, msg)
proc UnicodeDecodeError*(msg=""): auto = newException(PyUnicodeDecodeError, msg)
proc UnicodeEncodeError*(msg=""): auto = newException(PyUnicodeEncodeError, msg)
proc UnicodeTranslateError*(msg=""): auto = newException(PyUnicodeTranslateError, msg)
proc Warning*(msg=""): auto = newException(PyWarning, msg)
proc DeprecationWarning*(msg=""): auto = newException(PyDeprecationWarning, msg)
proc PendingDeprecationWarning*(msg=""): auto = newException(PyPendingDeprecationWarning, msg)
proc RuntimeWarning*(msg=""): auto = newException(PyRuntimeWarning, msg)
proc SyntaxWarning*(msg=""): auto = newException(PySyntaxWarning, msg)
proc UserWarning*(msg=""): auto = newException(PyUserWarning, msg)
proc FutureWarning*(msg=""): auto = newException(PyFutureWarning, msg)
proc ImportWarning*(msg=""): auto = newException(PyImportWarning, msg)
proc UnicodeWarning*(msg=""): auto = newException(PyUnicodeWarning, msg)
proc BytesWarning*(msg=""): auto = newException(PyBytesWarning, msg)

# nimにもあるもの
# avoid overdefinition
proc pyValueError*(msg=""): auto = newException(PyValueError, msg)
proc pyEOFError*(msg=""): auto = newException(PyEOFError, msg)
proc pyOSError*(msg=""): auto = newException(PyOSError, msg)
proc pyIOError*(msg=""): auto = newException(PyIOError, msg)
proc pyIndexError*(msg=""): auto = newException(PyIndexError, msg)
proc pyKeyError*(msg=""): auto = newException(PyKeyError, msg)
proc pyFloatingPointError*(msg=""): auto = newException(PyFloatingPointError, msg)

if isMainModule:
    raise pyValueError("aaa")
    # raise pySyntaxError -> OK
    # raise pySyntaxError("aaa")
