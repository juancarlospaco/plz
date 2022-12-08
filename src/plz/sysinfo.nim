import std/[os, posix, osproc, strutils, json, times]


template isSsd(): bool =
  when defined(linux): # Returns `true` if main disk is SSD (Solid). Linux only
    try: readFile("/sys/block/sda/queue/rotational") == "0\n" except: false
  else: false


proc getSystemInfo*(): JsonNode =
  result = %*{
    "compiled":           CompileDate & "T" & CompileTime,
    "NimVersion":         NimVersion,
    "hostCPU":            hostCPU,
    "hostOS":             hostOS,
    "cpuEndian":          cpuEndian,
    "getTempDir":         getTempDir(),
    "now":                $now(),
    "getFreeMem":         getFreeMem(),
    "getTotalMem":        getTotalMem(),
    "getOccupiedMem":     getOccupiedMem(),
    "countProcessors":    countProcessors(),
    "currentCompilerExe": getCurrentCompilerExe(),
    "ssd":                isSsd(),
    "FileSystemCaseSensitive": FileSystemCaseSensitive,
    "gcc":                try: execCmdEx("gcc --version").output.splitLines()[0].strip except: "",
    "clang":              try: execCmdEx("clang --version").output.splitLines()[0].strip except: "",
    "git":                try: execCmdEx("git --version").output.replace("git version", "").strip except: "",
    "node":               try: execCmdEx("node --version").output.strip except: "",
    "python":             try: execCmdEx("python --version").output.replace("Python", "").strip except: "",
    "pip":                try: execCmdEx("pip --version").output.strip except: "",
    "tox":                try: execCmdEx("tox --version").output.strip except: "",
    "pre-commit":         try: execCmdEx("pre-commit --version").output.strip except: "",
  }
