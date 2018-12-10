# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

type pybool* = enum
    True = 0
    False = 1

proc toBool(x: pybool): bool =
    case repr(x)
    of "True":
        true
    else:
        false

proc toInt(x: pybool): int {.used.} =
    case x
    of True:
        0
    else:
        1

proc `==`*(x, y: pybool): bool = x.toBool == y.toBool
proc `!=`*(x, y: pybool): bool = x.toBool != y.toBool
proc `and`*(x, y: pybool): bool = x.toBool and y.toBool
proc `or`*(x, y: pybool): bool = x.toBool or y.toBool
proc `not`*(x: pybool): bool = not x.toBool
proc `xor`*(x, y: pybool): bool = x.toBool xor y.toBool
