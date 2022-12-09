from std/json import JsonNode, newJInt, newJFloat, newJBool, newJString, newJObject, newJArray, add, parseJson
from std/parseutils import parseSaturatedNatural, parseFloat
from std/strutils import split

template parseBool(s: string): bool = s == "true"

func strip(s: var string) =
  var first = 0
  var last = s.high
  while first <= last  and s[first] in {' ', '\t'}: inc first
  while last  >= first and s[last]  in {' ', '\t'}: dec last
  if unlikely(first > last):
    s.setLen 0
    return
  template impl =
    for index in first .. last: s[index - first] = s[index]
  if first > 0:
    when nimvm: impl()
    else:
      when not declared(moveMem): impl()
      else:
        when declared(prepareMutation): prepareMutation(s)
        moveMem(addr s[0], addr s[first], last - first + 1)
  s.setLen last - first + 1

func validateKey(s: string): bool {.inline.} =
  result = true
  for c in s:
    if c notin {'a'..'z', 'A'..'Z', '0'..'9', '_'}: return false

proc parseDotEnv*(s: string; nl = '\n'; allowEmpty: static[bool] = true): JsonNode =
  result = newJObject()
  if likely(s.len > 1):
    for zz in s.split(nl):          # Split by lines
      var z = zz                    # k= is the shortest possible
      strip(z)
      if z.len > 1 and z[0] != '#': # No comment lines, no empty lines
        let k_v = z.split('=')
        if k_v.len >= 2:            # k sep v
          var k = k_v[0]            # Key name
          strip(k)
          doAssert validateKey(k), "DotEnv key must be a non-empty ASCII string ([a-zA-Z0-9_])"
          var v = k_v[1].split('#')[0] # remove inline comments
          strip(v)
          when not allowEmpty: doAssert v.len > 0, "DotEnv value must not be empty"
          var tipe = k_v[^1].split('#')[1]  # Get type annotation
          strip(tipe)
          if k.len > 0:   # k must not be empty string
            case tipe
            of "bool":   result.add k, newJBool(parseBool(v))
            of "string": result.add k, newJString(v)
            of "json":   result.add k, parseJson(v)
            of "int":
              var i = 0
              discard parseSaturatedNatural(v, i)
              result.add k, newJInt(i)
            of "float":
              var f = 0.0
              discard parseFloat(v, f)
              result.add k, newJFloat(f)
            else: doAssert false, "Type must be 1 of int, float, bool, string, json"


runnableExamples:
  from std/json import pretty  ## To pretty print JSON.
  ## These examples are from the official dotenv git repo.
  echo parseDotEnv("""
# This is a comment = 42
json0 = {"key":"value"} # json
k="v"                   # string
x = 42                  # int
v = 2.0                 # float
o = true                # bool
b = false               # bool
t = +inf                # float
w = -inf                # float
g = NaN                 # float
cc=""                   # string
x=""                    # int
t = 9999999999999999999 # int
isConsoleApplication=False                   # bool
COMPILE=True                                 # bool
BASIC=basic                                  # string

# previous line intentionally left blank
AFTER_LINE=after_line                        # string
EMPTY=                                       # string
SINGLE_QUOTES='single_quotes'                # string
SINGLE_QUOTES_SPACED='    single quotes    ' # string
DOUBLE_QUOTES="double_quotes"                # string
DOUBLE_QUOTES_SPACED="    double quotes    " # string
RETAIN_INNER_QUOTES={"foo": "bar"}           # json
RETAIN_LEADING_DQUOTE="retained              # string
RETAIN_LEADING_SQUOTE='retained              # string
RETAIN_TRAILING_DQUOTE=retained"             # string
RETAIN_TRAILING_SQUOTE=retained'             # string
RETAIN_INNER_QUOTES_AS_STRING='{"k":"v"}'    # string
TRIM_SPACE_FROM_UNQUOTED=  spaced out string # string
USERNAME=therealnerdybeast@example.tld       # string
    SPACED_KEY = parsed                      # string
EXPAND_NEWLINES="expand\nnew\nlines"         # string
DONT_EXPAND_UNQUOTED=dontexpand\nnewlines    # string
DONT_EXPAND_SQUOTED='dontexpand\nnewlines'   # string
EQUAL_SIGNS=equals==                         # string
  """).pretty == """
{
  "json0": {
    "key": "value"
  },
  "k": "\"v\"",
  "x": 0,
  "v": 2.0,
  "o": true,
  "b": false,
  "t": 9223372036854775807,
  "w": -inf,
  "g": nan,
  "cc": "\"\"",
  "isConsoleApplication": false,
  "COMPILE": true,
  "BASIC": "basic",
  "AFTER_LINE": "after_line",
  "EMPTY": "",
  "SINGLE_QUOTES": "'single_quotes'",
  "SINGLE_QUOTES_SPACED": "'    single quotes    '",
  "DOUBLE_QUOTES": "\"double_quotes\"",
  "DOUBLE_QUOTES_SPACED": "\"    double quotes    \"",
  "RETAIN_INNER_QUOTES": {
    "foo": "bar"
  },
  "RETAIN_LEADING_DQUOTE": "\"retained",
  "RETAIN_LEADING_SQUOTE": "'retained",
  "RETAIN_TRAILING_DQUOTE": "retained\"",
  "RETAIN_TRAILING_SQUOTE": "retained'",
  "RETAIN_INNER_QUOTES_AS_STRING": "'{\"k\":\"v\"}'",
  "TRIM_SPACE_FROM_UNQUOTED": "spaced out string",
  "USERNAME": "therealnerdybeast@example.tld",
  "SPACED_KEY": "parsed",
  "EXPAND_NEWLINES": "\"expand\\nnew\\nlines\"",
  "DONT_EXPAND_UNQUOTED": "dontexpand\\nnewlines",
  "DONT_EXPAND_SQUOTED": "'dontexpand\\nnewlines'",
  "EQUAL_SIGNS": "equals"
}"""
  ## Simple example.
  echo parseDotEnv("""
DB_HOST=localhost # string
DB_USER=root      # string
DB_PASS="123"     # string
DB_TIMEOUT=42     # int
DELAY=3.14        # float
ACTIVE=true       # bool
""", allowEmpty = false).pretty
