import httpclient, os, osproc, macros

template `:=`(name: untyped; value: any) =
  var name {.inject.} = createU(type(value), sizeOf type(value))
  name[] = value

macro deallocs(variables: varargs[typed]) =
  result = newStmtList()
  for it in variables: result.add newCall(bindSym"dealloc", it)

macro creates(value: any; variables: varargs[untyped]) =
  result = newStmtList()
  for it in variables: result.add quote do:
    var `it` = createU(type(`value`), sizeOf type(`value`))
    `it`[] = `value`

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

template cleanvenvs() =
  # No official documented way to get virtualenv location on windows
  let files2delete = create(seq[string], sizeOf seq[string])
  for pythonfile in walkPattern(virtualenvDir / "*.*"):
    styledEcho(fgRed, bgBlack, pythonfile)
    if readLineFromStdin("Delete Python Virtualenv? (y/N): ") == "y": files2delete[].add pythonfile
  if files2delete[].len > 0:
    styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
    for pyc in files2delete[]: echo $tryRemoveFile(pyc) & "\t" & pyc
  else: styledEcho(fgGreen, bgBlack, "Virtualenvs not found, nothing to clean.")
  dealloc files2delete

template cleanpipcache() =
  let temp = create(string, sizeOf string)
  temp[] = getTempDir()
  echo "\n\nDeleted?\tFile" # Dir Found in the wild
  echo $tryRemoveFile(temp[] / "pip-build-root") & "\t" & temp[] / "pip-build-root"
  echo $tryRemoveFile(temp[] / "pip_build_root") & "\t" & temp[] / "pip_build_root"
  echo $tryRemoveFile(temp[] / "pip-build-" & getEnv"USER") & "\t" & temp[] / "pip-build-" & getEnv"USER"
  echo $tryRemoveFile(temp[] / "pip_build_" & getEnv"USER") & "\t" & temp[] / "pip_build_" & getEnv"USER"
  echo $tryRemoveFile(pipCacheDir) & "\t" & pipCacheDir
  echo $tryRemoveFile(getEnv"PIP_DOWNLOAD_CACHE") & "\t" & getEnv"PIP_DOWNLOAD_CACHE"
  dealloc temp

template cleanpyc() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for pyc in walkFiles(getCurrentDir() / "*.pyc"): info $tryRemoveFile(pyc) & "\t" & pyc
  for pyc in walkDirs(getCurrentDir() / "__pycache__"): info $tryRemoveFile(pyc) & "\t" & pyc

template cleantemp() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for tmp in walkPattern(getTempDir() / "**" / "*.*"): info $tryRemoveFile(tmp) & "\t" & tmp
  for tmp in walkPattern(getTempDir() / "**" / "*"): info $tryRemoveFile(tmp) & "\t" & tmp

template cleanpypackages() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for pyc in walkFiles(getCurrentDir() / "__pypackages__"): info $tryRemoveFile(pyc) & "\t" & pyc

template fakeCommits(amount: Positive) =
  for i in 0..amount: discard execShellCmd("git commit --allow-empty --date='" & $(now() - minutes(i + rand(0..9))) & "' --message=" & fakeCommitMessages.sample)
