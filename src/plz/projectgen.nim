
template pySkeleton*() =
  ## Creates the skeleton (folders and files) for a New Python project.
  var name, ext: string
  while not(name.len > 0 and name.len < 99):
    name = readLineFromStdin"New Python project name?: ".strip.toLowerAscii.replace(" ", "_")
  discard existsOrCreateDir(name)
  discard existsOrCreateDir(name / name)
  writeFile(name / name / "__init__.py", "print('Hello World')\n")
  writeFile(name / name / "__main__.py", "\nprint('Main Module')\n")
  writeFile(name / name / "__version__.py", "__version__ = '0.0.1'\n")
  writeFile(name / name / name & ".py", "\nprint('Hello World')\n")
  writeFile(name / name / "main.nim", nimpyTemplate)
  if readLineFromStdin("Generate Unitests files on ./tests/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "tests")
    writeFile(name / "tests" / "__init__.py", testTemplate)
  if readLineFromStdin("Generate Documentation files on ./docs/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "docs")
    writeFile(name / "docs" / "documentation.md", "# " & name & "\n\n")
    writeFile(name / "docs" / "generate_documentation.sh", "plz doc2html documentation.md ; plz doc2latex documentation.md\n")
  if readLineFromStdin("Generate Example files on ./examples/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "examples")
    writeFile(name / "examples" / "example.py", "# -*- coding: utf-8 -*-\n\nprint('Example')\n")
  if readLineFromStdin("Generate DevOps files on ./devops/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "devops")
    writeFile(name / "devops" / "Dockerfile", "")
    writeFile(name / "devops" / name & ".service", serviceTemplate)
  if readLineFromStdin("Generate GitHub files including GitHub Actions on ./github/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / ".github")
    discard existsOrCreateDir(name / ".github" / "workflows")
    discard existsOrCreateDir(name / ".github/ISSUE_TEMPLATE")
    discard existsOrCreateDir(name / ".github/PULL_REQUEST_TEMPLATE")
    writeFile(name / ".github/ISSUE_TEMPLATE/ISSUE_TEMPLATE.md", "")
    writeFile(name / ".github/PULL_REQUEST_TEMPLATE/PULL_REQUEST_TEMPLATE.md", "")
    writeFile(name / ".github/FUNDING.yml", "")
    writeFile(name / ".github" / "workflows" / "build.yml", "")
  if readLineFromStdin("Generate .gitignore file? (y/N): ") == "y":
    writeFile(name / ".gitignore", gitignoreTemplate)
    discard existsOrCreateDir(name / ".hooks")
  if readLineFromStdin("Generate .gitattributes file? (y/N): ") == "y":
    writeFile(name / ".gitattributes", "*.py linguist-language=Python\n*.nim linguist-language=Nim\n")
  if readLineFromStdin("Generate setup.py ? (y/N): ") == "y":
    writeFile(name / "tox.ini", "")
    writeFile(name / "setup.cfg", setupCfg)
    writeFile(name / "requirements.txt", "")
    writeFile(name / "setup.py", "# -*- coding: utf-8 -*-\nfrom setuptools import setup\nsetup() # Edit setup.cfg,not here!.\n")
  if readLineFromStdin("Generate .editorconfig ? (y/N): ") == "y":
    writeFile(name / ".editorconfig", editorconfigTemplate)
  if readLineFromStdin("Generate MANIFEST.in ? (y/N): ") == "y":
    writeFile(name / "MANIFEST.in", manifestTemplate)
  if readLineFromStdin("Generate Makefile ? (y/N): ") == "y":
    writeFile(name / "Makefile", makefileTemplate)
  if readLineFromStdin("Generate Arch Linux PKGBUILD ? (y/N): ") == "y":
    writeFile(name / "PKGBUILD", pkgbuildTemplate)
  if readLineFromStdin("Generate Ubuntu Linux and Debian Linux packaging files on ./debian/ ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "debian")
    discard existsOrCreateDir(name / "debian" / "source")
    writeFile(name / "debian" / "rules", debianRules)
    writeFile(name / "debian" / "control", debianControl)
    writeFile(name / "debian" / "compat", "9\n")
    writeFile(name / "debian" / "changelog", debianChangelog)
    writeFile(name / "debian" / "source" / "options", """extend-diff-ignore="\.egg-info/\" """)
    writeFile(name / "debian" / "source" / "format", "3.0 (quilt)\n")
  if readLineFromStdin("Generate README,LICENSE,CHANGELOG,etc ? (y/N): ") == "y":
    ext = if readLineFromStdin("Use Markdown (MD) instead of ReSTructuredText (RST)? (y/N): ") == "y": ".md" else: ".rst"
    writeFile(name / "LICENSE" & ext, "See https://tldrlegal.com/licenses/browse\n")
    writeFile(name / "CODE_OF_CONDUCT" & ext, "")
    writeFile(name / "CONTRIBUTING" & ext, "")
    writeFile(name / "AUTHORS" & ext, "# Authors\n\n- " & getEnv"USER" & "\n")
    writeFile(name / "README" & ext, "# " & name & "\n")
    writeFile(name / "CHANGELOG" & ext, "# 0.0.1\n\n- First initial version of " & name & " created at " & $now())
  if readLineFromStdin("Generate extra helper scripts and dist? (y/N): ") == "y":
    discard existsOrCreateDir(name / "dist")
    discard existsOrCreateDir(name / "dist" / name & ".egg-info")
    writeFile(name / "dist" / name & ".egg-info" / "top_level.txt", "")
    writeFile(name / "dist" / name & ".egg-info" / "dependency_links.txt", "")
    writeFile(name / "dist" / name & ".egg-info" / "requires.txt", "")
    writeFile(name / "dist" / name & ".egg-info" / "zip-safe", "")
    writeFile(name / "dist" / name & ".egg-info" / "PKG-INFO", pkgInfoTemplate)
    writeFile(name / "upload2pypi.sh", "twine upload --verbose --repository-url 'https://test.pypi.org/legacy/' dist/*.zip\n")
    writeFile(name / "package4pypi.sh", "cd " & name / "dist && zip -9 -T -v -r " & name & ".zip *\n")
    writeFile(name / "install2local4testing.sh", "pip --verbose install dist/*.zip\n")
    writeFile(name / "pyc_clean.sh", "rm --verbose --force --recursive *.pyc\n")
  if readLineFromStdin("Generate a ./tools/ folder ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "tools")
  if readLineFromStdin("Generate a ./icons/ folder ? (y/N): ") == "y":
    discard existsOrCreateDir(name / "icons")
  if readLineFromStdin("List all created files ? (y/N): ") == "y":
    for file in walkDirRec(name): echo file
  setCurrentDir name

  if findExe"git".len > 0 and readLineFromStdin("Run 'git init .' on the project folder? (y/N): ") == "y":
    if execShellCmd("git init .") == 0:
      if readLineFromStdin("Run 'git add .' on the project folder? (y/N): ") == "y":
        if execShellCmd("git add .") == 0:
          if readLineFromStdin("Run 'git commit -a' on the project folder? (y/N): ") == "y":
            if execShellCmd("git commit -am 'init'") == 0:
              if readLineFromStdin("Generate 'Fake' empty commits (using git commit --allow-empty) on the project folder? (y/N): ") == "y":
                fakeCommits(readLineFromStdin("How many 'Fake' commits to generate? (Positive integer): ").parseInt.Positive)
              if readLineFromStdin("Run 'git remote add origin ...' to add 1 Remote URL? (y/N): ") == "y":
                if execShellCmd("git remote add origin " & readLineFromStdin("Git Remote URL?: ").strip) == 0:
                  if readLineFromStdin("Run 'git fetch --all' on the project folder? (y/N): ") == "y":
                    echo execShellCmd("git fetch --all") == 0

  quit("Created a new Python project skeleton, happy hacking, bye...\n", 0)
