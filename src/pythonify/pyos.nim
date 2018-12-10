import ../pythonify
import os

template error = OSError
var argv = os.commandLineParams()
var path = newEmptyList(string)
