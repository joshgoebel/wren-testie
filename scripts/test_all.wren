#!/usr/bin/env wrenc

import "io" for Directory, File
import "os" for Process
import "meta" for Meta
import "essentials" for Strings

// 1. set cwd to wren-testie root

// TODO (enhancement): static method File.tempfile()
// TODO (enhancement): reading stdout of a process

var tmpfile = ".git.root.%(Process.pid)"
Process.exec("sh", ["-c", "git rev-parse --show-toplevel > %(tmpfile)"])
var rootdir = File.read(tmpfile).trim()
File.delete(tmpfile)

Process.chdir(rootdir)

import "../testie" for Testie
import "../src/expect" for Expect

// 2. fetch all wren files
var testDir = "./tests/"
var testFiles = Directory.list(testDir)
                         .where {|f| Strings.globMatch(f, "*.wren")}
                         .map {|f| testDir + f[0..-6]}

// 3. import each
for (file in testFiles) {
    var code = "import \"%(file)\""
    System.print(code + "\n")
    var f = Fiber.new {Meta.eval(code)}
    f.try()
    if (f.error != null) Fiber.abort(f.error)
}

