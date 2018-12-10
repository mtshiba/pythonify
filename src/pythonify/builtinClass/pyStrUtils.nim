import strutils
import strformat
import math
import nre
import sugar
import encodings
import algorithm

import ../builtinFuncs
import ../exceptions
import pyDictUtils

{.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

# 型アノーテーション用
type str* = string

using s: string

template capitalize*(s): string = capitalizeAscii(s)

export center

proc pycount*(str: string, sub: string, starts=0, ends=sub.high): int =
    let s = sub[starts..ends]
    str.count(s)

proc encode*() = discard

template decode*(s): string = convert(s)

export endswith

proc expandtabs*(s: string, tabsize=8): string =
    let tab = " " * tabsize
    s.replace(tab, "")

export find

proc index*(s, sub: string): int =
    let idx = s.find(sub)
    if idx == -1:
        raise pyIndexError("Not found.")
    else:
        idx

template isalnum*(s): bool = isAlphaNumeric(s)

template isalpha*(s): bool = isAlphaAscii(s)

export isdigit

template islower*(s): bool = isLowerAscii(s)

template isspace*(s): bool = isSpaceAscii(s)

proc istitle*(s): bool =
    if isUpperAscii(s, true):
        return false
    else:
        let strs = s.split(" ")
        for i in strs:
            if i[0].isUpperAscii() == false:
                return false
        return true

template issuper*(s): bool = isupperascii(s, true)

template join*(sep: string, ary: openArray[string]): string = ary.join(sep)

template ljust*(s: string, count: Natural, padding=' '): string = alignLeft(s, count, padding)

template lower*(): string = toLowerAscii(s)

proc lstrip*(vs: var string, delstr: string): string =
    for i in delstr:
        var isfound = vs.find(i)
        while isfound == 0:
            vs.delete(0, 0)
            isfound = vs.find(i)
    return vs

proc partition*() = discard

proc pyreplace*(s, old: string, rep: string, counts=s.len()): string =
    let ranges = s[0..counts]
    ranges.replace(old, rep)

proc pyrfind*(s, sub: string, start=s.low , ends=s.high): int =
    let ranges = s[start..ends]
    ranges.rfind(sub)

proc rindex*(s, sub: string, start=s.low , ends=s.high): int =
    let ranges = s[start..ends]
    let idx = ranges.rfind(sub)
    if idx == -1:
        raise pyIndexError("Not found.")
    else:
        return idx

template rjust*(s: string, width: int, padding=' '): string = align(s, width, padding)

proc rpartition*(vs: var string, sep: string): tuple =
    vs.reverse()
    let idx = vs.find(sep)
    vs.reverse()
    if idx != -1:
        return (vs[0..idx-1], sep, vs[idx+1..^1])
    else:
        return ("", "", vs)

export rsplit

proc rstrip*(vs: var string, delstr: string): string =
    vs.reverse()
    for i in delstr:
        var isfound = vs.find(i)
        while isfound == 0:
            vs.delete(0, 0)
            isfound = vs.find(i)
    vs.reverse()
    return vs

export split

export splitlines

export startswith

export strip

proc swapcase*(vs: var string): string =
    for i in 0..vs.high:
        if vs[i].toLowerAscii() == vs[i]:
            vs[i] = vs[i].toUpperAscii()
        else:
            vs[i] = vs[i].toLowerAscii()
    return vs


proc title*(vs: var string): string =
    vs[0] = vs[0].toUpperAscii()
    for i in 1..vs.high:
        vs[i] = vs[i].toLowerAscii()
    return vs

# **cf. string.maketrans()
template translate*(s: string, args: varargs[(string, string)]): string = multiReplace(s, args)

template upper*(s): string = toUpperAscii(s)

template zfill*(s: string, width: int): string = align(s, width, '0')

# F strings
# nimの定義と被っているわけではないが一文字の関数(templateだけど)は衝突を招きやすいと思われるから...
# a one-character function seems to be easy to conflict
template pyf*(s): string = fmt(s)

proc pyformat*(cent, padding: string): string =
    if padding.find('^') != -1:
        if padding[1] != '^':
            raise pyValueError("invaid specifier")
        else:
            raise RuntimeError("something's wrong.this will not be caused")
    let fst: int = padding.len() // 2 - 1
    let en: int = pyint(ceil(padding.len()/2)) - 1
    return padding[0..fst] & cent & padding[padding.high-en..padding.high]

proc pyformat*[T](formStr: string, emb: varargs[T]): string =
    var ary: seq[string] = @[]
    for i in emb:
        ary.add($i)
    # "".format()
    # "{foo} is {bar}" -> "$foo is $bar"
    var flag0 = false
    for i in formStr.findIter(re"\{([a-z]|[A-Z]){1,}\}"):
        flag0 = true
    if flag0:
        var words:seq[string] = @[]
        for i in ary:
            var j = i.split("=")
            for word in j:
                words.add($word)
        var formStr = formStr.replace(re"\{*\}", (m: string) => m.multiReplace(("{", ""), ("}", "")))
        formStr = formStr.replace("{", "$")
        return formStr % words

    # "{} is {}" -> "$# is $#"
    var flag1 = false
    for i in formStr.findIter(re"\{\}"):
        flag1 = true
    if flag1:
        var formStr = formStr.replace("{}", "$#")
        return formStr % ary

    # "{0} is {1}" -> "$1 is $2"
    var flag2 = false
    for i in formStr.findIter(re"\{[0-9]\}"):
        flag2 = true
    if flag2:
        var formStr = formStr.replace(re"\{[0-9]", (m: string) => "$" & $(m.replace("{", "").parseInt+1))
        formStr = formStr.replace("}", "")
        return formStr % ary

proc pyformat*(formStr: string, ary: seq[string]): string =
    var flag0 = false
    for i in formStr.findIter(re"\{([a-z]|[A-Z]){1,}\}"):
        flag0 = true
    if flag0:
        var words:seq[string] = @[]
        for i in ary:
            var j = i.split("=")
            for word in j:
                words.add($word)
        var formStr = formStr.replace(re"\{*\}", (m: string) => m.multiReplace(("{", ""), ("}", "")))
        formStr = formStr.replace("{", "$")
        return formStr % words

    # "{} is {}" -> "$# is $#"
    var flag1 = false
    for i in formStr.findIter(re"\{\}"):
        flag1 = true
    if flag1:
        var formStr = formStr.replace("{}", "$#")
        return formStr % ary

    # "{0} is {1}" -> "$1 is $2"
    var flag2 = false
    for i in formStr.findIter(re"\{[0-9]\}"):
        flag2 = true
    if flag2:
        var formStr = formStr.replace(re"\{[0-9]", (m: string) => "$" & $(m.replace("{", "").parseInt+1))
        formStr = formStr.replace("}", "")
        return formStr % ary

proc format_map*(formStr: string, dict: PyDict): string =
    var ary: seq[string] = @[]
    for i in dict:
        ary.add(i)
        ary.add(dict[i])
    # "".format()
    # "{foo} is {bar}" -> "$foo is $bar"
    var flag0 = false
    for i in formStr.findIter(re"\{([a-z]|[A-Z]){1,}\}"):
        flag0 = true
    if flag0:
        var words:seq[string] = @[]
        for i in ary:
            var j = i.split("=")
            for word in j:
                words.add($word)
        var formStr = formStr.replace(re"\{*\}", (m: string) => m.multiReplace(("{", ""), ("}", "")))
        formStr = formStr.replace("{", "$")
        return formStr % words

proc format_map*(formStr: string, dict: PyDiffTypeDict): string =
    var ary: seq[string] = @[]
    for i in dict:
        ary.add($i)
        ary.add($dict[i])
    # "".format()
    # "{foo} is {bar}" -> "$foo is $bar"
    var flag0 = false
    for i in formStr.findIter(re"\{([a-z]|[A-Z]){1,}\}"):
        flag0 = true
    if flag0:
        var words:seq[string] = @[]
        for i in ary:
            var j = i.split("=")
            for word in j:
                words.add($word)
        var formStr = formStr.replace(re"\{*\}", (m: string) => m.multiReplace(("{", ""), ("}", "")))
        formStr = formStr.replace("{", "$")
        return formStr % words
