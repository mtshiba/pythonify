import math

proc toFloat(x: float): float = x
proc toInt(x: int): int = x

export ceil

proc copysign*[T](x: T, y: T): T =
    if y.toFloat == -0.0: return -x
    elif y.toFloat == 0.0: return x
    elif y.toFloat < 0.0: return -x
    elif y.toFloat > 0.0: return x

proc fabs*[T](x: T): float = x.abs.toFloat

proc factorial*[T](x: T): int = x.toInt.fac

proc floor*(x: int): int = x
export floor

export fmod

export frexp

proc fsum*(x: openArray[float]): float =
    var sum = 0.0
    for i in countup(0, x.len(), 2):
        sum += x[i] + x[i+1]
    return sum

export gcd

proc isclose*(x, y: float, rel_tol=1e-9, abs_tol=0.0): bool =
    if abs(x-y) <= rel_tol:
        return true
    return false
template isclose*(x, y: int, rel_tol=1e-9, abs_tol=0.0): bool = false

proc isfinite*[T](x: T): bool =
    if x.toFloat == Inf or x.toFloat == NegInf or x.toFloat == NaN:
        return true
    return false

proc isinf*[T](x: T): bool =
    if x.toFloat == Inf or x.toFloat == NegInf:
        return true
    return false

proc isnan*[T](x: T): bool =
    if x.toFloat == NaN:
        return true
    return false

template idexp*[T, U](x: T, i: U): float = x.toFloat * pow(2.0,i.toFloat)

template trunc*(x: int): int = x
export trunc

template exp*(x: int): int = pow(math.E, x.toFloat).toInt
export exp

proc expm1*[T](x: T): T = exp(x) - 1

export log
proc log*(x: int, base=math.E): float = math.log(x.toFloat, base)

proc log1p*[T](x: T, base=math.E): float = log(x.toFloat+1, base)

export log2

export log10

export pow

export sqrt

template acos*[T](x: T): float = arccos(x)
template asin*[T](x: T): float = arcsin(x)
template atan*[T](x: T): float = arctan(x)
template atan2*[T](x: T): float = arctan2(x)

template cos*(x: int): float = math.cos(x.toFloat)
export cos

template hypot*(x: int): float = math.hypot(x.toFloat)
export hypot

template sin*(x: int): float = math.sin(x.toFloat)
export sin

template tan*(x: int): float = math.tan(x.toFloat)
export tan

template degrees*[T](x: T): float = radToDeg(x.toFloat)

template radians*[T](x: T): float = degToRad(x.toFloat)

template acosh*[T](x: T): float = arccosh(x)
template asinh*[T](x: T): float = arcsinh(x)
template atanh*[T](x: T): float = arctanh(x)

template cosh*(x: int): float = math.cosh(x.toFloat)
export cosh

template sinh*(x: int): float = math.sinh(x.toFloat)
export sinh

template tanh*(x: int): float = math.tanh(x.toFloat)
export tanh

const
    pi* = math.PI
    e* = math.E
    tau* = math.TAU

export Inf
export NegInf
export NaN

template erf*(x: int): float = math.erf(x.toFloat)
export erf
template erfc*(x: int): float = math.erfc(x.toFloat)
export erfc

template gamma*(x: int): float = math.gamma(x.toFloat)
export gamma
template lgamma*(x: int): float = math.lgamma(x.toFloat)
export lgamma

if isMainModule:
    echo copysign(2,4)
    echo cos(2)
