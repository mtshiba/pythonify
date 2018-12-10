{.experimental: "notnil".}

import times
import typetraits
import strformat
import strutils
import math
import builtinClass/pyStrUtils
import ../pythonify

import time

const
    minyear = 1
    maxyear = 9999

type date* = ref object of RootObj
  monthday*: MonthdayRange
  month*: Month
  year*: int
  weekday*: WeekDay
  yearday*: YeardayRange
  timezone*: Timezone
  utcOffset*: int

type pydatetime* = object of date not nil
  nanosecond*: NanosecondRange
  second*: SecondRange
  minute*: MinuteRange
  hour*: HourRange

type Timedelta = object of RootObj
  days*: int
  hours*: int
  minutes*: int
  seconds*: int
  milliseconds*: int
  microseconds*: int
  nanosecond*: int

proc timedelta*(days, weeks, hours, minutes, seconds, milliseconds, microseconds, nanosecond: int=0): Timedelta =
    result.days = days + weeks*7
    result.hours = hours
    result.minutes = minutes
    result.seconds = seconds
    result.milliseconds = milliseconds
    result.microseconds = microseconds + nanosecond // 1000

# 基本的にnimのtimesを使いまわす方針
proc toNimdatetime(dt: pydatetime): Datetime =
    Datetime(nanosecond:dt.nanosecond,
            second:dt.second,
            minute:dt.minute,
            hour:dt.hour,
            monthday:dt.monthday,
            month:dt.month,
            year:dt.year,
            weekday:dt.weekday,
            yearday:dt.yearday,
            timezone:dt.timezone,
            utcOffSet:dt.utcOffSet
            )

proc toPydatetime(dt: Datetime): pydatetime =
    pydatetime(nanosecond:dt.nanosecond,
            second:dt.second,
            minute:dt.minute,
            hour:dt.hour,
            monthday:dt.monthday,
            month:dt.month,
            year:dt.year,
            weekday:dt.weekday,
            yearday:dt.yearday,
            timezone:dt.timezone,
            utcOffSet:dt.utcOffSet
            )

proc toFloat(td: Timedelta): float =
    td.days.toFloat*24*60*60 + td.hours.toFloat*60*60 + td.minutes.toFloat*60 + td.seconds.toFloat + 0.001*td.milliseconds.toFloat + 0.001*0.001*td.microseconds.toFloat

proc toDelta(f: float): Timedelta =
    var intf = f.splitDecimal()[0].toInt
    let day = (intf - intf mod (24*60*60)) // (24*60*60)
    intf -= day*24*60*60
    let hour = (intf - intf mod (60*60)) // (60*60)
    intf -= hour*60*60
    let minute = (intf - intf mod 60) // 60
    intf -= minute*60
    # オーバーフローが起こるので小数点以下6桁で丸める
    let
        floatf = f.splitDecimal()[1].round(6)
        strf = $floatf
    var millis, micros = 0
    case strf.len()
    of 3:
        millis = strf[2..2].parseInt
    of 4:
        millis = strf[2..3].parseInt
    of 5:
        millis = strf[2..4].parseInt
    of 6:
        millis = strf[2..4].parseInt
        micros = strf[5..5].parseInt
    of 7:
        millis = strf[2..4].parseInt
        micros = strf[5..6].parseInt
    of 8:
        millis = strf[2..4].parseInt
        micros = strf[5..7].parseInt
    else:
        discard

    timedelta(days=day,hours=hour,minutes=minute,seconds=intf,milliseconds=millis,microseconds=micros)

proc toDelta(d: Duration): Timedelta =
    result.days = int(d.days)
    result.hours = int(d.hours)
    result.minutes = int(d.minutes)
    result.seconds = int(d.seconds)
    result.milliseconds = d.milliseconds
    result.microseconds = d.microseconds

proc `$`*(td: Timedelta): string =
    let
        d = td.days
        h = zfill($td.hours, 2)
        m = zfill($td.minutes, 2)
        s = zfill($td.seconds, 2)
        mils = zfill($td.milliseconds, 3)
        mics = zfill($td.microseconds, 3)
    if d > 0:
        fmt"{$d} days, {h}:{m}:{s}.{mils}{mics}"
    else:
        fmt"{h}:{m}:{s}.{mils}{mics}"

proc `$`*(dt: pydatetime): string =
    dt.toNimdatetime.format("yyyy-MM-dd HH:mm:ss'.'ffffff")


proc today*(dt: type pydatetime): pydatetime = now().toPydatetime

template now*(dt: type pydatetime): pydatetime = pydatetime.today()

proc min*(td: type Timedelta): Timedelta = timedelta(days=999999999)
proc max*(td: type Timedelta): Timedelta = timedelta(days=(-999999999))
proc resolution*(td: type Timedelta): Timedelta = timedelta(microseconds=1)

# operation
proc `+`*(td1, td2: Timedelta): Timedelta = (td1.toFloat + td2.toFloat).toDelta
proc `-`*(td1, td2: Timedelta): Timedelta = (td1.toFloat - td2.toFloat).toDelta
proc `*`*(td: Timedelta, t: float): Timedelta = (td.toFloat * t).toDelta
proc `*`*(t: float, td: Timedelta): Timedelta = td * t
proc `*`*(td1, td2: Timedelta): Timedelta = (td1.toFloat * td2.toFloat).toDelta
proc `/`*(td: Timedelta, t: float): Timedelta = (td.toFloat / t).toDelta
proc `/`*(td1, td2: Timedelta): Timedelta = (td1.toFloat / td2.toFloat).toDelta
proc `+`*(td: Timedelta): Timedelta = td
proc `-`*(td: var Timedelta): Timedelta = td * -1
proc abs*(td: var Timedelta): Timedelta =
    if td.days >= 0: td else: -td
proc `-`*(dt1, dt2: pydatetime): Timedelta = (dt1.toNimdatetime - dt2.toNimdatetime).toDelta

proc repr*(td: Timedelta): string = $td

if isMainModule:
    let min = pydatetime.now()
    time.sleep(1000)
    echo pydatetime.now() - min
