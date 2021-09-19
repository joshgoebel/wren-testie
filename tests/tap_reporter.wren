import "io" for File
import "os" for Process
import "../testie" for Testie, Expect

var WRENC_BIN = Process.allArguments[0]

class TestRunner {
  static run(filename) {
    var tmpfile = ".tap.output.%(Process.pid)"
    Process.exec("sh", ["-c", "%(WRENC_BIN) %(filename) > %(tmpfile) 2>&1"])
    var content = File.read(tmpfile)
    File.delete(tmpfile)
    return content
  }
}

Testie.test("TAP reporter") { |do, skip|
  do.test("TAP success output") {
    var actual = TestRunner.run("./tests/tap_data/success.spec.wren")
    var expected = """
TAP version 13
1..2
ok 1 test 1
ok 2 test 2
"""
    Expect.value(actual.trim()).toEqual(expected)
  }

  do.test("TAP skip output") {
    var actual = TestRunner.run("./tests/tap_data/skip.spec.wren")
    var expected = """
TAP version 13
1..2
ok 1 test 1
ok 2 test 2 # SKIP
"""
    Expect.value(actual.trim()).toEqual(expected)
  }

  do.test("TAP failure output") {
    var actual = TestRunner.run("./tests/tap_data/fail.spec.wren")
    var expected = """
TAP version 13
1..2
ok 1 Success section: test 1
not ok 2 Failure section: test 2
# expect(received).toEqual(expected)
#
# Expected: 42
# Received: 4
#
#   13 |   do.describe("Failure section") {
#   14 |     do.test("test 2") {
# > 15 |       Expect.that(2 + 2).toEqual(42)
#   16 |     }
#   17 |   }
"""
    // the failure diagnostics also include a stack trace
    Expect.value(actual.startsWith(expected)).toBe(true)
  }
}
