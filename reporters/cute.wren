import "random" for Random
import "../vendor/colors" for Colors as Color
import "../src/stacktrace_report" for StackTraceReport
import "../src/capabilities" for Capabilities

var RND = Random.new()
var SAD_EMOJI = ["😡","👺","👿","🙀","💩","😰","😤","😬"]

class CuteReporter {
    construct new(name) {
        _name = name
        _fail = _skip = _success = 0
        _tests = []
        _fails = []
        _section = name.trim()
    }
    start() { System.print(_name) }
    skip(name) {
        _skip = _skip + 1
        System.print("  🌀 [skip] %(name)")
    }
    section(name) {
        _section = name.trim()
        System.print("\n  %(name)\n")
    }
    fail(name, fiber) {
        _fail = _fail + 1
        // System.print("  ❌ %(name) \n     %(error)\n")
        System.print("  ❌ %(name)")
        _fails.add([_section,name,fiber])
    }
    success(name) {
        _success = _success + 1
        System.print("  ✅ %(name)")
    }
    sadEmotion { SAD_EMOJI[RND.int(SAD_EMOJI.count)] }
    printErrors() {
        System.print()
        for (fail in _fails) {
            var section = fail[0]
            var name = fail[1]
            var fiber = fail[2]
            var error = fiber.error
            System.print(Color.RED + Color.BOLD + "● %(section) -> %(name)" + Color.RESET + "\n")
            if (error is String) {
                System.print(error)
            } else {
                System.print(error.error)
            }
            System.print()
            if (Capabilities.hasMirror) {
                var s = StackTraceReport.new(fiber)
                s.print()
            }
        }
    }
    done() {
        printErrors()
        var overall = "💯"
        if (_fail > 0) overall = "%(sadEmotion)"
        _groups = []
        if (_fail > 0) _groups.add("%(Color.RED + Color.BOLD)✕ %(_fail) failed%(Color.RESET)")
        if (_skip > 0) _groups.add("%(Color.YELLOW + Color.BOLD)☐ %(_skip) skipped%(Color.RESET)")
        if (_success>0) {
            _groups.add("%(Color.GREEN)✓ %(_success) passed%(Color.RESET)")
        } else {
            _groups.add("✓ %(_success) passed")
        }
        var total = _fail + _skip + _success
        _groups.add("%(total) total")

        System.print("Tests:  %(overall) %(_groups.join(", "))\n")
    }
}
