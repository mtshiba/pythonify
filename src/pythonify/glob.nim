import os
import sequtils
import strutils
import nre

import builtinClass/pyIterator

proc glob*(pattern: string, recursive=false): seq[string] =
    if recursive:
        for i in walkDirRec(pattern.split("/")[0]):
            if i.match(re(pattern.multireplace((".", "\\."), ("/", "\\\\"), ("*", ".*")))).isSome:
                if i.multireplace(("/", "\\\\")).findAll(re"\\").len() == pattern.multireplace(("/", "\\\\")).findAll(re"\\\\").len():
                    result.add(i)
    else:
        for _, i in walkDir(pattern.split("/")[0]):
            if i.match(re(pattern.multireplace((".", "\\."), ("/", "\\\\"), ("*", ".*")))).isSome:
                if i.multireplace(("/", "\\\\")).findAll(re"\\").len() == pattern.multireplace(("/", "\\\\")).findAll(re"\\\\").len():
                    result.add(i)

proc iglob*(pattern: string, recursive=false): PyIterator[string] = glob(pattern, recursive).iter()

when isMainModule:
    echo glob("testdir/*/*.txt", true)
