<!--

# PLZ

- PLZ [Python PIP](https://pypi.org) faster alternative.


# Use

```console
plz install pre-commit   # Install 1 or more packages
plz uninstall pre-commit # Uninstall 1 or more packages
plz reinstall pre-commit # Reinstall 1 or more packages
plz download pre-commit  # Download 1 or more packages
plz hash file.py         # Show SHA CheckSum of file/package
plz init                 # New Python project template (Interactive)
plz --version            # Show Version
plz --help               # Show Help
```

- For more info see the Help.


# Features

- The only PIP alternative in the world that just works even with PIP/Python/Virtualenv completely broken.
- Works fully independently self-contained standalone application.
- [Design by Contract, Contract Programming](https://dev.to/juancarlospaco/design-by-contract-immutability-side-effects-and-gulag-44fk).
- Security Hardened by default (based from [Gentoo Hardened](https://wiki.gentoo.org/wiki/Hardened_Gentoo) and [Debian Hardened](https://wiki.debian.org/Hardening), checked with [`hardening-check`](https://bitbucket.org/Alexander-Shukaev/hardening-check)).
- Coded following the [Power of 10: NASA Coding guidelines for safety-critical code](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code#Rules) (as much as possible).
- No Regular Expressions used on the Core, [No Regex Bugs and Vulnerabilities](https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019).
- Compiled machine code performance, as fast as optimized hand crafted C.
- Faster than Cython, Pypy, Go, NodeJS, D.
- High performance with low resources (RPi, VPS, cloud, old pc, etc).
- Immutable programming, No Global Mutable State.
- Single file binary, it can even delete itself after use.
- Single file source code.
- 0 Dependencies.
- ~750Kb file size.
- No Installs, no setups, just copy & paste and run (even on Alpine).
- New Python project skeleton creator (GitHub, Pre-Commit, etc supports).
- DRY code via Templates.
- Self-Linting, Self-Documented.
- Real Inferred Static Typed.
- Colored output on the Terminal.
- Project skeleton creator to create your own new Python projects.
- Wont save any passwords, databases, keys, secrets, to disk nor Internet.
- No temporary folders nor files.
- Optimize Python native module binary (PIP Wont optimize binaries,it left all Debugging on)
- Not meant as a drop-in replacement for anything pre-existing.
- 1 language for the whole stack, including high performance modules without requiring C.
- No Global Interpreter Lock.
- No user Tracking Analytics by default.
- No YAML used on the Core, No YAML Vulnerabilities (you can still use YAML).
- No `node_modules/`.
- KISS, Packaging should be KISS.


# Install

- [**Download it!.**](https://github.com/juancarlospaco/plz/releases)
- ~`1` MegaByte single-file standalone native binary executable, no install required, just copy it and run it.

#### Compile

<details>

<summary> Manually compiling is usually not needed, but if you want to do it </summary>

```console
$ nimble install https://github.com/juancarlospaco/plz.git
```

</details>


# Uninstall

- Delete it.


# Dependencies

- **None**


# Platforms

- ✅ Linux
- ✅ Windows
- ✅ Mac
- ✅ Raspberry Pi
- ✅ ARM
- ✅ BSD
- ✅ Anything that can compile C.


# FAQ

- This requires Cython ?.

No.

- This requires DotNet Frameworks on Windows ?.

No.

- This runs on Python2 ?.

I dunno. (Not supported)

- This runs on 32Bit ?.

I dunno. (Not supported)

- This works on Mac?.

Yes.

- This works with SSL ?.

Yes.

- This requires Nim ?.

No.


# API Bugs

From XML-RPC API Server-side this endpoints wont work anymore (Not my Bug):

- `release_downloads`, `top_packages`, `updated_releases`, `changed_packages`.
- Sometimes it returns Python Tracebacks as strings on the body of the response.
- Since is a big project, some features are not yet implemented as App,
but the source contains the functionanity whatsoever.


#### Notes

- http://tonsky.me/blog/disenchantment
- https://chriswarrick.com/blog/2018/07/17/pipenv-promises-a-lot-delivers-very-little/

-->
