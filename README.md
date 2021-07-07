# PLZ

- PLZ [Python PIP](https://pypi.org) alternative.

<img src="https://raw.githubusercontent.com/juancarlospaco/plz/master/python-wat.png" width="256" height="256" title="plz for Linux! (1 file, 1 Mb)">

![](https://img.shields.io/github/languages/count/juancarlospaco/plz?logoColor=green&style=for-the-badge)
![](https://img.shields.io/github/languages/top/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/stars/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/languages/code-size/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/issues-raw/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/issues-pr-raw/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/last-commit/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/liberapay/patrons/juancarlospaco?style=for-the-badge)
![CI](https://github.com/juancarlospaco/plz/workflows/CI/badge.svg)


# Use

```console
$ plz install pre-commit   # Install 1 or more packages
$ plz uninstall pre-commit # Uninstall 1 or more packages
$ plz reinstall pre-commit # Reinstall 1 or more packages
$ plz download pre-commit  # Download 1 or more packages
$ plz hash file.py         # Show SHA CheckSum of file/package
$ plz init                 # New Python project template (Interactive)
$ plz stats                # PyPI official service status report
$ plz newpackages          # List all the new Packages uploaded to PyPI recently
$ plz lastupdates          # List all existing Packages updated on PyPI recently
$ plz lastjobs             # List all new Job Posts updated on Python recently
$ plz userpackages         # List all existing Packages by User (Interactive)
$ plz latestversion        # Show the Latest Version of a PYPI Package (SemVer)
$ plz forceInstallPip      # Force install PIP on arbitrary folder (get-pip.py)
$ plz doc file.md          # Markdown/ReSTructuredText to HTML  (MD/RST can be mixed).
$ plz doc2latex file.md    # Markdown/ReSTructuredText to Latex (MD/RST can be mixed).
$ plz doc2json file.md     # Markdown/ReSTructuredText to JSON  (MD/RST can be mixed).
$ plz upload packg-1.0.zip # Similar to "twine upload" (Interactive,asks user,wont need Twine).
$ plz parserequirements    # Parse a requirements file, print it to stdout (Linter,Debug,etc).
$ plz fakecommits          # Generate "Fake" Git commits (Restart CI,trigger GitHub Actions,etc).
$ plz bug                  # Python Bug Report Assistant (Interactive).
$
$ plz --python="/path/to/python"  # Full path to a Python executable to use, defaults to autodetect.
$ plz --dotenv="/path/to/.env"    # Full path to a Type-safe DotEnv file.
$ plz --cleanpyc           # Clean all __pycache__ and *.pyc
$ plz --cleanpypackages    # Clean all __pypackages__
$ plz --cleantemp          # Clean all temporary folder.
$ plz --cleanpipcache      # Clean all PIP Cache folder.
$ plz --cleanvenvs         # Clean Virtualenvs (interactive, asks Y/N 1-by-1).
$ plz --publicip           # Show your Public IP Address (Internet connectivity check).
$ plz --log=file.log       # Full path to a verbose local log file.
$ plz --putenv:key=val     # Set an environment variable "KEY=Value", can be repeated.
$ plz --suicide            # Deletes itself permanently and exit (single file binary).
$ plz --dump               # Show system info JSON and quit (for Developers and Bug Reporting).
$ plz --version            # Show Version
$ plz --help               # Show Help
```


# Interactive Python Project Creator

<details>

![](https://raw.githubusercontent.com/juancarlospaco/plz/master/project_creator.png)

</details>

# Requirements Parser for debug

<details>

![](https://raw.githubusercontent.com/juancarlospaco/plz/master/requirements_parser.png)

</details>


# Type-safe DotEnv

Type-safe `.env` file is just a `.env` but Typed.

Types are enforced via a comment, so it is still a "vanilla" `.env`.

Type-safe `.env` file can be used with unsafe `.env` parsers, legacy parsers will ignore the comment.

Keys must be a non-empty ASCII string `[a-zA-Z0-9_]`, keys are validated. Key-Value separator must be `=`.

Parses the same `.env` file from the vanilla implementation tests.

Several orders of magnitude faster than the vanilla implementation. Implementation is ~ 50 lines of code.

Example:

```ini
# This is a comment
DB_HOST=localhost  # string
DB_USER=root       # string
DB_PASS="123"      # string
DB_TIMEOUT=42      # int
DELAY=3.14         # float
ACTIVE=true        # bool
```


# Features

- Python `1.x`, `2.x`, `3.x` support.
- Private PYPI custom URL.
- No configurations needed.
- No `PATH` pollution.
- Self-Bootstrapping, no dependency on system PIP, no dependency on system Python.
- 1 Megabyte, 1 file, 0 Dependencies.
- Designed for Docker or Alpine usage.
- Install, uninstall, reinstall, download, upload to PyPI, etc.
- Real Inferred Strong Static Typing.
- No Garbage Collector (Rust-like memory management).
- Immutable programming, No Global Mutable State.
- The only PIP alternative in the world that just works even with PIP/Python/Virtualenv completely broken.
- Compiled machine code performance, as fast as optimized hand crafted C.
- High performance with low resources (RPi, VPS, cloud, old pc, etc).
- Single file binary, it can even delete itself after use.
- No Installs, no setups, just copy & paste and run (even on Alpine).
- Colored output on the Terminal.
- Project skeleton creator to create your own new Python projects.
- Wont save any passwords, databases, keys, secrets, to disk nor Internet.
- No temporary folders nor files.
- Not meant as a drop-in replacement for anything pre-existing.
- Tiny single file source code (not counting string static constants).
- Self-Documentation Generator outputs HTML, PDF, JSON.
- Works fully independently self-contained standalone application.
- Fast startup time.

**WIP:**

![](https://raw.githubusercontent.com/juancarlospaco/plz/master/pepehack.gif "Work in progress!")


# Uninstall

- Delete it.


# Dependencies

- It does NOT depend on `pip` (Not a `pip` wrapper), it can work with `pip` completely broken.


# Requisites

- Python 64Bit.


# FAQ

- How to use a Private PYPI custom URL ?.

Compile adding the argument ` -d:pypiApiUrl="http://url-here.io" `.

- This requires Cython ?.

No.

- This is a drop-in replacement of X ?.

No.

- Whats "Generate Fake Git Commits" ?.

Sometimes you may need to create commits to restart CI, trigger GitHub Actions, Git Hooks, etc
but you dont have anything new to commit, that feature can create empty commits to force-trigger the Git service.

Some Git services do not trigger for new repos with 1 or 2 commits,
that feature can create empty commits to force-start the Git service.


# Python Bugs

From XML-RPC API Server-side this endpoints wont work anymore (Not my Bug):

- `release_downloads`, `top_packages`, `updated_releases`, `changed_packages`.
- Sometimes PYPI returns Python Tracebacks as strings on the body of the response.
- We tried to implement fully parallel install of packages, but because of the way Python packages work, they need to be installed sequentially whatsoever.


## Stars

[![Stars over time](https://starchart.cc/juancarlospaco/plz.svg)](https://starchart.cc/ThomasTJdev/nim_websitecreator "Star PLZ on GitHub!")


<details>
  <summary>Notes</summary>

- http://tonsky.me/blog/disenchantment
- https://medium.com/telnyx-engineering/rip-pipenv-tried-too-hard-do-what-you-need-with-pip-tools-d500edc161d4
- http://arindampaul.blogspot.com/2016/03/python-tips-avoid-pip-as-much-as.html
- https://github.com/pypa/pipenv/issues/4058#issue-537298446
- https://chriswarrick.com/blog/2018/07/17/pipenv-promises-a-lot-delivers-very-little/
- https://old.reddit.com/r/Python/comments/chkah3/is_pipenv_dead_why_has_the_project_stopped/
- https://np.reddit.com/r/Python/comments/8jd6aq/why_is_pipenv_the_recommended_packaging_tool_by/
- https://github.com/pypa/pipenv/commit/6d77e4a0551528d5d72d81e8a15da4722ad82f26
- https://github.com/pypa/pipenv/commit/1c956d37e6ad20babdb5021610b2ed2c9c4203f2
- https://github.com/pypa/pipenv/commit/e3c72e167d21b921bd3bd89d4217b04628919bb2
- https://github.com/mitsuhiko/pipsi#pipsi (Dead Project)
- https://github.com/zachtylr21/pyp#pyp
- https://www.python.org/dev/peps/pep-0650
- https://pip.pypa.io/en/stable/news/#id1
- https://discuss.python.org/t/what-to-do-about-gpus-and-the-built-distributions-that-support-them/7125

Quote from PIPEnv Project:

> pipenv release cadence came to a super dramatic halt because of a lot of upstream issues
> (pip broke, setuptools broke, then pip and setuptools both released breaking fixes,
> and we have about 15 dependencies which I personally maintain).

Quote from PIP Project:

> Due to lack of interest and maintenance, 'pip bundle' and support for installing files is now deprecated.

Important, near year 2021, the PyPI server started responding empty responses and error messages,
but with HTTP status 200 OK, to PIP alternatives that are not the official PIP, the error message said
`HTTPTooManyRequests: The action could not be performed because there were too many requests by the client. Limit may reset in 1 seconds.`
and your client has to wait >1 second per request, even for empty responses, and sometimes retries fail anyway,
this looks kinda intentional, maybe to make it look like PIP is the fastest or something like that ?.

All Python tools dropped support for Python `2.7` and `3.5`, some only support `3.8` as of ~2021.

As of 2021 PYPI says that the Search API of XML RPC is now "permanently disabled"
https://status.python.org/incidents/grk0k7sz6zkp


</details>


[  ⬆️  ⬆️  ⬆️  ⬆️  ](#plz "Go to top")
