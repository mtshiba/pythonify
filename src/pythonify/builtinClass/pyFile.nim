import strutils
import pyListUtils

import ../base/exceptions

# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

type PyFile* = ref object of RootObj
    file: File
    lineLen: int

using self: PyFile

iterator items*(f: PyFile): string =
    var idx = 0
    while idx < f.lineLen:
        yield f.file.readLine()
        idx.inc()

proc dd_next*(self): string =
    try:
        return self.file.readLine()
    except EOFError:
        raise StopIteration("Index out of bounds")

proc read*(self): string = self.file.readAll
proc readline*(self): string = self.dd_next
proc readlines*(self): PyList[string] =
    var flines = newEmptyList()
    for i in self:
        flines.append(i)
    return flines
proc write*(self: PyFile, s: string) {.discardable.} = self.file.write(s)
proc writeline*(self: PyFile, s: string) {.discardable.} = self.file.writeline(s)
proc writelines*[T](self: PyFile, iterable: T) {.discardable.} =
    self.write(iterable.join(""))
proc endoffile*(self): bool = self.file.endOfFile
proc getfilesize*(self): auto = self.file.getFileSize
proc close*(self) {.discardable.} = self.file.close

proc pyopen*(args: varargs[string]): PyFile =
    let filename = args[0]
    let mode = args[1]
    var encoding = "utf-8"
    if args.len() == 3:
        encoding = args[2]
    var asmode = fmRead
    case mode
    of "w":
        asmode = fmWrite
    of "r+":
        asmode = fmReadWriteExisting
    of "w+":
        asmode = fmReadWrite
    of "a":
        asmode = fmAppend
    of "a+":
        asmode = fmReadWrite
    else:
        asmode = fmRead
    let f = open(filename, asmode)
    let flines = f.readAll().split("\n")
    var linelen = 0
    case flines[^1]
    of "":
        linelen = flines.len-1
    else:
        linelen = flines.len
    f.close
    PyFile(file: open(filename, asmode), lineLen: linelen)

proc ENTER*(self) {.discardable.} =
    discard

proc EXIT*(self) {.discardable.} =
    self.close
