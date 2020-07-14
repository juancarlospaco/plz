import
  httpclient, strutils, xmlparser, xmltree, json, mimetypes, os, base64,
  times, osproc, rdstdin, md5, std/sha1, requirementstxt, libarchibi

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
  assert packageName.len > 0, "packageName must not be empty string"
  assert releaseVersion.len > 0, "releaseVersion must not be empty string"
  assert destDir.len > 0, "destDir must not be empty string"
  choosenUrl := ""
  filename := ""
  choosenUrl[] = this.releaseUrls(packageName, releaseVersion)[0]
  assert choosenUrl[].startsWith"https://", "PyPI Download URL is not HTTPS SSL"
  filename[] = destDir / choosenUrl[].split("/")[^1]
  echo choosenUrl[]
  this.downloadFile(choosenUrl[], filename[])
  assert fileExists(filename[]), "file failed to download"
  echo "\t" & $getFileSize(filename[]) & " Bytes total (compressed)"
  if likely(findExe"sha256sum".len > 0): echo "\t" & execCmdEx(cmdChecksum & filename[]).output.strip
  try:
    echo "\t" & choosenUrl[] & ".asc"
    this.downloadFile(choosenUrl[] & ".asc", filename[] & ".asc")
    if unlikely(findExe"gpg".len > 0 and fileExists(filename[] & ".asc")):
      echo "\t" & execCmdEx(cmdVerify & filename[] & ".asc").output.strip
  except:
    echo "\tHTTP-404? " & choosenUrl[] & ".asc (Package without PGP Signature)"
  if likely(generateScript):
    echo("curl -LO " & choosenUrl[] & "\ncurl -LO " & choosenUrl[] & ".asc\n" & cmdVerify &
      filename[].replace(destDir, "") & ".asc\n" & pipInstallCmd & filename[].replace(destDir, ""))
  result = filename[]
  deallocs choosenUrl, filename

proc installPackage(this: PyPI, packageName: string, releaseVersion: string, generateScript: bool): tuple[output: TaintedString, exitCode: int] =
  assert packageName.len > 0 and releaseVersion.len > 0, "packageName and releaseVersion must not be empty string"
  creates "", packageFile, oldDir, path
  packageFile[] = this.downloadPackage(packageName, releaseVersion, generateScript = generateScript)
  oldDir[] = getCurrentDir()
  if unlikely(packageFile[].endsWith".whl"):
    setCurrentDir(sitePackages)
    echo extract(packageFile[], sitePackages).output
  else:
    setCurrentDir(getTempDir())
    echo extract(packageFile[], getTempDir()).output
    path[] = packageFile[][0..^5]
    if fileExists(path[] / "setup.py"):
      setCurrentDir(path[])
      result = execCmdEx(findExe"python3" & " " & path[] / "setup.py install --user")
  setCurrentDir(oldDir[])
  deallocs packageFile, oldDir, path

proc install(this: PyPI, args: seq[array[2, string]]) =
  assert args.len > 0, "Error parsing the list of packages"
  suces := 0.byte
  failed := 0.byte
  semver := ""
  let time0 = create(DateTime, sizeOf DateTime)
  time0[] = now()
  echo($now() & ", PID is " & $getCurrentProcessId() & ", " & $args.len & " packages to download and install " & $args)
  for argument in args:
    semver[] = if argument[1].len == 0: $this.packageLatestRelease(argument[0]) else: argument[1]
    echo "\t" & argument[0] & "\t" & semver[]
    let resultados = this.installPackage(argument[0], semver[], true)
    echo "\t" & resultados.output
    if resultados.exitCode == 0: inc suces[] else: inc failed[]
  echo($now() & " " & $failed[] & " Failed, " & $suces[] &
    " Success on " & $(now() - time0[]) & " to download+install " & $args.len & " packages")
  deallocs semver, time0, suces, failed

proc download(this: PyPI, args: seq[string]) =
  ## Download a package to a local folder, dont decompress nor install.
  assert args.len > 0
  dir := ""
  while not dirExists(dir[]): dir[] = readLineFromStdin"Download to where? (Full path to existing folder): "
  for pkg in args: echo this.downloadPackage(pkg, $this.packageLatestRelease(pkg), dir[], false)
  dealloc dir

proc releaseData(this: PyPI, packageName: string, releaseVersion: string): XmlNode =
  ## Retrieve metadata describing a specific releaseVersion. Returns a dict.
  assert packageName.len > 0, "packageName must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("release_data", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion))))

proc browse(this: PyPI, classifiers: seq[string]): XmlNode =
  ## Retrieve a list of name, version of all releases classified with all of given classifiers.
  ## Classifiers must be a list of standard Trove classifier strings. Returns 100 results max.
  assert classifiers.len > 0, "classifiers must not be empty seq"
  this.headers = newHttpHeaders(hdrXml)
  s := ""
  for item in classifiers: s[].add xmlRpcParam.format(item)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("browse", s[])))
  dealloc s

proc uninstall(this: PyPI, args: seq[string]) =
  # /usr/lib/python3.7/site-packages/PACKAGENAME-1.0.0.dist-info/RECORD is a CSV
  assert args.len > 0
  echo("Uninstall " & $args.len & " Packages:\t" & $args)
  let recordFiles = create(seq[string], sizeOf seq[string])
  for a in args: # RECORD Metadata file (CSV without file extension).
    for r in walkFiles(sitePackages / a & "*.dist-info" / "RECORD"): recordFiles[].add r
  if recordFiles[].len > 0:
    let size = create(int, sizeOf int)
    let files2delete = create(seq[string], sizeOf seq[string])
    for record in recordFiles[]:
      for recordfile in parseRecord(record):
        files2delete[].add sitePackages / recordfile[0]
        if recordfile.len == 3 and recordfile[2].len > 0: size[] += parseInt(recordfile[2])
    echo("Total disk space freed:\t" & formatSize(size[].int64, prefix = bpColloquial, includeSpace = true))
    dealloc size
    if files2delete[].len > 0:
      echo "\nrm --verbose --force " & files2delete[].join" " & "\n\nDeleted?\tFile"
      for pythonfile in files2delete[]: echo $tryRemoveFile(pythonfile) & "\t" & pythonfile
    dealloc files2delete
  # TODO: If fails, delete from list here  python -c "print(__import__('pip').__path__)" ?.
  # other alternative?  python -c "print(__import__('imp').find_module('pip'))"
  # Not even pip show knows which files belongs to which package, sometimes package wont have "installed-files.txt" ?.
  dealloc recordFiles

template multiInstall(this: PyPI; pkgs: seq[string]) =
  assert pkgs.len > 0, "Error parsing the list of packages from the command line arguments"
  let pkgseq = create(seq[array[2, string]], sizeOf seq[array[2, string]])
  for item in requirements(pkgs.join("\n"), [("*", "0")]): pkgseq[].add [item.name, item.version]
  assert pkgseq[].len > 0, "Error parsing the requirements of packages from the command line arguments"
  this.install(pkgseq[])
  dealloc pkgseq

proc upload(this: PyPI, name, version, license, summary, description, author, downloadurl, authoremail, maintainer, maintaineremail, homepage, filename,
  md5_digest, username, password: string, keywords: seq[string], requirespython = ">=3", filetype = "sdist", pyversion = "source",
  description_content_type = "text/markdown; charset=UTF-8; variant=GFM"): string =
  # https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
  # github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135
  assert name.len > 0 and version.len > 0 and  license.len > 0 and summary.len > 0 and  description.len > 0
  assert author.len > 0 and downloadurl.len > 0 and authoremail.len > 0 and maintainer.len > 0 and maintaineremail.len > 0
  assert homepage.len > 0 and filename.len > 0 and md5_digest.len > 0 and username.len > 0 and password.len > 0
  assert keywords.len > 0 and requirespython.len > 0 and filetype.len > 0 and pyversion.len > 0 and description_content_type.len > 0
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
