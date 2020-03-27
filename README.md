# PLZ

- PLZ [Python PIP](https://pypi.org) alternative.

<img src="https://raw.githubusercontent.com/juancarlospaco/plz/master/python-wat.png" width="256" height="256" title="plz for Linux! (1 file, 1 Mb)">

![](https://img.shields.io/github/languages/count/juancarlospaco/plz?logoColor=green&style=for-the-badge)
![](https://img.shields.io/github/languages/top/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/stars/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/maintenance/yes/2020?style=for-the-badge)
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
$ plz open file.py         # Open a module in your default code editor
$ plz backup /folder/      # Compressed signed backup of file/package (GPG+SHA512)
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
$
$ plz --enUsUtf8           # Force Encoding to UTF-8 and Language to English
$ plz --cleanpyc           # Clean all __pycache__ and *.pyc
$ plz --cleanpypackages    # Clean all __pypackages__
$ plz --cleantemp          # Clean all temporary folder.
$ plz --cleanpipcache      # Clean all PIP Cache folder.
$ plz --cleanvenvs         # Clean Virtualenvs (interactive, asks Y/N 1-by-1).
$ plz --publicip           # Show your Public IP Address (Internet connectivity check).
$ plz --log=file.log       # Full path to a verbose local log file.
$ plz --backuplogs         # Compress old PLZ Logs at exit, to save disk resources.
$ plz --putenv:key=val     # Set an environment variable "KEY=Value", can be repeated.
$ plz --nice20             # Runs with "nice = 20" (CPU Priority, smooth priority).
$ plz --suicide            # Deletes itself permanently and exit (single file binary).
$ plz --dump               # Show system info JSON and quit (for Developers and Bug Reporting).
$ plz --version            # Show Version
$ plz --help               # Show Help
```


# Features

- Designed for Docker or Alpine usage.
- 1 Megabyte, 1 file, 0 Dependencies, ~500 Lines of code.
- Install, uninstall, reinstall, download, upload to PyPI, etc.
- Real Inferred Strong Static Typing with [Z3 Theorem Prover](https://en.wikipedia.org/wiki/Z3_Theorem_Prover).
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

**TODO, WIP:**

![](https://raw.githubusercontent.com/juancarlospaco/plz/master/pepehack.gif "Work in progress!")

The only thing missing to fully replace PIP is to parse versions of each package,
currently it only installs the latest version of each package,
the feature works but is not connected with the CLI arguments, the rest is working.


# Install

- [**Download it!.**](https://github.com/juancarlospaco/plz/releases)


# Uninstall

- Delete it.


# Dependencies

- It does NOT depend on `pip` (Not a `pip` wrapper), it can work with `pip` completely broken.


# Requisites

- Python 3.
- 64 Bit.


# FAQ

- This requires Cython ?.

No.

- This runs on Python2 ?.

I dunno. (Not supported)

- This runs on 32Bit ?.

I dunno. (Not supported)

- This works with SSL ?.

Yes.

- This is a drop-in replacement of PIPEnv ?.

No.


# Python Bugs

From XML-RPC API Server-side this endpoints wont work anymore (Not my Bug):

- `release_downloads`, `top_packages`, `updated_releases`, `changed_packages`.
- Sometimes PYPI returns Python Tracebacks as strings on the body of the response.
- We tried to implement fully parallel install of packages, but because of the way Python packages work, they need to be installed sequentially whatsoever.


## Stars

[![Stars over time](https://starchart.cc/juancarlospaco/plz.svg)](https://starchart.cc/ThomasTJdev/nim_websitecreator "Star PLZ on GitHub!")


#### Notes

<details>

- http://tonsky.me/blog/disenchantment
- https://medium.com/telnyx-engineering/rip-pipenv-tried-too-hard-do-what-you-need-with-pip-tools-d500edc161d4
- https://github.com/pypa/pipenv/issues/4058#issue-537298446
- https://chriswarrick.com/blog/2018/07/17/pipenv-promises-a-lot-delivers-very-little/
- https://old.reddit.com/r/Python/comments/chkah3/is_pipenv_dead_why_has_the_project_stopped/
- https://np.reddit.com/r/Python/comments/8jd6aq/why_is_pipenv_the_recommended_packaging_tool_by/
- https://github.com/pypa/pipenv/commit/6d77e4a0551528d5d72d81e8a15da4722ad82f26
- https://github.com/pypa/pipenv/commit/1c956d37e6ad20babdb5021610b2ed2c9c4203f2
- https://github.com/pypa/pipenv/commit/e3c72e167d21b921bd3bd89d4217b04628919bb2
- https://github.com/mitsuhiko/pipsi#pipsi (Dead Project)

Quote from PIPEnv Project:

> pipenv release cadence came to a super dramatic halt because of a lot of upstream issues
> (pip broke, setuptools broke, then pip and setuptools both released breaking fixes,
> and we have about 15 dependencies which I personally maintain).

</details>


[  ⬆️  ⬆️  ⬆️  ⬆️  ](#plz "Go to top")
