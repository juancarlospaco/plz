import strutils, os, times, osproc

template enUsUtf8() =
  for envar in ["LC_CTYPE", "LC_NUMERIC", "LC_TIME", "LC_COLLATE", "LC_NAME", "LC_MONETARY", "LC_MESSAGES", "LC_PAPER",
    "LC_ADDRESS", "LC_TELEPHONE", "LANG", "LC_MEASUREMENT", "LC_IDENTIFICATION", "LC_ALL"]: putEnv(envar, "en_US.UTF-8")

template forceInstallPip(destination: string): tuple[output: TaintedString, exitCode: int] =
  newHttpClient(timeout = 9999).downloadFile("https://bootstrap.pypa.io/get-pip.py", destination) # Download
  assert fileExists(destination), "File not found: 'get-pip.py'"
  execCmdEx(findExe"python3" & " " & destination & " -I") # Installs PIP via get-pip.py
