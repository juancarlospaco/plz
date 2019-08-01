import
  asyncdispatch, httpclient, strutils, xmlparser, xmltree, json, mimetypes, os,
  base64, tables, parseopt, terminal, random, times, posix, logging, osproc,
  rdstdin, sequtils, md5, contra
hardenedBuild()
# For compile time code executions, we dont care the optimization or how clunky
# it looks because is done compile time only,worse case scenario it wont compile
const
  pypiApiUrl* = "https://pypi.org/"                             ## PyPI Base API URL.
  pypiXmlUrl = pypiApiUrl & "pypi"                              ## PyPI XML RPC API URL.
  pypiPackagesXml = "https://pypi.org/rss/packages.xml"         ## PyPI XML API URL.
  pypiUpdatesXml = "https://pypi.org/rss/updates.xml"           ## PyPI XML API URL.
  pypiUploadUrl = "https://test.pypi.org/legacy/"               ## PyPI Upload POST URL
  pypiJobUrl = "https://www.python.org/jobs/feed/rss/"          ## Python Jobs URL
  pypiStatus = "https://status.python.org/history.rss"          ## PyPI Status XML API URL.
  pipInstaller = "https://bootstrap.pypa.io/get-pip.py"         ## get-pip URL
  lppXml = "<methodName>list_packages</methodName>"             ## XML RPC Command.
  clsXml = "<methodName>changelog_last_serial</methodName>"     ## XML RPC Command.
  lpsXml = "<methodName>list_packages_with_serial</methodName>" ## XML RPC Command.
  xmlRpcParam = "<param><value><string>$1</string></value></param>"
  xmlRpcBody = "<?xml version='1.0'?><methodCall><methodName>$1</methodName><params>$2</params></methodCall>"
  hdrJson = {"dnt": "1", "accept": "application/json", "content-type": "application/json"}
  hdrXml  = {"dnt": "1", "accept": "text/xml", "content-type": "text/xml"}
  commitHash = staticExec"git rev-parse --short HEAD"
  version = "0.1.0\n" & commitHash
  sitePackages = staticExec"""python3 -c "print(__import__('site').getsitepackages()[0])" """ ## https://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory#12950101
  pipCacheDir =
    when defined(linux):   r"~/.cache/pip"  # PIP "standards"
    elif defined(macos):   r"~/Library/Caches/pip"
    elif defined(windows): r"%LocalAppData%\pip\Cache"
    else:                  getEnv("PIP_DOWNLOAD_CACHE")
  xdgOpen =
    when defined(macos):   "open "
    elif defined(windows): "start "
    else:                  "xdg-open "
  pyExtPattern =
    when defined(windows): ".cpython-*.dll"
    elif defined(macos):   ".cpython-*.dynlib"
    else:                  ".cpython-*.so"
  virtualenvDir = r"~/.virtualenvs"
  pipCommons = "--isolated --disable-pip-version-check --no-color --no-cache-dir --quiet "
  pipInstallCmd = "pip3 install --upgrade --no-index --no-warn-script-location --user --no-dependencies " & pipCommons
  cmdChecksum = "sha256sum --tag "  # I prefer SHA512,but PyPI uses SHA256 only?
  cmdSign = "gpg --armor --detach-sign --yes --digest-algo sha512 "
  cmdTar = "tar cafv "
  cmdVerify = "gpg --verify "
  cmdStrip = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag "  ## PIP Wont optimize Production binaries, they are left with all Debugging on!.

const helpy = """ 👑 PIP Fast Single-File Hardened Compiled Alternative 👑
Commands:
  install          Install packages (Download, Decompress, Install packages).
  uninstall        Uninstall packages (Interactive, asks Y/N to user before).
  upload           Mimics "twine upload" (Interactive,asks user,wont need Twine)
  search           Search PyPI for packages (PyPI API is Buggy, is still WIP).
  hash             Compute hashes of package archives (SHA256 Checksum file).
  init             New Python project template (Interactive, asks Y/N to user).
  backup           Compressed signed backup of a file and quit (GPG + SHA512).
  strip            Optimize size of Python native binary module (PIP wont strip)
  newpackages      List all the new Packages uploaded to PyPI recently (RSS).
  lastupdates      List all existing Packages updated on PyPI recently (RSS).
  lastjobs         List all new Job Posts updated on Python recently (RSS).
  stats            PyPI service status report from official statuspage (RSS).
  userpackages     List all existing Packages by User (Interactive, asks user).
  latestversion    Show the Latest Version release of a PYPI Package (SemVer).
  open             Open a given module in your default editor (xdg-open).
  forceInstallPip  Force install PIP on a given location directory (get-pip.py).
  cleanvirtualenv  Delete local Virtualenv (Interactive,asks Y/N to user before)

Options:
  --help           Show Help and quit.
  --version        Show Version and quit.
  --license        Show License and quit.
  --debug          Show Debug info and quit (for Developers).
  --timeout=42     Set Timeout.
  --putenv:key=val Set an environment variable "KEY=Value", can be repeated.
  --nopyc          Recursively remove all *.pyc
  --nopycache      Recursively remove all __pycache__
  --cleantemp      Remove all files and folders from the OS Temporary folder.
  --cleanpipcache  Remove all files and folders from the PIP Cache folder.
  --nice20         Runs with "nice = 20" (CPU Priority, smooth priority).
  --completion:zsh Show Auto-Completion for Bash/ZSH/Fish terminal and quit.
  --publicip       Show your Public IP Address (Internet connectivity check).
  --suicide        Deletes itself permanently and exit (single file binary).

Other environment variables (literally copied from python3 executable itself):
  --pythonstartup:f.py Python file executed at startup (not directly executed).
  --pythonpath:FOO     ADD ':'-separated list of directories to the PYTHONPATH
  --pythonhome:FOO     Alternate Python directory.
  --ioencodingutf8     Set Encoding to UTF-8 to Python stdin/stdout/stderr.
  --hashseed:42        Random Seed, integer in the range [0, 4294967295].
  --malloc             Set Python memory allocators to Debug.
  --localewarn         Set the locale coerce to Warning.
  --debugger:FOO       Set the Python debugger. You can use ipdb, ptpdb, etc.

Compile options (Optimize/Enable/Disable features when compiling source code):
  Fastest              -d:release -d:danger --gc:markAndSweep
  Safest               -d:release -d:contracts -d:hardened --styleCheck:hint

✅ This wont save any passwords, databases, keys, secrets to disk nor Internet.
 👑 http://nim-lang.org/learn.html 🐍 http://github.com/juancarlospaco ⚡ """

const setupCfg = """# See: https://setuptools.readthedocs.io/en/latest/setuptools.html#metadata
[metadata]
name             = example
provides         = example
description      = example package
url              = https://github.com/example/example
download_url     = https://github.com/example/example
author           = Deborah Melltrozzo
author_email     = example@example.com
maintainer       = Deborah Melltrozzo
maintainer_email = example@example.com
keywords         = python, exampletag, sometag
license          = MIT
platforms        = Linux, Darwin, Windows
version          = attr: somepythonmodule.__version__
project_urls     =
    Docs = https://github.com/example/example/README.md
    Bugs = https://github.com/example/example/issues
    C.I. = https://travis-ci.org/example/example

license_file = LICENSE
long_description = file: README.md
long_description_content_type = text/markdown
classifiers =  # https://pypi.python.org/pypi?%3Aaction=list_classifiers
    Development Status :: 5 - Production/Stable
    Environment :: Console
    Environment :: Other Environment
    Intended Audience :: Developers
    Intended Audience :: Other Audience
    Natural Language :: English
    Operating System :: OS Independent
    Operating System :: POSIX :: Linux
    Operating System :: Microsoft :: Windows
    Operating System :: MacOS :: MacOS X
    Programming Language :: Python
    Programming Language :: Python :: 3
    Programming Language :: Python :: Implementation :: CPython
    Topic :: Software Development

[options]
zip_safe = True
include_package_data = True
python_requires  = >=3.7
tests_require    = prospector ; pre-commit ; twine
install_requires = pip
setup_requires   = pip
packages         = find:

[bdist_wheel]
universal = 1

[bdist_egg]
exclude-source-files = true

# [options.package_data]
# * = *.pxd, *.pyx, *.json, *.txt

# [options.exclude_package_data]
# ;* = *.c, *.so, *.js

# [options.entry_points]
# console_scripts =
#     foo = my_package.some_module:main_func
#     bar = other_module:some_func
# gui_scripts =
#     baz = my_package_gui:start_func

# [options.packages.find]
# where   = .
# include = *.py, *.pyw
# exclude = *.c, *.so, *.js, *.tests, *.tests.*, tests.*, tests """

const testTemplate = """# -*- coding: utf-8 -*-
'''Unittest.'''
import unittest
from random import randint
# Random order for tests runs. (Original is: -1 if x<y, 0 if x==y, 1 if x>y).
unittest.TestLoader.sortTestMethodsUsing = lambda _, x, y: randint(-1, 1)

def setUpModule():
    pass

def tearDownModule():
    pass

class TestName(unittest.TestCase):
    maxDiff, __slots__ = None, ()

    def setUp(self):
        pass  # Method to prepare the test fixture. Run BEFORE the test methods

    def tearDown(self):
        pass  # Method to tear down the test fixture. Run AFTER the test methods

    def addCleanup(self, function, *args, **kwargs):
        pass  # Function called AFTER tearDown() to clean resources used on test

    @classmethod
    def setUpClass(cls):
        pass  # Probably you may not use this one. See setUp().

    @classmethod
    def tearDownClass(cls):
        pass  # Probably you may not use this one. See tearDown().

    @unittest.skip("Demonstrating skipping")  # Skips this test only
    @unittest.skipIf("boolean_condition", "Reason to Skip Test here.")  # Skips
    @unittest.expectedFailure  # This test MUST fail. If test fails, then is Ok
    def test_dummy(self):
        self.skipTest("Just examples, use as template!.")  # Skips this test
        self.assertEqual(a, b)  # a == b
        self.assertTrue(x)  # bool(x) is True
        self.assertIs(a, b)  # a is b
        self.assertIsNotNone(x)  # x is not None
        self.assertIn(a, b)  # a in b
        self.assertIsInstance(a, b)  # isinstance(a, b)
        self.assertRaises(SomeException, callable, *args, **kwds)  # Must raise
        with self.assertRaises(SomeException) as cm:
            do_something_that_raises() # This line  Must raise SomeException

if __name__ in "__main__":
    unittest.main() """

const dockerfileTemplate = """FROM alpine:latest
RUN apk add --no-cache ca-certificates gnupg tar xz bzip2 coreutils dpkg findutils gcc libc-dev linux-headers make openssl readline sqlite zlib tk tcl ncurses gdbm
ENV LANG C.UTF-8
ENV PYTHON_VERSION 3.7
ENV PYTHON_PIP_VERSION 3.7
ENV PATH /usr/local/bin:$PATH
# Do your magic here. Download and Compile Python... """

const completionBash = """_pip_completion() { COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" COMP_CWORD=$COMP_CWORD PIP_AUTO_COMPLETE=1 $1 ) ) }
complete -o default -F _pip_completion pip """

const completionZsh = """function _pip_completion {
  local words cword
  read -Ac words
  read -cn cword
  reply=( $( COMP_WORDS="$words[*]" COMP_CWORD=$(( cword-1 )) PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip """

const completionFish = """function __fish_complete_pip
  set -lx COMP_WORDS (commandline -o) ""
  set -lx COMP_CWORD ( math (contains -i -- (commandline -t) $COMP_WORDS)-1 )
  set -lx PIP_AUTO_COMPLETE 1
  string split \  -- (eval $COMP_WORDS[1])
end
complete -fa "(__fish_complete_pip)" -c pip """

const licenseHint = """Licenses:
💡 See https://tldrlegal.com/licenses/browse or https://choosealicense.com
💡 No License = Proprietary,WTFPL/Unlicense = Proprietary, Dont invent your own
MIT   ➡️Simple and permissive,short,KISS,maybe can be an Ok default
PPL   ➡️Simple and permisive,wont allow corporations to steal/sell your code
GPL   ➡️Ensures that code based on this is shared with the same terms,strict
LGPL  ➡️Ensures that code based on this is shared with the same terms,no strict
Apache➡️Simple and explicitly grants Patents
BSD   ➡️Simple and permissive,but your code can be closed/sold by 3rd party
"""

let
  py2 = findExe"python2"
  py3 = findExe"python3"
  cython = findExe"cython"
  nuitka = findExe"nuitka"
  headerJson = newHttpHeaders(hdrJson)
  headerXml =  newHttpHeaders(hdrXml)
  user = getEnv"USER"

var script: string
setControlCHook((proc {.noconv.} = quit" CTRL+C Pressed,shutting down,Bye! "))

type
  PyPIBase*[HttpType] = object ## Base object.
    timeout*: byte  ## Timeout Seconds for API Calls, byte type, 0~255.
    proxy*: Proxy  ## Network IPv4 / IPv6 Proxy support, Proxy type.
  PyPI* = PyPIBase[HttpClient]           ##  Sync PyPI API Client.
  AsyncPyPI* = PyPIBase[AsyncHttpClient] ## Async PyPI API Client.

using
  generateScript: bool
  classifiers: seq[string]
  project_name, project_version, package_name, user, release_version, destDir: string

template clientify(this: PyPI | AsyncPyPI): untyped =
  ## Build & inject basic HTTP Client with Proxy and Timeout.
  var client {.inject.} =
    when this is AsyncPyPI: newAsyncHttpClient(
      proxy = when declared(this.proxy): this.proxy else: nil, userAgent="")
    else: newHttpClient(
      timeout = when declared(this.timeout): this.timeout.int * 1_000 else: -1,
      proxy = when declared(this.proxy): this.proxy else: nil, userAgent="")

proc newPackages*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML XmlNode type with the Newest Packages uploaded to PyPI.
  clientify(this)
  client.headers = headerXml
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiPackagesXml))
    else: parseXml(client.getContent(pypiPackagesXml))

proc lastUpdates*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML XmlNode type with the Latest Updates uploaded to PyPI.
  clientify(this)
  client.headers = headerXml
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiUpdatesXml))
    else: parseXml(client.getContent(pypiUpdatesXml))

proc lastJobs*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return an RSS XML XmlNode type with the Latest Jobs posted to PyPI.
  clientify(this)
  client.headers = headerXml
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(pypiJobUrl))
    else: parseXml(client.getContent(pypiJobUrl))

proc project*(this: PyPI | AsyncPyPI, project_name): Future[JsonNode] {.multisync.} =
  ## Return all JSON JsonNode type data for project_name from PyPI.
  clientify(this)
  client.headers = headerJson
  let url = pypiApiUrl & "pypi/" & project_name & "/json"
  result =
    when this is AsyncPyPI: parseJson(await client.getContent(url=url))
    else: parseJson(client.getContent(url=url))

proc release*(this: PyPI | AsyncPyPI, project_name, project_version): Future[JsonNode] {.multisync.} =
  ## Return all JSON data for project_name of an specific version from PyPI.
  clientify(this)
  client.headers = headerJson
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
  ## Return a project registered on PyPI as HTML string, Legacy Endpoint, Slow.
  clientify(this)
  result =
    when this is AsyncPyPI: await client.getContent(url=pypiApiUrl & "simple/" & project_name)
    else: client.getContent(url=pypiApiUrl & "simple/" & project_name)

proc stats*(this: PyPI | AsyncPyPI): Future[XmlNode] {.multisync.} =
  ## Return all JSON stats data for project_name of an specific version from PyPI.
  clientify(this)
  client.headers = headerXml
  result =
    when this is AsyncPyPI: parseXml(await client.getContent(url=pypiStatus))
    else: parseXml(client.getContent(url=pypiStatus))

proc listPackages*(this: PyPI | AsyncPyPI): Future[seq[string]] {.multisync.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI. Server-side Slow.
  clientify(this)
  client.headers = headerXml
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=lppXml))
    else: parseXml(client.postContent(pypiXmlUrl, body=lppXml))
  for tagy in response.findAll("string"): result.add tagy.innerText

proc changelogLastSerial*(this: PyPI | AsyncPyPI): Future[int] {.multisync.} =
  ## Return 1 XML XmlNode with the Last Serial number integer.
  clientify(this)
  client.headers = headerXml
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=clsXml))
    else: parseXml(client.postContent(pypiXmlUrl, body=clsXml))
  for tagy in response.findAll("int"): result = tagy.innerText.parseInt

proc listPackagesWithSerial*(this: PyPI | AsyncPyPI): Future[seq[array[2, string]]] {.multisync.} =
  ## Return 1 XML XmlNode of **ALL** the Packages on PyPI with Serial number integer. Server-side Slow.
  clientify(this)
  client.headers = headerXml
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=lpsXml))
    else: parseXml(client.postContent(pypiXmlUrl, body=lpsXml))
  for tagy in response.findAll("member"):
    result.add [tagy.child"name".innerText, tagy.child"value".child"int".innerText]

proc packageLatestRelease*(this: PyPI | AsyncPyPI, package_name): Future[string] {.multisync.} =
  ## Return the latest release registered for the given package_name.
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("package_releases", xmlRpcParam.format(package_name))
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))
  for tagy in response.findAll("string"): result = tagy.innerText

proc packageRoles*(this: PyPI | AsyncPyPI, package_name): Future[seq[XmlNode]] {.multisync.} =
  ## Retrieve a list of role, user for a given package_name. Role is Maintainer or Owner.
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("package_roles", xmlRpcParam.format(package_name))
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))
  for tagy in response.findAll("data"): result.add tagy

proc userPackages*(this: PyPI | AsyncPyPI, user = user): Future[seq[XmlNode]] {.multisync.} =
  ## Retrieve a list of role, package_name for a given user. Role is Maintainer or Owner.
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("user_packages", xmlRpcParam.format(user))
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))
  for tagy in response.findAll("data"): result.add tagy

proc releaseUrls*(this: PyPI | AsyncPyPI, package_name, release_version): Future[seq[string]] {.multisync.} =
  ## Retrieve a list of download URLs for the given release_version. Returns a list of dicts.
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("release_urls",
    xmlRpcParam.format(package_name) & xmlRpcParam.format(release_version))
  let response =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))
  for tagy in response.findAll("string"):
    if tagy.innerText.normalize.startsWith("https://"): result.add tagy.innerText

proc downloadPackage*(this: PyPI | AsyncPyPI, package_name, release_version,
  destDir = getTempDir(), generateScript): Future[string] {.multisync.} =
  ## Download a URL for the given release_version. Returns filename.
  let possibleUrls = await this.releaseUrls(package_name, release_version)
  let choosenUrl = possibleUrls[0]
  assert choosenUrl.startsWith("https://"), "PyPI Download URL is not HTTPS SSL"
  let filename = destDir / choosenUrl.split("/")[^1]
  clientify(this)
  echo "⬇️\t" & choosenUrl
  if generateScript: script &= "curl -LO " & choosenUrl & "\n"
  await client.downloadFile(choosenUrl, filename)
  assert existsFile(filename), "file failed to download"
  echo "🗜\t", getFileSize(filename), " Bytes total (compressed)"
  if findExe"sha512sum".len > 0: echo "🔐\t" & execCmdEx(cmdChecksum & filename).output.strip
  try:
    echo "⬇️\t" & choosenUrl & ".asc"
    await client.downloadFile(choosenUrl & ".asc", filename & ".asc")
    if generateScript: script &= "curl -LO " & choosenUrl & ".asc" & "\n"
    if findExe"gpg".len > 0 and existsFile(filename & ".asc"):
      echo "🔐\t" & execCmdEx(cmdVerify & filename & ".asc").output.strip
      if generateScript: script &= cmdVerify & filename.replace(destDir, "") & ".asc\n"
  except:
    echo "💩\tHTTP-404? ➡️ " & choosenUrl & ".asc"
  if generateScript: script &= pipInstallCmd & filename.replace(destDir, "") & "\n"
  result = filename

proc installPackage*(this: PyPI | AsyncPyPI, package_name, release_version,
  generateScript): Future[tuple[output: TaintedString, exitCode: int]] {.multisync.} =
  let cmd = pipInstallCmd & quoteShell(await this.downloadPackage(package_name, release_version, generateScript=generateScript))
  result = execCmdEx(cmd)

proc releaseData*(this: PyPI | AsyncPyPI, package_name, release_version): Future[XmlNode] {.multisync.} =
  ## Retrieve metadata describing a specific release_version. Returns a dict.
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("release_data",
    xmlRpcParam.format(package_name) & xmlRpcParam.format(release_version))
  result =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))

proc search*(this: PyPI | AsyncPyPI, query: Table[string, seq[string]], operator="and"): Future[XmlNode] {.multisync.} =
  ## Search package database using indicated search spec. Returns 100 results max.
  doAssert operator in ["or", "and"], "operator must be 1 of 'and', 'or'."
  clientify(this)
  client.headers = headerXml
  let bodi = xmlRpcBody.format("search", xmlRpcParam.format(replace($query, "@", "")) & xmlRpcParam.format(operator))
  result =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))

proc browse*(this: PyPI | AsyncPyPI, classifiers): Future[XmlNode] {.multisync.} =
  ## Retrieve a list of name, version of all releases classified with all of given classifiers.
  ## Classifiers must be a list of standard Trove classifier strings. Returns 100 results max.
  doAssert classifiers.len > 1, "classifiers must be at least 2 strings lenght."
  clientify(this)
  client.headers = headerXml
  let clasifiers = block:
    var x: string
    for item in classifiers: x &= xmlRpcParam.format(item)
    x
  let bodi = xmlRpcBody.format("browse", clasifiers)
  result =
    when this is AsyncPyPI: parseXml(await client.postContent(pypiXmlUrl, body=bodi))
    else: parseXml(client.postContent(pypiXmlUrl, body=bodi))

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
  doAssert filename.existsFile, "filename must be 1 existent valid readable file"
  let
    fext = filename.splitFile.ext.toLowerAscii
    mime = newMimetypes().getMimetype(fext)
    auth = {"Authorization": "Basic " & encode(username & ":" & password), "dnt": "1"}
  # doAssert fext in ["whl", "egg", "zip"], "file extension must be 1 of .whl or .egg or .zip"
  let multipart_data = block:
    var x = newMultipartData()
    x["protocol_version"] = "1"
    x[":action"] = "file_upload"
    x["metadata_version"] = "2.1"
    x["author"] = author
    x["name"] = name.normalize
    x["md5_digest"] = md5_digest # md5 hash of file in urlsafe base64
    x["summary"] = summary.normalize
    x["version"] = version.toLowerAscii
    x["license"] = license.toLowerAscii
    x["pyversion"] = pyversion.normalize
    x["requires_python"] = requirespython
    x["homepage"] = homepage.toLowerAscii
    x["filetype"] = filetype.toLowerAscii
    x["description"] = description.normalize
    x["keywords"] = keywords.join(" ").normalize
    x["download_url"] = downloadurl.toLowerAscii
    x["author_email"] = authoremail.toLowerAscii
    x["maintainer_email"] = maintaineremail.toLowerAscii
    x["description_content_type"] = description_content_type.strip
    x["maintainer"] = if maintainer == "": author else: maintainer
    x["content"] = (filename, mime, filename.readFile)
    x
  clientify(this)
  client.headers = newHttpHeaders(auth)
  result =  # TODO: Finish this and test against the test dev pypi server.
    when this is AsyncPyPI: await client.postContent(pypiUploadUrl, multipart=multipart_data)
    else: client.postContent(pypiUploadUrl, multipart=multipart_data)

proc pluginSkeleton() =
  ## Creates the skeleton (folders and files) for a New Python project.
  let pluginName = normalize(readLineFromStdin("New Python project name?: "))
  assert pluginName.len > 1, "Name must not be empty string: " & pluginName
  discard existsOrCreateDir(pluginName)
  writeFile(pluginName / pluginName & ".py", r"print((lambda r:'\n'.join('.'.join('█' if(y<r and((x-r)**2+(y-r)**2<=r**2or(x-3*r)**2+(y-r)**2<=r**2))or(y>=r and x+r>=y and x-r<=4*r-y)else '░' for x in range(4*r))for y in range(1,3*r,2)))(5))")
  if readLineFromStdin("Generate optional Unitests on ./tests (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "tests")
    writeFile(pluginName / "tests/tests.py", testTemplate)
  if readLineFromStdin("Generate optional Documentation on ./docs (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "docs")
    writeFile(pluginName / "docs/documentation.md", "# " & pluginName & "\n\n")
  if readLineFromStdin("Generate optional Examples on ./examples (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "examples")
    writeFile(pluginName / "examples/example.py", "# -*- coding: utf-8 -*-\n\nprint('Example')\n")
  if readLineFromStdin("Generate optional DevOps on ./devops (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / "devops")
    writeFile(pluginName / "devops/Dockerfile", dockerfileTemplate)
    writeFile(pluginName / "devops/build_package.sh", "python3 setup.py sdist --formats=zip\n")
    writeFile(pluginName / "devops/upload_package.sh", "twine upload .\n")
  if readLineFromStdin("Generate optional GitHub files on .github (y/N): ").normalize == "y":
    discard existsOrCreateDir(pluginName / ".github")
    discard existsOrCreateDir(pluginName / ".github/ISSUE_TEMPLATE")
    discard existsOrCreateDir(pluginName / ".github/PULL_REQUEST_TEMPLATE")
    writeFile(pluginName / ".github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md", "")
    writeFile(pluginName / ".github/PULL_REQUEST_TEMPLATE/PULL_REQUEST_TEMPLATE.md", "")
  if readLineFromStdin("Generate optional files (y/N): ").normalize == "y":
    writeFile(pluginName / ".gitattributes", "*.py linguist-language=Python\n")
    writeFile(pluginName / ".gitignore", "*.pyc\n*.pyd\n*.pyo\n*.egg-info\n*.egg\n*.log\n__pycache__\n")
    writeFile(pluginName / "MANIFEST.in", "include main.py\nrecursive-include *.py\n")
    writeFile(pluginName / "LICENSE.txt", "# https://tldrlegal.com/licenses/browse\n")
    writeFile(pluginName / "CODE_OF_CONDUCT.md", "")
    writeFile(pluginName / "CONTRIBUTING.md", "")
    writeFile(pluginName / "README.md", "")
    writeFile(pluginName / "requirements.txt", "")
    writeFile(pluginName / "setup.cfg", setupCfg)
    writeFile(pluginName / "setup.py", "# -*- coding: utf-8 -*-\nfrom setuptools import setup\nsetup() # Edit setup.cfg,not here!.\n")
    writeFile(pluginName / "CHANGELOG.md", "# 0.0.1\n\n- First initial version created at " & $now())
  quit("Created a new Python project skeleton, happy hacking, bye...\n", 0)

proc backup*(filename: string): tuple[output: TaintedString, exitCode: int] =
  var cmd: string
  if findExe"sha512sum".len > 0:
    cmd = cmdChecksum & filename & " > " & filename & ".sha512"
    when not defined(release): echo cmd
    result = execCmdEx(cmd)
    if result.exitCode == 0 and findExe"gpg".len > 0:
      cmd = cmdSign & filename
      when not defined(release): echo cmd
      result = execCmdEx(cmd)
      if result.exitCode == 0 and findExe"tar".len > 0:
        cmd = cmdTar & filename & ".tar.gz " & filename & " " & filename & ".sha512 " & filename & ".asc"
        when not defined(release): echo cmd
        result = execCmdEx(cmd)
        if result.exitCode == 0:
          removeFile(filename)
          removeFile(filename & ".sha512")
          removeFile(filename & ".asc")

proc ask2User(): auto =
  var username, password, name, version, license, summary, description, homepage: string
  var author, downloadurl, authoremail, maintainer, maintaineremail, iPwd2: string
  var keywords: seq[string]
  while not(author.len > 2 and author.len < 99):
    author = readLineFromStdin("\nType Author (Real Name): ").strip
  while not(username.len > 2 and username.len < 99):
    username = readLineFromStdin("Type Username (PyPI Username): ").strip
  while not(maintainer.len > 2 and maintainer.len < 99):
    maintainer = readLineFromStdin("Type Package Maintainer (Real Name): ").strip
  while not(password.len > 4 and password.len < 999 and password == iPwd2):
    password = readLineFromStdin("Type Password: ").strip  # Type it Twice.
    iPwd2 = readLineFromStdin("Confirm Password (Repeat it again): ").strip
  while not(authoremail.len > 5 and authoremail.len < 255 and "@" in authoremail):
    authoremail = readLineFromStdin("Type Author Email (Lowercase): ").strip.toLowerAscii
  while not(maintaineremail.len > 5 and maintaineremail.len < 255 and "@" in maintaineremail):
    maintaineremail = readLineFromStdin("Type Maintainer Email (Lowercase): ").strip.toLowerAscii
  while not(name.len > 0 and name.len < 99):
    name = readLineFromStdin("Type Package Name: ").strip.toLowerAscii
  while not(version.len > 4 and version.len < 99 and "." in version):
    version = readLineFromStdin("Type Package Version (SemVer): ").normalize
  echo licenseHint
  while not(license.len > 2 and license.len < 99):
    license = readLineFromStdin("Type Package License: ").normalize
  while not(summary.len > 0 and summary.len < 999):
    summary = readLineFromStdin("Type Package Summary (Short Description): ").strip
  while not(description.len > 0 and description.len < 999):
    description = readLineFromStdin("Type Package Description (Long Description): ").strip
  while not(homepage.len > 5 and homepage.len < 999 and homepage.startsWith"http"):
    homepage = readLineFromStdin("Type Package Web Homepage URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(downloadurl.len > 5 and downloadurl.len < 999 and downloadurl.startsWith"http"):
    downloadurl = readLineFromStdin("Type Package Web Download URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(keywords.len > 1 and keywords.len < 99):
    keywords = readLineFromStdin("Type Package Keywords,separated by commas,without spaces,at least 2 (CSV): ").normalize.split(",")
  result = (username: username, password: password, name: name, author: author,
    version: version, license: license, summary: summary, homepage: homepage,
    description: description,  downloadurl: downloadurl, maintainer: maintainer,
    authoremail: authoremail,  maintaineremail: maintaineremail, keywords: keywords)

proc forceInstallPip*(destination: string): tuple[output: TaintedString, exitCode: int] =
  assert destination.endswith".py", "Wrong filename for Python file"
  newHttpClient(timeout=9999).downloadFile(pipInstaller, destination) # Download
  assert existsFile(destination), "File not found: 'get-pip.py' " & destination
  result = execCmdEx(py3 & destination & " -I") # Installs PIP via get-pip.py


###############################################################################


when isMainModule:  # https://pip.readthedocs.io/en/1.1/requirements.html
  addHandler(newConsoleLogger(fmtStr = verboseFmtStr))
  addHandler(newRollingFileLogger(fmtStr = "$level, $datetime, $appname, "))
  putEnv("PIP_NO_INPUT", "1")
  randomize()
  var
    taimaout = 99.byte
    args: seq[string]
  for tipoDeClave, clave, valor in getopt():
    case tipoDeClave
    of cmdShortOption, cmdLongOption:
      case clave.normalize
      of "version":             quit(version, 0)
      of "license", "licencia": quit("PPL", 0)
      of "completion":  # I find this dumb,but PIP does it,so we add it.
        if valor == "zsh":      quit(completionZsh, 0)
        elif valor == "fish":   quit(completionFish, 0)
        else:                   quit(completionBash, 0)
      of "nice20":              discard nice(20.cint)
      of "timeout":             taimaout = valor.parseInt.byte
      of "help", "ayuda", "fullhelp":
        styledEcho(fgGreen, bgBlack, helpy)
        quit()
      of "publicip":
        quit("🌎\tPublic IP ➡️ " &
          newHttpClient(timeout=9999).getContent("https://api.ipify.org").strip, 0)
      of "debug", "desbichar":
        quit(pretty(%*{"CompileDate": CompileDate, "CompileTime": CompileTime,
        "NimVersion": NimVersion, "hostCPU": hostCPU, "hostOS": hostOS,
        "cpuEndian": cpuEndian, "tempDir": getTempDir(), "python2": py2,
        "currentDir": getCurrentDir(), "python3": py3, "ssl": defined(ssl),
        "release": defined(release), "contracts": defined(release),
        "hardened": defined(hardened), "sitePackages": sitePackages,
        "pipCacheDir": pipCacheDir, "cython": cython, "nuitka": nuitka,
        "currentCompilerExe": getCurrentCompilerExe(), "int.high": int.high,
        "processorsCount": countProcessors(), "danger": defined(danger),
        "currentProcessId": getCurrentProcessId(), "version": version}), 0)
      of "putenv":
        let envy = valor.split"="
        styledEcho(fgMagenta, bgBlack, $envy)
        putEnv(envy[0], envy[1])
      of "debugger": putEnv("PYTHONBREAKPOINT", valor.strip)
      of "localewarn": putEnv("PYTHONCOERCECLOCALE", "warn")
      of "malloc": putEnv("PYTHONMALLOC", "debug")
      of "hashseed": putEnv("PYTHONHASHSEED", $valor)
      of "ioencodingutf8": putEnv("PYTHONIOENCODING", "utf-8")
      of "pythonhome": putEnv("PYTHONHOME", valor.strip)
      of "pythonstartup": putEnv("PYTHONSTARTUP",  valor.strip)
      of "pythonpath": putEnv("PYTHONPATH",  getEnv"PYTHONPATH" & ":" & valor)
      of "nopyc":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for pyc in walkFiles("./*.pyc"): echo $tryRemoveFile(pyc) & "\t" & pyc
      of "nopycache":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for pyc in walkDirs("__pycache__"): echo $tryRemoveFile(pyc) & "\t" & pyc
      of "cleantemp":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for tmp in walkPattern(getTempDir()): echo $tryRemoveFile(tmp) & "\t" & tmp
      of "cleanvirtualenvs", "cleanvirtualenv", "clearvirtualenvs", "clearvirtualenv":
        discard # WIP
        # let files2delete = block:
        #   var x: seq[string]
        #   for pythonfile in walkPattern(virtualenvDir / "*.*"):
        #     styledEcho(fgRed, bgBlack, "🗑\t" & pythonfile)
        #     #if readLineFromStdin("Delete Python Virtualenv? (y/N): ").normalize == "y":
        #     x.add pythonfile
        #   x # No official documented way to get virtualenv location on windows
        # echo "files2delete ", files2delete
        # styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        # for pyc in files2delete: echo $tryRemoveFile(pyc) & "\t" & pyc
      of "cleanpipcache":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile") # Dir Found in the wild
        echo $tryRemoveFile("/tmp/pip-build-root") & "\t/tmp/pip-build-root"
        echo $tryRemoveFile("/tmp/pip_build_root") & "\t/tmp/pip_build_root"
        echo $tryRemoveFile("/tmp/pip-build-" & user) & "\t/tmp/pip-build-" & user
        echo $tryRemoveFile("/tmp/pip_build_" & user) & "\t/tmp/pip_build_" & user
        echo $tryRemoveFile(pipCacheDir) & "\t" & pipCacheDir
      of "color":
        setBackgroundColor(bgBlack)
        setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].sample)
      of "suicide": discard tryRemoveFile(currentSourcePath()[0..^5])
    of cmdArgument:
      args.add clave
    of cmdEnd: quit("Wrong Parameters, please see Help with: --help", 1)
  let is1argOnly = args.len == 2  # command + arg == 2 ("install foo")
  if args.len > 0:
    let cliente = PyPI(timeout: taimaout)
    case args[0].normalize
    of "stats":
      quit($cliente.stats(), 0)
    of "newpackages":
      quit($cliente.newPackages(), 0)
    of "lastupdates":
      quit($cliente.lastUpdates(), 0)
    of "lastjobs":
      quit($cliente.lastJobs(), 0)
    of "latestversion":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit($cliente.packageLatestRelease(args[1]), 0)
    of "open":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      discard execCmdEx(xdgOpen & args[1])
    of "userpackages":
      quit($cliente.userPackages(readLineFromStdin("PyPI Username?: ").normalize), 0)
    of "strip":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      let (output, exitCode) = execCmdEx(cmdStrip & args[1])
      quit(output, exitCode)
    of "search":
      quit("Not implemented yet (PyPI API is Buggy)")
      # echo args[1]
      # echo cliente.search({"name": @[args[1]]}.toTable)
    of "init":
      pluginSkeleton()
    of "hash":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      if findExe"sha512sum".len > 0:
        let sha512sum = execCmdEx(cmdChecksum & args[1]).output.strip
        echo sha512sum
        echo "--hash=sha512:" & sha512sum.split(" ")[^1]
    of "backup":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      quit(backup(args[1]).output, 0)
    of "uninstall":
      let files2delete = block:
        var result: seq[string]
        for argument in args[1..^1]:
          for pythonfile in walkFiles(sitePackages / argument / "*.*"):
            result.add pythonfile
            styledEcho(fgRed, bgBlack, "🗑\t" & pythonfile)
          for pythonfile in walkFiles(sitePackages / argument & "-*.dist-info" / "*"):
            result.add pythonfile  # Metadata folder & files (no file extension)
            styledEcho(fgRed, bgBlack, "🗑\t" & pythonfile)
          for pythonfile in walkFiles(sitePackages / argument & pyExtPattern):
            result.add pythonfile  # *.so are compiled native binary modules
            styledEcho(fgRed, bgBlack, "🗑\t" & pythonfile)
        result
      when defined(linux):
        if readLineFromStdin("\nGenerate Uninstall Script? (y/N): ").normalize == "y":
          echo "\nsudo rm --verbose --force ", files2delete.join" "
      if readLineFromStdin("\nDelete " & $files2delete.len & " Python files? (y/N): ").normalize == "y":
        styledEcho(fgRed, bgBlack, "\n\nDeleted?\tFile")
        for pythonfile in files2delete:
          echo $tryRemoveFile(pythonfile) & "\t" & pythonfile
    of "install":
      var failed, suces: byte
      echo("🐍\t", now(), ", PID is ", getCurrentProcessId(), ", ",
        args[1..^1].len, " packages to download and install ➡️ ", args[1..^1])
      let generateScript = readLineFromStdin("\nGenerate Install Script? (y/N): ").normalize == "y"
      let time0 = now()
      for argument in args[1..^1]:
        let semver = $cliente.packageLatestRelease(argument)
        echo "🌎\tPyPI ➡️ " & argument & " " & semver
        let resultados = cliente.installPackage(argument, semver, generateScript)
        echo if resultados.exitCode == 0: "✅\t" else: "❌\t", resultados
        if resultados.exitCode == 0: inc suces else: inc failed
      if generateScript: echo "\n", script
      echo(if failed == 0: "✅\t" else: "❌\t", now(), " ", failed,
        " Failed, ", suces, " Success on ", now() - time0,
        " to download/decompress/install ", args[1..^1].len, " packages")
    of "upload":
      if not is1argOnly: quit"Too many arguments,command only supports 1 argument"
      doAssert existsFile(args[1]), "File not found: " & args[1]
      let (username, password, name, author, version, license, summary, homepage,
        description, downloadurl, maintainer, authoremail, maintaineremail, keywords
      ) = ask2User()
      echo cliente.upload(
        username = username, password = password, name = name,
        version = version, license = license, summary = summary,
        description = description, author = author, downloadurl = downloadurl,
        authoremail = authoremail, maintainer = maintainer, keywords = keywords,
        maintaineremail = maintaineremail, homepage = homepage, filename = args[1],
        md5_digest = getMD5(readFile(args[1])),
      )

  else: quit("Wrong Parameters, please see Help with: --help", 1)
  resetAttributes()  # Reset terminal colors.
  # Delete virtualenvs
  #