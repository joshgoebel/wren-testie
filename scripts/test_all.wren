#!/usr/bin/env wrenc

import "io" for Directory, File
import "os" for Process
import "meta" for Meta

// 1. set cwd to wren-testie root
/* pending https://github.com/joshgoebel/wren-console/pull/8
 *
 * var tmpfile = ".git.root.%(Process.pid)"
 * Process.exec("sh", ["-c", "git rev-parse --show-toplevel > %(tmpfile)"])
 * var rootdir = File.read(tmpfile).trim()
 * File.delete(tmpfile)
 * Process.chdir(rootdir)
 */

import "../testie" for Testie
import "../src/expect" for Expect

// 2. fetch all tests wren files
var testFiles = Directory.list("tests")
                         .where {|f| f.endsWith(".wren")}
                         .map {|f| "./tests/" + f[0..-6]}

// 3. import each
for (file in testFiles) {
  var code = "import \"%(file)\""
  System.print(code + "\n")
  var f = Fiber.new {Meta.eval(code)}
  f.try()
  if (f.error != null) Fiber.abort(f.error)
}

