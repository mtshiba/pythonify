import macros
import strformat
import strutils
import sequtils
import math
import typetraits

import ../base/exceptions
import ../base/consts
import pyIterator

export dd_NEXT

# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

type
    PyDict*[T] = ref object of RootObj
        value*: seq[(T, T)]
        idx: int
    PyDiffTypeDict*[T, U] = ref object of RootObj
        value*: seq[(T, U)]
        idx: int

proc `$`*(x: type PyDict): string = "<class 'dict'>"

# access by word
proc `[]`*[T](dict: PyDict[T], idx: string): T =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]
# access by word
proc `[]`*[T, U](dict: PyDiffTypeDict[T, U], idx: string): U =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]
# access by number
proc `[]`*[T](dict: PyDiffTypeDict[int, T], idx: int): T =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]
# access by float number
proc `[]`*[T](dict: PyDiffTypeDict[float, T], idx: float): T =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]


# access by number (for user access)
proc `[]`*(dict: PyDict[string], idx: int): string = dict.value[idx][0]

# access by number (for user access)
proc `[]`*(dict: PyDict[int], idx: int): int = dict.value[idx][0]

# access by number (for user access)
proc `[]`*(dict: PyDict[float], idx: int): float = dict.value[idx][0]

proc iter*[T](dict: PyDict[T]): PyIterator[T] =
    return PyIterator[T](value: dict.value, idx:0, typ: "dict")

# __iter__()
proc dd_ITER*[T](dict: PyDict[T]): PyIterator[T] =
    return PyIterator[T](value: dict.value, idx:0, typ: "dict")

# __next__()
proc dd_NEXT*(list: PyDict) {.discardable.} =
    raise AttributeError("'dict' object has no attribute '__next__'")
proc dd_NEXT*(list: PyDiffTypeDict) {.discardable.} =
    raise AttributeError("'dict' object has no attribute '__next__'")


proc len*(a: PyDict): int = a.value.len.floorDiv(2)

proc newDict*[T](val: seq[(T, T)]): PyDict[T] =
    return PyDict[T](value: val, idx: 0)

proc newDiffTypeDict*[T, U](val: seq[(T, U)]): PyDiffTypeDict[T, U] =
    return PyDiffTypeDict[T, U](value: val, idx: 0)

proc newEmptyDict*(): PyDict[string] =
    var d: seq[(string,string)] = @[]
    return PyDict[string](value: d, idx: 0)

iterator items*[T](a: PyDict[T]): T {.inline.} =
    ## iterates over each item of `a`.
    var i = 0
    while i <= len(a):
        yield a.value[i][0]
        inc(i)

iterator items*[T, U](a: PyDiffTypeDict[T, U]): T {.inline.} =
    ## iterates over each item of `a`.
    var i = 0
    while i <= len(a):
        yield a.value[i][0]
        inc(i)

proc iter*[T](a: PyDict[T]): PyIterator[T] = dd_ITER(a.value)
proc iter*[T, U](a: PyDiffTypeDict[T, U]): PyDiffTypeIterator[T, U] = dd_ITER_difftype(a.value)

proc py*(args: openArray[(string, string)]): PyDict[string] =
    var protoDict: seq[(string, string)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDict(protoDict)
proc py*(args: openArray[(int, int)]): PyDict[int] =
    var protoDict: seq[(int, int)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDict(protoDict)
proc py*(args: openArray[(float, float)]): PyDict[float] =
    var protoDict: seq[(float, float)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDict(protoDict)

proc py*[T](args: openArray[(T, string)]): PyDiffTypeDict[T, string] =
    var protoDict: seq[(T, string)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDiffTypeDict(protoDict)
proc py*[T](args: openArray[(T, int)]): PyDiffTypeDict[T, int] =
    var protoDict: seq[(T, int)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDiffTypeDict(protoDict)
# WARNING
# float overflow may occur!
# floatのオーバーフローが発生する場合あり。
proc py*[T](args: openArray[(T, float)]): PyDiffTypeDict[T, float] =
    var protoDict: seq[(T, float)] = @[]
    for i in args.items:
        protoDict.add((i[0], i[1]))
    result = newDiffTypeDict(protoDict)

proc `$`*(list: PyDict[string]): string =
    var counter = 0
    result = "py{"
    for i in list.value.items:
        for j in i.fields:
            if counter mod 2 == 0:
                result &= "\"" & $j & "\": "
            else:
                result &= "\"" & $j & "\", "
            counter += 1
    result = result[0..^2]
    result[^1] = '}'
    return result
proc `$`*(list: PyDict[int]): string =
    var counter = 0
    result = "py{"
    for i in list.value.items:
        for j in i.fields:
            if counter mod 2 == 0:
                result &= $j & ": "
            else:
                result &= $j & ", "
            counter += 1
    result = result[0..^2]
    result[^1] = '}'
    return result
proc `$`*(list: PyDict[float]): string =
    var counter = 0
    result = "py{"
    for i in list.value.items:
        for j in i.fields:
            if counter mod 2 == 0:
                result &= $j & ": "
            else:
                result &= $j & ", "
            counter += 1
    result = result[0..^2]
    result[^1] = '}'
    return result

proc `$`*[T](list: PyDiffTypeDict[string, T]): string =
    var counter = 0
    result = "py{"
    for i in list.value.items:
        for j in i.fields:
            if counter mod 2 == 0:
                result &= "\"" & $j & "\": "
            else:
                result &= $j & ", "
            counter += 1
    result = result[0..^2]
    result[^1] = '}'
    return result
proc `$`*[T](list: PyDiffTypeDict[T, string]): string =
    var counter = 0
    result = "py{"
    for i in list.value.items:
        for j in i.fields:
            if counter mod 2 == 0:
                result &= $j & ": "
            else:
                result &= "\"" & $j & "\", "
            counter += 1
    result = result[0..^2]
    result[^1] = '}'
    return result

#[proc `%`*(formstr: string, list: PyDict): string =
    formstr % list.value]#

proc update*[T](list: PyDict[T], one: PyDict[T]) {.discardable.} =
    for i in one.value:
        (list.value).add(i)

proc append*(list: PyDict, one: PyDict) {.discardable.} =
    raise SyntaxError("'dict' object has no attribute 'append'.")

proc echo*(dict: PyDict) {.discardable.} =
    echo $dict

proc print*(dict: PyDict) {.discardable.} =
    echo dict
