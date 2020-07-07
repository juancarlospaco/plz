# For compile time code executions, we dont care the optimization or how clunky
# it looks because is done compile time only,worse case scenario it wont compile

const
  NimblePkgVersion {.strdefine.} = CompileDate.replace("-", ".")
  timeouts {.intdefine.}: Positive = 9999
  maxRedirects {.intdefine.}: Positive = 9
  pypiApiUrl = "https://pypi.org/"                          ## PyPI Base API URL.
  pypiXmlUrl = pypiApiUrl & "pypi"                          ## PyPI XML RPC API URL.
  pypiPackagesXml = "https://pypi.org/rss/packages.xml"     ## PyPI XML API URL.
  pypiUpdatesXml = "https://pypi.org/rss/updates.xml"       ## PyPI XML API URL.
  pypiUploadUrl = "https://test.pypi.org/legacy/"           ## PyPI Upload POST URL
  pypiJobUrl = "https://www.python.org/jobs/feed/rss/"      ## Python Jobs URL
  pypiStatus = "https://status.python.org/history.rss"      ## PyPI Status XML API URL.
  lppXml = "<methodName>list_packages</methodName>"         ## XML RPC Command.
  clsXml = "<methodName>changelog_last_serial</methodName>" ## XML RPC Command.
  lpsXml = "<methodName>list_packages_with_serial</methodName>" ## XML RPC Command.
  xmlRpcParam = "<param><value><string>$1</string></value></param>"
  xmlRpcBody = "<?xml version='1.0'?><methodCall><methodName>$1</methodName><params>$2</params></methodCall>"
  hdrJson = {"dnt": "1", "accept": "application/json", "content-type": "application/json"}
  hdrXml = {"dnt": "1", "accept": "text/xml", "content-type": "text/xml"}
  sitePackages = staticExec"""python3 -c "print(__import__('site').getsitepackages()[0])" """ ## https://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory#12950101
  virtualenvDir = r"~/.virtualenvs"
  pipCommons = "--isolated --disable-pip-version-check --no-color --no-cache-dir --quiet "
  pipInstallCmd = "pip3 install --upgrade --no-index --no-warn-script-location --user " & pipCommons
  pipMaintenance = "pip3 install --upgrade --no-warn-script-location --user " & pipCommons & " pip virtualenv setuptools wheel twine"
  cmdChecksum = "sha256sum --tag " # I prefer SHA512,but PyPI uses SHA256 only?
  cmdVerify = "gpg --verify "
  cmdStrip = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag " ## PIP Wont optimize Production binaries, they are left with all Debugging on!.
  osOpen = when defined(macos): "open " elif defined(windows): "start " else: "xdg-open "
  pyExtPattern = when defined(windows): ".cpython-*.dll" elif defined(macos): ".cpython-*.dynlib" else: ".cpython-*.so"
  pipCacheDir =
    when defined(linux): r"~/.cache/pip"                    # PIP "standards"
    elif defined(macos): r"~/Library/Caches/pip"
    elif defined(windows): r"%LocalAppData%\pip\Cache"
    else: getEnv"PIP_DOWNLOAD_CACHE"

# TODO: search    Search PyPI for packages (PyPI API is Buggy???).
const helpy = """ 👑 PIP Fast Single-File Compiled Alternative 👑
https://nim-lang.org
Commands:
  install         Install packages (Download, Decompress, Install packages).
  uninstall       Uninstall packages (Interactive, asks Y/N to user before).
  reinstall       Uninstall & Install packages (Interactive, asks Y/N to user).
  download        Download packages (Interactive,no decompress,asks destination)
  hash            Compute hashes of package archives (SHA256 Checksum file).
  init            New Python project template (Interactive, asks Y/N to user).
  strip           Optimize size of Python native binary module (PIP wont strip).
  newpackages     List all the new Packages uploaded to PyPI recently (RSS).
  lastupdates     List all existing Packages updated on PyPI recently (RSS).
  lastjobs        List all new Job Posts updated on Python recently (RSS).
  stats           PyPI service status report from official statuspage (RSS).
  userpackages    List all existing Packages by User (Interactive, asks user).
  latestversion   Show the Latest Version release of a PYPI Package (SemVer).
  open            Open a given module in your default code editor (xdg-open).
  forceInstallPip Force install PIP on a given location directory (get-pip.py).
  doc             Markdown/ReSTructuredText to HTML  (MD/RST can be mixed).
  doc2latex       Markdown/ReSTructuredText to Latex (MD/RST can be mixed).
  doc2json        Markdown/ReSTructuredText to JSON  (MD/RST can be mixed).
  upload          Similar to "twine upload" (Interactive,asks user,wont need Twine).

Options:
  --help           Show Help and quit.
  --version        Show Version and quit.
  --license        Show License and quit.
  --dump           Show system info JSON and quit (for Developers and Bug Reporting).
  --enUsUtf8       Force Encoding to UTF-8 and Language to English (en_US.UTF-8)
  --putenv:key=val Set an environment variable "KEY=Value", can be repeated.
  --cleanpyc       Recursively remove all __pycache__ and *.pyc
  --cleanpypackages Recursively remove all __pypackages__
  --cleantemp      Remove all files and folders from the OS Temporary folder.
  --cleanpipcache  Remove all files and folders from the PIP Cache folder.
  --cleanvenvs     Remove Virtualenvs (interactive, asks Y/N 1-by-1).
  --log=file.log   Full path to a verbose local log file.
  --backuplogs     Compress old PLZ Logs at exit to save disk resources.
  --nice20         Runs with "nice = 20" (CPU Priority, smooth priority).
  --publicip       Show your Public IP Address (Internet connectivity check).
  --suicide        Deletes itself permanently and exit (single file binary).
"""


const setupCfg = """
# See: https://setuptools.readthedocs.io/en/latest/setuptools.html#metadata

[metadata]
name             = example
provides         = example
description      = example package
url              = https://github.com/example/example
download_url     = https://github.com/example/example
author           = Deborah Melltrozzo
author_email     = example@example.com
maintainer       = User
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
python_requires  = >=3.8
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
# exclude = *.c, *.so, *.js, *.tests, *.tests.*, tests.*, tests
"""


const pkgInfoTemplate = """Metadata-Version: 2.1
Name: example
Version: 0.0.1
Summary: example package
Description: example package
Home-page: https://github.com/example/example
url: https://github.com/example/example
download_url: https://github.com/example/example
Author: anonymous
Author-email: user@mail.com
Maintainer: anonymous
Maintainer-email: user@mail.com
License: MIT
Keywords: python3, python4, cpython
Platform: Linux
Platform: Darwin
Platform: Windows
Classifier: Development Status :: 5 - Production/Stable
Classifier: Environment :: Console
Classifier: Environment :: Other Environment
Classifier: Intended Audience :: Developers
Classifier: Intended Audience :: Other Audience
Classifier: Natural Language :: English
Classifier: Operating System :: OS Independent
Classifier: Operating System :: POSIX :: Linux
Classifier: Programming Language :: Python
Classifier: Programming Language :: Python :: 3
Classifier: Programming Language :: Python :: 3 :: Only
Classifier: Programming Language :: Python :: 3.8
Classifier: Programming Language :: Python :: Implementation :: CPython
Classifier: Topic :: Software Development
Requires-Python: >=3.8
Description-Content-Type: text/markdown """


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
    unittest.main()
"""


const serviceTemplate = """
[Unit]
Description=Example Service
Documentation=https://example.com/documentation
After=network-online.target

[Service]
Type=simple
User=nobody         # Change to your user.
Restart=always      # on-failure
RestartSec=1        # Sleep Seconds before restarting the process.
# RuntimeMaxSec=1w  # Restart process periodically. 1w=week, 1d=day, 1m=minute.
TimeoutStartSec=999 # Timeout Seconds while starting the process.
TimeoutStopSec=999  # Timeout Seconds while stopping the process.
# ExecStartPre=     # Execute BEFORE start.
ExecStart=echo      # Execute your application command.
# ExecStartPost=    # Execute AFTER start.
# ExecReload=       # Execute while restarting the process.
# ExecStop=         # Execute while stopping the process.
# ExecStopPost=     # Execute AFTER stopping the process.
# Environment=      # You can add any Environment variables here.
# WorkingDirectory=/home/<user>/  # MODIFY to your installation path

[Install]
WantedBy=multi-user.target
"""

const nimpyTemplate = """import os, strutils, nimpy

proc function(a, b: int): auto {.exportpy.} =
  ## Documentation comment, Markdown/ReSTructuredText/PlainText, generates HTML.
  a + b  # Comment, ignored by compiler.       https://github.com/yglukhov/nimpy
"""


##############################################################################


addHandler(newConsoleLogger(fmtStr = ""))
setControlCHook((proc {.noconv.} = quit" CTRL+C Pressed, shutting down, bye! "))

var logfile = defaultFilename()

let
  py3 = findExe"python3"
  user = getEnv"USER"

using
  generateScript: bool
  query: Table[string, seq[string]]
  args, classifiers, keywords: seq[string]
  projectName, projectVersion, packageName, user, releaseVersion: string
  destDir, name, version, license, summary, description, author: string
  downloadurl, authoremail, maintainer, maintaineremail, filename: string
  homepage, md5_digest, username, password, destination: string
