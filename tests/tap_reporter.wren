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
ok 1 test 1
ok 2 test 2
1..2
"""
    Expect.value(actual.trim()).toEqual(expected)
  }

  do.test("TAP skip output") {
    var actual = TestRunner.run("./tests/tap_data/skip.spec.wren")
    var expected = """
TAP version 13
ok 1 test 1
ok 2 test 2 # SKIP
1..2
"""
    Expect.value(actual.trim()).toEqual(expected)
  }

  do.test("TAP failure output") {
    var actual = TestRunner.run("./tests/tap_data/fail.spec.wren")
    var expected = """
TAP version 13
ok 1 test 1
not ok 2 test 2
# expect(received).toEqual(expected)
#
# Expected: 42
# Received: 4
#
#   10 |   }
#   11 |   do.test("test 2") {
# > 12 |     Expect.that(2 + 2).toEqual(42)
#   13 |   }
#   14 | }
"""
    // the failure diagnostics also include a stack trace
    Expect.value(actual.startsWith(expected)).toBe(true)
    // TAP output ends with the number of tests run
    Expect.value(actual.trim().split("\n")[-1]).toBe("1..2")
  }
}
