class Capabilities {
  static tryImport_ (fn) {
    var f = Fiber.new(fn) 
    var module = f.try()
    return f.error ? null : module
  }
  static hasMirror { tryImportMirror }

  static tryImportMirror {
    return tryImport_ {
      import "mirror" for Mirror
      return Mirror
    }
  }
  static tryImportFile { 
    return tryImport_ {
      import "io" for File
      return File
    }
  }
  static tryImportRepl {
    return tryImport_ {
      import "repl" for Lexer, Token
      return [Lexer, Token]
    }
  }
}
