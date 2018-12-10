# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

#[import pythonify

import pythonify/datetime as datetime
import pythonify/time as time

proc lap(fn: proc): proc =
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
]#

echo if cpuEndian == littleEndian: "litte" else: "big"