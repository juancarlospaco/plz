import strutils, os, parseopt, terminal, logging, osproc, rdstdin, requirementstxt
include plz/constants, plz/utils, plz/docgen, plz/pypiapi, plz/pypinteract, plz/projectgen, plz/sysinfo

addHandler(newConsoleLogger(fmtStr = ""))
setControlCHook((proc {.noconv.} = quit" CTRL+C Pressed, shutting down, bye! "))
var logfile = defaultFilename()

proc main() =
  var args: seq[string]
  for tipoDeClave, clave, valor in getopt():
    case tipoDeClave
    of cmdShortOption, cmdLongOption:
      case clave.normalize
      of "version": quit(static(NimblePkgVersion & "\n" & staticExec"git rev-parse --short HEAD"), 0)
      of "license", "licencia": quit("PPL", 0)
      of "dump": quit(getSystemInfo().pretty, 0)
      of "nice20": echo nice(20.cint)
      of "log": logfile = valor
      of "enusutf8": enUsUtf8()
      of "publicip": quit(newHttpClient(timeout = 9999).getContent("https://api.ipify.org"), 0)
      of "help", "ayuda", "fullhelp", "h":
        styledEcho(fgGreen, bgBlack, helpy)
        quit(errorcode = 0)
      of "putenv":
        let envy = valor.split"="
        styledEcho(fgMagenta, bgBlack, $envy)
        putEnv(envy[0], envy[1])
      of "cleanpyc":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for pyc in walkFiles(getCurrentDir() / "*.pyc"): info $tryRemoveFile(pyc) & "\t" & pyc
        for pyc in walkDirs(getCurrentDir() / "__pycache__"): info $tryRemoveFile(pyc) & "\t" & pyc
      of "cleantemp", "cleartemp":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for tmp in walkPattern(getTempDir() / "**" / "*.*"): info $tryRemoveFile(tmp) & "\t" & tmp
        for tmp in walkPattern(getTempDir() / "**" / "*"): info $tryRemoveFile(tmp) & "\t" & tmp
      of "cleanpypackages":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for pyc in walkFiles(getCurrentDir() / "__pypackages__"): info $tryRemoveFile(pyc) & "\t" & pyc
      of "cleanvenvs", "cleanvirtualenvs", "cleanvirtualenv", "clearvirtualenvs", "clearvirtualenv":
        let files2delete = block:
          var x: seq[string]
          for pythonfile in walkPattern(virtualenvDir / "*.*"):
            styledEcho(fgRed, bgBlack, pythonfile)
            if readLineFromStdin("Delete Python Virtualenv? (y/N): ").normalize == "y": x.add pythonfile
          x # No official documented way to get virtualenv location on windows
        if files2delete.len > 0:
          styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
          for pyc in files2delete: info $tryRemoveFile(pyc) & "\t" & pyc
        else: styledEcho(fgGreen, bgBlack, "Virtualenvs not found, nothing to clean.")
      of "cleanpipcache", "clearpipcache":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile") # Dir Found in the wild
        info $tryRemoveFile("/tmp/pip-build-root") & "\t/tmp/pip-build-root"
        info $tryRemoveFile("/tmp/pip_build_root") & "\t/tmp/pip_build_root"
        info $tryRemoveFile("/tmp/pip-build-" & getEnv"USER") & "\t/tmp/pip-build-" & getEnv"USER"
        info $tryRemoveFile("/tmp/pip_build_" & getEnv"USER") & "\t/tmp/pip_build_" & getEnv"USER"
        info $tryRemoveFile(pipCacheDir) & "\t" & pipCacheDir
      of "suicide": echo tryRemoveFile(currentSourcePath()[0..^5])
    of cmdArgument: args.add clave
    of cmdEnd: quit("Wrong Parameters, please see Help with: --help", 1)
  addHandler(newRollingFileLogger(filename = logfile, fmtStr = verboseFmtStr))
  let is1argOnly = args.len == 2 # command + arg == 2 ("install foo")
  if args.len > 0:
    case args[0].normalize
    of "init": pySkeleton()
    of "completion", "completions": quit(completionsTemplate, 0)
    of "stats": quit($client.stats(), 0)
    of "newpackages": quit($client.newPackages(), 0)
    of "lastupdates": quit($client.lastUpdates(), 0)
    of "lastjobs": quit($client.lastJobs(), 0)
    of "userpackages": quit($client.userPackages(readLineFromStdin("PyPI Username?: ").normalize), 0)
    of "uninstall": client.uninstall(args[1..^1])
    of "install": client.multiInstall(args[1..^1])
    of "download": client.download(args[1..^1])
    of "doc":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(doc2html(args[1]), 0)
    of "doc2latex":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(doc2latex(args[1]), 0)
    of "doc2json":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(doc2json(args[1]), 0)
    of "reinstall":
      client.uninstall(args[1..^1])
      client.multiInstall(args[1..^1])
    of "latestversion":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit($client.packageLatestRelease(args[1]), 0)
    of "open":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(execCmdEx(osOpen & args[1]).output, 0)
    of "strip":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(execCmdEx(cmdStrip & args[1]).output, 0)
    of "hash":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      if findExe"sha256sum".len > 0:
        let sha256sum = execCmdEx(cmdChecksum & args[1]).output.strip
        info sha256sum
        info "--hash=sha256:" & sha256sum.split(" ")[^1]
    of "parserequirements":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      for item in requirements(readFile(args[1]), [("*", "0")]): echo item
    of "upload":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      doAssert fileExists(args[1]), "File not found: " & args[1]
      let (username, password, name, author, version, license, summary, homepage,
        description, downloadurl, maintainer, authoremail, maintaineremail, keywords
      ) = ask2User()
      echo (username, name, author, version, license, summary, homepage,
        description, downloadurl, maintainer, authoremail, maintaineremail, keywords)
      info client.upload(
        username = username, password = password, name = name,
        version = version, license = license, summary = summary,
        description = description, author = author, downloadurl = downloadurl,
        authoremail = authoremail, maintainer = maintainer, keywords = keywords,
        maintaineremail = maintaineremail, homepage = homepage, filename = args[1],
        md5_digest = getMD5(readFile(args[1])))
  else: quit("Wrong Parameters, please see Help with: --help", 1)


when isMainModule: main()
