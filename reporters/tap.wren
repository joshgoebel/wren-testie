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
    printDiagnostic_(text) {
        for (line in text.split("\n")) {
            System.print("# %(line)".trimEnd())
        }
    }
    fail(name, fiber) {
        _fail = _fail + 1
        System.print("not ok %(testNumber) %(_section)%(name)")
        printDiagnostic_(fiber.error.toString)
        printDiagnostic_("")
        printDiagnostic_(StackTraceReport.new(fiber).toString)
    }
    bail(message) {
        System.print("Bail out! $(message)")
    }
    done() {
        if (_showNumTestsWhenDone) { System.print("1..%(testNumber)") }
    }
}
