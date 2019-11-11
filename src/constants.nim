# For compile time code executions, we dont care the optimization or how clunky
# it looks because is done compile time only,worse case scenario it wont compile

const
  pypiApiUrl = "https://pypi.org/"                          ## PyPI Base API URL.
  pypiXmlUrl = pypiApiUrl & "pypi"                          ## PyPI XML RPC API URL.
  pypiPackagesXml = "https://pypi.org/rss/packages.xml"     ## PyPI XML API URL.
  pypiUpdatesXml = "https://pypi.org/rss/updates.xml"       ## PyPI XML API URL.
  pypiUploadUrl = "https://test.pypi.org/legacy/"           ## PyPI Upload POST URL
  pypiJobUrl = "https://www.python.org/jobs/feed/rss/"      ## Python Jobs URL
  pypiStatus = "https://status.python.org/history.rss"      ## PyPI Status XML API URL.
  pipInstaller = "https://bootstrap.pypa.io/get-pip.py"     ## get-pip URL
  lppXml = "<methodName>list_packages</methodName>"         ## XML RPC Command.
  clsXml = "<methodName>changelog_last_serial</methodName>" ## XML RPC Command.
  lpsXml = "<methodName>list_packages_with_serial</methodName>" ## XML RPC Command.
  xmlRpcParam = "<param><value><string>$1</string></value></param>"
  xmlRpcBody = "<?xml version='1.0'?><methodCall><methodName>$1</methodName><params>$2</params></methodCall>"
  hdrJson = {"dnt": "1", "accept": "application/json",
      "content-type": "application/json"}
  hdrXml = {"dnt": "1", "accept": "text/xml", "content-type": "text/xml"}
  commitHash = staticExec"git rev-parse --short HEAD"
  NimblePkgVersion {.strdefine.} = "1.0.0"
  version = NimblePkgVersion & "\n" & commitHash
  sitePackages = staticExec"""python3 -c "print(__import__('site').getsitepackages()[0])" """ ## https://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory#12950101
  virtualenvDir = r"~/.virtualenvs"
  pipCommons = "--isolated --disable-pip-version-check --no-color --no-cache-dir --quiet "
  pipInstallCmd = "pip3 install --upgrade --no-index --no-warn-script-location --user " & pipCommons
  pipMaintenance = "pip3 install --upgrade --no-warn-script-location --user " &
      pipCommons & " pip virtualenv setuptools wheel twine"
  cmdChecksum = "sha256sum --tag " # I prefer SHA512,but PyPI uses SHA256 only?
  cmdSign = "gpg --armor --detach-sign --yes --digest-algo sha512 "
  cmdTar = "tar cafv "
  cmdVerify = "gpg --verify "
  cmdStrip = "strip --strip-all --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag " ## PIP Wont optimize Production binaries, they are left with all Debugging on!.
  cmdBsdtar = "bsdtar -xvf "
  pipCacheDir =
    when defined(linux): r"~/.cache/pip"                    # PIP "standards"
    elif defined(macos): r"~/Library/Caches/pip"
    elif defined(windows): r"%LocalAppData%\pip\Cache"
    else: getEnv"PIP_DOWNLOAD_CACHE"
  osOpen =
    when defined(macos): "open "
    elif defined(windows): "start "
    else: "xdg-open "
  pyExtPattern =
    when defined(windows): ".cpython-*.dll"
    elif defined(macos): ".cpython-*.dynlib"
    else: ".cpython-*.so"


# TODO:
# upload          Mimics "twine upload" (Interactive,asks user,wont need Twine).
# search          Search PyPI for packages (PyPI API is Buggy, is still WIP).
# doc             Markdown/ReSTructuredText to HTML  (MD/RST can be mixed).
# doc2latex       Markdown/ReSTructuredText to Latex (MD/RST can be mixed).
# doc2json        Markdown/ReSTructuredText to JSON  (MD/RST can be mixed).
# extract         Extract a valid compressed file of any format (LibArchive).
# cleanvirtualenv Delete local Virtualenv (Interactive,asks Y/N to user before).

const helpy = """ 👑 PIP Fast Single-File Hardened Compiled Alternative 👑
Commands:
  install         Install packages (Download, Decompress, Install packages).
  uninstall       Uninstall packages (Interactive, asks Y/N to user before).
  reinstall       Uninstall & Install packages (Interactive, asks Y/N to user).
  download        Download packages (Interactive,no decompress,asks destination)
  hash            Compute hashes of package archives (SHA256 Checksum file).
  init            New Python project template (Interactive, asks Y/N to user).
  backup          Compressed signed backup of a file and quit (GPG + SHA512).
  strip           Optimize size of Python native binary module (PIP wont strip).
  newpackages     List all the new Packages uploaded to PyPI recently (RSS).
  lastupdates     List all existing Packages updated on PyPI recently (RSS).
  lastjobs        List all new Job Posts updated on Python recently (RSS).
  stats           PyPI service status report from official statuspage (RSS).
  userpackages    List all existing Packages by User (Interactive, asks user).
  latestversion   Show the Latest Version release of a PYPI Package (SemVer).
  open            Open a given module in your default code editor (xdg-open).
  forceInstallPip Force install PIP on a given location directory (get-pip.py).

Options:
  --help           Show Help and quit.
  --version        Show Version and quit.
  --license        Show License and quit.
  --enUsUtf8       Force Encoding to UTF-8 and Language to English (en_US.UTF-8)
  --debug          Show Debug info and quit (for Developers and Bug Reporting).
  --timeout=42     Set the default timeout on seconds (for HTTPS Downloads).
  --putenv:key=val Set an environment variable "KEY=Value", can be repeated.
  --cleanpyc       Recursively remove all __pycache__ and *.pyc
  --cleanpypackages Recursively remove all __pypackages__
  --cleantemp      Remove all files and folders from the OS Temporary folder.
  --cleanpipcache  Remove all files and folders from the PIP Cache folder.
  --cleanvenvs     Remove Virtualenvs (interactive, asks y/n 1-by-1).
  --nice20         Runs with "nice = 20" (CPU Priority, smooth priority).
  --publicip       Show your Public IP Address (Internet connectivity check).
  --suicide        Deletes itself permanently and exit (single file binary).

http://nim-lang.org http://github.com/juancarlospaco http://github.com/yglukhov/nimpy
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
# exclude = *.c, *.so, *.js, *.tests, *.tests.*, tests.*, tests
"""


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


# http://github.com/pre-commit/pre-commit/blob/master/pre_commit/resources/hook-tmpl
const precommitTemplate = """
import distutils.spawn, os, subprocess, sys
HERE = os.path.dirname(os.path.abspath(__file__))
Z40 = '0' * 40
ID_HASH = '138fd403232d2ddd5efb44317e38bf03'
# start templated
CONFIG = None
HOOK_TYPE = None
INSTALL_PYTHON = None
SKIP_ON_MISSING_CONFIG = None
# end templated

class EarlyExit(RuntimeError):
    pass

class FatalError(RuntimeError):
    pass

def _norm_exe(exe):
    with open(exe, 'rb') as f:
        if f.read(2) != b'#!':
            return ()
        try:
            first_line = f.readline().decode('UTF-8')
        except UnicodeDecodeError:
            return ()

        cmd = first_line.split()
        if cmd[0] == '/usr/bin/env':
            del cmd[0]
        return tuple(cmd)

def _run_legacy():
    if __file__.endswith('.legacy'):
        raise SystemExit(
            "bug: pre-commit's script is installed in migration mode\n"
            'run `pre-commit install -f --hook-type {}` to fix this\n\n'
            'Please report this bug at '
            'https://github.com/pre-commit/pre-commit/issues'.format(
                HOOK_TYPE,
            ),
        )
    if HOOK_TYPE == 'pre-push':
        stdin = getattr(sys.stdin, 'buffer', sys.stdin).read()
    else:
        stdin = None
    legacy_hook = os.path.join(HERE, '{}.legacy'.format(HOOK_TYPE))
    if os.access(legacy_hook, os.X_OK):
        cmd = _norm_exe(legacy_hook) + (legacy_hook,) + tuple(sys.argv[1:])
        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE if stdin else None)
        proc.communicate(stdin)
        return proc.returncode, stdin
    else:
        return 0, stdin

def _validate_config():
    cmd = ('git', 'rev-parse', '--show-toplevel')
    top_level = subprocess.check_output(cmd).decode('UTF-8').strip()
    cfg = os.path.join(top_level, CONFIG)
    if os.path.isfile(cfg):
        pass
    elif SKIP_ON_MISSING_CONFIG or os.getenv('PRE_COMMIT_ALLOW_NO_CONFIG'):
        print(
            '`{}` config file not found. '
            'Skipping `pre-commit`.'.format(CONFIG),
        )
        raise EarlyExit()
    else:
        raise FatalError(
            'No {} file was found\n'
            '- To temporarily silence this, run '
            '`PRE_COMMIT_ALLOW_NO_CONFIG=1 git ...`\n'
            '- To permanently silence this, install pre-commit with the '
            '--allow-missing-config option\n'
            '- To uninstall pre-commit run '
            '`pre-commit uninstall`'.format(CONFIG),
        )

def _exe():
    with open(os.devnull, 'wb') as devnull:
        for exe in (INSTALL_PYTHON, sys.executable):
            try:
                if not subprocess.call(
                        (exe, '-c', 'import pre_commit.main'),
                        stdout=devnull, stderr=devnull,
                ):
                    return (exe, '-m', 'pre_commit.main', 'run')
            except OSError:
                pass
    if distutils.spawn.find_executable('pre-commit'):
        return ('pre-commit', 'run')
    raise FatalError(
        '`pre-commit` not found.  Did you forget to activate your virtualenv?',
    )

def _rev_exists(rev):
    return not subprocess.call(('git', 'rev-list', '--quiet', rev))

def _pre_push(stdin):
    remote = sys.argv[1]
    opts = ()
    for line in stdin.decode('UTF-8').splitlines():
        _, local_sha, _, remote_sha = line.split()
        if local_sha == Z40:
            continue
        elif remote_sha != Z40 and _rev_exists(remote_sha):
            opts = ('--origin', local_sha, '--source', remote_sha)
        else:
            # ancestors not found in remote
            ancestors = subprocess.check_output((
                'git', 'rev-list', local_sha, '--topo-order', '--reverse',
                '--not', '--remotes={}'.format(remote),
            )).decode().strip()
            if not ancestors:
                continue
            else:
                first_ancestor = ancestors.splitlines()[0]
                cmd = ('git', 'rev-list', '--max-parents=0', local_sha)
                roots = set(subprocess.check_output(cmd).decode().splitlines())
                if first_ancestor in roots:
                    # pushing the whole tree including root commit
                    opts = ('--all-files',)
                else:
                    cmd = ('git', 'rev-parse', '{}^'.format(first_ancestor))
                    source = subprocess.check_output(cmd).decode().strip()
                    opts = ('--origin', local_sha, '--source', source)
    if opts:
        return opts
    else:
        # An attempt to push an empty changeset
        raise EarlyExit()

def _opts(stdin):
    fns = {
        'prepare-commit-msg': lambda _: ('--commit-msg-filename', sys.argv[1]),
        'commit-msg': lambda _: ('--commit-msg-filename', sys.argv[1]),
        'pre-commit': lambda _: (),
        'pre-push': _pre_push,
    }
    stage = HOOK_TYPE.replace('pre-', '')
    return ('--config', CONFIG, '--hook-stage', stage) + fns[HOOK_TYPE](stdin)

if sys.version_info < (3, 7):  # https://bugs.python.org/issue25942
    def _subprocess_call(cmd):  # this is the python 2.7 implementation
        return subprocess.Popen(cmd).wait()
else:
    _subprocess_call = subprocess.call

def main():
    retv, stdin = _run_legacy()
    try:
        _validate_config()
        return retv | _subprocess_call(_exe() + _opts(stdin))
    except EarlyExit:
        return retv
    except FatalError as e:
        print(e.args[0])
        return 1
    except KeyboardInterrupt:
        return 1

if __name__ == '__main__':
    exit(main())
"""


const dockerfileTemplate = """
FROM alpine:latest
RUN apk add --no-cache ca-certificates gnupg tar xz bzip2 coreutils dpkg findutils gcc libc-dev linux-headers make openssl readline sqlite zlib tk tcl ncurses gdbm
ENV LANG C.UTF-8
ENV PYTHON_VERSION 3.7
ENV PYTHON_PIP_VERSION 3.7
ENV PATH /usr/local/bin:$PATH
# Do your magic here. Download and Compile Python...
"""


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


const nimpyTemplate = """import os, strutils, nimpy

proc function(a, b: int): auto {.exportpy.} =
  ## Documentation comment, Markdown/ReSTructuredText/PlainText, generates HTML.
  a + b  # Comment, ignored by compiler.       https://github.com/yglukhov/nimpy
"""


##############################################################################


addHandler(newConsoleLogger(fmtStr = ""))
addHandler(newRollingFileLogger(fmtStr = verboseFmtStr))
setControlCHook((proc {.noconv.} = quit" CTRL+C Pressed, shutting down, bye! "))

var script: string

let
  py3 = findExe"python3"
  headerJson = newHttpHeaders(hdrJson)
  headerXml = newHttpHeaders(hdrXml)
  user = getEnv"USER"

using
  generateScript: bool
  query: Table[string, seq[string]]
  args, classifiers, keywords: seq[string]
  projectName, projectVersion, packageName, user, releaseVersion: string
  destDir, name, version, license, summary, description, author: string
  downloadurl, authoremail, maintainer, maintaineremail, filename: string
  homepage, md5_digest, username, password, destination: string

{.passC: "-flto -ffast-math -march=native -mtune=native -fsingle-precision-constant", passL: "-s".}
