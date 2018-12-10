import macros
import strformat
import strutils
import sequtils

import ../base/exceptions
import ../base/consts
import pyIterator

export dd_NEXT

# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}


type PyList*[T] = object of PyIterator[T]

proc `$`*(x: type PyList): string = "<class 'list'>"

proc seqToList*[T](s: seq[T]): PyList =
    let news: seq[string] = s.map() do (x: T) -> string: $x
    return PyList(value: news, idx: 0)

proc tupleToList*(t: tuple): PyList =
    var news: seq[string] = @[]
    for i in t.fields:
        news.add($i)
    return PyList(value: news, idx: 0)

proc newList*[T](val: seq[T]): PyList[T] =
    return PyList[T](value: val, idx: 0)

proc newEmptyList*(typ= string): PyList[typ] =
    var s: seq[typ] = @[]
    return PyList[typ](value: s, idx: 0)

# __next__()
proc dd_NEXT*(list: PyList): string =
    raise AttributeError("'list' object has no attribute '__next__'")

macro del*(listAndIdx: untyped): untyped =
    let list_idx = repr(listAndIdx).replace("]", "").split("[")
    parseStmt(fmt"{list_idx[0]}.value.del({list_idx[1]})")

proc append*[T](list: var PyList[string], ap: T) =
    list.value.add($ap)
proc append*(list: var PyList[int], ap: int) =
    list.value.add(ap)
proc append*(list: var PyList[float], ap: float) =
    list.value.add(ap)


template append*(list: seq, num: int) = list.add(num)

# 一応普通のseqと互換性を持たせる
# this makes it compatible with ordinary "seq"
proc add*(list: var PyList, ap: auto) =
    list.append(ap)

proc `$`*(list: PyList[string]): string =
    result = "py["
    for i in 0..list.value.len-1:
        result &= "\"" & $list.value[i] & "\", "
    result[^2] = ']'
    result[^1] = ' '
    return result
proc `$`*(list: PyList[int]): string =
    result = "py["
    for i in 0..list.value.len-1:
        result &= $list.value[i] & ", "
    result[^2] = ']'
    result[^1] = ' '
    return result
proc `$`*(list: PyList[float]): string =
    result = "py["
    for i in 0..list.value.len-1:
        result &= $list.value[i] & ", "
    result[^2] = ']'
    result[^1] = ' '
    return result

proc `%`*(formstr: string, list: PyList): string =
    formstr % list.value

proc echo*(list: PyList) {.discardable.} =
    echo $list

proc print*(list: PyList) {.discardable.} =
    echo list

proc parseSeq*(reprSeq: string): seq[string] =
    var reprSeq = reprSeq.replace("@", "")
    reprSeq = reprSeq.replace("py", "")
    reprSeq = reprSeq.replace("[", "")
    reprSeq = reprSeq.replace("]", "")
    let values = reprSeq.split(",")
    var res: seq[string] = @[]
    for val in values:
        res.add(val)
    return res

proc `[]`*[T](list: PyList[T], idx: int): T =
    list.value[idx]

proc len*(a: PyList): int = a.value.len

iterator items*[T](a: PyList[T]): T {.inline.} =
    ## iterates over each item of `a`.
    var i = 0
    while i <= len(a):
        yield a[i]
        inc(i)

proc max*[T](a: PyList[T]): T =
    return a.value.max

proc min*[T](a: PyList[T]): T =
    return a.value.min

proc iter*[T](list: PyList[T]): PyIterator[T] =
    return PyIterator[T](value: list.value, idx: 0, typ: "list")

# __iter__()
proc dd_ITER*[T](list: PyList[T]): PyIterator[T] =
    return PyIterator[T](value: list.value, idx: 0, typ: "list")


# pythonの仕様
# python's specification
proc join*(s: string, a: PyList[string]): string =
    a.value.join(s)
# nimの仕様
# nim's specification
proc join*(a: PyList[string], s: string): string =
    a.value.join(s)

proc high*(a: PyList): int =
    a.value.high

proc low*(a: PyList): int =
    a.value.low

# pyList定義マクロ。
# pyList macro
# nimのseqは違う型を持てないので混在している場合内部で全ての要素をstringにする。
# Since nim's "seq" cannot have different types, when they are mixed, all elements will convert "string".
# TODO:
# アクセス時に自動で型を戻せるようにしたい。
# casting type when it is accessed
macro pyd*(args: varargs[untyped]): untyped =
    var base = repr(args)
    let baseary = base.multiReplace((" ", ""), ("[", ""), ("]", ""), ("\"", "")).split(",")
    result = parseStmt(fmt"newList({$baseary})")
# 型が混在していない場合
# single type version
proc py*(args: openArray[string]): PyList[string] =
    result = newList((args.map do (x:string) -> string: x))
proc py*(args: openArray[int]): PyList[int] =
    result = newList((args.map do (x:int) -> int: x))
proc py*(args: openArray[float]): PyList[float] =
    result = newList((args.map do (x:float) -> float: x))

# sugarのlcを移植しただけである。今のところ。
# this only ported "sugar"'s "lc".
macro pylc*(comp, typ: untyped): untyped =

    expectLen(comp, 3)
    expectKind(comp, nnkInfix)
    expectKind(comp[0], nnkIdent)
    assert($comp[0] == "|")

    result = newCall(
        newDotExpr(
        newIdentNode("result"),
        newIdentNode("add")),
        comp[1])

    for i in countdown(comp[2].len-1, 0):
        let x = comp[2][i]
        expectMinLen(x, 1)
        if x[0].kind == nnkIdent and $x[0] == "<-":
            expectLen(x, 3)
            result = newNimNode(nnkForStmt).add(x[1], x[2], result)
        else:
            result = newIfStmt((x, result))

    result = newNimNode(nnkCall).add(
        newNimNode(nnkPar).add(
        newNimNode(nnkLambda).add(
            newEmptyNode(),
            newEmptyNode(),
            newEmptyNode(),
            newNimNode(nnkFormalParams).add(
            newNimNode(nnkBracketExpr).add(
                newIdentNode("seq"),
                typ)),
            newEmptyNode(),
            newEmptyNode(),
            newStmtList(
            newAssignment(
                newIdentNode("result"),
                newNimNode(nnkPrefix).add(
                newIdentNode("@"),
                newNimNode(nnkBracket))),
            result))))
