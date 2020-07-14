import strtabs, packages/docutils/rst, packages/docutils/rstgen, packages/docutils/rstast

proc doc2html(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  result = rstToHtml(readFile(filename), {roSupportSmilies, roSupportRawDirective, roSupportMarkdown}, newStringTable(modeStyleInsensitive))
  assert result.len > 0, "doc2latex docgen error result must not be empty string"
  writeFile(filename & ".html", result)

proc doc2latex(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  result = rstToLatex(readFile(filename), {roSupportSmilies, roSupportRawDirective, roSupportMarkdown})
  assert result.len > 0, "doc2latex docgen error result must not be empty string"
  writeFile(filename & ".tex", result)

proc doc2json(filename: string): string {.inline.} =
  assert filename.len > 0, "filename must not be empty string"
  option := false
  result = renderRstToJson(rstParse(readFile(filename), "", 1, 1, option[], {roSupportSmilies, roSupportRawDirective, roSupportMarkdown}))
  dealloc option
  assert result.len > 0, "doc2latex docgen error result must not be empty string"
  writeFile(filename & ".json", result)
