
import strutils, rdstdin

proc ask2User(): auto =
  let username = create(string, sizeOf string)
  let password = create(string, sizeOf string)
  let name = create(string, sizeOf string)
  let version = create(string, sizeOf string)
  let license = create(string, sizeOf string)
  let summary = create(string, sizeOf string)
  let description = create(string, sizeOf string)
  let homepage = create(string, sizeOf string)
  let author = create(string, sizeOf string)
  let downloadurl = create(string, sizeOf string)
  let authoremail = create(string, sizeOf string)
  let maintainer = create(string, sizeOf string)
  let maintaineremail = create(string, sizeOf string)
  let iPwd2 = create(string, sizeOf string)
  let keywords = create(seq[string], sizeOf seq[string])
  echo "The following questions are required by Python PYPI API, answers must not be empty string!."
  while not(author[].len > 2 and author[].len < 99): author[] = readLineFromStdin("\nType Author (Real Name): ").strip
  while not(username[].len > 2 and username[].len < 99): username[] = readLineFromStdin("Type Username (PyPI Username): ").strip
  while not(maintainer[].len > 2 and maintainer[].len < 99): maintainer[] = readLineFromStdin("Type Package Maintainer (Real Name): ").strip
  while not(authoremail[].len > 5 and authoremail[].len < 255 and "@" in authoremail[]): authoremail[] = readLineFromStdin("Type Author Email (Lowercase): ").strip.toLowerAscii
  while not(maintaineremail[].len > 5 and maintaineremail[].len < 255 and "@" in maintaineremail[]): maintaineremail[] = readLineFromStdin("Type Maintainer Email (Lowercase): ").strip.toLowerAscii
  while not(name[].len > 0 and name[].len < 99): name[] = readLineFromStdin("Type Package Name: ").strip.toLowerAscii
  while not(version[].len > 4 and version[].len < 99 and "." in version[]): version[] = readLineFromStdin("Type Package Version (SemVer): ").normalize
  while not(summary[].len > 0 and summary[].len < 999): summary[] = readLineFromStdin("Type Package Summary (Short Description): ").strip
  while not(description[].len > 0 and description[].len < 999): description[] = readLineFromStdin("Type Package Description (Long Description): ").strip
  while not(homepage[].len > 5 and homepage[].len < 999 and homepage[].startsWith"http"): homepage[] = readLineFromStdin("Type Package Web Homepage URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(downloadurl[].len > 5 and downloadurl[].len < 999 and downloadurl[].startsWith"http"): downloadurl[] = readLineFromStdin("Type Package Web Download URL (HTTP/HTTPS): ").strip.toLowerAscii
  while not(keywords[].len > 1 and keywords[].len < 99): keywords[] = readLineFromStdin("Type Package Keywords,separated by commas,without spaces,at least 2 (CSV): ").normalize.split(",")
  echo """Licenses:
  💡 See https://tldrlegal.com/licenses/browse or https://choosealicense.com
  💡 No License == Proprietary
  MIT    ➡️ Simple and permissive,short,KISS,maybe can be an Ok default
  PPL    ➡️ Simple and permisive,wont allow corporations to steal/sell your code
  GPL    ➡️ Ensures that code based on this is shared with the same terms,strict
  LGPL   ➡️ Ensures that code based on this is shared with the same terms,no strict
  Apache ➡️ Simple and explicitly grants Patents
  BSD    ➡️ Simple and permissive,but your code can be closed/sold by 3rd party """
  while not(license[].len > 2 and license[].len < 99): license[] = readLineFromStdin("Type Package License: ").normalize
  while not(password[].len > 4 and password[].len < 999 and password[] == iPwd2[]):
    password[] = readLineFromStdin("Type Password: ").strip # Type it Twice.
    iPwd2[] = readLineFromStdin("Confirm Password (Repeat it again): ").strip
  result = (username: username[], password: password[], name: name[], author: author[], version: version[], license: license[], summary: summary[], homepage: homepage[],
    description: description[], downloadurl: downloadurl[], maintainer: maintainer[], authoremail: authoremail[], maintaineremail: maintaineremail[], keywords: keywords[])
  zeroMem(password, sizeOf password)
  zeroMem(iPwd2, sizeOf iPwd2)
  dealloc password
  dealloc iPwd2
  dealloc username
  dealloc name
  dealloc version
  dealloc license
  dealloc summary
  dealloc description
  dealloc homepage
  dealloc author
  dealloc downloadurl
  dealloc authoremail
  dealloc maintainer
  dealloc maintaineremail
  dealloc keywords
