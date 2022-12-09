import std/[httpclient, strutils, xmlparser, xmltree, json, mimetypes, os, base64, times, osproc, rdstdin, md5, sha1]

import requirementstxt

include utils

type PyPI = HttpClient

let client: PyPI = newHttpClient(maxRedirects = maxRedirects, timeout = timeouts, headers = newHttpHeaders(hdrJson))


proc newPackages*(this: PyPI): XmlNode =
  ## Return an RSS XML XmlNode type with the Newest Packages uploaded to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiPackagesXml))


proc lastUpdates*(this: PyPI): XmlNode =
  ## Return an RSS XML XmlNode type with the Latest Updates uploaded to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiUpdatesXml))


proc lastJobs*(this: PyPI): XmlNode =
  ## Return an RSS XML XmlNode type with the Latest Jobs posted to PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(pypiJobUrl))


proc project*(this: PyPI, projectName: string): JsonNode =
  ## Return all JSON JsonNode type data for projectName from PyPI.
  doAssert projectName.len > 0, "projectName must not be empty string"
  this.headers = newHttpHeaders(hdrJson)
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/json"))


proc release*(this: PyPI, projectName: string, projectVersion: string): JsonNode =
  ## Return all JSON data for projectName of an specific version from PyPI.
  doAssert projectName.len > 0 and projectVersion.len > 0, "packageName and projectVersion must not be empty string"
  this.headers = newHttpHeaders(hdrJson)
  result = parseJson(this.getContent(pypiApiUrl & "pypi/" & projectName & "/" & projectVersion & "/json"))


proc htmlAllPackages*(this: PyPI): string =
  ## Return all projects registered on PyPI as HTML string,Legacy Endpoint,Slow.
  result = this.getContent(url = pypiApiUrl & "simple")


proc htmlPackage*(this: PyPI, projectName: string): string =
  ## Return a project registered on PyPI as HTML string, Legacy Endpoint, Slow.
  doAssert projectName.len > 0, "projectName must not be empty string"
  result = this.getContent(url = pypiApiUrl & "simple/" & projectName)


proc stats*(this: PyPI): XmlNode  =
  ## Return all JSON stats data for projectName of an specific version from PyPI.
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.getContent(url = pypiStatus))


proc listPackages*(this: PyPI): seq[string] =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI. Server-side Slow.
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = lppXml)).findAll"string":
    result.add t.innerText


proc changelogLastSerial*(this: PyPI): int =
  ## Return 1 XML XmlNode with the Last Serial number integer.
  this.headers = newHttpHeaders(hdrXml)
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = clsXml)).findAll"int":
    result = tagy.innerText.parseInt


proc listPackagesWithSerial*(this: PyPI): seq[array[2, string]] =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI with Serial number integer. Server-side Slow.
  this.headers = newHttpHeaders(hdrXml)
  for tagy in parseXml(this.postContent(pypiXmlUrl, body = lpsXml)).findAll"member":
    result.add [tagy.child"name".innerText, tagy.child"value".child"int".innerText]


proc packageLatestRelease*(this: PyPI, packageName: string): string =
  ## Return the latest release registered for the given packageName.
  doAssert packageName.len > 0, "packageName must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("package_releases", xmlRpcParam.format(packageName)))).findAll"string":
    result = t.innerText


proc packageRoles*(this: PyPI, packageName: string): seq[XmlNode] =
  ## Retrieve a list of role, user for a given packageName. Role is Maintainer or Owner.
  doAssert packageName.len > 0, "packageName must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("package_roles", xmlRpcParam.format(packageName)))).findAll"data":
    result.add t


proc userPackages*(this: PyPI, user: string): seq[XmlNode] =
  ## Retrieve a list of role, packageName for a given user. Role is Maintainer or Owner.
  doAssert user.len > 0, "user must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  for t in parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("user_packages", xmlRpcParam.format(user)))).findAll"data":
    result.add t


proc releaseUrls*(this: PyPI, packageName: string, releaseVersion: string): seq[string] =
  ## Retrieve a list of download URLs for the given releaseVersion. Returns a list of dicts.
  doAssert packageName.len > 0 and releaseVersion.len > 0, "packageName and releaseVersion must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  sleep 1_000  # HTTPTooManyRequests: The action could not be performed because there were too many requests by the client. Limit may reset in 1 seconds.
  let response = this.post(pypiXmlUrl, body = xmlRpcBody.format("release_urls", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion)))
  if response.code == Http200:
    for tagy in parseXml(response.body).findAll"string":
      if tagy.innerText.normalize.startsWith"https://":
        result.add tagy.innerText
  else:
    echo "PYPI Server Error: Slow response timed out or unknown connectivity error: ", response.code
  doAssert result.len > 0, "PYPI Server Error: Slow or wrong response received or unknown connectivity error: " & response.body


proc downloadPackage*(this: PyPI, packageName: string, releaseVersion: string, destDir = getTempDir(), generateScript: bool): string =
  ## Download a URL for the given releaseVersion. Returns filename.
  doAssert packageName.len > 0, "packageName must not be empty string"
  doAssert releaseVersion.len > 0, "releaseVersion must not be empty string"
  doAssert destDir.len > 0, "destDir must not be empty string"
  let choosenUrl = this.releaseUrls(packageName, releaseVersion)[0]
  doAssert choosenUrl.startsWith"https://", "PyPI Download URL is not HTTPS SSL"
  let filename = destDir / choosenUrl.split("/")[^1]
  echo choosenUrl, '\t', filename
  this.headers = newHttpHeaders(hdrJson)
  this.downloadFile(choosenUrl, filename)
  assert fileExists(filename), "Failed to download a file: " & filename
  echo '\t', $getFileSize(filename), " Bytes total (compressed)"
  if findExe"sha256sum".len > 0:
    echo '\t', execCmdEx(cmdChecksum & filename).output.strip
  try:
    echo '\t', choosenUrl, ".asc"
    this.downloadFile(choosenUrl & ".asc", filename & ".asc")
    if findExe"gpg".len > 0 and fileExists(filename & ".asc"):
      echo '\t', execCmdEx(cmdVerify & filename & ".asc").output.strip
  except:
    echo "\tHTTP-404? ", choosenUrl, ".asc (Package without PGP Signature)"
  if generateScript:
    echo "curl -LO ", choosenUrl
    echo "curl -LO ", choosenUrl, ".asc"
    echo cmdVerify, filename.replace(destDir, ""), ".asc"
    echo pipInstallCmd, filename.replace(destDir, "")
  result = filename


proc installPackage*(this: PyPI, packageName: string, releaseVersion: string, generateScript: bool): tuple[output: string, exitCode: int] =
  doAssert packageName.len > 0 and releaseVersion.len > 0, "packageName and releaseVersion must not be empty string"
  let packageFile = this.downloadPackage(packageName, releaseVersion, generateScript = generateScript)
  let oldDir = getCurrentDir()
  if packageFile.endsWith".whl":
    let sitePackages = resolveSitePackages(pythonexe)
    setCurrentDir(sitePackages)
    echo extract(packageFile, sitePackages).output
  else:
    let temp = getTempDir()
    setCurrentDir(temp)
    echo extract(packageFile, temp).output
    let path = packageFile.multiReplace([(".tar.gz", ""), (".zip", ""), (".egg", "")])
    if fileExists(path / "setup.py"):
      echo pythonexe, path / "setup.py"
      setCurrentDir(path)
      result = execCmdEx(pythonexe & ' ' & path / "setup.py install --user")
  setCurrentDir(oldDir)


proc install*(this: PyPI, args: seq[array[2, string]]) =
  doAssert args.len > 0, "Error parsing the list of packages"
  var suces, failed: int
  let time0 = now()
  echo now(), ", PID is ", getCurrentProcessId(), ", ", args.len, " packages to download and install ", args
  for argument in args:
    let semver =
      if argument[1].len == 0:
        $this.packageLatestRelease(argument[0])
      else:
        argument[1]
    echo '\t', argument[0], '\t', semver
    let resultados = this.installPackage(argument[0], semver, true)
    echo '\t', resultados.output
    if resultados.exitCode == 0:
      inc suces
    else:
      inc failed
  echo now(), ' ', failed, " Failed, ", suces, " Success on ", now() - time0, " to download+install ", args.len, " packages"


proc download*(this: PyPI, args: seq[string]) =
  ## Download a package to a local folder, dont decompress nor install.
  doAssert args.len > 0, "args must not be empty string"
  var dir: string
  while not dirExists(dir):
    dir = readLineFromStdin"Download to where? (Full path to existing folder): "
  for pkg in args:
    echo this.downloadPackage(pkg, $this.packageLatestRelease(pkg), dir, false)


proc releaseData*(this: PyPI, packageName: string, releaseVersion: string): XmlNode =
  ## Retrieve metadata describing a specific releaseVersion. Returns a dict.
  doAssert packageName.len > 0 and releaseVersion.len > 0, "packageName and releaseVersion must not be empty string"
  this.headers = newHttpHeaders(hdrXml)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("release_data", xmlRpcParam.format(packageName) & xmlRpcParam.format(releaseVersion))))


proc browse*(this: PyPI, classifiers: seq[string]): XmlNode =
  ## Retrieve a list of name, version of all releases classified with all of given classifiers.
  ## Classifiers must be a list of standard Trove classifier strings. Returns 100 results max.
  doAssert classifiers.len > 0, "classifiers must not be empty seq"
  this.headers = newHttpHeaders(hdrXml)
  var s: string
  for item in classifiers:
    s.add xmlRpcParam.format(item)
  result = parseXml(this.postContent(pypiXmlUrl, body = xmlRpcBody.format("browse", s)))


proc uninstall*(this: PyPI, args: seq[string]) =
  # /usr/lib/python3.7/site-packages/PACKAGENAME-1.0.0.dist-info/RECORD is a CSV
  doAssert args.len > 0, "args must not be empty string"
  echo "Uninstall ", args.len, " Packages:\t", args
  var recordFiles: seq[string]
  var files2delete: seq[string]

  var fixedPackageNames: seq[string]
  for a in args:
    var packageName = a
    if packageName notin fixedPackageNames:
      fixedPackageNames.add packageName
    packageName = replace(a, "-", "_")
    if packageName notin fixedPackageNames:
      fixedPackageNames.add packageName
    packageName = capitalizeAscii(a)
    if packageName notin fixedPackageNames:
      fixedPackageNames.add packageName

  let sitePackages = resolveSitePackages(pythonexe)
  echo sitePackages
  for packageName in fixedPackageNames: # RECORD Metadata file (CSV without file extension).
    for item in walkFiles(sitePackages / packageName & "*.dist-info" / "RECORD"):
      recordFiles.add item
    for item in walkFiles(sitePackages / packageName & "*.dist-info" / "INSTALLER"):
      files2delete.add item

  if recordFiles.len > 0:
    var size: int
    for record in recordFiles:
      for recordfile in parseRecord(record):
        files2delete.add sitePackages / recordfile[0]
        if recordfile.len == 3 and recordfile[2].len > 0:
          size += parseInt(recordfile[2])
    echo "Total disk space freed:\t", formatSize(size.int64, prefix = bpColloquial, includeSpace = true)
    if files2delete.len > 0:
      echo "\nrm --verbose --force ", files2delete.join" ", "\n\nDeleted?\tFile"
      for pythonfile in files2delete:
        echo $removeFileAndEmptyDirsUntilSitePackages(pythonfile) & '\t' & pythonfile
  # TODO: If fails, delete from list here  python -c "print(__import__('pip').__path__)" ?.
  # other alternative?  python -c "print(__import__('imp').find_module('pip'))"
  # Not even pip show knows which files belongs to which package, sometimes package wont have "installed-files.txt" ?.


template multiInstall*(this: PyPI; pkgs: seq[string]) =
  doAssert pkgs.len > 0, "Error parsing the list of packages from the command line arguments"
  var pkgseq: seq[array[2, string]]
  for item in requirements(pkgs.join("\n"), [("*", "0")]):
    pkgseq.add [item.name, item.version]
  doAssert pkgseq.len > 0, "Error parsing the requirements of packages from the command line arguments"
  this.install(pkgseq)


proc upload*(this: PyPI, name, version, license, summary, description, author, downloadurl, authoremail, maintainer, maintaineremail, homepage, filename,
  md5_digest, username, password: string, keywords: seq[string], requirespython = ">=3", filetype = "sdist", pyversion = "source",
  description_content_type = "text/markdown; charset=UTF-8; variant=GFM"): string =
  # https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
  # github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135

  doAssert name.len > 0 and version.len > 0 and  license.len > 0 and summary.len > 0 and  description.len > 0
  doAssert author.len > 0 and downloadurl.len > 0 and authoremail.len > 0 and maintainer.len > 0 and maintaineremail.len > 0
  doAssert homepage.len > 0 and filename.len > 0 and md5_digest.len > 0 and username.len > 0 and password.len > 0
  doAssert keywords.len > 0 and requirespython.len > 0 and filetype.len > 0 and pyversion.len > 0 and description_content_type.len > 0

  var multipartData = newMultipartData()
  multipartData["name"]                     = name
  multipartData["author"]                   = author
  multipartData[":action"]                  = "file_upload"
  multipartData["summary"]                  = summary
  multipartData["version"]                  = version.toLowerAscii
  multipartData["license"]                  = license.toLowerAscii
  multipartData["keywords"]                 = keywords.join(" ").normalize
  multipartData["homepage"]                 = homepage.toLowerAscii
  multipartData["filetype"]                 = filetype.toLowerAscii
  multipartData["pyversion"]                = pyversion.normalize
  multipartData["md5_digest"]               = md5_digest # md5 hash of file in urlsafe base64
  multipartData["maintainer"]               = if maintainer == "": author else: maintainer
  multipartData["description"]              = description
  multipartData["download_url"]             = downloadurl.toLowerAscii
  multipartData["author_email"]             = authoremail.toLowerAscii
  multipartData["requires_python"]          = requirespython
  multipartData["protocol_version"]         = "1"
  multipartData["metadata_version"]         = "2.1"
  multipartData["maintainer_email"]         = maintaineremail.toLowerAscii
  multipartData["description_content_type"] = description_content_type.strip
  multipartData["content"]                  = (
    filename, newMimetypes().getMimetype(filename.splitFile.ext.toLowerAscii), filename.readFile)
  this.headers = newHttpHeaders({"Authorization": "Basic " & encode(username & ':' & password), "dnt": "1"})

  echo "Uploading..."
  result = this.postContent(pypiUploadUrl, multipart = multipartData)
