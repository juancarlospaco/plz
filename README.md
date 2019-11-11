# PLZ

- PLZ [Python PIP](https://pypi.org) alternative.

<img src="https://raw.githubusercontent.com/juancarlospaco/plz/master/python-wat.png" width="256" height="256" title="plz for Linux! (1 Mb, 1 file)">

![](https://img.shields.io/github/languages/count/juancarlospaco/plz?logoColor=green&style=for-the-badge)
![](https://img.shields.io/github/languages/top/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/stars/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/maintenance/yes/2019?style=for-the-badge)
![](https://img.shields.io/github/languages/code-size/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/issues-raw/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/issues-pr-raw/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/commit-activity/y/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/github/last-commit/juancarlospaco/plz?style=for-the-badge)
![](https://img.shields.io/liberapay/patrons/juancarlospaco?style=for-the-badge)
![](https://img.shields.io/twitch/status/juancarlospaco?style=for-the-badge)


# Use

```console
$ plz install pre-commit   # Install 1 or more packages
$ plz uninstall pre-commit # Uninstall 1 or more packages
$ plz reinstall pre-commit # Reinstall 1 or more packages
$ plz download pre-commit  # Download 1 or more packages
$ plz hash file.py         # Show SHA CheckSum of file/package
$ plz open file.py         # Open a module in your default code editor
$ plz backup               # Compressed signed backup of file/package (GPG+SHA512)
$ plz init                 # New Python project template (Interactive)
$ plz stats                # PyPI official service status report
$ plz newpackages          # List all the new Packages uploaded to PyPI recently
$ plz lastupdates          # List all existing Packages updated on PyPI recently
$ plz lastjobs             # List all new Job Posts updated on Python recently
$ plz userpackages         # List all existing Packages by User (Interactive)
$ plz latestversion        # Show the Latest Version of a PYPI Package (SemVer)
$ plz forceInstallPip      # Force install PIP on arbitrary folder (get-pip.py)
$
$ plz --enUsUtf8           # Force Encoding to UTF-8 and Language to English
$ plz --cleanpyc           # Clean all __pycache__ and *.pyc
$ plz --cleanpypackages    # Clean all __pypackages__
$ plz --cleantemp          # Clean all temporary folder.
$ plz --cleanpipcache      # Clean all PIP Cache folder.
$ plz --cleanvenvs         # Clean Virtualenvs (interactive, asks y/n 1-by-1).
$ plz --publicip           # Show your Public IP Address (Internet connectivity check).
$ plz --suicide            # Deletes itself permanently and exit (single file binary).
$ plz --debug              # Show Debug info (for Developers and Bug Reporting).
$ plz --version            # Show Version
$ plz --help               # Show Help
```

- For more info see the Help.


# Install

- [**Download it!.**](https://github.com/juancarlospaco/plz/releases)
- ~`1` MegaByte single-file standalone native binary executable, no install required, just copy it and run it.

#### Compile

<details>

<summary> Manually compiling is usually not needed, but if you want to do it </summary>

```console
$ nimble install https://github.com/juancarlospaco/plz.git
```

Or even more manual:

```console
$ git clone https://github.com/juancarlospaco/plz.git
$ cd plz
$ nim c plz/plz.nim
```

</details>


# Uninstall

- Delete it.


# Dependencies

- It does NOT depend on `pip` (Not a `pip` wrapper), it can work with `pip` completely broken, works on Alpine.


# Platforms

- ✅ Linux (Use Docker for Windows or Docker for Mac on ther OS).


# Features

- 1 Megabyte, 1 file.
- 0 Dependencies.
- The only PIP alternative in the world that just works even with PIP/Python/Virtualenv completely broken.
- Works fully independently self-contained standalone application.
- [Design by Contract, Contract Programming](https://dev.to/juancarlospaco/design-by-contract-immutability-side-effects-and-gulag-44fk).
- Security Hardened by default (based from [Gentoo Hardened](https://wiki.gentoo.org/wiki/Hardened_Gentoo) and [Debian Hardened](https://wiki.debian.org/Hardening), checked with [`hardening-check`](https://bitbucket.org/Alexander-Shukaev/hardening-check)).
- Coded following the [Power of 10: NASA Coding guidelines for safety-critical code](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code#Rules) (as much as possible).
- No Regular Expressions used, [No Regex Bugs and Vulnerabilities](https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019).
- Compiled machine code performance, as fast as optimized hand crafted C.
- Faster than Cython, Pypy, Go, NodeJS, D.
- High performance with low resources (RPi, VPS, cloud, old pc, etc).
- Immutable programming, No Global Mutable State.
- Single file binary, it can even delete itself after use.
- No Installs, no setups, just copy & paste and run (even on Alpine).
- New Python project skeleton creator (supports GitHub, Pre-Commit, etc).
- Self-Linting, Self-Documented.
- Real Inferred Static Typed.
- Colored output on the Terminal.
- Project skeleton creator to create your own new Python projects.
- Wont save any passwords, databases, keys, secrets, to disk nor Internet.
- No temporary folders nor files.
- Optimize Python native module binary (PIP Wont optimize binaries).
- Not meant as a drop-in replacement for anything pre-existing.
- 1 language for the whole stack, including high performance modules.
- No Global Interpreter Lock.
- No user Tracking Analytics by default.
- No YAML used on the Core, No YAML Vulnerabilities (you can still use YAML).
- Tiny single file source code.
- No `node_modules`.
- DRY code via Templates.


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

- This requires Nim ?.

No.


# API Bugs

From XML-RPC API Server-side this endpoints wont work anymore (Not my Bug):

- `release_downloads`, `top_packages`, `updated_releases`, `changed_packages`.
- Sometimes PYPI returns Python Tracebacks as strings on the body of the response.
- Its a big project, some features are not yet implemented as App, but source contains the functionanity whatsoever.
- We tried to implement fully parallel install of packages, but because of the way Python packages work, they need to be installed sequentially whatsoever.


## Stars

[![Stars over time](https://starchart.cc/juancarlospaco/plz.svg)](https://starchart.cc/ThomasTJdev/nim_websitecreator "Star PLZ on GitHub!")


#### Notes

- http://tonsky.me/blog/disenchantment
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


![](https://raw.githubusercontent.com/juancarlospaco/plz/master/pepehack.gif "Work in progress!")


[  ⬆️  ⬆️  ⬆️  ⬆️  ](#plz "Go to top")
