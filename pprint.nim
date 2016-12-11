import
  os, osproc, streams, future, strtabs, macros, strutils

import
  json,
  xmlparser, xmltree,
  parsexml

type
  LanguageType = enum
    Unknown,
    JSON,
    XML,

proc prettyPrintXML(xml: XmlNode, s: Stream) =
  # macro (args: varargs[string, `$`]) =
  #   for arg in args:
  #     s.write(arg)

  var indent = 0
  var queue = @[xml]
  while queue.len > 0:
    let cur = queue.pop
    let args = cur.attrs

    echo '<', cur.tag, '>'

proc detectFormat(str: string): LanguageType =
  case str[0]
  of '{', '[':
    return JSON
  of '<':
    return XML
  else:
    return Unknown

proc main =

  template err(format: LanguageType, errors: typed) =
      stderr.writeLine json.pretty(%* { "assumed_format": $format, "errors": errors })
      quit(-1)

  let inp = stdin.readAll()
  let format = detectFormat(inp)

  case format
  of JSON:
    try:
      let jinp = parseJson(newStringStream(inp), "")
      echo json.pretty(jinp)
    except:
      let e = getCurrentException()
      err(format, [escapeJson(e.msg)])

  of XML:
    var x: XmlParser
    x.open(newStringStream(inp), "")
    while true:
      x.next()
      echo repr x.kind
      case x.kind
      of xmlEof: break
      else: discard

  # of XML:
  #   var errors = newSeq[string]()
  #   let xml = parseXml(newStringStream(inp), "", errors)

  #   if errors.len > 0:
  #     var escaped_errors = newSeq[string]()
  #     for error in errors:
  #       escaped_errors.add escapeJson(error)

  #     err(format, escaped_errors)

  #   prettyPrintXML(xml, newFileStream(stdout))

  of Unknown:
    err(format, "Unknown input format")

when isMainModule:
  main()
