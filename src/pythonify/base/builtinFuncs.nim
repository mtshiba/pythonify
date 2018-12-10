import strutils
import macros
import strformat
import pegs
import sugar
import parseutils
import math
import nre
import sequtils
import typetraits except `$`

import exceptions
import consts
import ../builtinClass/pyListUtils
import ../builtinClass/pyDictUtils
import ../builtinClass/pyComplexUtils
import ../builtinClass/pyIterator
import ../builtinClass/pyFile


{.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

# 無理 or Rattleの思想的につける必要のない関数にはこれを付ける
# しかしそもそもこれらの関数はRattleのトランスパイル時に弾かれる
proc notSupport*(): void = raise RuntimeError("This func isn't available")

# prototype decl
proc pyrange*(ends: int): HSlice[int, int]
proc pow*(x, y: int): int
proc pybool*[T](x: T): bool
proc pyint*[T](num: T): int

# ------ operateors ------
# proc `+`*(a,b: char): string = a & b
template `+`*(a,b: string): string = a & b
template `+`*(a: int, y: bool): int =
    if y: a + 1 else: a
template `+`*(a: bool, y: int): int = y + a
proc `*`*(a: string, times: int): string  =
    result = ""
    for i in pyrange(times):
        result = result + a
template `%`*[T, U](x: T, y: U): auto = x mod y
template `^`*[T](x, y: T): T = x xor y
template `//`*[T, U](x: T, y: U): auto = floorDiv(x, y)
template `**`*(x, y: int): int = x.pow(y)
proc `**`*(x: PyDict): seq[string] =
    var dicts: seq[string] = @[]
    try:
        for i in x:
            dicts.add(i)
            dicts.add(x[i])
        return dicts
    except IndexError:
        return dicts
template `<<`*[T](x, y: T): int = pyint(x) shl pyint(y)
template `>>`*[T](x, y: T): int = pyint(x) shr pyint(y)
template `&`*[T](x, y: T): T = x and y
template `|`*[T](x, y: T): T = x or y
template `~`*(x: SomeInteger): int = not x
template `~`*(x: int): int = -(x + 1)
template `<>`*[T, U](x: T, y: U): bool = pybool(x) != pybool(y)

# "is" will convert "=="
# "is not" will convert "!="

# assignment operators
macro `+=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} + {repr(literal)}")
macro `*=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} ** {repr(literal)}")
macro `%=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} % {repr(literal)}")
macro `^=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} % {repr(literal)}")
macro `//=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} ** {repr(literal)}")
macro `**=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} ** {repr(literal)}")
macro `<<=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} << {repr(literal)}")
macro `>>=`*(sym, literal: untyped): untyped =
    parseStmt(fmt"{repr(sym)} = {repr(sym)} ** {repr(literal)}")


# ------ built-in type conversion functions -------
template pystr*[T](num: T): string = $num

template pyints*(num: int): int = num
template pyints*(num: float): int = num.toInt()
template pyints*(num: string): int = num.parseInt()
template pyints*(num: bool): int =
    if num == true: 1 else: 0
proc pyint*[T](num: T): int = pyints(num)

template pyfloats*(num: int): float = num.toFloat()
template pyfloats*(num: float): float = num
template pyfloats*(num: string): float = num.parseFloat()
template pyfloats*(num: bool): float =
    if num == true: 1.0 else: 0.0
proc pyfloat*[T](num: T): float = pyfloats(num)

# pythonとnimの真偽値判定ルールの違いが調べる気にならない
template pybools*(bo: bool): bool = bo
proc pybools*(bo: string): bool =
    if bo == "":
        return false
    return true
proc pybools*(bo: int): bool =
    if bo == 0:
        return false
    return true
proc pybools*(bo: float): bool =
    if bo.toInt == 0:
        return false
    return true
template pybools*(bo: None): bool = false
template pybools*[T: NotImplemented | Ellipsis](bo: T): bool = true
proc pybools*[T](bo: openArray[T]): bool =
    if bo.len == 0:
        return false
    return true
proc pybools*[T](bo: tuple): bool =
    if bo.len == 0:
        return false
    return true
proc pybools*[T](bo: T): bool =
    if bo.len() == 0:
        return false
    return true
proc pybool*[T](x: T): bool = pybools(x)


proc dict*() = discard
proc list*() = discard
proc set*() = discard

# pythonでは組み込みであるため先頭が小文字
template complex*(): type Complex = (type Complex)
proc complex*(num: string): Complex =
    let elem: seq[string] = num.split("+")
    let im_num = elem[1].multiReplace(("j", ""), ("i", ""))
    let real_num = elem[0]
    let comp: Complex = (real_num.pyfloat, im_num.pyfloat)
    return comp
proc complex*(real: SomeNumber, im: SomeNumber): Complex =
    return Complex(real.pyfloat, im.pyfloat)

# TODO
proc bytes*() = discard
proc bytearray*() = discard

# 特別な表記が必要なら別途宣言すればよい
proc `$`*[T: type](x: T): string = "<class '" & x.type.name & "'>"
proc `$`*(x: type string): string = "<class 'str'>"

proc `==`*[T, U: type](x: T, y: U): bool =
    if $x == $y: return true else: return false

# ------ built-in functions ------

proc all*[T](ary: openArray[T]): bool =
    for i in ary:
        if not pybool(i):
            return false
    return true
proc all*(tup: tuple): bool =
    for i in tup:
        if not pybool(i):
            return false
    return true

proc pyany*(ary: openArray[bool]): bool =
    for i in ary:
        if pybool(i):
            return true
    return false
proc pyany*(ary: tuple): bool =
    for i in ary:
        if pybool(i):
            return true
    return false

proc ascii*(str: string): string = repr(str)

proc bin*(num: BiggestInt): string =
    let strnum = $num
    let digit = math.log10(pyfloat(strnum)) / math.log10(2.0)
    result = "0b" & num.toBin(pyint(math.round(digit)))

proc callable*() = notSupport()
proc compile*() = notSupport()
proc delattr*() = notSupport()

# 正直nimにトランスパイルするならあんまり意味がない。
# だが他の状態系の関数と比べて頻出するので
# それのためにエラーを出すのは忍びない。よって効果なしにしておく。
# Since transpiling to nim, this has no meaning.
proc del*() = discard

proc divmod*[T, U](x: T, y: U): auto =
    (x//y, x%y)

# 静的に決定できる場合のみ
# Those macros can be used only when the argument is static.
macro exec*(s: string): untyped =
    try:
        result = parseStmt($s)
    except:
        result = parseStmt("raise newException(SyntaxError, \"This macro can be used only when the argument is static.\")")
# 厳密にはevalに文は渡せないが...
# Strictly speaking, eval() cannot evaluate statement...
macro eval*(s: string): untyped =
    try:
        result = parseStmt($s)
    except:
        result = parseStmt("raise newException(SyntaxError, \"This macro can be used only when the argument is static.\")")

proc pyformat*(num: int, form: string): string =
    let strnum = $num
    var digit: int = pyint(math.log10(pyfloat(strnum)) / math.log10(16.0))
    if form[2] == 'o':
        digit = pyint(math.log10(pyfloat(strnum)) / math.log10(8.0))
    elif form[2] == 'b':
        digit = pyint(math.log10(pyfloat(strnum)) / math.log10(2.0))

    if form.len() == 3 and form[0] == '0':
        # 指定された桁数がn進数表記で表記できない(足りない)場合無視する
        if parseInt($form[1]) < digit:
            # hex
            case form[2]
            of 'x':
                result = num.toHex(digit)
            # oct
            of 'o':
                result = num.toOct(digit)
            # bin
            of 'b':
                result = num.toBin(digit)
            else:
                discard
        else:
            # hex
            case form[2]
            of 'x':
                result = num.toHex(parseInt($form[1]))
            # oct
            of 'o':
                result = num.toOct(parseInt($form[1]))
            # bin
            of 'b':
                result = num.toBin(parseInt($form[1]))
            else:
                discard
    elif form.len() == 3 and form[0] != '0':
        # hex
        case form[2]
        of 'x':
            result = num.toHex((form[0] & form[1]).parseInt).replace("0", " ")
        # oct
        of 'o':
            result = num.toOct((form[0] & form[1]).parseInt).replace("0", " ")
        # bin
        of 'b':
            result = num.toBin((form[0] & form[1]).parseInt).replace("0", " ")
        else:
            discard

proc globals*() = notSupport()
proc hasattr*() = notSupport()

proc hex*(num: BiggestInt): string =
    let strnum = $num
    let digit = math.log10(pyfloat(strnum)) / math.log10(16.0)
    result = "0x" & num.toHex(pyint(math.round(digit)))

template id*[T](val: T): int =
    var value = 0
    discard repr(val.addr).split(" ")[1].parseHex(value)
    value

template input*(): untyped = readLine(stdin)

proc isinstance*[U: type, T](val: T, tp: U): bool =
    if val.type == tp:
        return true
    # TODO
    # subclass evaluation
    return false

proc issubclass*() = notSupport()

proc iter*[T](iter: T): PyIterator = iter.dd_ITER()

proc iter*[T, U](callable_obj: T, sentinel: U): PyIterator =
    var it = dd_ITER()
    for i in callable_obj:
        if i == sentinel: break else: it.append(i)
    return it

export locals

proc memoryview*() = discard

# nimとは順番が逆になっている
# lambdaまでは実装できなかったので置換する
proc map[T](fn: proc, s: seq[T]): seq[T] = s.map(fn)

proc next*[T](call: T): auto = call.dd_NEXT()

### object()
# """
# a = object()
# a.hoge = 1
# print(a.hoge)
# """

# ↑ WILL CONVERT ↓

# """
# type pyobject = object
#     hoge: int
# var a = pyobject(hoge: 1)
# print(a.hoge)
# """

proc oct*(num: BiggestInt): string =
    let strnum = $num
    let digit = math.log10(pyfloat(strnum)) / math.log10(8.0)
    result = "0o" & num.toOct(pyint(math.round(digit)))

export pyopen
export pyFile

proc pow*(x: int, y: int): int = math.pow(x.pyfloat, y.pyfloat).pyint
proc pow*[T](x: T, y: float): float = math.pow(x.pyfloat, y.pyfloat)
proc pow*[T](x: float, y: T): float = math.pow(x.pyfloat, y.pyfloat)

template print*(args: varargs[untyped]): void =
    echo args

# 置換案件
# proc property()  = discard

proc pyrange*(ends: int): HSlice[int, int] = 0..ends
template pyrange*(starts, ends: int, step=1): auto = countup(starts, ends, step)
proc xrange*(ends: int): HSlice[int, int] = 0..ends
template xrange*(starts, ends: int, step=1): auto = countup(starts, ends, step)

template pytype*[T](x: T): auto = x.type

proc zip*[T, U](x: openArray[T], y: openArray[T]): seq[tuple[a: U, b: T]] = sequtils.zip(x, y)
