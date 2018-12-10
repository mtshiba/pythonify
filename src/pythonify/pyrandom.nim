import mersenne
import ../pythonify
import datetime


proc toInt(x: int): int = x
proc toInt(x: uint): uint = x

type Random = object of RootObj
    seed: MersenneTwister
var randgen = Random(seed: newMersenneTwister(pydatetime.now().nanosecond))
proc getnum(self: var Random): uint = self.seed.getnum

proc randrange*[T](start: T, ends=Inf, step=1): int =
    if ends == Inf:
        return int(randgen.getNum mod uint32(start.toInt))
    else:
        return int((randgen.getnum mod uint32(toInt((ends.toInt-int(start.toInt)) / step)))) * step + int(start.toInt)

proc randint*(start, ends: int): int =
    randrange(start, ends.toFloat+1.0)

proc choise*[T](list: PyList[T]): T =
    if list == newEmptyList(int):
        raise pyIndexError("list is empty")
    let num = randint(0, list.high)
    return list[num]

proc shuffle*[T](list: var PyList[T]): PyList[T] =
    var shuffled = newEmptyList(T)
    for i in 0..list.high:
        let idx = randint(0, list.high)
        shuffled.append(list[idx])
        del list[idx]
    return shuffled


if isMainModule:
    var counter = [0,0,0,0,0,0,0]
    for i in 0..1000:
        counter[randrange(0,6,2)] += 1
    echo counter

    var lis = py(pylc[x | (x <- 0..100), int])

    echo lis.shuffle
