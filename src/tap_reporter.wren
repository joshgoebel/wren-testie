import "./capabilities" for Capabilities
import "./stacktrace_report" for StackTraceReport
import "./expect" for Expect

StackTraceReport.withoutColors
Expect.withoutColors

class TapReporter {
    construct new(name) {
        _name = name
        _fail = _skip = _success = _number = 0
        _plan = false
    }
    start() {
        System.print("TAP version 13")
    }
    start(num_tests) {
        start()
        _plan = true
        System.print("1..%(num_tests)")
    }
    skip(name) {
        _skip = _skip + 1
        _number = _number + 1
        System.print("ok %(_number) %(name) # SKIP")
    }
    section(name) {
        System.print("## %(name.trim())")
    }
    success(name) {
        _success = _success + 1
        _number = _number + 1
        System.print("ok %(_number) %(name)")
    }
    fail(name, fiber) {
        _fail = _fail + 1
        _number = _number + 1
        System.print("not ok %(_number) %(name)")
        for (line in fiber.error.toString.split("\n")) {
            System.print("# %(line)")
        }
        if (Capabilities.hasMirror) {
            System.print("#")
            var st = StackTraceReport.new(fiber)
            for (line in st.toString.split("\n")) {
                System.print("# %(line)")
            }
        }
    }
    done() {
        if (!_plan) { System.print("1..%(_number)") }
    }
}
