import
  httpclient, strutils, xmlparser, xmltree, json, mimetypes, os, base64, tables,
  parseopt, terminal, times, posix, posix_utils, logging, osproc, rdstdin, md5,
  packages/docutils/rst, packages/docutils/rstgen, packages/docutils/rstast,
  strtabs, std/sha1, requirementstxt, libarchibi
include constants

type PyPI = HttpClient
let client: PyPI = newHttpClient(maxRedirects = maxRedirects, timeout = timeouts, headers = headerJson)


# ^ Types,Constants,Imports,Includes #################### v PyPI API procedures


proc newPackages(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Newest Packages uploaded to PyPI.
  this.headers = headerXml
  result = parseXml(this.getContent(pypiPackagesXml))

proc lastUpdates(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Latest Updates uploaded to PyPI.
  this.headers = headerXml
  result = parseXml(this.getContent(pypiUpdatesXml))

proc lastJobs(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Latest Jobs posted to PyPI.
  this.headers = headerXml
  result = parseXml(this.getContent(pypiJobUrl))

proc project(this: PyPI, projectName): JsonNode {.inline.} =
  ## Return all JSON JsonNode type data for projectName from PyPI.
  this.headers = headerJson
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/json"))

proc release(this: PyPI, projectName, projectVersion): JsonNode {.inline.} =
  ## Return all JSON data for projectName of an specific version from PyPI.
  this.headers = headerJson
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/" & projectVersion & "/json"))

proc htmlAllPackages(this: PyPI): string {.inline.} =
  ## Return all projects registered on PyPI as HTML string,Legacy Endpoint,Slow.
  result = this.getContent(url = pypiApiUrl & "simple")

proc htmlPackage(this: PyPI, projectName): string {.inline.} =
  ## Return a project registered on PyPI as HTML string, Legacy Endpoint, Slow.
  result = this.getContent(url = pypiApiUrl & "simple/" & projectName)

proc stats(this: PyPI): XmlNode {.inline.} =
  ## Return all JSON stats data for projectName of an specific version from PyPI.
  this.headers = headerXml
  result = parseXml(this.getContent(url = pypiStatus))

proc listPackages(this: PyPI): seq[string] {.inline.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI. Server-side Slow.
  this.headers = headerXml
  for t in parseXml(this.postContent(pypiXmlUrl, body = lppXml)).findAll"string": result.add t.innerText

proc changelogLastSerial(this: PyPI): int {.inline.} =
  ## Return 1 XML XmlNode with the Last Serial number integer.
  this.headers = headerXml
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = clsXml)).findAll"int": result = tagy.innerText.parseInt

proc listPackagesWithSerial(this: PyPI): seq[array[2, string]] {.inline.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI with Serial number integer. Server-side Slow.
  this.headers = headerXml
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = lpsXml)).findAll"member":
    result.add [tagy.child"name".innerText, tagy.child"value".child"int".innerText]

proc packageLatestRelease(this: PyPI, packageName): string {.inline.} =
  ## Return the latest release registered for the given packageName.
  this.headers = headerXml
  let bodi = xmlRpcBody.format("package_releases", xmlRpcParam.format(packageName))
  for t in parseXml(this.postContent(pypiXmlUrl, body = bodi)).findAll"string": result = t.innerText

proc packageRoles(this: PyPI, packageName): seq[XmlNode] {.inline.} =
  ## Retrieve a list of role, user for a given packageName. Role is Maintainer or Owner.
  this.headers = headerXml
  let bodi = xmlRpcBody.format("package_roles", xmlRpcParam.format(packageName))
  for t in parseXml(this.postContent(pypiXmlUrl, body = bodi)).findAll"data": result.add t

proc userPackages(this: PyPI, user = user): seq[XmlNode] =
  ## Retrieve a list of role, packageName for a given user. Role is Maintainer or Owner.
  this.headers = headerXml
  let bodi = xmlRpcBody.format("user_packages", xmlRpcParam.format(user))
  for t in parseXml(this.postContent(pypiXmlUrl, body = bodi)).findAll"data": result.add t

proc releaseUrls(this: PyPI, packageName, releaseVersion): seq[string] =
  ## Retrieve a list of download URLs for the given releaseVersion. Returns a list of dicts.
  this.headers = headerXml
  let bodi = xmlRpcBody.format("release_urls", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion))
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = bodi)).findAll"string":
    if tagy.innerText.normalize.startsWith"https://": result.add tagy.innerText

proc downloadPackage(this: PyPI, packageName, releaseVersion, destDir = getTempDir(), generateScript): string =
  ## Download a URL for the given releaseVersion. Returns filename.
  let choosenUrl = this.releaseUrls(packageName, releaseVersion)[0]
  assert choosenUrl.startsWith"https://", "PyPI Download URL is not HTTPS SSL"
  let filename = destDir / choosenUrl.split("/")[^1]
  info "\t" & choosenUrl
  if generateScript: script &= "curl -LO " & choosenUrl & "\n"
  this.downloadFile(choosenUrl, filename)
  assert existsFile(filename), "file failed to download"
  info "\t" & $getFileSize(filename) & " Bytes total (compressed)"
  if likely(findExe"sha256sum".len > 0): info "\t" & execCmdEx(cmdChecksum & filename).output.strip
  try:
    info "\t" & choosenUrl & ".asc"
    this.downloadFile(choosenUrl & ".asc", filename & ".asc")
    if generateScript: script &= "curl -LO " & choosenUrl & ".asc" & "\n"
    if unlikely(findExe"gpg".len > 0 and existsFile(filename & ".asc")):
      info "\t" & execCmdEx(cmdVerify & filename & ".asc").output.strip
      if generateScript: script &= cmdVerify & filename.replace(destDir, "") & ".asc\n"
  except:
    warn "\tHTTP-404? " & choosenUrl & ".asc (Package without PGP Signature)"
  if generateScript: script &= pipInstallCmd & filename.replace(destDir, "") & "\n"
  result = filename

proc installPackage(this: PyPI, packageName, releaseVersion, generateScript): tuple[output: TaintedString, exitCode: int] =
  let packageFile = this.downloadPackage(packageName, releaseVersion, generateScript = generateScript)
  let oldDir = getCurrentDir()
  if unlikely(packageFile.endsWith".whl"):
    setCurrentDir(sitePackages)
    echo extract(packageFile, sitePackages).output
  else:
    setCurrentDir(getTempDir())
    echo extract(packageFile, getTempDir()).output
    let path = packageFile[0..^5]
    if existsFile(path / "setup.py"):
      setCurrentDir(path)
      result = execCmdEx(py3 & " " & path / "setup.py install --user")
  setCurrentDir(oldDir)

proc install(this: PyPI, args) =
  ## Install a Python package, download & decompress files, runs python setup.py
  var failed, suces: byte
  info($now() & ", PID is " & $getCurrentProcessId() & ", " & $args.len & " packages to download and install " & $args)
  let generateScript = readLineFromStdin"Generate Install Script? (y/N): ".normalize == "y"
  let time0 = now()
  for argument in args:
    let semver = $this.packageLatestRelease(argument)
    info "\t" & argument & "\t" & semver
    let resultados = this.installPackage(argument, semver, generateScript)
    info "\t" & resultados.output
    if resultados.exitCode == 0: inc suces else: inc failed
  if generateScript: info "\n" & script
  info($now() & " " & $failed & " Failed, " & $suces &
    " Success on " & $(now() - time0) & " to download+install " & $args.len & " packages")

proc download(this: PyPI, args) =
  ## Download a package to a local folder, dont decompress nor install.
  var dir: string
  while not existsDir(dir): dir = readLineFromStdin"Download to where? (Full path to existing folder): "
  for pkg in args: echo this.downloadPackage(pkg, $this.packageLatestRelease(pkg), dir, false)

proc releaseData(this: PyPI, packageName, releaseVersion): XmlNode {.inline.} =
  ## Retrieve metadata describing a specific releaseVersion. Returns a dict.
  this.headers = headerXml
  let bodi = xmlRpcBody.format("release_data", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion))
  result = parseXml(this.postContent(pypiXmlUrl, body = bodi))

proc search(this: PyPI, query, operator = "and"): XmlNode {.inline.} =
  ## Search package database using indicated search spec. Returns 100 results max.
  this.headers = headerXml
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("search", xmlRpcParam.format(replace($query, "@", "")) & xmlRpcParam.format(operator))))

proc browse(this: PyPI, classifiers): XmlNode {.inline.} =
  ## Retrieve a list of name, version of all releases classified with all of given classifiers.
  ## Classifiers must be a list of standard Trove classifier strings. Returns 100 results max.
  this.headers = headerXml
  var s: string
  for item in classifiers: s &= xmlRpcParam.format(item)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("browse", s)))

proc upload(this: PyPI, name, version, license, summary, description, author, downloadurl, authoremail, maintainer, maintaineremail, homepage, filename,
  md5_digest, username, password: string, keywords: seq[string], requirespython = ">=3", filetype = "sdist", pyversion = "source",
  description_content_type = "text/markdown; charset=UTF-8; variant=GFM"): string =
  ## Upload 1 new version of 1 registered package to PyPI from a local filename.
  ## PyPI Upload is HTTP POST with MultipartData with HTTP Basic Auth Base64.
  ## For some unknown reason intentionally undocumented (security by obscurity?)
  # https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
  # github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135
  let mime = newMimetypes().getMimetype(filename.splitFile.ext.toLowerAscii)
  # doAssert fext in ["whl", "egg", "zip"], "file extension must be 1 of .whl or .egg or .zip"
  let multipartData = block: # TODO: Finish this and test against the test dev pypi server.
    var output = newMultipartData()
    output["protocol_version"] = "1"
    output[":action"] = "file_upload"
    output["metadata_version"] = "2.1"
    output["author"] = author
    output["name"] = name.normalize
    output["md5_digest"] = md5_digest # md5 hash of file in urlsafe base64
    output["summary"] = summary.normalize
    output["version"] = version.toLowerAscii
    output["license"] = license.toLowerAscii
    output["pyversion"] = pyversion.normalize
    output["requires_python"] = requirespython
    output["homepage"] = homepage.toLowerAscii
    output["filetype"] = filetype.toLowerAscii
    output["description"] = description.normalize
    output["keywords"] = keywords.join(" ").normalize
    output["download_url"] = downloadurl.toLowerAscii
    output["author_email"] = authoremail.toLowerAscii
    output["maintainer_email"] = maintaineremail.toLowerAscii
    output["description_content_type"] = description_content_type.strip
    output["maintainer"] = if maintainer == "": author else: maintainer
    output["content"] = (filename, mime, filename.readFile)
    output
  this.headers = newHttpHeaders({"Authorization": "Basic " & encode(username & ":" & password), "dnt": "1"})
  result = this.postContent(pypiUploadUrl, multipart = multipartData)


# ^ End of PyPI API procedures ####################### v App related procedures


proc pySkeleton() =
  ## Creates the skeleton (folders and files) for a New Python project.
  let pluginName = readLineFromStdin"New Python project name?: ".normalize
  assert pluginName.len > 1, "Name must not be empty string: " & pluginName
  discard existsOrCreateDir(pluginName)
  discard existsOrCreateDir(pluginName / pluginName)
  writeFile(pluginName / pluginName / "__init__.py", "print('Hello World')\n")
  writeFile(pluginName / pluginName / "__main__.py", "\nprint('Main Module')\n")
  writeFile(pluginName / pluginName / "__version__.py", "__version__ = '0.0.1'\n")
  writeFile(pluginName / pluginName / "main.nim", nimpyTemplate)
  if readLineFromStdin("Generate optional Unitests on ./tests (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "tests")
    writeFile(pluginName / "tests" / "__init__.py", testTemplate)
  if readLineFromStdin("Generate optional Documentation on ./docs (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "docs")
    writeFile(pluginName / "docs" / "documentation.md", "# " & pluginName & "\n\n")
  if readLineFromStdin("Generate optional Examples on ./examples (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "examples")
    writeFile(pluginName / "examples" / "example.py", "# -*- coding: utf-8 -*-\n\nprint('Example')\n")
  if readLineFromStdin("Generate optional DevOps on ./devops (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "devops")
    writeFile(pluginName / "devops" / "Dockerfile", "")
    writeFile(pluginName / "devops" / pluginName & ".service", serviceTemplate)
    writeFile(pluginName / "devops" / "build_package.sh", "python3 setup.py sdist --formats=zip\n")
    writeFile(pluginName / "devops" / "upload_package.sh", "twine upload .\n")
  if readLineFromStdin("Generate optional GitHub files on .github (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / ".github")
    discard existsOrCreateDir(pluginName / ".github/ISSUE_TEMPLATE")
    discard existsOrCreateDir(pluginName / ".github/PULL_REQUEST_TEMPLATE")
    writeFile(pluginName / ".github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md", "")
    writeFile(pluginName / ".github/PULL_REQUEST_TEMPLATE/PULL_REQUEST_TEMPLATE.md", "")
    writeFile(pluginName / ".github/FUNDING.yml", "")
  if readLineFromStdin("Generate .gitignore file (y/N): ").normalize == "y":
    writeFile(pluginName / ".gitattributes", "*.py linguist-language=Python\n*.nim linguist-language=Nim\n")
    writeFile(pluginName / ".gitignore", "*.pyc\n*.pyd\n*.pyo\n*.egg-info\n*.egg\n*.log\n__pycache__\n*.c\n*.h\n*.o\n")
    writeFile(pluginName / ".coveragerc", "")
    discard existsOrCreateDir(pluginName / ".hooks")
  if readLineFromStdin("Generate optional files (y/N): ").normalize == "y":
    writeFile(pluginName / "MANIFEST.in", "include main.py\nrecursive-include *.py\n")
    writeFile(pluginName / "requirements.txt", "")
    writeFile(pluginName / "setup.cfg", setupCfg)
    writeFile(pluginName / "Makefile", "")
    writeFile(pluginName / "setup.py", "# -*- coding: utf-8 -*-\nfrom setuptools import setup\nsetup() # Edit setup.cfg,not here!.\n")
    let ext = if readLineFromStdin("Use Markdown(MD) instead of ReSTructuredText(RST)  (y/N): ").normalize == "y": "md" else: "rst"
    writeFile(pluginName / "LICENSE." & ext, "See https://tldrlegal.com/licenses/browse\n")
    writeFile(pluginName / "CODE_OF_CONDUCT." & ext, "")
    writeFile(pluginName / "CONTRIBUTING." & ext, "")
    writeFile(pluginName / "AUTHORS." & ext, "# Authors\n\n- " & user & "\n")
    writeFile(pluginName / "README." & ext, "# " & pluginName & "\n")
    writeFile(pluginName / "CHANGELOG." & ext, "# 0.0.1\n\n- First initial version of " & pluginName & "created at " & $now())
  quit("Created a new Python project skeleton, happy hacking, bye...\n", 0)

template enUsUtf8() =
  for envar in ["LC_CTYPE", "LC_NUMERIC", "LC_TIME", "LC_COLLATE", "LC_NAME", "LC_MONETARY", "LC_MESSAGES", "LC_PAPER",
    "LC_ADDRESS", "LC_TELEPHONE", "LANG", "LC_MEASUREMENT", "LC_IDENTIFICATION", "LC_ALL"]: putEnv(envar, "en_US.UTF-8")

proc backup(): tuple[output: TaintedString, exitCode: int] =
  var folder: string
  while not(folder.len > 0 and existsDir(folder)): folder = readLineFromStdin"Full path of 1 existing folder to Backup?: ".strip
  var files2backup: seq[string]
  for pythonfile in walkFiles(folder / "*.*"):
    files2backup.add pythonfile
    styledEcho(fgGreen, bgBlack, pythonfile)
  if likely(files2backup.len > 0):
    result = compress(Action.create, Algo.gzip, folder, files2backup.join" ", verbose = true)
    if result.exitCode == 0 and readLineFromStdin("SHA1 CheckSum Backup? (y/N): ").normalize == "y":
      writeFile(folder & ".tar.gz.sha1", $secureHashFile(folder & ".tar.gz"))

proc ask2User(): auto =
  var username, password, name, version, license, summary, description, homepage: string
  var author, downloadurl, authoremail, maintainer, maintaineremail, iPwd2: string
  var keywords: seq[string]
  while not(author.len > 2 and author.len < 99): author = readLineFromStdin("\nType Author (Real Name): ").strip
  while not(username.len > 2 and username.len < 99): username = readLineFromStdin("Type Username (PyPI Username): ").strip
  while not(maintainer.len > 2 and maintainer.len < 99): maintainer = readLineFromStdin("Type Package Maintainer (Real Name): ").strip
  while not(password.len > 4 and password.len < 999 and password == iPwd2):
    password = readLineFromStdin("Type Password: ").strip # Type it Twice.
    iPwd2 = readLineFromStdin("Confirm Password (Repeat it again): ").strip
  while not(authoremail.len > 5 and authoremail.len < 255 and "@" in authoremail): authoremail = readLineFromStdin("Type Author Email (Lowercase): ").strip.toLowerAscii
  while not(maintaineremail.len > 5 and maintaineremail.len < 255 and "@" in maintaineremail): maintaineremail = readLineFromStdin("Type Maintainer Email (Lowercase): ").strip.toLowerAscii
  while not(name.len > 0 and name.len < 99): name = readLineFromStdin("Type Package Name: ").strip.toLowerAscii
  while not(version.len > 4 and version.len < 99 and "." in version): version = readLineFromStdin("Type Package Version (SemVer): ").normalize
  info licenseHint
  while not(license.len > 2 and license.len < 99): license = readLineFromStdin("Type Package License: ").normalize
  while not(summary.len > 0 and summary.len < 999): summary = readLineFromStdin("Type Package Summary (Short Description): ").strip
  while not(description.len > 0 and description.len < 999): description = readLineFromStdin("Type Package Description (Long Description): ").strip
  while not(homepage.len > 5 and homepage.len < 999 and homepage.startsWith"http"): homepage = readLineFromStdin("Type Package Web Homepage URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(downloadurl.len > 5 and downloadurl.len < 999 and downloadurl.startsWith"http"): downloadurl = readLineFromStdin("Type Package Web Download URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(keywords.len > 1 and keywords.len < 99): keywords = readLineFromStdin("Type Package Keywords,separated by commas,without spaces,at least 2 (CSV): ").normalize.split(",")
  result = (username: username, password: password, name: name, author: author, version: version, license: license, summary: summary, homepage: homepage,
    description: description, downloadurl: downloadurl, maintainer: maintainer, authoremail: authoremail, maintaineremail: maintaineremail, keywords: keywords)

proc forceInstallPip(destination): tuple[output: TaintedString, exitCode: int] {.inline.} =
  newHttpClient(timeout = 9999).downloadFile(pipInstaller, destination) # Download
  assert existsFile(destination), "File not found: 'get-pip.py' " & destination
  result = execCmdEx(py3 & destination & " -I") # Installs PIP via get-pip.py

proc uninstall(this: PyPI, args) {.inline.} =
  # /usr/lib/python3.7/site-packages/PACKAGENAME-1.0.0.dist-info/RECORD is a CSV
  styledEcho(fgGreen, bgBlack, "Uninstall " & $args.len & " Packages:\t" & $args)
  let recordFiles = block:
    var output: seq[string]
    for argument in args: # RECORD Metadata file (CSV without file extension).
      for r in walkFiles(sitePackages / argument & "-*.dist-info" / "RECORD"): output.add r
    output
  assert recordFiles.len > 0, "RECORD Metadata CSV files not found."
  let files2delete = block:
    var output: seq[string]
    var size: int
    for record in recordFiles:
      for recordfile in parseRecord(record):
        output.add sitePackages / recordfile[0]
        if recordfile.len == 3 and recordfile[2].len > 0: size += parseInt(recordfile[2])
    styledEcho(fgGreen, bgBlack, "Total disk space freed:\t" &
      formatSize(size.int64, prefix = bpColloquial, includeSpace = true))
    output
  assert files2delete.len > 0, "Files of a Python Package not found."
  if readLineFromStdin("\nGenerate Uninstall Script? (y/N): ").normalize == "y":
    info((if readLineFromStdin("\nGenerate Uninstall Script for Admin/Root? (y/N): ").normalize == "y": "\nsudo " else: "\n") & "rm --verbose --force " & files2delete.join" " & "\n")
  for pyfile in files2delete: styledEcho(fgRed, bgBlack, pyfile)
  if readLineFromStdin("\nDelete " & $files2delete.len & " files? (y/N): ").normalize == "y":
    styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
    for pythonfile in files2delete: info $tryRemoveFile(pythonfile) & "\t" & pythonfile

proc backupOldLogs() {.noconv.} =
  if compress(Action.create, Algo.gzip, "logs-" & replace($now(), ":", "_") & ".tar.gz", logfile, verbose = true).exitCode == 0: discard tryRemoveFile(logfile)

template isSsd(): bool =
  when defined(linux): # Returns `true` if main disk is SSD (Solid). Linux only
    try: readFile("/sys/block/sda/queue/rotational") == "0\n" except: false

proc getSystemInfo(): JsonNode =
  result = %*{
    "compiled": CompileDate & "T" & CompileTime,
    "NimVersion": NimVersion,
    "hostCPU": hostCPU,
    "hostOS": hostOS,
    "cpuEndian": cpuEndian,
    "getTempDir": getTempDir(),
    "now": $now(),
    "getFreeMem": getFreeMem(),
    "getTotalMem": getTotalMem(),
    "getOccupiedMem": getOccupiedMem(),
    "countProcessors": countProcessors(),
    "arch": uname().machine,
    "FileSystemCaseSensitive": FileSystemCaseSensitive,
    "currentCompilerExe": getCurrentCompilerExe(),
    "nimpretty": execCmdEx("nimpretty --version").output.strip,
    "nimble": execCmdEx("nimble --noColor --version").output.strip,
    "nimgrep": execCmdEx("nimgrep --nocolor --version").output.strip,
    "nimsuggest": execCmdEx("nimsuggest --version").output.strip,
    "choosenim": if findExe"choosenim".len > 0: execCmdEx("choosenim --noColor --version").output.strip else: "",
    "gcc": if findExe"gcc".len > 0: execCmdEx("gcc --version").output.splitLines()[0].strip else: "",
    "clang": if findExe"clang".len > 0: execCmdEx("clang --version").output.splitLines()[0].strip else: "",
    "git": if findExe"git".len > 0: execCmdEx("git --version").output.replace("git version", "").strip else: "",
    "node": if findExe"node".len > 0: execCmdEx("node --version").output.strip else: "",
    "python": if findExe"python".len > 0: execCmdEx("python --version").output.replace("Python", "").strip else: "",
    "ssd": isSsd()
  }

proc doc2html(filename: string): string {.inline.} =
  result = rstToHtml(readFile(filename), {}, newStringTable(modeStyleInsensitive))
  writeFile(filename & ".html", result)

proc doc2latex(filename: string): string {.inline.} =
  var option: bool
  var rst2latex: RstGenerator
  rst2latex.initRstGenerator(outLatex, defaultConfig(), "", {})
  rst2latex.renderRstToOut(rstParse(readFile(filename), "", 1, 1, option, {}), result)
  writeFile(filename & ".tex", result)

proc doc2json(filename: string): string {.inline.} =
  var option: bool
  result = renderRstToJson(rstParse(readFile(filename), "", 1, 1, option, {}))
  writeFile(filename & ".json", result)


# ^ End of App related procedures #################### v CLI related procedures


when isMainModule:
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
        quit()
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
        info $tryRemoveFile("/tmp/pip-build-" & user) & "\t/tmp/pip-build-" & user
        info $tryRemoveFile("/tmp/pip_build_" & user) & "\t/tmp/pip_build_" & user
        info $tryRemoveFile(pipCacheDir) & "\t" & pipCacheDir
      of "backuplogs": addQuitProc(backupOldLogs)
      of "suicide": echo tryRemoveFile(currentSourcePath()[0..^5])
    of cmdArgument: args.add clave
    of cmdEnd: quit("Wrong Parameters, please see Help with: --help", 1)
  addHandler(newRollingFileLogger(filename = logfile, fmtStr = verboseFmtStr))
  let is1argOnly = args.len == 2 # command + arg == 2 ("install foo")
  if args.len > 0:
    case args[0].normalize
    of "init": pySkeleton()
    of "backup": quit(backup().output, 0)
    of "stats": quit($client.stats(), 0)
    of "newpackages": quit($client.newPackages(), 0)
    of "lastupdates": quit($client.lastUpdates(), 0)
    of "lastjobs": quit($client.lastJobs(), 0)
    of "userpackages": quit($client.userPackages(readLineFromStdin("PyPI Username?: ").normalize), 0)
    of "uninstall": client.uninstall(args[1..^1])
    of "install": client.install(args[1..^1])
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
      let packages = args[1..^1]
      client.uninstall(packages)
      client.install(packages)
    of "latestversion":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit($client.packageLatestRelease(args[1]), 0)
    of "open":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(execCmdEx(osOpen & args[1]).output, 0)
    of "strip":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(execCmdEx(cmdStrip & args[1]).output, 0)
    of "search":
      quit("Not implemented yet (PyPI API is Buggy)")
      # info args[1]
      # info client.search({"name": @[args[1]]}.toTable)
    of "hash":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      if findExe"sha256sum".len > 0:
        let sha256sum = execCmdEx(cmdChecksum & args[1]).output.strip
        info sha256sum
        info "--hash=sha256:" & sha256sum.split(" ")[^1]
    of "upload":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      doAssert existsFile(args[1]), "File not found: " & args[1]
      let (username, password, name, author, version, license, summary, homepage,
        description, downloadurl, maintainer, authoremail, maintaineremail, keywords
      ) = ask2User()
      info client.upload(
        username = username, password = password, name = name,
        version = version, license = license, summary = summary,
        description = description, author = author, downloadurl = downloadurl,
        authoremail = authoremail, maintainer = maintainer, keywords = keywords,
        maintaineremail = maintaineremail, homepage = homepage, filename = args[1],
        md5_digest = getMD5(readFile(args[1])))
  else: quit("Wrong Parameters, please see Help with: --help", 1)
