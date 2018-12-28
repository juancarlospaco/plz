## MultiSync API Client for PyPI.
## XML-RPC not supported: XML-RPC API is deprecated. Use is not recommended.
import asyncdispatch, httpclient, strutils, xmlparser, xmltree, json, mimetypes, ospaths

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
  ## Return an RSS XML with the Newest Packages uploaded to PyPI.
  clientify(this)
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiPackagesXml))
    else: parseXml(client.getContent(pypiPackagesXml))

proc lastUpdates*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML with the Latest Updates uploaded to PyPI.
  clientify(this)
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiUpdatesXml))
    else: parseXml(client.getContent(pypiUpdatesXml))

proc project*(this: PyPI | AsyncPyPI, project_name: string): Future[JsonNode] {.multisync.} =
  ## Return all JSON data for project_name from PyPI.
  clientify(this)
  let url = pypiApiUrl & "pypi/" & project_name & "/json"
  result =
    when this is AsyncPyPI: parseJson(await client.getContent(url=url))
    else: parseJson(client.getContent(url=url))

proc release*(this: PyPI | AsyncPyPI, project_name, project_version: string): Future[JsonNode] {.multisync.} =
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

proc htmlPackage*(this: PyPI | AsyncPyPI, project_name: string): Future[string] {.multisync.} =
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

# proc upload*(this: PyPI | AsyncPyPI,
#              name, version, license, summary, description, author, maintainer: string,
#              homepage, downloadurl, authoremail, maintaineremail, requirespython: string,
#              filename: string, keywords: seq[string]): Future[string] {.multisync.} =
#   ## Upload a new version of a registered package to PyPI.
#   # Auth: https://github.com/python/cpython/blob/master/Lib/distutils/command/upload.py#L131-L135 https://warehouse.readthedocs.io/api-reference/legacy/#upload-api
#   clientify(this)
#
#   var multipart_data = newMultipartData()
#   multipart_data["protocol_version"] = "1"
#   multipart_data[":action"] = "file_upload"
#   multipart_data["metadata_version"] = "2.1"
#   multipart_data["description_content_type"] = "text/markdown; charset=UTF-8; variant=GFM"
#   multipart_data["name"] = name
#   multipart_data["version"] = version
#   multipart_data["license"] = license
#   multipart_data["summary"] = summary
#   multipart_data["description"] = description
#   multipart_data["author"] = author
#   multipart_data["maintainer"] = maintainer
#   multipart_data["homepage"] = homepage
#   multipart_data["download_url"] = downloadurl
#   multipart_data["author_email"] = authoremail
#   multipart_data["maintainer_email"] = maintaineremail
#   multipart_data["requires_python"] = requirespython
#   multipart_data["keywords"] = keywords.join(" ")
#   multipart_data["content"] = (
#     filename, newMimetypes().getMimetype(filename.splitFile.ext), filename.readFile)
#   when not defined(release): echo multipart_data.repr
#
#   result =
#     when this is AsyncPyPI: await client.postContent(pypiUploadUrl, multipart=multipart_data)
#     else: client.postContent(pypiUploadUrl, multipart=multipart_data)


when isMainModule and not defined(release):
  let cliente = PyPI(timeout: 99)
  echo cliente.stats()
  echo cliente.newPackages()
  echo cliente.lastUpdates()
  echo cliente.htmlAllPackages()
  echo cliente.project(project_name="pip")
  echo cliente.htmlPackage(project_name="requests")
  echo cliente.release(project_name="microraptor", project_version="2.0.0")


  # echo cliente.upload(
  #   name            = "TestPackage",
  #   version         = "0.0.1",
  #   license         = "MIT",
  #   summary         = "A Test Package",
  #   description     = "This should upload to PyPI",
  #   author          = "Juan Carlos",
  #   maintainer      = "Juan Carlos",
  #   homepage        = "https://www.example.com",
  #   downloadurl     = "https://www.example.com/download",
  #   authoremail     = "author@example.com",
  #   maintaineremail = "maintainer@example.com",
  #   requirespython  = ">3.5",
  #   filename        = "pyvoicechanger-1.5.0.zip",
  #   keywords        = @["example", "keywords", "tags"],
  # )
