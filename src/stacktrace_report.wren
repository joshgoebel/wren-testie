import "../vendor/colors" for Colors as Color
import "io" for File
import "mirror" for Mirror
import "repl" for Lexer, Token

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
  static classInitialize() {
    __withColors = true
  }
  static withoutColors {
    __withColors = false
  }

  construct new(fiber) {
    _fiber = fiber
    _trace = Mirror.reflect(_fiber).stackTrace
  }

  toString {
    return codeSummary() + "\n" + "\n" + traceSummary()
  }
  print() {
    System.print(this)
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
    var summary = []
    var entry
    (start..stop).each { |line|
      var num = line + 1
      var here = " "
      if (line == frame.line-1) {
        here = "%(__withColors ? Color.RED + Color.BOLD : "")>"
      }
      if (__withColors) {
        entry = "%(here) %(Color.BLACK + Color.BOLD)%(num) |%(Color.RESET + Color.WHITE) %(highlight(lines[line]))%(Color.RESET)"
      } else {
        entry = "%(here) %(num) | %(lines[line])"
      }
      summary.add(entry)
    }
    return summary.join("\n")
  }

  traceSummary() {
    var f = _trace.frames[0]
    var summary = []
    var entry

    var bold = Color.BOLD
    var reset = Color.RESET
    var black = Color.BLACK
    var cyan = Color.CYAN
    if (!__withColors) {
      bold = reset = black = cyan = ""
    }

    entry = black + bold
    entry = entry + "at %( f.methodMirror.signature ) (%(reset + cyan)%( f.methodMirror.moduleMirror.name )" +
      "%(reset + black + bold) line %( f.line ))"
    entry = entry + reset
    summary.add(entry)

    // simple `X metaclass does not implement 'y()'.` errors do not more than a single
    // trace line
    if (_trace.frames.count > 1) {
      _trace.frames[1..-1].each { |f|
        entry = black + bold
        entry = entry + "at %( f.methodMirror.signature ) (%( f.methodMirror.moduleMirror.name ) line %( f.line ))"
        entry = entry + reset
        summary.add(entry)
      }
    }
    return summary.join("\n")
  }
}

StackTraceReport.classInitialize()
