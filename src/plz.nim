import strutils, json, os, httpclient, parseopt, terminal, logging, osproc, rdstdin, uri, browsers, requirementstxt

var
  logfile = defaultFilename()
  pythonexe = findExe"python"

include plz/constants, plz/pypiapi, plz/pypinteract

import plz/sysinfo, plz/docgen, plz/projectgen, plz/dotenv

setControlCHook((proc {.noconv.} = quit" CTRL+C Pressed, shutting down, bye! "))

addHandler(newConsoleLogger(fmtStr = ""))

proc main() =
  var args: seq[string]
  for tipoDeClave, clave, valor in getopt():
    case tipoDeClave
    of cmdShortOption, cmdLongOption:
      case clave.normalize
      of "version":
        quit(static(NimblePkgVersion & "\n" & staticExec"git rev-parse --short HEAD"), 0)
      of "dump":
        quit(getSystemInfo().pretty, 0)
      of "log":
        logfile = valor
      of "python":
        doAssert fileExists(valor), "File not found: " & valor
        pythonexe = valor
      of "enusutf8":
        enUsUtf8()
      of "publicip":
        quit(newHttpClient(timeout = 9999).getContent("https://api.ipify.org"), 0)
      of "help", "ayuda", "fullhelp", "h":
        styledEcho(fgGreen, helpy)
        quit(errorcode = 0)
      of "dotenv":
        doAssert fileExists(valor), "File not found: " & valor
        let dotenvpairs = parseDotEnv(readFile(valor).strip)
        echo dotenvpairs.pretty
        for k_v in dotenvpairs.pairs:
          putEnv($k_v[0], $k_v[1])
      of "cleanpyc":
        cleanpyc()
      of "cleantemp", "cleartemp":
        cleantemp()
      of "cleanpypackages":
        cleanpypackages()
      of "cleanvenvs", "cleanvirtualenvs", "cleanvirtualenv", "clearvirtualenvs", "clearvirtualenv":
        cleanvenvs()
      of "cleanpipcache", "clearpipcache":
        cleanpipcache()
      of "suicide":
        echo tryRemoveFile(currentSourcePath()[0..^5])
    of cmdArgument:
      args.add clave
    of cmdEnd:
      quit("Wrong Parameters, please see Help with: --help", 1)

  addHandler(newRollingFileLogger(filename = logfile, fmtStr = verboseFmtStr))
  let is1argOnly = args.len == 2 # command + arg == 2 ("install foo")

  if args.len > 0:
    case args[0].normalize
    of "init":
      pySkeleton()
    of "bug":
      reportBug()
    of "stats":
      quit($client.stats(), 0)
    of "newpackages":
      quit($client.newPackages(), 0)
    of "lastupdates":
      quit($client.lastUpdates(), 0)
    of "lastjobs":
      quit($client.lastJobs(), 0)
    of "userpackages":
      quit($client.userPackages(readLineFromStdin("PyPI Username?: ").normalize), 0)
    of "uninstall":
      client.uninstall(args[1..^1])
    of "install":
      client.multiInstall(args[1..^1])
    of "download":
      client.download(args[1..^1])
    of "doc":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      quit(doc2html(args[1]), 0)
    of "doc2latex":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      quit(doc2latex(args[1]), 0)
    of "doc2json":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      quit(doc2json(args[1]), 0)
    of "reinstall":
      client.uninstall(args[1..^1])
      client.multiInstall(args[1..^1])
    of "latestversion":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      quit($client.packageLatestRelease(args[1]), 0)
    of "strip":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      quit(execCmdEx(cmdStrip & args[1]).output, 0)
    of "fakecommits":
      fakeCommits(readLineFromStdin("How many 'Fake' commits to generate? (Positive integer): ").parseInt.Positive)
      quit(errorcode = 0)
    of "hash":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      if findExe"sha256sum".len > 0:
        let sha256sum = execCmdEx(cmdChecksum & args[1]).output.strip
        info sha256sum
        info "--hash=sha256:" & sha256sum.split(" ")[^1]
    of "parserequirements":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      for item in requirements(readFile(args[1]), [("*", "0")]):
        echo item
    of "upload":
      if not is1argOnly:
        quit"Too many arguments,command only supports 1 argument"
      uploadToPypi(args[1])
  else:
    quit("Wrong Parameters, please see Help with: --help", 1)


when isMainModule:
  main()
