version     = CompileDate.replace("-", ".")
author      = "Juan Carlos"
description = "PLZ Python PIP alternative"
license     = "MIT"
srcDir      = "src"
bin         = @["plz"]

requires "nim >= 1.2.4"
requires "requirementstxt >= 0.0.1"
requires "libarchibi >= 0.0.1"
