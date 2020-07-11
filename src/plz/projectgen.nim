import os, times, rdstdin, strutils, random
randomize()

template pySkeleton() =
  ## Creates the skeleton (folders and files) for a New Python project.
  var namex = create(string, sizeOf string)
  while not(namex[].len > 0 and namex[].len < 99): namex[] = readLineFromStdin"New Python project name?: ".strip.toLowerAscii.replace(" ", "_")
  discard existsOrCreateDir(namex[])
  discard existsOrCreateDir(namex[] / namex[])
  writeFile(namex[] / namex[] / "__init__.py", "print('Hello World')\n")
  writeFile(namex[] / namex[] / "__main__.py", "\nprint('Main Module')\n")
  writeFile(namex[] / namex[] / "__version__.py", "__version__ = '0.0.1'\n")
  writeFile(namex[] / namex[] / namex[] & ".py", "\nprint('Hello World')\n")
  writeFile(namex[] / namex[] / "main.nim", nimpyTemplate)
  if readLineFromStdin("Generate Unitests files on ./tests/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "tests")
    writeFile(namex[] / "tests" / "__init__.py", testTemplate)
  if readLineFromStdin("Generate Documentation files on ./docs/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "docs")
    writeFile(namex[] / "docs" / "documentation.md", "# " & namex[] & "\n\n")
    writeFile(namex[] / "docs" / "generate_documentation.sh", "plz doc2html documentation.md ; plz doc2latex documentation.md\n")
  if readLineFromStdin("Generate Example files on ./examples/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "examples")
    writeFile(namex[] / "examples" / "example.py", "# -*- coding: utf-8 -*-\n\nprint('Example')\n")
  if readLineFromStdin("Generate DevOps files on ./devops/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "devops")
    writeFile(namex[] / "devops" / "Dockerfile", "")
    writeFile(namex[] / "devops" / namex[] & ".service", serviceTemplate)
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
    writeFile(namex[] / ".gitignore", gitignoreTemplate)
    discard existsOrCreateDir(namex[] / ".hooks")
  if readLineFromStdin("Generate .gitattributes file? (y/N): ") == "y":
    writeFile(namex[] / ".gitattributes", "*.py linguist-language=Python\n*.nim linguist-language=Nim\n")
  if readLineFromStdin("Generate setup.py ? (y/N): ") == "y":
    writeFile(namex[] / "tox.ini", "")
    writeFile(namex[] / "setup.cfg", setupCfg)
    writeFile(namex[] / "requirements.txt", "")
    writeFile(namex[] / "setup.py", "# -*- coding: utf-8 -*-\nfrom setuptools import setup\nsetup() # Edit setup.cfg,not here!.\n")
  if readLineFromStdin("Generate .editorconfig ? (y/N): ") == "y":
    writeFile(namex[] / ".editorconfig", editorconfigTemplate)
  if readLineFromStdin("Generate MANIFEST.in ? (y/N): ") == "y":
    writeFile(namex[] / "MANIFEST.in", manifestTemplate)
  if readLineFromStdin("Generate Makefile ? (y/N): ") == "y":
    writeFile(namex[] / "Makefile", makefileTemplate)
  if readLineFromStdin("Generate Arch Linux PKGBUILD ? (y/N): ") == "y":
    writeFile(namex[] / "PKGBUILD", pkgbuildTemplate)
  if readLineFromStdin("Generate Ubuntu Linux and Debian Linux packaging files on ./debian/ ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "debian")
    discard existsOrCreateDir(namex[] / "debian" / "source")
    writeFile(namex[] / "debian" / "rules", debianRules)
    writeFile(namex[] / "debian" / "control", debianControl)
    writeFile(namex[] / "debian" / "compat", "9\n")
    writeFile(namex[] / "debian" / "changelog", debianChangelog)
    writeFile(namex[] / "debian" / "source" / "options", """extend-diff-ignore="\.egg-info/\" """)
    writeFile(namex[] / "debian" / "source" / "format", "3.0 (quilt)\n")
  if readLineFromStdin("Generate README,LICENSE,CHANGELOG,etc ? (y/N): ") == "y":
    let ext = create(string, sizeOf string)
    ext[] = if readLineFromStdin("Use Markdown (MD) instead of ReSTructuredText (RST)? (y/N): ") == "y": ".md" else: ".rst"
    writeFile(namex[] / "LICENSE" & ext[], "See https://tldrlegal.com/licenses/browse\n")
    writeFile(namex[] / "CODE_OF_CONDUCT" & ext[], "")
    writeFile(namex[] / "CONTRIBUTING" & ext[], "")
    writeFile(namex[] / "AUTHORS" & ext[], "# Authors\n\n- " & getEnv"USER" & "\n")
    writeFile(namex[] / "README" & ext[], "# " & namex[] & "\n")
    writeFile(namex[] / "CHANGELOG" & ext[], "# 0.0.1\n\n- First initial version of " & namex[] & " created at " & $now())
    dealloc ext
  if readLineFromStdin("Generate extra helper scripts and dist? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "dist")
    discard existsOrCreateDir(namex[] / "dist" / namex[] & ".egg-info")
    writeFile(namex[] / "dist" / namex[] & ".egg-info" / "top_level.txt", "")
    writeFile(namex[] / "dist" / namex[] & ".egg-info" / "dependency_links.txt", "")
    writeFile(namex[] / "dist" / namex[] & ".egg-info" / "requires.txt", "")
    writeFile(namex[] / "dist" / namex[] & ".egg-info" / "zip-safe", "")
    writeFile(namex[] / "dist" / namex[] & ".egg-info" / "PKG-INFO", pkgInfoTemplate)
    writeFile(namex[] / "upload2pypi.sh", "twine upload --verbose --repository-url 'https://test.pypi.org/legacy/' dist/*.zip\n")
    writeFile(namex[] / "package4pypi.sh", "cd " & namex[] / "dist && zip -9 -T -v -r " & namex[] & ".zip *\n")
    writeFile(namex[] / "install2local4testing.sh", "pip --verbose install dist/*.zip\n")
    writeFile(namex[] / "pyc_clean.sh", "rm --verbose --force --recursive *.pyc\n")
  if readLineFromStdin("Generate a ./tools/ folder ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "tools")
  if readLineFromStdin("Generate a ./icons/ folder ? (y/N): ") == "y":
    discard existsOrCreateDir(namex[] / "icons")
  setCurrentDir namex[]
  dealloc namex
  if findExe"git".len > 0 and readLineFromStdin("Run 'git init .' on the project folder? (y/N): ") == "y":
    if execShellCmd("git init .") == 0:
      if readLineFromStdin("Run 'git add .' on the project folder? (y/N): ") == "y":
        if execShellCmd("git add .") == 0:
          if readLineFromStdin("Run 'git commit -a' on the project folder? (y/N): ") == "y":
            if execShellCmd("git commit -am 'init'") == 0:
              if readLineFromStdin("Generate 'Fake' empty commits (using git commit --allow-empty) on the project folder? (y/N): ") == "y":
                for i in 0..readLineFromStdin("How many 'Fake' commits to generate? (Positive integer): ").parseInt.Positive:
                  discard execShellCmd("git commit --allow-empty --date='" & $(now() - minutes(i + rand(0..9))) & "' --message=" & fakeCommitMessages.sample)
              if readLineFromStdin("Run 'git remote add origin ...' to add 1 Remote URL? (y/N): ") == "y":
                if execShellCmd("git remote add origin " & readLineFromStdin("Git Remote URL?: ").strip) == 0:
                  if readLineFromStdin("Run 'git fetch --all' on the project folder? (y/N): ") == "y":
                    echo execShellCmd("git fetch --all") == 0
  quit("Created a new Python project skeleton, happy hacking, bye...\n", 0)
