import std/[strutils, rdstdin, assertions]


template uploadToPypi(file: string) {.used.} =
  doAssert fileExists(file), "File not found: " & file
  var username, password, version, license, summary, description, homepage, author,
    downloadurl, authoremail, maintainer, iPwd2, maintaineremail, name: string
  var keywords: seq[string]

  echo "The following questions are required by Python PYPI API, answers must not be empty string!."
  while not(author.len > 2 and author.len < 99):
    author = readLineFromStdin("\nType Author (Real Name): ").strip
  while not(username.len > 2 and username.len < 99):
    username = readLineFromStdin("Type Username (PyPI Username): ").strip
  while not(maintainer.len > 2 and maintainer.len < 99):
    maintainer = readLineFromStdin("Type Package Maintainer (Real Name): ").strip
  while not(authoremail.len > 5 and authoremail.len < 255 and "@" in authoremail):
    authoremail = readLineFromStdin("Type Author Email (Lowercase): ").strip.toLowerAscii
  while not(maintaineremail.len > 5 and maintaineremail.len < 255 and "@" in maintaineremail):
    maintaineremail = readLineFromStdin("Type Maintainer Email (Lowercase): ").strip.toLowerAscii
  while not(name.len > 0 and name.len < 99):
    name = readLineFromStdin("Type Package Name: ").strip.toLowerAscii
  while not(version.len > 4 and version.len < 99 and "." in version):
    version = readLineFromStdin("Type Package Version (SemVer): ").normalize
  while not(summary.len > 0 and summary.len < 999):
    summary = readLineFromStdin("Type Package Summary (Short Description): ").strip
  while not(description.len > 0 and description.len < 999):
    description = readLineFromStdin("Type Package Description (Long Description): ").strip
  while not(homepage.len > 5 and homepage.len < 999 and homepage.startsWith"http"):
    homepage = readLineFromStdin("Type Package Web Homepage URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(downloadurl.len > 5 and downloadurl.len < 999 and downloadurl.startsWith"http"):
    downloadurl = readLineFromStdin("Type Package Web Download URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(keywords.len > 1 and keywords.len < 99):
    keywords = readLineFromStdin("Type Package Keywords,separated by commas,without spaces,at least 2 (CSV): ").normalize.split(",")
  echo licenseMsg
  while not(license.len > 2 and license.len < 99):
    license = readLineFromStdin("Type Package License: ").normalize
  echo "Password is never written to disk."
  while not(password.len > 4 and password.len < 999 and password == iPwd2):
    password = readLineFromStdin("Type Password: ").strip # Type it Twice.
    iPwd2 = readLineFromStdin("Confirm Password (Repeat it again): ").strip
  echo (username: username, password: password, name: name, author: author,
    version: version, license: license, summary: summary, homepage: homepage,
    description: description, downloadurl: downloadurl, maintainer: maintainer,
    authoremail: authoremail, maintaineremail: maintaineremail, keywords: keywords)

  echo client.upload(
    username        = username,
    password        = password,
    name            = name,
    version         = version,
    license         = license,
    summary         = summary,
    description     = description,
    author          = author,
    downloadurl     = downloadurl,
    authoremail     = authoremail,
    maintainer      = maintainer,
    keywords        = keywords,
    maintaineremail = maintaineremail,
    homepage        = homepage,
    filename        = file,
    md5_digest      = getMD5(readFile(file))
  )
