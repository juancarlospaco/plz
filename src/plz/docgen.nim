import strtabs, packages/docutils/rst, packages/docutils/rstgen, packages/docutils/rstast

proc doc2html(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  result = rstToHtml(readFile(filename), {}, newStringTable(modeStyleInsensitive))
  writeFile(filename & ".html", result)

proc doc2latex(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  result = rstToLatex(readFile(filename), {})
  writeFile(filename & ".tex", result)

proc doc2json(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  var option = create(bool, sizeOf bool)
  result = renderRstToJson(rstParse(readFile(filename), "", 1, 1, option[], {}))
  dealloc option
  writeFile(filename & ".json", result)
