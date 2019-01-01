import
  asyncdispatch, httpclient, strutils, xmlparser, xmltree, json, mimetypes, os,
  ospaths, base64

const
  pypiApiUrl* = "https://pypi.org/"                      ## PyPI Base API URL.
  pypiPackagesXml* = "https://pypi.org/rss/packages.xml" ## PyPI XML API URL.
  pypiUpdatesXml* = "https://pypi.org/rss/updates.xml"   ## PyPI XML API URL.
  pypiUploadUrl* = "https://test.pypi.org/legacy/"       ## PyPI Upload POST URL

type
  PyPIBase*[HttpType] = object ## Base object.
    timeout*: byte  ## Timeout Seconds for API Calls, byte type, 0~255.
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
  PyPI* = PyPIBase[HttpClient]           ##  Sync PyPI API Client.
  AsyncPyPI* = PyPIBase[AsyncHttpClient] ## Async PyPI API Client.

using project_name, project_version: string

template clientify(this: PyPI | AsyncPyPI): untyped =
  ## Build & inject basic HTTP Client with Proxy and Timeout.
  var client {.inject.} =
    when this is AsyncPyPI: newAsyncHttpClient(
      proxy = when declared(this.proxy): this.proxy else: nil, userAgent="")
    else: newHttpClient(
      timeout = when declared(this.timeout): this.timeout.int * 1_000 else: -1,
      proxy = when declared(this.proxy): this.proxy else: nil, userAgent="")
  client.headers = newHttpHeaders({"dnt": "1", "accept": "application/json",
                                   "content-type": "application/json"})

proc newPackages*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML XmlNode type with the Newest Packages uploaded to PyPI.
  clientify(this)
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiPackagesXml))
    else: parseXml(client.getContent(pypiPackagesXml))

proc lastUpdates*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML XmlNode type with the Latest Updates uploaded to PyPI.
  clientify(this)
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiUpdatesXml))
    else: parseXml(client.getContent(pypiUpdatesXml))

proc project*(this: PyPI | AsyncPyPI, project_name): Future[JsonNode] {.multisync.} =
  ## Return all JSON JsonNode type data for project_name from PyPI.
  clientify(this)
  let url = pypiApiUrl & "pypi/" & project_name & "/json"
  result =
    when this is AsyncPyPI: parseJson(await client.getContent(url=url))
    else: parseJson(client.getContent(url=url))

proc release*(this: PyPI | AsyncPyPI, project_name, project_version): Future[JsonNode] {.multisync.} =
  ## Return all JSON data for project_name of an specific version from PyPI.
  clientify(this)
  let url = pypiApiUrl & "pypi/" & project_name & "/" & project_version & "/json"
  result =
    when this is AsyncPyPI: parseJson(await client.getContent(url=url))
    else: parseJson(client.getContent(url=url))

proc htmlAllPackages*(this: PyPI | AsyncPyPI): Future[string] {.multisync.} =
  ## Return all projects registered on PyPI as HTML string,Legacy Endpoint,Slow.
  clientify(this)
  result =
    when this is AsyncPyPI: await client.getContent(url=pypiApiUrl & "simple")
    else: client.getContent(url=pypiApiUrl & "simple")

proc htmlPackage*(this: PyPI | AsyncPyPI, project_name): Future[string] {.multisync.} =
  ## Return a project registered on PyPI as HTML string, Legacy Endpoint.
  clientify(this)
  result =
    when this is AsyncPyPI: await client.getContent(url=pypiApiUrl & "simple/" & project_name)
    else: client.getContent(url=pypiApiUrl & "simple/" & project_name)

proc stats*(this: PyPI | AsyncPyPI): Future[JsonNode] {.multisync.} =
  ## Return all JSON data for project_name of an specific version from PyPI.
  clientify(this)
  result =
    when this is AsyncPyPI: parseJson(await client.getContent(url=pypiApiUrl & "stats"))
    else: parseJson(client.getContent(url=pypiApiUrl & "stats"))

proc upload*(this: PyPI | AsyncPyPI,
             name, version, license, summary, description, author: string,
             downloadurl, authoremail, maintainer, maintaineremail: string,
             homepage, filename, md5_digest, username, password: string,
             keywords: seq[string],
             requirespython=">=3", filetype="sdist", pyversion="source",
             description_content_type="text/markdown; charset=UTF-8; variant=GFM",
             ): Future[string] {.multisync.} =
  ## Upload 1 new version of 1 registered package to PyPI from a local filename.
  ## PyPI Upload is HTTP POST with MultipartData with HTTP Basic Auth Base64.
  ## For some unknown reason intentionally undocumented (security by obscurity?)
  # https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
  # github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135
  var multipart_data = newMultipartData()
  multipart_data["protocol_version"] = "1"
  multipart_data[":action"] = "file_upload"
  multipart_data["metadata_version"] = "2.1"
  multipart_data["author"] = author
  multipart_data["name"] = name.normalize
  multipart_data["md5_digest"] = md5_digest # md5 hash of file in urlsafe base64
  multipart_data["summary"] = summary.normalize
  multipart_data["version"] = version.toLowerAscii
  multipart_data["license"] = license.toLowerAscii
  multipart_data["pyversion"] = pyversion.normalize
  multipart_data["requires_python"] = requirespython
  multipart_data["homepage"] = homepage.toLowerAscii
  multipart_data["filetype"] = filetype.toLowerAscii
  multipart_data["description"] = description.normalize
  multipart_data["keywords"] = keywords.join(" ").normalize
  multipart_data["download_url"] = downloadurl.toLowerAscii
  multipart_data["author_email"] = authoremail.toLowerAscii
  multipart_data["maintainer_email"] = maintaineremail.toLowerAscii
  multipart_data["description_content_type"] = description_content_type.strip
  multipart_data["maintainer"] = if maintainer == "": author else: maintainer

  doAssert filename.existsFile, "filename must be 1 existent valid readable file"
  let fext = filename.splitFile.ext.toLowerAscii
  # doAssert fext in ["whl", "egg", "zip"], "file extension must be 1 of .whl or .egg or .zip"
  let mime = newMimetypes().getMimetype(fext)
  multipart_data["content"] = (filename, mime, filename.readFile)
  when not defined(release): echo multipart_data.repr

  let auth = {"Authorization": "Basic " & encode(username & ":" & password)}
  when not defined(release): echo auth

  clientify(this)
  client.headers = newHttpHeaders(auth)
  # result =  # TODO: Finish this and test against the test dev pypi server.
  #   when this is AsyncPyPI: await client.postContent(pypiUploadUrl, multipart=multipart_data)
  #   else: client.postContent(pypiUploadUrl, multipart=multipart_data)
  result = "result"


when isMainModule and not defined(release):
  let cliente = PyPI(timeout: 99)
  echo cliente.stats()
  echo cliente.newPackages()
  echo cliente.lastUpdates()
  echo cliente.htmlAllPackages()
  echo cliente.project(project_name="pip")
  echo cliente.htmlPackage(project_name="requests")
  echo cliente.release(project_name="microraptor", project_version="2.0.0")

  echo cliente.upload(
    username        = "user",
    password        = "s3cr3t",
    name            = "TestPackage",
    version         = "0.0.1",
    license         = "MIT",
    summary         = "A test package for testing purposes",
    description     = "A test package for testing purposes",
    author          = "Juan Carlos",
    downloadurl     = "https://www.example.com/download",
    authoremail     = "author@example.com",
    maintainer      = "Juan Carlos",
    maintaineremail = "maintainer@example.com",
    homepage        = "https://www.example.com",
    filename        = "pypi.nim",
    md5_digest      = "4266642",
    keywords        = @["test", "testing"],
  )
