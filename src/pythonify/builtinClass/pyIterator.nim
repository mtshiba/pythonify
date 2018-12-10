import ../base/exceptions
from strformat import fmt
import strutils
import sugar
import typetraits

# {.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

type
    PyIterator*[T] = ref object of RootObj
        value*: seq[T]
        idx*: int
        typ*: string

    PyDiffTypeIterator*[T, U] = ref object of RootObj
        value: seq[(T, U)]
        idx: int
        typ: string

proc pytype*[T](x: PyIterator[T]): string = fmt"<class '{x.typ}_iterator'>"

proc `$`*[T](x: var PyIterator[T]): string =
    let point = repr(x.addr).split(" ")[4]
    fmt"<{x.typ}_iterator object at {point}>"

proc `[]`*[T](a: PyIterator[T], idx: int): T = a.value[idx]

proc len*(a: PyIterator): int = a.value.len

proc append*[T](a: PyIterator[T], one: T) {.discardable.} = a.value.add(one)

proc add*[T](a: PyIterator[T], one: T) {.discardable.} = a.value.add(one)

proc dd_ITER*(typ="string_list"): PyIterator =
    let s: seq[string] = @[]
    return PyIterator(value: s, idx: 0, typ: typ)

proc dd_ITER*[T](a: seq[T], typ="unknown"): PyIterator[T] =
    return PyIterator[T](value: a, idx: 0, typ:repr(T))

proc dd_ITER*[T, U](a: seq[(T, U)], typ="unknown"): PyIterator[T] =
    var base: seq[T] = @[]
    for i in a:
        base.add(i[0])
    return PyIterator[T](value: base, idx:0, typ: typ)

template dd_ITER*[T](it: iterator (): T {.inline, nosideeffect, gcsafe, locks:0.}): PyIterator[T] =
    var x = lc[x | (x <- it()), T]
    PyIterator[T](value: x, idx: 0, typ: T.name & "_generator")

proc iter*[T](x: seq[T]): PyIterator[T] = PyIterator[T](value: x, idx: 0, typ: T.name & "_generator")

iterator items*[T](a: PyIterator[T]): T {.inline.} =
    ## iterates over each item of `a`.
    var i = 0
    while i < len(a):
        yield a[i]
        inc(i)

proc dd_NEXT*[T](list: PyIterator[T]): T =
    try:
        result = list[list.idx]
        inc(list.idx)
        return result
    except:
        raise StopIteration("List index out of range")


# access by word
proc `[]`*[T, U](dict: PyDiffTypeIterator[T, U], idx: string): U =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]
# access by number
proc `[]`*[T, U](dict: PyDiffTypeIterator[T, U], idx: int): U =
    for i in dict.value.items:
        if i[0] == idx:
            return i[1]

proc len*(a: PyDiffTypeIterator): int =
    return a.value.len

proc append*[T](a: PyDiffTypeIterator, one: T) {.discardable.} =
    a.value.add($one)

proc add*[T](a: PyDiffTypeIterator, one: T) {.discardable.} =
    a.value.add($one)

proc dd_ITER_difftype*(): PyDiffTypeIterator =
    let s: seq[string] = @[]
    return PyDiffTypeIterator(value: s, idx: 0, typ: "string")

proc dd_ITER_difftype*[T, U](a: seq[(T, U)]): PyDiffTypeIterator[T, U] =
    return PyDiffTypeIterator[T, U](value: a, idx: 0, typ:repr(T))

iterator items*[T, U](a: PyDiffTypeIterator[T, U]): T {.inline.} =
    ## iterates over each item of `a`.
    var i = 0
    while i <= len(a):
        yield a[i][0]
        inc(i)

proc dd_NEXT*[T, U](list: PyDiffTypeIterator[T, U]): T =
    try:
        result = list.value[list.idx][0]
        inc(list.idx)
        return result
    except:
        raise StopIteration("List index out of range")
