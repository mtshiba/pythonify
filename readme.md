# pythonify
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repo is now developing.

# Examples

## def

```nim
import pythonify

def add(x, y):
    return x + y
```

## with

```nim
import pythonify

with pyopen("foo.txt", "r") as f:
    print(f.read())
```

## decorator

```nim
import pythonify/datetime as datetime
import pythonify/time as time

def lap(fn: proc) -> proc:
        proc inner() =
            echo "---start---"
            var start = pydatetime.now()
            fn()
            echo "---end---"
            echo "time: ", pydatetime.now() - start
        return inner

@lap:
    def testfunc():
        time.sleep(1000)
        print("1 sec")

testfunc()
```

## Exceptions

```nim
import pythonify

if true:
    raise SyntaxError("Error!")
```

## str methods

```nim
import pythonify
import pythonify/pymath as math

print("pi: {0} e: {1}".pyformat(math.pi, math.e))
print(pyf"pi: {math.pi} e: {math.e}")
print("aaaa".rjust(10))
```
