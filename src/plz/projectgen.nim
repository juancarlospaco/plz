import os, times, rdstdin, strutils

template pySkeleton() =
  ## Creates the skeleton (folders and files) for a New Python project.
  var namex = create(string, sizeOf string)
  namex[] = readLineFromStdin"New Python project name?: ".strip.normalize
  assert namex[].len > 1, "Name must not be empty string"
  discard existsOrCreateDir(namex[])
  discard existsOrCreateDir(namex[] / namex[])
  writeFile(namex[] / namex[] / "__init__.py", "print('Hello World')\n")
  writeFile(namex[] / namex[] / "__main__.py", "\nprint('Main Module')\n")
  writeFile(namex[] / namex[] / "__version__.py", "__version__ = '0.0.1'\n")
  writeFile(namex[] / namex[] / "main.nim", nimpyTemplate)
  if readLineFromStdin("Generate helper scripts and dist? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / namex[] / "dist")
    discard existsOrCreateDir(namex[] / namex[] / "dist" / namex[] & ".egg-info")
    writeFile(namex[] / namex[] / "dist" / namex[] & ".egg-info" / "top_level.txt", "")
    writeFile(namex[] / namex[] / "dist" / namex[] & ".egg-info" / "dependency_links.txt", "")
    writeFile(namex[] / namex[] / "dist" / namex[] & ".egg-info" / "requires.txt", "")
    writeFile(namex[] / namex[] / "dist" / namex[] & ".egg-info" / "zip-safe", "")
    writeFile(namex[] / namex[] / "dist" / namex[] & ".egg-info" / "PKG-INFO", pkgInfoTemplate)
    writeFile(namex[] / "upload2pypi.sh", "twine upload --verbose --repository-url 'https://test.pypi.org/legacy/' " & namex[] / "dist/*.zip\n")
    writeFile(namex[] / "package4pypi.sh", "cd " & namex[] / "dist && zip -9 -T -v -r " & namex[] & ".zip *\n")
    writeFile(namex[] / "install2local4testing.sh", "pip --verbose install " & namex[] / "dist/*.zip\n")
  if readLineFromStdin("Generate Unitests files on ./tests/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "tests")
    writeFile(namex[] / "tests" / "__init__.py", testTemplate)
  if readLineFromStdin("Generate Documentation files on ./docs/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "docs")
    writeFile(namex[] / "docs" / "documentation.md", "# " & namex[] & "\n\n")
  if readLineFromStdin("Generate Example files on ./examples ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "examples")
    writeFile(namex[] / "examples" / "example.py", "# -*- coding: utf-8 -*-\n\nprint('Example')\n")
  if readLineFromStdin("Generate DevOps files on ./devops/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "devops")
    writeFile(namex[] / "devops" / "Dockerfile", "")
    writeFile(namex[] / "devops" / namex[] & ".service", serviceTemplate)
    writeFile(namex[] / "devops" / "build_package.sh", "python3 setup.py sdist --formats=zip\n")
    writeFile(namex[] / "devops" / "upload_package.sh", "twine upload .\n")
    writeFile(namex[] / "devops" / "pyc_clean.sh", "rm --verbose --force --recursive *.pyc\n")
  if readLineFromStdin("Generate GitHub files including GitHub Actions on ./github/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / ".github")
    discard existsOrCreateDir(namex[] / ".github" / "workflows")
    discard existsOrCreateDir(namex[] / ".github/ISSUE_TEMPLATE")
    discard existsOrCreateDir(namex[] / ".github/PULL_REQUEST_TEMPLATE")
    writeFile(namex[] / ".github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md", "")
    writeFile(namex[] / ".github/PULL_REQUEST_TEMPLATE/PULL_REQUEST_TEMPLATE.md", "")
    writeFile(namex[] / ".github/FUNDING.yml", "")
    writeFile(namex[] / ".github" / "workflows" / "build.yml", "")
  if readLineFromStdin("Generate .gitignore file? (y/N): ") == "y":
    writeFile(namex[] / ".gitignore", "*.pyc\n*.pyd\n*.pyo\n*.egg-info\n*.egg\n*.log\n__pycache__\n*.c\n*.h\n*.o\n")
    discard existsOrCreateDir(namex[] / ".hooks")
  if readLineFromStdin("Generate .gitattributes file? (y/N): ") == "y":
    writeFile(namex[] / ".gitattributes", "*.py linguist-language=Python\n*.nim linguist-language=Nim\n")
  if readLineFromStdin("Generate optional files? (y/N): ") == "y":
    writeFile(namex[] / "MANIFEST.in", "include main.py\nrecursive-include *.py\n")
    writeFile(namex[] / "requirements.txt", "")
    writeFile(namex[] / "setup.cfg", setupCfg)
    writeFile(namex[] / "Makefile", "")
    writeFile(namex[] / "setup.py", "# -*- coding: utf-8 -*-\nfrom setuptools import setup\nsetup() # Edit setup.cfg,not here!.\n")
    let ext = create(string, sizeOf string)
    ext[] = if readLineFromStdin("Use Markdown (MD) instead of ReSTructuredText (RST)? (y/N): ") == "y": ".md" else: ".rst"
    writeFile(namex[] / "LICENSE" & ext[], "See https://tldrlegal.com/licenses/browse\n")
    writeFile(namex[] / "CODE_OF_CONDUCT" & ext[], "")
    writeFile(namex[] / "CONTRIBUTING" & ext[], "")
    writeFile(namex[] / "AUTHORS" & ext[], "# Authors\n\n- " & getEnv"USER" & "\n")
    writeFile(namex[] / "README" & ext[], "# " & namex[] & "\n")
    writeFile(namex[] / "CHANGELOG" & ext[], "# 0.0.1\n\n- First initial version of " & namex[] & "created at " & $now())
    dealloc ext
  setCurrentDir namex[]
  dealloc namex
  if readLineFromStdin("Run 'git init .' on the project folder? (y/N): ") == "y":
    if execShellCmd("git init .") == 0:
      if readLineFromStdin("Run 'git add .' on the project folder? (y/N): ") == "y":
        if execShellCmd("git add .") == 0:
          if readLineFromStdin("Run 'git commit -a' on the project folder? (y/N): ") == "y":
            if execShellCmd("git commit -am 'init'") == 0:
              if readLineFromStdin("Run 'git remote add origin ...' to add 1 Remote URL? (y/N): ") == "y":
                if execShellCmd("git remote add origin " & readLineFromStdin("Git Remote URL?: ").strip) == 0:
                  if readLineFromStdin("Run 'git fetch --all' on the project folder? (y/N): ") == "y":
                    echo execShellCmd("git fetch --all") == 0
  quit("Created a new Python project skeleton, happy hacking, bye...\n", 0)
