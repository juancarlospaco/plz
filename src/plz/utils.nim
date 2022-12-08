import httpclient, os, osproc, terminal, rdstdin, times, random, browsers, sugar, strutils, uri, json, sysinfo


var bodi = """
# Description


# Examples

```python

```


# Current Output

```python

```


# Expected Output

```python

```

# Possible Solution


# Additional Information


# System Information

"""


proc enUsUtf8*() =
  putEnv("LANG",              "en_US.UTF-8")
  putEnv("LC_ALL",            "en_US.UTF-8")
  putEnv("LC_TIME",           "en_US.UTF-8")
  putEnv("LC_NAME",           "en_US.UTF-8")
  putEnv("LC_PAPER",          "en_US.UTF-8")
  putEnv("LC_CTYPE",          "en_US.UTF-8")
  putEnv("LC_ADDRESS",        "en_US.UTF-8")
  putEnv("LC_NUMERIC",        "en_US.UTF-8")
  putEnv("LC_COLLATE",        "en_US.UTF-8")
  putEnv("LC_MONETARY",       "en_US.UTF-8")
  putEnv("LC_MESSAGES",       "en_US.UTF-8")
  putEnv("LC_TELEPHONE",      "en_US.UTF-8")
  putEnv("LC_MEASUREMENT",    "en_US.UTF-8")
  putEnv("LC_IDENTIFICATION", "en_US.UTF-8")


proc cleanvenvs*() =
  # No official documented way to get virtualenv location on windows
  var files2delete: seq[string]
  for pythonfile in walkPattern("~/.virtualenvs" / "*.*"):
    styledEcho(fgRed, bgBlack, pythonfile)
    if readLineFromStdin("Delete Python Virtualenv? (y/N): ") == "y":
      files2delete.add pythonfile
  if files2delete.len > 0:
    styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
    for pyc in files2delete:
      echo $tryRemoveFile(pyc) & '\t' & pyc
  else:
    styledEcho(fgGreen, bgBlack, "Virtualenvs not found, nothing to clean.")


proc cleanpipcache*() =
  const pipCacheDir =
    when defined(linux): r"~/.cache/pip"  # PIP "standards"
    elif defined(macos): r"~/Library/Caches/pip"
    elif defined(windows): r"%LocalAppData%\pip\Cache"
    else: getEnv"PIP_DOWNLOAD_CACHE"
  let temp = getTempDir()
  echo "\n\nDeleted?\tFile" # Dir Found in the wild
  echo $tryRemoveFile(temp / "pip-build-root") & '\t' & temp / "pip-build-root"
  echo $tryRemoveFile(temp / "pip_build_root") & '\t' & temp / "pip_build_root"
  echo $tryRemoveFile(temp / "pip-build-" & getEnv"USER") & '\t' & temp / "pip-build-" & getEnv"USER"
  echo $tryRemoveFile(temp / "pip_build_" & getEnv"USER") & '\t' & temp / "pip_build_" & getEnv"USER"
  echo $tryRemoveFile(pipCacheDir) & '\t' & pipCacheDir
  echo $tryRemoveFile(getEnv"PIP_DOWNLOAD_CACHE") & '\t' & getEnv"PIP_DOWNLOAD_CACHE"


proc cleanpyc*() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for pyc in walkFiles(getCurrentDir() / "*.pyc"):
    echo $tryRemoveFile(pyc) & '\t' & pyc
  for pyc in walkDirs(getCurrentDir() / "__pycache__"):
    echo $tryRemoveFile(pyc) & '\t' & pyc


proc cleantemp*() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for tmp in walkPattern(getTempDir() / "**" / "*.*"):
    echo $tryRemoveFile(tmp) & '\t' & tmp
  for tmp in walkPattern(getTempDir() / "**" / "*"):
    echo $tryRemoveFile(tmp) & '\t' & tmp


proc cleanpypackages*() =
  styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
  for pyc in walkFiles(getCurrentDir() / "__pypackages__"):
    echo $tryRemoveFile(pyc) & '\t' & pyc


proc fakeCommits*(amount: Positive) =
  const fakeCommitMessages = [
    "'Update documentation'", "'Fix a Typo'", "'Update README.md'", "'Optimization, minor'", "'Typo, minor'", "'Minor'", "'Fix README'",
    "'Update config'", "'Fix configuration'", "'Update configuration'", "'Fix trailing whitespaces'", "'Add Documentation'", "'Styles'",
    "'Optimization of a structure'", "'Add a new line at the end of the file'", "'Remove extra spaces'", "'Code Style'", "'Updates'",
    "'Improve code style'", "'Fix wrong name on a variable'", "'Trim spaces'", "'Strip spaces'", "'Rename a variable'", "'Fixes'",
    "'-'", "'.'", "'Format code'", "'Reorder an import'", "'Minor, style'", "'Fix typo on documentation'", "'Optimizations'", "'OwO'",
    "'Bump'", "'Fix Docs'", "'Add Docs'", "'Improve user documentation'", "'Minor optimizations'", "'Tiny refactor'", "'Working now'",
    "'init'", "'Add a test'", "'Fix a test'", "'improve a test'", "'tests'", "'Deprecate old stuff'", "'New code'", "'Small change'",
    "'Fix helper function'", "'Remove debug code'", "'Clean out comments'", "'Add comments to code'", "'improvements'", "'Optimize'"
  ]
  for i in 0..amount:
    discard execShellCmd("git commit --allow-empty --date='" &
      $(now() - minutes(i + rand(0..9))) & "' --message=" & fakeCommitMessages.sample)


proc reportBug*() =
  var title, labels, assignee, urlz, linky: string
  bodi.add("<details>\n\n```json\n\n" & getSystemInfo().pretty & "\n```\n[_Powered by PLZ_](https://github.com/juancarlospaco/plz)\n</details>\n\n")
  echo "Python Bug Report Assistant: Answer a few questions, generate a Bug report on GitHub!."
  while title.len == 0:
    title = readLineFromStdin("Issue report short and descriptive Title? (Must not be empty): ").strip
  labels = readLineFromStdin("Issue report proposed Labels? (Comma separated, can be empty): ").strip
  if labels.len > 0:
    bodi.add "# Proposed Labels\n\n```csv\n" & labels & "\n```\n\n"
  assignee = readLineFromStdin("Issue report 1 proposed Assignee? (GitHub User, can be empty): ").strip
  if assignee.len > 0:
    bodi.add "# Proposed Assignee\n\n* <kbd>" & assignee & "</kbd>\n\n"
  var links = newSeqOfCap[string](9)
  for _ in 1..9:
    linky = readLineFromStdin("Links with useful info/pastebin?  (9 Links max, can be empty): ").toLowerAscii.strip
    if linky.len == 0: break else: links.add linky
  if links.len > 0:
    bodi.add "# Links\n\n"
    for i, url in links: bodi.add $i & ". " & url & '\n'
    bodi.add "\n\n"
  urlz = ("https://github.com/" & readLineFromStdin("GitHub User or Team?: ").strip & '/' &
    readLineFromStdin("GitHub Repository?:   ").strip & "/issues/new?" &
    encodeQuery({"title": title, "labels": labels, "assignee": assignee, "body": bodi}))
  echo urlz
  openDefaultBrowser urlz


proc forceInstallPip*(destination: string): tuple[output: string, exitCode: int] =
  assert destination.len > 0, "destination must not be empty string"
  let client = newHttpClient(timeout = 9999)
  client.downloadFile("https://bootstrap.pypa.io/get-pip.py", destination) # Download
  client.close()
  assert fileExists(destination), "File not found: 'get-pip.py'"
  execCmdEx(pythonexe & ' ' & destination & " -I") # Installs PIP via get-pip.py


template compressImpl(filename, includes, excludes: string, verbose: bool): string =
  ("bsdtar --format ustar --create --auto-compress -f '" & filename & "' " &
  (if excludes.len > 0: "--exclude='" & excludes & "' " else: " ") &
  (if includes.len > 0: "--include='" & includes & "' " else: " ") & (if verbose: "-v -totals " else: " "))

proc compress*(filename: string, includes = "", excludes = "", verbose = true): tuple[output: string, exitCode: int] =
  doAssert filename.len > 0, "filename must not be empty string"
  result = execCmdEx(compressImpl(filename, includes, excludes, verbose))


template extractImpl(filename, destinationDir: string, overwrite, verbose, permissions, time: bool): string =
  ("bsdtar --extract -C '" & destinationDir & "' -f '" & filename & "' " &
  (if permissions: "-p " else: "") & (if overwrite: "" else: "-k ") &
  (if verbose: "-v " else: "") & (if time: "" else: "-m "))

proc extract*(filename, destinationDir: string, overwrite = true, verbose = true, permissions = true, time = true): tuple[output: string, exitCode: int] =
  doAssert filename.len > 0 and destinationDir.len > 0, "filename must not be empty string"
  result = execCmdEx(extractImpl(filename, destinationDir, overwrite, verbose, permissions, time))


proc tryRemoveSitePackagesDir(path: string): bool =
  #doAssert contains(path, "site-packages"), "path " & path & " should be located inside site-packages"
  if not dirExists(path):
    return true
  try:
    removeDir(path / "__pycache__")
  except OSError:
    discard
  let files = collect(for f in walkDir(path): f)
  if len(files) > 0:
    return false
  try:
    removeDir(path)
    return true
  except OSError:
    return false

proc removeFileAndEmptyDirsUntilSitePackages(path: string): bool =
  #doAssert contains(path, "site-packages"), "path " & path & " should be located inside site-packages"
  if not tryRemoveFile(path):
    return false
  var currentPath = path
  while true:
    var pathPart = splitPath(currentPath)
    if pathPart[1] in ["", "site-packages"] or not tryRemoveSitePackagesDir(pathPart[0]):
      break
    currentPath = pathPart[0]
  return true
