import "../src/capabilities" for Capabilities
import "../src/stacktrace_report" for StackTraceReport
import "../src/expect" for Expect

StackTraceReport.withoutColors
Expect.withoutColors

class TapReporter {
    // https://testanything.org/tap-version-13-specification.html
    static tapVersion { 13 }

    construct new(name) {
        _name = name
        _fail = _skip = _success = 0
        _showNumTestsWhenDone = true
        _section = ""
    }
    testNumber { _fail + _skip + _success }

    start(numTestsToRun) {
        System.print("TAP version %(this.type.tapVersion)")
        System.print("1..%(numTestsToRun)")
        _showNumTestsWhenDone = false
    }
    section(name) {
        _section = "%(name): "
    }
    skip(name) {
        _skip = _skip + 1
        System.print("ok %(testNumber) %(_section)%(name) # SKIP")
    }
    success(name) {
        _success = _success + 1
        System.print("ok %(testNumber) %(_section)%(name)")
    }
    fail(name, fiber) {
        _fail = _fail + 1
        System.print("not ok %(testNumber) %(_section)%(name)")
        for (line in fiber.error.toString.split("\n")) {
            System.print(line.isEmpty ? "#" : "# %(line)")
        }
        if (Capabilities.hasMirror) {
            System.print("#")
            var st = StackTraceReport.new(fiber)
            for (line in st.toString.split("\n")) {
                System.print(line.isEmpty ? "#" : "# %(line)")
            }
        }
    }
    bail(message) {
        System.print("Bail out! $(message)")
    }
    done() {
        if (_showNumTestsWhenDone) { System.print("1..%(testNumber)") }
    }
}
