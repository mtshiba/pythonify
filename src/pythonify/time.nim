import os
import times

proc sleep*(time: int) = os.sleep(time*1000)
proc clock*(): float = cpuTime()
