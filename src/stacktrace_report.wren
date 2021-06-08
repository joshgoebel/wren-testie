import "../vendor/colors" for Colors as Color
import "io" for File
import "./capabilities" for Capabilities
var Mirror = null
var Lexer = null
var Token = null
if (Capabilities.hasMirror) {
  import "mirror" for Mirror as M
  Mirror = M
  import "repl" for Lexer as L, Token as T
  Lexer = L
  Token = T
}

class Highlighter {
  construct new(code) {
    _code = code
    var lexer = Lexer.new(code)
    _tokens = []
    while (true) {
      var token = lexer.readToken()
      // System.print("%(token.type) `%(token.text)`")
      if (token.type == Token.eof) break
      _tokens.add(token)
    }
  }
  toString {
    var s = ""
    for (token in _tokens) {
      var color = ""
      if (token.type == Token.string) color = Color.GREEN
      s = s + color + token.text + (color!="" ? Color.RESET + Color.WHITE : "")
    }
    return s
  }
}

class StackTraceReport {
  construct new(fiber) {
    _fiber = fiber
    _trace = Mirror.reflect(_fiber).stackTrace
  }
  highlight(line) {
    return Highlighter.new(line).toString
  }
  codeSummary() {
    var frame = _trace.frames[0]
    var file = _trace.frames[0].methodMirror.moduleMirror.name
    var code = File.read(file)
    var lines = code.split("\n")

    var lineNumber = frame.line - 1
    var start = (lineNumber - 2).max(0)
    var stop = (lineNumber + 2).min(lines.count-1)
    (start..stop).each { |line|
      var num = line + 1
      var here = " "
      if (line==frame.line-1) here = "%(Color.RED + Color.BOLD)>"
      System.print("%(here) %(Color.BLACK + Color.BOLD)%(num) |%(Color.RESET + Color.WHITE) %(highlight(lines[line]))%(Color.RESET)")
    }
    System.print()
  }
  print() {
    codeSummary()
    traceSummary()
  }
  traceSummary() {
    var f = _trace.frames[0]
    System.write(Color.BLACK + Color.BOLD  )
    System.print("at %( f.methodMirror.signature ) (%(Color.RESET + Color.CYAN)%( f.methodMirror.moduleMirror.name )" +
      "%(Color.RESET + Color.BLACK + Color.BOLD) line %( f.line ))")
    System.write(Color.RESET)

    // simple `X metaclass does not implement 'y()'.` errors do not more than a single
    // trace line
    if (_trace.frames.count > 1) {
      _trace.frames[1..1].each { |f|
        System.write(Color.BLACK + Color.BOLD  )
        System.print("at %( f.methodMirror.signature ) (%( f.methodMirror.moduleMirror.name ) line %( f.line ))")
        System.write(Color.RESET)
      }
    }
    System.print()
  }
}