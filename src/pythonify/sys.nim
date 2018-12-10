import os
var
    argv* = commandLineParams()
    byteorder* = if cpuEndian == littleEndian: "litte" else: "big"
    builtin_module_names* = (
        "_ast", "_bisect", "_codecs", "_codecs_cn", "_codecs_hk", "_codecs_iso2022", "_codecs_jp", "_codecs_kr", "_codecs_tw",
        "_collections", "_csv", "_datetime", "_functools", "_heapq", "_imp", "_io", "_json", "_locale", "_lsprof",
        "_md5", "_multibytecodec", "_opcode", "_operator", "_pickle", "_random", "_sha1", "_sha256", "_sha512",
        "_signal", "_sre", "_stat", "_string", "_struct", "_symtable", "_thread", "_tracemalloc", "_warnings", "_weakref",
        "_winapi", "array", "atexit", "audioop", "binascii", "builtins", "cmath", "errno", "faulthandler", "gc", "itertools",
        "marshal", "math", "mmap", "msvcrt", "nt", "parser", "sys", "time", "winreg", "xxsubtype", "zipimport","zlib"
    )

template platform*(): string =
    case hostOS
    of "linux":
        "linux"
    of "windows":
        "win32"
    of "macosx":
        "darwin"
    else:
        ""

proc exit*(arg: string) =
    quit(arg, -1)
proc exit*(errc: int) =
    quit(errc)

export stdin
export stdout
export stderr
