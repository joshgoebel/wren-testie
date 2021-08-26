import "wren-package" for WrenPackage, Dependency
import "os" for Process

class Package is WrenPackage {
  construct new() {}
  name { "wren-testie" }
  version { "0.2.0" }
  dependencies {
    return []
  }
}

Package.new().default()
