import
  httpclient, strutils, xmlparser, xmltree, json, mimetypes, os, base64, terminal,
  times, logging, osproc, rdstdin, md5, std/sha1, requirementstxt, libarchibi

type PyPI = HttpClient
let client: PyPI = newHttpClient(maxRedirects = maxRedirects, timeout = timeouts, headers = newHttpHeaders(hdrJson))

proc newPackages(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Newest Packages uploaded to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiPackagesXml))

proc lastUpdates(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Latest Updates uploaded to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiUpdatesXml))

proc lastJobs(this: PyPI): XmlNode {.inline.} =
  ## Return an RSS XML XmlNode type with the Latest Jobs posted to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiJobUrl))

proc project(this: PyPI, projectName: string): JsonNode {.inline.} =
  ## Return all JSON JsonNode type data for projectName from PyPI.
  this.headers = newHttpHeaders(hdrJson)
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/json"))

proc release(this: PyPI, projectName: string, projectVersion: string): JsonNode {.inline.} =
  ## Return all JSON data for projectName of an specific version from PyPI.
  this.headers = newHttpHeaders(hdrJson)
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/" & projectVersion & "/json"))

proc htmlAllPackages(this: PyPI): string {.inline.} =
  ## Return all projects registered on PyPI as HTML string,Legacy Endpoint,Slow.
  result = this.getContent(url = pypiApiUrl & "simple")

proc htmlPackage(this: PyPI, projectName: string): string {.inline.} =
  ## Return a project registered on PyPI as HTML string, Legacy Endpoint, Slow.
  result = this.getContent(url = pypiApiUrl & "simple/" & projectName)

proc stats(this: PyPI): XmlNode {.inline.} =
  ## Return all JSON stats data for projectName of an specific version from PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(url = pypiStatus))

proc listPackages(this: PyPI): seq[string] {.inline.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI. Server-side Slow.
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = lppXml)).findAll"string": result.add t.innerText

proc changelogLastSerial(this: PyPI): int {.inline.} =
  ## Return 1 XML XmlNode with the Last Serial number integer.
  this.headers = newHttpHeaders(hdrXml)
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = clsXml)).findAll"int": result = tagy.innerText.parseInt

proc listPackagesWithSerial(this: PyPI): seq[array[2, string]] {.inline.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI with Serial number integer. Server-side Slow.
  this.headers = newHttpHeaders(hdrXml)
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = lpsXml)).findAll"member":
    result.add [tagy.child"name".innerText, tagy.child"value".child"int".innerText]

proc packageLatestRelease(this: PyPI, packageName: string): string {.inline.} =
  ## Return the latest release registered for the given packageName.
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("package_releases", xmlRpcParam.format(packageName)))).findAll"string": result = t.innerText

proc packageRoles(this: PyPI, packageName: string): seq[XmlNode] {.inline.} =
  ## Retrieve a list of role, user for a given packageName. Role is Maintainer or Owner.
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("package_roles", xmlRpcParam.format(packageName)))).findAll"data": result.add t

proc userPackages(this: PyPI, user: string): seq[XmlNode] =
  ## Retrieve a list of role, packageName for a given user. Role is Maintainer or Owner.
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("user_packages", xmlRpcParam.format(user)))).findAll"data": result.add t

proc releaseUrls(this: PyPI, packageName: string, releaseVersion: string): seq[string] =
  ## Retrieve a list of download URLs for the given releaseVersion. Returns a list of dicts.
  this.headers = newHttpHeaders(hdrXml)
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("release_urls", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion)))).findAll"string":
    if tagy.innerText.normalize.startsWith"https://": result.add tagy.innerText

proc downloadPackage(this: PyPI, packageName: string, releaseVersion: string, destDir = getTempDir(), generateScript: bool): string =
  ## Download a URL for the given releaseVersion. Returns filename.
  var script: string
  let choosenUrl = this.releaseUrls(packageName, releaseVersion)[0]
  assert choosenUrl.startsWith"https://", "PyPI Download URL is not HTTPS SSL"
  let filename = destDir / choosenUrl.split("/")[^1]
  info "\t" & choosenUrl
  if generateScript: script &= "curl -LO " & choosenUrl & "\n"
  this.downloadFile(choosenUrl, filename)
  assert fileExists(filename), "file failed to download"
  info "\t" & $getFileSize(filename) & " Bytes total (compressed)"
  if likely(findExe"sha256sum".len > 0): info "\t" & execCmdEx(cmdChecksum & filename).output.strip
  try:
    info "\t" & choosenUrl & ".asc"
    this.downloadFile(choosenUrl & ".asc", filename & ".asc")
    if generateScript: script &= "curl -LO " & choosenUrl & ".asc" & "\n"
    if unlikely(findExe"gpg".len > 0 and fileExists(filename & ".asc")):
      info "\t" & execCmdEx(cmdVerify & filename & ".asc").output.strip
      if generateScript: script &= cmdVerify & filename.replace(destDir, "") & ".asc\n"
  except:
    warn "\tHTTP-404? " & choosenUrl & ".asc (Package without PGP Signature)"
  if generateScript: script &= pipInstallCmd & filename.replace(destDir, "") & "\n"
  result = filename

proc installPackage(this: PyPI, packageName: string, releaseVersion: string, generateScript: bool): tuple[output: TaintedString, exitCode: int] =
  let packageFile = this.downloadPackage(packageName, releaseVersion, generateScript = generateScript)
  let oldDir = getCurrentDir()
  if unlikely(packageFile.endsWith".whl"):
    setCurrentDir(sitePackages)
    echo extract(packageFile, sitePackages).output
  else:
    setCurrentDir(getTempDir())
    echo extract(packageFile, getTempDir()).output
    let path = packageFile[0..^5]
    if fileExists(path / "setup.py"):
      setCurrentDir(path)
      result = execCmdEx(findExe"python3" & " " & path / "setup.py install --user")
  setCurrentDir(oldDir)

proc install(this: PyPI, args: seq[string]) =
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
  info($now() & " " & $failed & " Failed, " & $suces &
    " Success on " & $(now() - time0) & " to download+install " & $args.len & " packages")

proc download(this: PyPI, args: seq[string]) =
  ## Download a package to a local folder, dont decompress nor install.
  var dir: string
  while not dirExists(dir): dir = readLineFromStdin"Download to where? (Full path to existing folder): "
  for pkg in args: echo this.downloadPackage(pkg, $this.packageLatestRelease(pkg), dir, false)

proc releaseData(this: PyPI, packageName: string, releaseVersion: string): XmlNode {.inline.} =
  ## Retrieve metadata describing a specific releaseVersion. Returns a dict.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("release_data", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion))))

proc browse(this: PyPI, classifiers: seq[string]): XmlNode {.inline.} =
  ## Retrieve a list of name, version of all releases classified with all of given classifiers.
  ## Classifiers must be a list of standard Trove classifier strings. Returns 100 results max.
  this.headers = newHttpHeaders(hdrXml)
  var s: string
  for item in classifiers: s &= xmlRpcParam.format(item)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("browse", s)))

proc uninstall(this: PyPI, args: seq[string]) {.inline.} =
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

proc upload(this: PyPI, name, version, license, summary, description, author, downloadurl, authoremail, maintainer, maintaineremail, homepage, filename,
  md5_digest, username, password: string, keywords: seq[string], requirespython = ">=3", filetype = "sdist", pyversion = "source",
  description_content_type = "text/markdown; charset=UTF-8; variant=GFM"): string =
  # https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
  # github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135
  assert filename.splitFile.ext.toLowerAscii in ["whl", "egg", "zip"], "File extension must be 1 of whl or egg or zip"
  var multipartData = create(MultipartData, sizeOf MultipartData)
  multipartData[] = newMultipartData()
  multipartData[]["protocol_version"] = "1"
  multipartData[][":action"] = "file_upload"
  multipartData[]["metadata_version"] = "2.1"
  multipartData[]["author"] = author
  multipartData[]["name"] = name
  multipartData[]["md5_digest"] = md5_digest # md5 hash of file in urlsafe base64
  multipartData[]["summary"] = summary
  multipartData[]["version"] = version.toLowerAscii
  multipartData[]["license"] = license.toLowerAscii
  multipartData[]["pyversion"] = pyversion.normalize
  multipartData[]["requires_python"] = requirespython
  multipartData[]["homepage"] = homepage.toLowerAscii
  multipartData[]["filetype"] = filetype.toLowerAscii
  multipartData[]["description"] = description
  multipartData[]["keywords"] = keywords.join(" ").normalize
  multipartData[]["download_url"] = downloadurl.toLowerAscii
  multipartData[]["author_email"] = authoremail.toLowerAscii
  multipartData[]["maintainer_email"] = maintaineremail.toLowerAscii
  multipartData[]["description_content_type"] = description_content_type.strip
  multipartData[]["maintainer"] = if maintainer == "": author else: maintainer
  multipartData[]["content"] = (filename, newMimetypes().getMimetype(filename.splitFile.ext.toLowerAscii), filename.readFile)
  this.headers = newHttpHeaders({"Authorization": "Basic " & encode(username & ":" & password), "dnt": "1"})
  echo "Uploading..."
  result = this.postContent(pypiUploadUrl, multipart = multipartData[])
  dealloc multipartData
