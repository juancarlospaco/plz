import httpclient, os, osproc

template enUsUtf8() =
  putEnv("LC_CTYPE", "en_US.UTF-8")
  putEnv("LC_NUMERIC", "en_US.UTF-8")
  putEnv("LC_TIME", "en_US.UTF-8")
  putEnv("LC_COLLATE", "en_US.UTF-8")
  putEnv("LC_NAME", "en_US.UTF-8")
  putEnv("LC_MONETARY", "en_US.UTF-8")
  putEnv("LC_MESSAGES", "en_US.UTF-8")
  putEnv("LC_PAPER", "en_US.UTF-8")
  putEnv("LC_ADDRESS", "en_US.UTF-8")
  putEnv("LC_TELEPHONE", "en_US.UTF-8")
  putEnv("LANG", "en_US.UTF-8")
  putEnv("LC_MEASUREMENT", "en_US.UTF-8")
  putEnv("LC_IDENTIFICATION", "en_US.UTF-8")
  putEnv("LC_ALL", "en_US.UTF-8")

template forceInstallPip(destination: string): tuple[output: TaintedString, exitCode: int] =
  assert destination.len > 0, "destination must not be empty string"
  newHttpClient(timeout = 9999).downloadFile("https://bootstrap.pypa.io/get-pip.py", destination) # Download
  assert fileExists(destination), "File not found: 'get-pip.py'"
  execCmdEx(findExe"python3" & " " & destination & " -I") # Installs PIP via get-pip.py
