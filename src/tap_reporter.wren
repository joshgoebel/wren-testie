import "./capabilities" for Capabilities
import "./stacktrace_report" for StackTraceReport
import "./expect" for Expect

StackTraceReport.withoutColors
Expect.withoutColors

class TapReporter {
    // https://testanything.org/tap-version-13-specification.html
    static tapVersion { 13 }

    construct new(name) {
        _name = name
        _fail = _skip = _success = _number = 0
        _plan = false
        _section = ""
    }
    start() {
        System.print("TAP version %(this.type.tapVersion)")
    }
    start(num_tests) {
        start()
        _plan = true
        System.print("1..%(num_tests)")
    }
    section(name) {
        _section = "%(name): "
    }
    skip(name) {
        _skip = _skip + 1
        _number = _number + 1
        System.print("ok %(_number) %(_section)%(name) # SKIP")
    }
    success(name) {
        _success = _success + 1
        _number = _number + 1
        System.print("ok %(_number) %(_section)%(name)")
    }
    fail(name, fiber) {
        _fail = _fail + 1
        _number = _number + 1
        System.print("not ok %(_number) %(_section)%(name)")
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
        if (!_plan) { System.print("1..%(_number)") }
    }
}
