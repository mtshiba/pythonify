# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

import macros

type
    None* = object
    NotImplemented* = object
    Ellipsis* = object

macro pass*(): untyped =
    parseStmt("discard")
