#!/usr/bin/env wrenc

import "io" for Directory, File
import "os" for Process
import "meta" for Meta
import "essentials" for Strings

import "../testie" for Testie
import "../src/expect" for Expect

// fetch all wren files
var testDir = "./tests/"

if (!Directory.exists(testDir)) {
  Fiber.abort("Run this script from the project root dir.")
}

var modulePaths = Directory.list(testDir)
        .where {|f| Strings.globMatch(f, "*.wren")}
        .map {|f| testDir + f[0..-6]}

// import each
var fails = []
var oks = []
for (module in modulePaths) {
    var code = "import \"%(module)\""
    System.print(code + "\n")

    var f = Fiber.new {Meta.eval(code)}
    f.try()

    if (f.error == null) {
        oks.add(module + ".wren")
    } else {
        fails.add(module + ".wren")
    }
}

System.print()
System.print("OK:\t%(oks.join("\n\t"))")
System.print("FAIL:\t%(fails.join("\n\t"))")
