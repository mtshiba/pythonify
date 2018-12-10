import strutils
import strformat
import sequtils
import macros

{.push checks:off, line_dir:off, stack_trace:off, debugger:off.}

proc insertGenerics*(args: seq[string]):string =
    var counter = 1
    var ret = ""
    var idx = 0
    var vargs = args[1..^1]
    for i in 'A'..'Z':
        if vargs[idx].find("=") == -1:
            ret.add(i)
        else:
            counter += 1
        if counter >= vargs.len():
            break
        else:
            ret.add(",")
        counter.inc()
        idx.inc()
    return ret

proc insertArgs*(args: seq[string]): string =
    var ret = ""
    var gen = 'A'
    var vargs = args[1..^1]
    for i in vargs:
        var gens = ""
        gens.add(gen)
        if i.find("=") != -1:
            ret.add(i & ",")
        else:
            ret.add(i & fmt": {gens},")
        gen.inc()
    ret.delete(ret.len(), ret.len())
    return ret

# ------ def ------
# ジェネリクスで照合するのでメソッドの場合pythonより危険。解決策が思いついたら何とかする。
macro def*(head, body: untyped): untyped =
    let funcName: string = $head[0]
    var args: seq[string] = @[]
    for i in head:
        args.add(repr(i))
    var bodys: string = repr(body)
    bodys = bodys.replace("\x0A", "\x0A  ")
    var mainNode = ""
    if args.len() == 1:
        mainNode = fmt"proc {args[0]}*() {{.discardable.}} ={bodys}"
    # type anotation
    elif args[0] == "->":
        args[1] = args[1].replace("(", "*(")
        mainNode = fmt"proc {args[1]}: {args[2]} {{.discardable.}} ={bodys}"
    else:
        mainNode = fmt"proc {funcName}*[{insertGenerics(args)}]({insertArgs(args)}): untyped {{.discardable.}}={bodys}"
    result = parseStmt(mainNode)


## 公開しない関数。nimはトップレベル以外での関数のexportができない。
## private function
macro privatedef*(head, body: untyped): untyped =
    let funcName: string = $head[0]
    var args: seq[string] = @[]
    for i in head:
        args.add(repr(i))
    var bodys: string = repr(body)
    bodys = bodys.replace("\x0A", "\x0A  ")
    var mainNode = ""
    if args.len() == 1:
        mainNode = fmt"proc {args[0]}() {{.discardable.}} ={bodys}"
    # type anotation
    elif args[0] == "->":
        mainNode = fmt"proc {args[1]}: {args[2]} {{.discardable.}} ={bodys}"
    else:
        mainNode = fmt"proc {funcName}[{insertGenerics(args)}]({insertArgs(args)}): untyped {{.discardable.}}={bodys}"
    result = parseStmt(mainNode)


# ------ with -------
## (class).ENTER()と(class).EXIT()をインターフェースとして提供する
## 今のところasを使用したバージョンのみ対応
## provides (class).ENTER() and (class).EXIT() as an interface
## for now it only supports versions using "as"

macro with*(head, body: untyped): untyped =
    var res = ""
    head.expectLen(3)
    case head.len()
    of 3:
        assert $head[0] == "as"
        var args: seq[string] = @[]
        let classname = $head[1][0]
        for i in 1..head[1].len-1:
            args.add($head[1][i])
        let asname = $head[2]
        res = fmt"""
var {asname} = {classname}({args})
{asname}.ENTER()
{repr(body)}
{asname}.EXIT()"""
    else:
        discard
    # echo res
    parsestmt(res)

# decorator
macro `@`*(head, body: untyped): untyped =
    var
        bodys = repr(body)
    let
        dec = repr(head)
        fname = bodys.split(" ")[1].split("(")[0]
    bodys = bodys.multiReplace(("proc ", "proc unwrap"), ("def ", "def unwrap"), (",\n", ":\n"))
    parseStmt fmt"""
{bodys}
var {fname} = {dec}(unwrap{fname})
"""
